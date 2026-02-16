# ------------------------------------------------------------------------------
#                 Analysis of TrackMate/Cellblocks data
#                   ~ Read XML files
# ------------------------------------------------------------------------------
# Date Created: August 29, 2019
# Author: Michael Barbier
# Date Last Updated: February 16, 2026
# Updated by: Marlies Verschuuren - marlies.verschuuren@uantwerpen.be
# ------------------------------------------------------------------------------

#--1. Input User ---------------------------------------------------------------
#----1.1. Directory ------------------------------------------------------------
data_manual=read.table(file="Ruptures.txt",sep="\t", header=TRUE)
#data_manual$CONDITION=factor(data_manual$CONDITION, levels =(c("SCR","LRRC59")))

dir_input=unique(data_manual[,c('DIR','REP_ID')])

dir_output=file.path(getwd(),"Analysis")
dir.create(dir_output)

time_interval=3

#--2. Loading libraries --------------------------------------------------------
if(any(grepl("package:plyr", search()))) detach("package:plyr") else message("plyr not loaded") #Detach Plyr packages to avoid problems with dplyr package
library(tidyverse)    #Function: %>%
library(data.table)    #Function: fread
library(xml2)         #Xml function
library(gridExtra) #Function: arrageGrob
library(ggpubr)    #Function: ggarange
library(plotly)    #Function: ggplotly

#--4. Loading data -------------------------------------------------------------
#----4.1. Trackmate ------------------------------------------------------------
trackmate_spots_all=data.frame()
trackmate_links_all=data.frame()
trackmate_tracks_all=data.frame()

for(index in 1:nrow(dir_input)){
  trackmate_spots_rep=data.frame()
  trackmate_links_rep=data.frame()
  trackmate_tracks_rep=data.frame()
  print(index)
  
  file_list=list.files(path = file.path(dir_input[index,"DIR"],"Output"), full.names = TRUE, pattern = ".xml")
  for(file in file_list){
    file_xml = read_xml(file)
    image_id=substring(str_extract(file,"_F[0-9]{2}"),3,4)
    print(image_id)
    
    #Links data
    links <- xml_find_all(file_xml, ".//Edge")
    links_list=xml_attrs(links)
    features=names(links_list[[1]])
    links_table_image=data.frame(TRACK_ID = xml_find_first(links, ".//ancestor::Track") %>% xml_attr("TRACK_ID"))
    for(i in 1:length(features)){
      links_table_image[,features[i]]= links %>% xml_attr(features[i])
    }
    links_table_image=links_table_image%>%
      mutate_if(is.character,as.numeric)
    
    
    #Track data
    tracks <- xml_find_all(file_xml, ".//Track")
    tracks_list=xml_attrs(tracks)
    features=names(tracks_list[[1]])
    tracks_table_image=data.frame( TRACK_ID = xml_find_first(tracks, ".//ancestor::Track") %>% xml_attr("TRACK_ID"))
    for(i in 1:length(features)){
      tracks_table_image[,features[i]]= tracks %>% xml_attr(features[i])
    }
    tracks_table_image=tracks_table_image%>%
      select(-name)%>%
      mutate_if(is.character,as.numeric)
    
    #Spot data
    spots <- xml_find_all(file_xml, ".//Spot")
    spots_list=xml_attrs(spots)
    features=names(spots_list[[1]])
    spots_table_image=data.frame( TRACK_ID = xml_find_first(spots, ".//ancestor::Track") %>% xml_attr("TRACK_ID"))
    for(i in 1:length(features)){
      spots_table_image[,features[i]]= spots %>% xml_attr(features[i])
    }
    spots_table_image=spots_table_image%>%
      select(-name)%>%
      mutate_if(is.character,as.numeric)
    
    #Link Tracks with SPOT_ID
    table_spotTrack_image=links_table_image%>%
      dplyr::select(TRACK_ID,SPOT_SOURCE_ID,SPOT_TARGET_ID)%>%
      gather(type,SPOT_ID,-TRACK_ID)%>%
      rename(ID=SPOT_ID)
    
    spots_table_image=spots_table_image%>%
      dplyr::select(-TRACK_ID)%>%
      left_join(.,table_spotTrack_image[,c("TRACK_ID","ID")],by="ID")%>%
      rename(SPOT_ID=ID)
    
    spots_table_image=spots_table_image%>%
      mutate(REP_ID=dir_input[index,"REP_ID"])%>%
      mutate(IMAGE_ID=image_id)
    
    links_table_image=links_table_image%>%
      mutate(REP_ID=dir_input[index,"REP_ID"])%>%
      mutate(IMAGE_ID=image_id)
    
    tracks_table_image=tracks_table_image%>%
      mutate(REP_ID=dir_input[index,"REP_ID"])%>%
      mutate(IMAGE_ID=image_id)
    
    trackmate_spots_rep=rbind(trackmate_spots_rep,spots_table_image)%>%
      distinct()%>%
      as.data.frame()
    trackmate_links_rep=rbind(trackmate_links_rep,links_table_image)%>%
      as.data.frame()
    trackmate_tracks_rep=rbind(trackmate_tracks_rep,tracks_table_image)%>%
      as.data.frame()
  }
  
  trackmate_spots_all=rbind(trackmate_spots_all,trackmate_spots_rep)%>%
    as.data.frame()
  trackmate_links_all=rbind(trackmate_links_all,trackmate_links_rep)%>%
    as.data.frame()
  trackmate_tracks_all=rbind(trackmate_tracks_all,trackmate_tracks_rep)%>%
    as.data.frame()
}

trackmate_spots_all$REP_ID=as.factor(trackmate_spots_all$REP_ID)
trackmate_spots_all$IMAGE_ID=as.factor(as.numeric(trackmate_spots_all$IMAGE_ID))

trackmate_links_all$REP_ID=as.factor(trackmate_links_all$REP_ID)
trackmate_links_all$IMAGE_ID=as.factor(as.numeric(trackmate_links_all$IMAGE_ID))

trackmate_tracks_all$REP_ID=as.factor(trackmate_tracks_all$REP_ID)
trackmate_tracks_all$IMAGE_ID=as.factor(as.numeric(trackmate_tracks_all$IMAGE_ID))

#----4.2. Cellblocks -----------------------------------------------------------
cellblocks_summary_all=data.frame()
cellblocks_spots_all=data.frame()

for(index in 1:nrow(dir_input)){
  #CELLBLOCKS
  files = list.files(path =  file.path(dir_input[index,"DIR"],"Output"), pattern = "summary", full.names = TRUE)
  
  #Read data and extract metadata
  data = tibble(File = files) %>%
    mutate(data = lapply(File, fread)) %>%
    unnest(data)%>%
    mutate(IMAGE=substring(basename(File),1,nchar(basename(File))-12),
           IMAGE_ID=substring(str_extract(File,"_F[0-9]{2}"),3,4),
           FRAME_ID= as.integer(substring(str_extract(File,"Frame_[0-9]{4}"),7,10)),
           REP_ID=dir_input[index,"REP_ID"]) 
  
  cellblocks_summary_rep=data%>%
    as.data.frame()%>%
    select(REP_ID,IMAGE,IMAGE_ID,FRAME_ID,V1,X,Y,Nucl_SC3_XM_MC1,Nucl_SC3_YM_MC1,Nucl_SC3_Area_MC3,Nucl_SC3_Solidity_MC3,Nucl_SC3_Mean_MC1,Nucl_SC3_Mean_MC2,Nucl_SC3_Mean_MC3,
           Cell,Cell_SC3_Area_MC1,Cell_SC3_Mean_MC1,Cell_SC3_Mean_MC2,Cell_SC3_Mean_MC3,Spot_SC1_NrPerNuc,Spot_SC1_NrPerCell,Spot_SC1_Area_MC1_SumPerNuc,Spot_SC1_Area_MC1_SumPerCell)%>%
    rename(INDEX=V1)
  
  cellblocks_summary_all=rbind(cellblocks_summary_all,cellblocks_summary_rep)
  
  
  #Read Cellblocks spots data and extract metadata
  files = list.files(path =  file.path(dir_input[index,"DIR"],"Output"), pattern = "spots_a_result", full.names = TRUE)
  
  data = tibble(File = files) %>%
    mutate(data = lapply(File, fread)) %>%
    unnest(data)%>%
    mutate(IMAGE=substring(basename(File),1,nchar(basename(File))-12),
           IMAGE_ID=substring(str_extract(File,"_F[0-9]{2}"),3,4),
           FRAME_ID=as.integer(substring(str_extract(File,"Frame_[0-9]{4}"),7,10)),
           REP_ID=dir_input[index,"REP_ID"]) 
  
  cellblocks_spots_rep=data%>%
    as.data.frame()%>%
    select(REP_ID,IMAGE_ID,FRAME_ID,V1,Area_MC1,Mean_MC1,Nucleus,Cell)%>%
    #filter(!(Nucleus==0 & Cell==0))%>% #Not needed if no filtering on nucleus is needed
    rename(SPOT_INDEX=V1)
  
  cellblocks_spots_rep$IMAGE_ID=as.integer(cellblocks_spots_rep$IMAGE_ID)
  
  cellblocks_spots_all=rbind(cellblocks_spots_all, cellblocks_spots_rep)
  
} 

cellblocks_spots_all$REP_ID=as.factor(cellblocks_spots_all$REP_ID)
cellblocks_spots_all$IMAGE_ID=as.factor(as.numeric(cellblocks_spots_all$IMAGE_ID))

cellblocks_summary_all$REP_ID=as.factor(cellblocks_summary_all$REP_ID)
cellblocks_summary_all$IMAGE_ID=as.factor(as.numeric(cellblocks_summary_all$IMAGE_ID))

#--4. Filter out Manual Tracks -------------------------------------------------------------

unique(trackmate_spots_all[c("REP_ID", "IMAGE_ID")])
unique(cellblocks_spots_all[c("REP_ID", "IMAGE_ID")])
unique(data_manual[c("REP_ID", "IMAGE_ID")])

#Prepare trackmate spot dataset
trackmate_spots_filter=trackmate_spots_all%>%
  rowwise()%>%
  filter(!is.na(TRACK_ID))%>%
  mutate(SPOT_INDEX=as.integer(MAX_INTENSITY_CH3),
         Nucleus=as.integer(MAX_INTENSITY_CH1),
         Cell=as.integer(MAX_INTENSITY_CH2), 
         CELL_INDEX=max(Nucleus,Cell),
         FRAME_ID=as.integer(FRAME)+1)%>% #Trackmate start=0, cellblocks=1
  ungroup()%>%
  select(REP_ID,IMAGE_ID,FRAME_ID,TRACK_ID,MAX_INTENSITY_CH1,MAX_INTENSITY_CH2,MAX_INTENSITY_CH3,Nucleus,Cell,CELL_INDEX,SPOT_INDEX,AREA,POSITION_X,POSITION_Y)
  
  
data_manual$REP_ID=as.factor(data_manual$REP_ID)
data_manual$IMAGE_ID=as.factor(data_manual$IMAGE_ID)
data_manual=data_manual%>%
  mutate(FRAME_ID=Manual_Rupture_Frame)

track_manual_frame=semi_join(trackmate_spots_filter,data_manual)%>%
  select(REP_ID, FRAME_ID, IMAGE_ID, TRACK_ID)%>%
  rename(FRAME_START=FRAME_ID)

track_manual=track_manual_frame%>%
  select(REP_ID, IMAGE_ID,TRACK_ID)

trackmate_spots_filter=semi_join(trackmate_spots_filter,track_manual)%>%
  left_join(.,track_manual_frame)%>%
  filter(FRAME_ID>=FRAME_START)%>%
  group_by(REP_ID,IMAGE_ID,TRACK_ID)%>%
  mutate(FRAME_SYNC=FRAME_ID-(min(FRAME_ID)),
         FRAME_SYNC_MINUTES=FRAME_SYNC*time_interval)%>% 
  ungroup()

trackmate_spots_filter=left_join(trackmate_spots_filter,cellblocks_spots_all)

# #--5. Experimental setup -------------------------------------------------------------
exp_setup=data_manual%>%
  select(REP_ID,IMAGE_ID,CONDITION)
exp_setup$IMAGE_ID=as.factor(exp_setup$IMAGE_ID)
trackmate_spots_filter=left_join(trackmate_spots_filter, exp_setup)

#--6. Plots --------------------------------------------------------------------
col=c("grey50","firebrick2","orange3")

#----6.1 TRACKS --------------------------------------------------------------
plot_list_track = list()
i=1

axisMin=0
axisMax=1024

for (rep in unique(trackmate_spots_filter$REP_ID)){
  data.rep=trackmate_spots_filter%>%
    filter(REP_ID==rep)
  for (image in unique(data.rep$IMAGE_ID)){
    data.plot=data.rep%>%
      filter(IMAGE_ID==image)%>%
      arrange(FRAME_ID)
    
    p1=ggplot(data.plot, aes(x=POSITION_X, y=POSITION_Y, group=as.factor(TRACK_ID)))+
      geom_point(aes(fill=Mean_MC1, size=Area_MC1), shape=21, alpha=0.5)+
      geom_path(aes(color=FRAME_ID), size=1)+
      scale_y_reverse(limits=c(axisMax,axisMin))+
      scale_x_continuous(limits=c(axisMin,axisMax))+
      coord_fixed()+
      scale_fill_viridis_c()+
      scale_color_viridis_c(option="magma")+
      #scale_color_manual(values=as.vector(polychrome(length(unique(data.plot$CELL_LABEL)))))+
      ggtitle(paste("Rep: ",rep," - Image: ",image,sep=""))+
      theme_minimal()
    p1
    plot_list_track[[i]] = p1
    
    i=i+1
  }
}


ggsave(file=file.path(dir_output,"Plot_Line_Track.pdf"),marrangeGrob(plot_list_track, nrow=1, ncol=1),width = 30, height=21, units = "cm")

#----PLOT--------------------------------------------------------------
data.plot=trackmate_spots_filter

p1=ggplot(data.plot,aes(x=FRAME_SYNC_MINUTES, y=paste(REP_ID,IMAGE_ID,TRACK_ID), fill=Area_MC1))+
  geom_tile()+
  geom_point(aes(color=CONDITION), x=-2, fill=NA, size=2, shape=15)+
  scale_fill_viridis_c()+
  scale_color_manual(values=col)+
  #facet_grid(REP_ID~., scales="free_y")+
  ylab("TRACK_ID")+
  theme_minimal()

p2=ggplot(data.plot,aes(x=FRAME_SYNC_MINUTES, y=paste(REP_ID,IMAGE_ID,TRACK_ID), fill=Mean_MC1))+
  geom_tile()+
  geom_point(aes(color=CONDITION), x=-2, fill=NA, size=2, shape=15)+
  scale_fill_viridis_c()+
  scale_color_manual(values=col)+
  #facet_grid(REP_ID~., scales="free_y")+
  ylab("TRACK_ID")+
  theme_minimal()

pTot=ggarrange(p1,p2,ncol=2)
ggsave(filename = file.path(dir_output, "Tileplot.png"),plot=pTot,width = 30, height=21, units = "cm")


p1=ggplot(data.plot, aes(x=FRAME_SYNC_MINUTES,y=Area_MC1, color=CONDITION, fill=CONDITION, group=paste(REP_ID,IMAGE_ID,TRACK_ID)))+
  geom_point()+
  geom_path()+
  scale_fill_manual(values=col)+
  scale_color_manual(values=col)+
  theme_minimal()+
  theme(panel.grid.minor.x = element_blank())

p2=ggplot(data.plot, aes(x=FRAME_SYNC_MINUTES,y=Mean_MC1, color=CONDITION, fill=CONDITION, group=paste(REP_ID,IMAGE_ID,TRACK_ID)))+
  geom_point()+
  geom_path()+
  scale_fill_manual(values=col)+
  scale_color_manual(values=col)+
  theme_minimal()+
  theme(panel.grid.minor.x = element_blank())

p3=ggplot(data.plot, aes(x=FRAME_SYNC_MINUTES,y=Area_MC1, color=CONDITION, fill=CONDITION))+
  stat_summary(fun.data = mean_se, fun.args = list(mult=1), geom ="ribbon", alpha=0.5) +
  stat_summary(fun= mean, geom = "line") +
  scale_x_continuous(breaks=seq(0,30,3))+
  scale_fill_manual(values=col)+
  scale_color_manual(values=col)+
  theme_minimal()+
  theme(panel.grid.minor.x = element_blank())

p4=ggplot(data.plot, aes(x=FRAME_SYNC_MINUTES,y=Mean_MC1, color=CONDITION, fill=CONDITION))+
  stat_summary(fun.data = mean_se, fun.args = list(mult=1), geom ="ribbon", alpha=0.5) +
  stat_summary(fun= mean, geom = "line") +
  scale_x_continuous(breaks=seq(0,30,3))+
  scale_fill_manual(values=col)+
  scale_color_manual(values=col)+
  theme_minimal()+
  theme(panel.grid.minor.x = element_blank())

pTot=ggarrange(p1,p2,p3,p4,ncol=2, nrow=2, common.legend = TRUE)
ggsave(filename = file.path(dir_output, "Lineplot_Area-Mean.png"),plot=pTot,width = 30, height=21, units = "cm")


data.plot.max.retention=data.plot%>%
  group_by(CONDITION,REP_ID,IMAGE_ID,TRACK_ID)%>%
  summarise(Area_MC1_MAX=max(Area_MC1),
            Mean_MC1_MAX=max(Mean_MC1),
            FRAME_RETENTION=max(FRAME_ID)-min(FRAME_ID))%>%
  mutate(MINUTES_RETENTION=FRAME_RETENTION*time_interval)

p1=ggplot(data.plot.max.retention,aes(x=CONDITION, y=Area_MC1_MAX, fill=CONDITION))+
  #stat_summary(fun.data = mean_sdl, fun.args = list(mult=1), geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun.data = mean_se, geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun= mean, geom = "bar", position=position_dodge(width = 0.9, preserve = "single"),width=0.85) +
  geom_jitter(height=0, width=0.2,shape=21, fill="grey90", stat="identity")+
  scale_fill_manual(values=col)+
  theme_minimal()

p2=ggplot(data.plot.max.retention,aes(x=CONDITION, y=Mean_MC1_MAX, fill=CONDITION))+
  #stat_summary(fun.data = mean_sdl, fun.args = list(mult=1), geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun.data = mean_se, geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun= mean, geom = "bar", position=position_dodge(width = 0.9, preserve = "single"),width=0.85) +
  geom_jitter(height=0, width=0.2,shape=21, fill="grey90", stat="identity")+
  scale_fill_manual(values=col)+
  theme_minimal()

p3=ggplot(data.plot.max.retention, aes(x=CONDITION,y=MINUTES_RETENTION, fill=CONDITION))+
  #stat_summary(fun.data = mean_sdl, fun.args = list(mult=1), geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun.data = mean_se, geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun= mean, geom = "bar", position=position_dodge(width = 0.9, preserve = "single"),width=0.85) +
  geom_jitter(height=0, width=0.2,shape=21, fill="grey90", stat="identity")+
  scale_fill_manual(values=col)+
  ylab("Retention Time (Min/Spot)")+
  theme_minimal()


pTot=ggarrange(p1,p2,p3,ncol=3, common.legend = TRUE)
ggsave(filename = file.path(dir_output, "Barplot_MaxAreaMean-Retention.png"),plot=pTot,width = 21, height=15, units = "cm")



#----PLOT Randomised Points-----------------------------------------------------
minSamples=data.plot.max.retention%>%
  group_by(CONDITION)%>%
  summarise(Count=n())

set.seed(1)
data.plot.max.retention.sample=data.plot.max.retention%>%
  group_by(CONDITION)%>%
  slice_sample(n=min(minSamples$Count))

p1=ggplot(data.plot.max.retention.sample,aes(x=CONDITION, y=Area_MC1_MAX, fill=CONDITION))+
  #stat_summary(fun.data = mean_sdl, fun.args = list(mult=1), geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun.data = mean_se, geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun= mean, geom = "bar", position=position_dodge(width = 0.9, preserve = "single"),width=0.85) +
  geom_jitter(height=0, width=0.2,shape=21, fill="grey90", stat="identity")+
  scale_fill_manual(values=col)+
  theme_minimal()

p2=ggplot(data.plot.max.retention.sample,aes(x=CONDITION, y=Mean_MC1_MAX, fill=CONDITION))+
  #stat_summary(fun.data = mean_sdl, fun.args = list(mult=1), geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun.data = mean_se, geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun= mean, geom = "bar", position=position_dodge(width = 0.9, preserve = "single"),width=0.85) +
  geom_jitter(height=0, width=0.2,shape=21, fill="grey90", stat="identity")+
  scale_fill_manual(values=col)+
  theme_minimal()

p3=ggplot(data.plot.max.retention.sample, aes(x=CONDITION,y=MINUTES_RETENTION, fill=CONDITION))+
  #stat_summary(fun.data = mean_sdl, fun.args = list(mult=1), geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun.data = mean_se, geom ="errorbar",position=position_dodge(width = 0.9, preserve = "single"),width=.5, linewidth=0.2) +
  stat_summary(fun= mean, geom = "bar", position=position_dodge(width = 0.9, preserve = "single"),width=0.85) +
  geom_jitter(height=0, width=0.2,shape=21, fill="grey90", stat="identity")+
  scale_fill_manual(values=col)+
  ylab("Retention Time (Min/Spot)")+
  theme_minimal()


pTot=ggarrange(p1,p2,p3,ncol=3, common.legend = TRUE)
ggsave(filename = file.path(dir_output, "Barplot_MaxAreaMean-Retention_Sample.png"),plot=pTot,width = 21, height=15, units = "cm")

