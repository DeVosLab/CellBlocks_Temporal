/*	CellBlocksTemporal.ijm
	***********************
	Author: 		Winnok H. De Vos
	Modified by: 		Marlies Verschuuren
	Date Created: 		July 23th, 2025
	Date Last Modified:	February 16th, 2026
 	
 	Description: 
 	
	Plugins required:
	- Requires FeatureJ
	- Imagescience
	- Stardist and CSBDeep 
	
	Change Log
	+ Build on CellBlocks_v23 	_________________________________________________________________
*/

/*
 	***********************

	Variable initiation

	***********************
*/


//	String variables
var cells_results					= "";										//	cell region results
var cells_roi_set 					= "";										//	cell region ROIsets
var cells_segmentation_method		= "Dilation";								//  Methods used for cell detection
var cells_threshold					= "Fixed";									//	threshold method for segmentation of cells 
var cells_cellpose_conda_env		= "/Users/marliesverschuuren/opt/anaconda3/envs/cellpose";
var dir								= "";										//	directory
var log_path						= "";										//	path for the log file
var labelmap						= "";										//  labelmap
var micron							= getInfo("micrometer.abbreviation");		// 	micro symbol
var model 							= "/Applications/Fiji.app/models/classifier.model"; // location of a trained model for cell segmentation
var nuclei_preprocess_method		= "Median";									//	preprocess method for segmentation of nuclei
var nuclei_roi_set 					= "";										//	nuclear ROIsets
var nuclei_results 					= "";										//	nuclear results
var nuclei_segmentation_method		= "Threshold";								// 	Method used for nuclei detection
var nuclei_threshold				= "Fixed";								//	threshold method for segmentation of nuclei 
var order							= "xyczt(default)";							//	hyperstack dimension order
var output_dir						= "";										//	dir for analysis output
var results							= "";										//	summarized results	
var spots_a_results					= "";										//	spot results ch A
var spots_a_roi_set					= "";										//	spot ROI sets ch A			
var spots_a_segmentation_method		= "Multi-Scale";								//	spots segmentation method ch A
var spots_a_threshold				= "Fixed";									//	threshold method for spot segmentation ch A
var spots_b_results					= "";										//	spot results ch B
var spots_b_roi_set					= "";										//	spot ROI sets ch B	
var spots_b_segmentation_method		= "Laplace";								//	spots segmentation method ch B
var spots_b_threshold				= "Fixed";									//	threshold method for spot segmentation ch B
var spots_c_results					= "";										//	spot results ch C
var spots_c_roi_set					= "";										//	spot ROI sets ch C	
var spots_c_segmentation_method		= "Laplace";								//	spots segmentation method ch C
var spots_c_threshold				= "Fixed";									//	threshold method for spot segmentation ch C
var suffix							= ".tif";									//	suffix for specifying the file type
var xmlfile							= "";										//  xml file trackmate

//	Number variables
var channels						= 3;										//	number of channels
var cells_channel					= 3;										//	channel used for segmentation of cells 
var cells_diameter					= 100;										//  approximate diameter of cells 
var cells_filter_scale				= 1;											//	radius for cell smoothing
var cells_fixed_threshold_value		= 1000;										//	fixed maximum threshold for cell segmentation (if auto doesn't work well);
var fields							= 4;										//	number of xy positions
var image_height					= 1000;										//	image height
var image_width						= 1000;										//	image width
var iterations						= 25;										// 	iterations of dilations in region growing (for determining cell boundaries)
var slices							= 7;										//	number of z-slices
var nuclei_channel					= 3;										//	channel used for segmentation of nuclei 
var nuclei_filter_scale				= 2;										// 	radius for nuclei smoothing/laplace
var nuclei_fixed_threshold_value	= 2900;										//	fixed maximum threshold for nuclei segmentation (if auto doesn't work well);
var nuclei_min_circularity			= 0.0;										//	min circularity
var nuclei_min_area					= 25;										//	calibrated min nuclear size (in µm2)
var nuclei_max_area					= 2500;										//	calibrated max nuclear size (in µm2)
var nuclei_overlap 					= 0.3;										//	nuclei_overlap amount tolerated for Stardist nuclei detection
var nuclei_probability				= 0.15;										//	minimal nuclei_probability for Stardist nuclei detection
var pixel_size						= 0.2046875;									//	pixel size (µm)
var rim								= 0;										//	percentage of the field to analyze
var spots_a_channel					= 1;										//	channel A used for segmentation of spots
var spots_a_filter_scale			= 4;										//	scale for Laplacian spots ch A
var spots_a_fixed_threshold_value	= -2750;										//	fixed maximum threshold for spot segmentation 
var spots_a_max_area				= 250;										//	max spot size in pixels ch A
var spots_a_min_area				= 5;										//	min spot size in pixels ch A
var spots_b_channel					= 0;										//	channel B used for segmentation of spots
var spots_b_filter_scale			= 1;										//	scale for Laplacian spots ch B
var spots_b_fixed_threshold_value	= -30;										//	fixed maximum threshold for spot segmentation
var spots_b_max_area				= 50;										//	max spot size in pixels ch B
var spots_b_min_area				= 2;										//	min spot size in pixels ch B
var spots_c_channel					= 0;										//	channel C used for segmentation of spots
var spots_c_filter_scale			= 1;										//	scale for Laplacian spots ch C
var spots_c_fixed_threshold_value	= -30;										//	fixed maximum threshold for spot segmentation
var spots_c_max_area				= 50;										//	max spot size in pixels ch C
var spots_c_min_area				= 2;										//	min spot size in pixels ch C
var tile_size						= 2000;										//	size of tiles to separate large mosaic files in
var trackmate_channel				= 3;										//  trackmate channel
var trackmate_maxDist				= 20;										//	trackmate maxDist
var trackmate_maxFrameGap			= 3;										// 	trackmate max frame gap
var trackmate_maxDistGap			= 20;										//	trackmate max dist gap
var trackmate_maxDistMerging		= 20;										//	trackmate max dist merging
var trackmate_maxDistSplitting		= 20;										//	trackmate max dist splitting

//	Boolean Parameters
var colocalize_spots				= false;									//	colocalize spot ROIs
var exclude_nuclei					= true;										//	analyze cellular regions without nuclear area
var flatfield						= false;									//	perform flatfield correction	
var nuclei_background				= false;										//	subtract nuclei_background for nuclei segmentation
var nuclei_clahe					= false;									// 	local contrast enhancement for nuclei segmentation
var nuclei_watershed				= false;									//	use nuclei_watershed for nuclei segmentation
var segment_cells					= false;										//	analyze cell and cytoplasmic ROIs
var segment_nuclei					= false;										//	analyze nuclear ROIs (currently redundant)
var segment_spots					= true;										//	analyze spot ROIs
var tracking						= true;										// 	run trackmate
var trackmate_gapClosing			= true;										// 	trackmate setting gap closing
var trackmate_trackMerging			= false;									// 	trackmate setting track merging
var trackmate_trackSplitting		= false;									// 	trackmate setting track splitting
var texture_analysis 				= false;									//  implement texture analysis
var z_project						= true;										//	generation of max projection images

//	Arrays
var cells_segmentation_methods		= newArray("Threshold","Dilation","Trained Model","Cellpose");
var cols 							= newArray("01","02","03","04","05","06","07","08","09","10","11","12");
var dimensions						= newArray("xyczt(default)","xyctz","xytcz","xytzc","xyztc","xyzct");		
var file_list						= newArray(0);								
var file_types 						= newArray(".tif",".tiff",".nd2",".ids",".jpg",".mvd2",".czi");		
var nuclei_segmentation_methods		= newArray("Threshold","Stardist");
var preprocess_methods				= newArray("Median","Gauss","Laplace");
var objects 						= newArray("Nuclei","Cells","Spots_a","Spots_b","Spots_c");
var prefixes 						= newArray(0);
var rows 							= newArray("A","B","C","D","E","F","G","H");
var spot_segmentation_methods		= newArray("Gauss","Laplace","Multi-Scale");
var threshold_methods				= getList("threshold.methods");	
var threshold_methods				= Array.concat(threshold_methods,"Fixed");	

/*
 	***********************

		Macros

	***********************
*/

macro "Autorun"
{
	erase(1);
}

macro "Setup Action Tool - C888 T5f16S"
{
	setup();
}
macro "Segment Nuclei Action Tool - C999 H11f5f8cf3f181100 C999 P11f5f8cf3f18110 Ceee V5558"
{
	erase(0);
	setBatchMode(true);
	idStack = getImageID;
	c 		= getNumber("Nuclear Channel",nuclei_channel);
	f		= getNumber("Frame",10);
	run("Duplicate...", "title=Frame duplicate frames="+f);
	id=getImageID();
	mid 	= segmentNuclei(id,c,0);
	selectImage(id);close;
	selectImage(idStack);
	Stack.setChannel(c);
	Stack.setFrame(f);
	toggleOverlay();
	setBatchMode("exit and display");
}

macro "Segment Cells Action Tool - C999 H11f5f8cf3f181100 Ceee P11f5f8cf3f18110"
{
	erase(0);
	setBatchMode(true);
	idStack = getImageID;
	c1 = getNumber("Nuclear Channel",nuclei_channel);
	c2 = getNumber("Cellular Mask Channel",cells_channel); // 0 if no additional mask
	f		= getNumber("Frame",10);
	run("Duplicate...", "title=Frame duplicate frames="+f);
	id=getImageID();
	mid = segmentNuclei(id,c1,1); 
	nuclei_nr = roiManager("count");
	if(nuclei_nr>0)cell_nr = segmentRegions(id, mid, c2, iterations);
	selectImage(id);close;
	selectImage(idStack);
	Stack.setChannel(c2);
	Stack.setFrame(f);
	toggleOverlay();
	setBatchMode("exit and display");
}

macro "Segment Spots Action Tool - C999 H11f5f8cf3f181100 C999 P11f5f8cf3f18110 Ceee V3633 V4b33 V7633 Va933"
{
	erase(0);
	setBatchMode(true);
	idStack = getImageID;
	c 		= getNumber("Spot Channel",spots_a_channel);
	f		= getNumber("Frame",10);
	run("Duplicate...", "title=Frame duplicate frames="+f);
	id=getImageID();
	if(c == spots_a_channel){args = newArray(spots_a_channel,spots_a_segmentation_method,spots_a_threshold,spots_a_fixed_threshold_value,spots_a_filter_scale,spots_a_min_area,spots_a_max_area);}
	if(c == spots_b_channel){args = newArray(spots_b_channel,spots_b_segmentation_method,spots_b_threshold,spots_b_fixed_threshold_value,spots_b_filter_scale,spots_b_min_area,spots_b_max_area);}
	if(c == spots_c_channel){args = newArray(spots_c_channel,spots_c_segmentation_method,spots_c_threshold,spots_c_fixed_threshold_value,spots_c_filter_scale,spots_c_min_area,spots_c_max_area);}
	snr 	= segmentSpots(id,c,args);
	selectImage(id);close;
	selectImage(idStack);
	Stack.setChannel(c);
	Stack.setFrame(f);
	toggleOverlay();
	setBatchMode("exit and display");
}

macro "Batch Analysis All Action Tool - C888 T5f16A Tch12#"
{
	erase(1);
	setBatchMode(true);
	setDirectory();
	prefixes = scanFiles();
	fields = prefixes.length;
	setup();
	start = getTime();
	for(i=0;i<fields;i++)
	{
		prefix = prefixes[i];
		file = prefix+suffix;
		print(i+1,"/",fields,":",prefix);
		path = dir+file;
		run("Bio-Formats Importer", "open=["+path+"] color_mode=Default open_files view=Hyperstack stack_order=XYCZT");
		//open(path);
		idStack = getImageID;
		Stack.getDimensions(width, height, channels, slices, frames);
		for(f=1;f<=frames;f++){
			setFileNames(prefix,f);
			print(i+1,"/",fields,":",prefix,"---",f,"/",frames);
			selectImage(idStack);
			run("Duplicate...", "title=Frame duplicate frames="+f);
			id=getImageID();
			if(flatfield)id = flatfield_correct(id);
			if(segment_nuclei){
				mid 	= segmentNuclei(id,nuclei_channel,1); 
				nuclei_nr 	= roiManager("count");
			}else{
				nuclei_nr=0;
				mid=-1;
			}
			if(nuclei_nr>0){
				roiManager("Save",nuclei_roi_set);
			}
			if(nuclei_nr>0 && segment_cells)
			{
				cell_nr = segmentRegions(id, mid, cells_channel, iterations);
				if(cell_nr>0)roiManager("Save",cells_roi_set);
				else {File.delete(nuclei_roi_set); nuclei_nr=0;} 
				roiManager("reset");
			}
			if(isOpen(mid)){selectImage(mid); close;}
			if(segment_spots)
			{
				roiManager("reset");
				if(spots_a_channel>0)
				{
					args	= newArray(spots_a_channel,spots_a_segmentation_method,spots_a_threshold,spots_a_fixed_threshold_value,spots_a_filter_scale,spots_a_min_area,spots_a_max_area);
					snr 	= segmentSpots(id,spots_a_channel,args);
					if(snr>0)
					{
						roiManager("Save",spots_a_roi_set);
						roiManager("reset");
					}
				}
				if(spots_b_channel>0)
				{
					args	= newArray(spots_b_channel,spots_b_segmentation_method,spots_b_threshold,spots_b_fixed_threshold_value,spots_b_filter_scale,spots_b_min_area,spots_b_max_area);
					snr 	= segmentSpots(id,spots_b_channel,args);
					if(snr>0)
					{
						roiManager("Save",spots_b_roi_set);
						roiManager("reset");
					}
				}
				if(spots_c_channel>0)
				{
					args	= newArray(spots_c_channel,spots_c_segmentation_method,spots_c_threshold,spots_c_fixed_threshold_value,spots_c_filter_scale,spots_c_min_area,spots_c_max_area);
					snr 	= segmentSpots(id,spots_c_channel,args);
					if(snr>0)
					{
						roiManager("Save",spots_c_roi_set);
						roiManager("reset");
					}
				}
				
			}
			readout = analyzeRegions(id);
			if(readout & segment_nuclei){
				summarizeResults();
			}
			selectImage(id); close;
			erase(0);
		}
		labelMap(prefix,idStack);
		selectImage(idStack); close;
	}
	print((getTime()-start)/1000,"sec");
	if(isOpen("Log")){selectWindow("Log");saveAs("txt",log_path);}
	print("Complete Analysis Done");
	setBatchMode("exit and display");
}

macro "Batch Analysis Spot Action Tool - C888 T5f16S Tch12#"
{
	erase(1);
	setBatchMode(true);
	setDirectory();
	prefixes = scanFiles();
	fields = prefixes.length;
	setup();
	start = getTime();
	for(i=0;i<fields;i++)
	{
		prefix = prefixes[i];
		file = prefix+suffix;
		print(i+1,"/",fields,":",prefix);
		path = dir+file;
		run("Bio-Formats Importer", "open=["+path+"] color_mode=Default open_files view=Hyperstack stack_order=XYCZT");
		//open(path);
		idStack = getImageID;
		Stack.getDimensions(width, height, channels, slices, frames);
		for(f=1;f<=frames;f++){
			setFileNames(prefix,f);
			print(i+1,"/",fields,":",prefix,"---",f,"/",frames);
			selectImage(idStack);
			run("Duplicate...", "title=Frame duplicate frames="+f);
			id=getImageID();
			if(flatfield)id = flatfield_correct(id);
			if(segment_spots)
			{
				roiManager("reset");
				if(spots_a_channel>0)
				{
					args	= newArray(spots_a_channel,spots_a_segmentation_method,spots_a_threshold,spots_a_fixed_threshold_value,spots_a_filter_scale,spots_a_min_area,spots_a_max_area);
					snr 	= segmentSpots(id,spots_a_channel,args);
					if(snr>0)
					{
						roiManager("Save",spots_a_roi_set);
						roiManager("reset");
					}
				}
				if(spots_b_channel>0)
				{
					args	= newArray(spots_b_channel,spots_b_segmentation_method,spots_b_threshold,spots_b_fixed_threshold_value,spots_b_filter_scale,spots_b_min_area,spots_b_max_area);
					snr 	= segmentSpots(id,spots_b_channel,args);
					if(snr>0)
					{
						roiManager("Save",spots_b_roi_set);
						roiManager("reset");
					}
				}
				if(spots_c_channel>0)
				{
					args	= newArray(spots_c_channel,spots_c_segmentation_method,spots_c_threshold,spots_c_fixed_threshold_value,spots_c_filter_scale,spots_c_min_area,spots_c_max_area);
					snr 	= segmentSpots(id,spots_c_channel,args);
					if(snr>0)
					{
						roiManager("Save",spots_c_roi_set);
						roiManager("reset");
					}
				}
				
			}
			readout = analyzeRegions(id);
			if(readout & segment_nuclei){
				summarizeResults();
			}
			selectImage(id); close;
			erase(0);
			
		}
		labelMap(prefix,idStack);
		selectImage(idStack); close;
	}
	print((getTime()-start)/1000,"sec");
	if(isOpen("Log")){selectWindow("Log");saveAs("txt",log_path);}
	print("Complete Analysis Done");
	setBatchMode("exit and display");
}

/*
macro "Batch LabelMap Action Tool - C888 T5f16L"
{
	erase(1);
	setBatchMode(true);
	setDirectory();
	prefixes = scanFiles();
	fields = prefixes.length;
	for(i=0;i<fields;i++)
	{
		prefix = prefixes[i];
		file = prefix+suffix;
		print(i+1,"/",fields,":",prefix);
		path = dir+file;
		run("Bio-Formats Importer", "open=["+path+"] color_mode=Default open_files view=Hyperstack stack_order=XYCZT");
		//open(path);
		idStack = getImageID;
		labelMap(prefix,idStack);
		selectImage(idStack); close;
	}
	print("Complete Analysis Done");
	setBatchMode("exit and display");
}
*/


macro "Trackmate Batch Analysis Action Tool - C888 T5f16T Tch12#"
{
	erase(1);
	setBatchMode(true);
	setDirectory();
	prefixes = scanFiles();
	fields = prefixes.length;
	setup();
	start = getTime();
	for(i=0;i<fields;i++)
	{
		prefix = prefixes[i];
		setFileNames(prefix,0);
		print(i+1,"/",fields,":",prefix);
		run("Bio-Formats Importer", "open=["+labelmap+"] color_mode=Default open_files view=Hyperstack stack_order=XYCZT");
		idLabelMap = getImageID;
		labelmapTitle=getTitle();
		run("CellBlocksTemporal Trackmate", "imp="+labelmapTitle+" filename_xml="+xmlfile+" c="+trackmate_channel+" maxdist="+trackmate_maxDist+" gapclosing="+trackmate_gapClosing+" maxframegap="+trackmate_maxFrameGap+" maxdistgap="+trackmate_maxDistGap+" trackmerging="+trackmate_trackMerging+" maxdistmerging="+trackmate_maxDistMerging+" tracksplitting="+trackmate_trackSplitting+" maxdistsplitting="+trackmate_maxDistSplitting);
		run("Close All");
	}
	print((getTime()-start)/1000,"sec");
	if(isOpen("Log")){selectWindow("Log");saveAs("txt",log_path);}
	print("Complete Analysis Done");
	setBatchMode("exit and display");
}

macro "Toggle Overlay Action Tool - Caaa O11ee"
{
	toggleOverlay();
}

macro "[t] Toggle Overlay"
{
	toggleOverlay();
}

/*
 	***********************

		Functions

	***********************
*/

function setOptions()
{
	run("Options...", "iterations=1 count=1");
	run("Colors...", "foreground=white nuclei_background=black selection=yellow");
	run("Overlay Options...", "stroke=red width=1 fill=none");
	setBackgroundColor(0, 0, 0);
	setForegroundColor(255,255,255);
}

function getMoment()
{
     MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
     DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     TimeString ="Date: "+DayNames[dayOfWeek]+" ";
     if (dayOfMonth<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+"\nTime: ";
     if (hour<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+hour+":";
     if (minute<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+minute+":";
     if (second<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+second;
     return TimeString;
}

function erase(all)
{
	if(all){
		print("\\Clear");
		run("Close All");
	}
	run("Clear Results");
	roiManager("reset");
	run("Collect Garbage");
}

function setDirectory()
{
	dir = getDirectory("Choose a Source Directory");
	file_list = getFileList(dir);
	output_dir = dir+"Output"+File.separator;
	if(!File.exists(output_dir))File.makeDirectory(output_dir);
	log_path = output_dir+"Log.txt";
}

function setFileNames(prefix,f)
{
	if(f<=9)f="000"+f;
	else if(f<=99)f="00"+f;	
	else if(f<=999)f="0"+f;	

	labelmap			= output_dir+prefix+"_labelmap.tif";
	xmlfile				= output_dir+prefix+"_trackmate.xml";
	nuclei_roi_set 		= output_dir+prefix+"_Frame_"+f+"_nuclei_roi_set.zip";
	nuclei_results 		= output_dir+prefix+"_Frame_"+f+"_nuclei_results.txt";
	cells_roi_set 		= output_dir+prefix+"_Frame_"+f+"_cells_roi_set.zip";
	cells_results		= output_dir+prefix+"_Frame_"+f+"_cells_results.txt";
	spots_a_roi_set		= output_dir+prefix+"_Frame_"+f+"_spots_a_roi_set.zip";
	spots_b_roi_set		= output_dir+prefix+"_Frame_"+f+"_spots_b_roi_set.zip";
	spots_a_results		= output_dir+prefix+"_Frame_"+f+"_spots_a_results.txt";
	spots_b_results		= output_dir+prefix+"_Frame_"+f+"_spots_b_results.txt";
	results				= output_dir+prefix+"_Frame_"+f+"_summary.txt";
}

function scanFiles()
{
	prefixes = newArray(0);
	for(i=0;i<file_list.length;i++)
	{
		path = dir+file_list[i];
		if(endsWith(path,suffix) && indexOf(path,"flatfield")<0)
		{
			print(path);
			prefixes = Array.concat(prefixes,substring(file_list[i],0,lastIndexOf(file_list[i],suffix)));			
		}
	}
	return prefixes;
}

function setup()
{
	setOptions();
	Dialog.createNonBlocking("CellBlocks Settings");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("----------------------------------------   General parameters  -----------------------------------------", 14, "#E95F55");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("Define here which regions you wish to analyze and whether you want to perform texture measurement.\n", 12, "#999999");
	Dialog.setInsets(0,0,0);
	Dialog.addChoice("Image Type", file_types, suffix);
	Dialog.addToSameRow();
	Dialog.addNumber("Pixel Size", pixel_size, 3, 5, micron+"");
	Dialog.addToSameRow();
	//Dialog.addNumber("Field Number",fields, 0, 5, "");
	//Dialog.addToSameRow();
	Dialog.addNumber("Channel Number", channels, 0, 5, "");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("Detectable Objects:\n",13,"#E95F55");
	labels = newArray(3);defaults = newArray(3);
	labels[0] = "Nuclei";		defaults[0] = segment_nuclei;
	labels[1] = "Cells";		defaults[1] = segment_cells;
	labels[2] = "Spots";		defaults[2] = segment_spots;
	Dialog.setInsets(0,0,0);
	Dialog.addCheckboxGroup(1,5,labels,defaults);
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("Applications:\n",13,"#E95F55");
	Dialog.setInsets(0,0,0);
	Dialog.addCheckbox("Texture Analysis",texture_analysis);
	Dialog.setInsets(0,0,0);
	Dialog.addCheckbox("Tracking Trackmate",tracking);
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("----------------------------------------   Nuclei parameters  ------------------------------------------", 14, "#E95F55");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("Nuclei are segmented by classic thresholding, or using a trained classifier (Stardist).\nVarious preprocessing steps can be included. Laplacian preprocessing can only be combined with thresholding.\nObject filtering is always applied.\n", 12, "#999999");
	Dialog.setInsets(0,0,0);
	Dialog.addNumber("Nuclei Channel", nuclei_channel, 0, 4, "");
	Dialog.addToSameRow();
	Dialog.addChoice("Segmentation", nuclei_segmentation_methods, nuclei_segmentation_method);
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("Preprocessing steps:\n",13,"#E95F55");
	Dialog.setInsets(0,0,0);
	Dialog.addCheckbox("Background Subtraction", nuclei_background);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Contrast Enhancement", nuclei_clahe);
	Dialog.setInsets(0,0,0);
	Dialog.addChoice("Filter", preprocess_methods, nuclei_preprocess_method);
	Dialog.addToSameRow();
	Dialog.addNumber("Filter Radius", nuclei_filter_scale, 0, 4, "");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
	Dialog.setInsets(0,0,0);	
	Dialog.addMessage("Threshold Settings:\n",13,"#E95F55");
	Dialog.setInsets(0,0,0);
	Dialog.addChoice("Method", threshold_methods, nuclei_threshold);
	Dialog.addToSameRow();
	Dialog.addNumber("Fixed Threshold", nuclei_fixed_threshold_value, 0, 4, "");
	Dialog.setInsets(0,0,0);	
	Dialog.addCheckbox("Watershed Separation", nuclei_watershed);
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
	Dialog.setInsets(0,0,0);	
	Dialog.addMessage("Stardist Settings:\n",13,"#E95F55");
	Dialog.setInsets(0,0,0);
	Dialog.addNumber("Probability", nuclei_probability, 2, 4, "");
	Dialog.addToSameRow();
	Dialog.addNumber("Tolerated overlap", nuclei_overlap, 2, 4, "");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
	Dialog.setInsets(0,0,0);	
	Dialog.addMessage("Object filters:\n",13,"#E95F55");
	Dialog.setInsets(0,0,0);
	Dialog.addNumber("Min. Circularity", nuclei_min_circularity, 2, 5, "");
	Dialog.setInsets(0,0,0);	
	Dialog.addNumber("Min. Area", nuclei_min_area, 0, 5, micron+"2");
	Dialog.addToSameRow();
	Dialog.addNumber("Max. Area", nuclei_max_area, 0, 5, micron+"2");	
	Dialog.setInsets(20,0,0);
	Dialog.show();
	
	print("%%%%%%%%%%%%%%%%CellBlocks_v23%%%%%%%%%%%%%%%%%%%%%%");
	suffix							= Dialog.getChoice();		print("Image Type:",suffix);
	pixel_size						= Dialog.getNumber(); 		print("Pixel Size:",pixel_size);
	channels 						= Dialog.getNumber();		print("Channels:",channels);
	segment_nuclei					= Dialog.getCheckbox(); 	print("Segment Nuclei:",segment_nuclei);
	segment_cells 					= Dialog.getCheckbox();		print("Segment Cells:",segment_cells);
	segment_spots 					= Dialog.getCheckbox();		print("Segment Spots:",segment_spots);
	texture_analysis				= Dialog.getCheckbox();		print("Texture Analysis:",texture_analysis);
	tracking						= Dialog.getCheckbox();		print("Tracking:",tracking);
	nuclei_channel 					= Dialog.getNumber();		print("Nuclear Channel:",nuclei_channel);
	nuclei_segmentation_method		= Dialog.getChoice();		print("Nuclei Segmentation Method:",nuclei_segmentation_method);
	nuclei_background				= Dialog.getCheckbox();		print("Background Subtraction:",nuclei_background);
	nuclei_clahe					= Dialog.getCheckbox();		print("Clahe:",nuclei_clahe);
	nuclei_preprocess_method		= Dialog.getChoice();		print("Nuclei Preprocess Method:",nuclei_preprocess_method);
	nuclei_filter_scale				= Dialog.getNumber();		print("Nuclei Filter Scale:",nuclei_filter_scale);
	nuclei_threshold				= Dialog.getChoice();		print("Nuclear Autothreshold:",nuclei_threshold);
	nuclei_fixed_threshold_value	= Dialog.getNumber();		print("Fixed Threshold Value:",nuclei_fixed_threshold_value);
	nuclei_watershed 				= Dialog.getCheckbox();		print("Watershed:",nuclei_watershed);
	nuclei_probability 				= Dialog.getNumber();		print("Probability:",nuclei_probability);
	nuclei_overlap 					= Dialog.getNumber();		print("Overlap:",nuclei_overlap);
	nuclei_min_circularity			= Dialog.getNumber();		print("Min Circ:",nuclei_min_circularity);
	nuclei_min_area					= Dialog.getNumber();		print("Min Nuclear Size:",nuclei_min_area);
	nuclei_max_area					= Dialog.getNumber();		print("Max Nuclear Size:",nuclei_max_area);
	
	if(segment_cells)
	{
		Dialog.createNonBlocking("CellBlocks Settings");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("-------------------------------------------   Cell parameters  --------------------------------------------", 14, "#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Cells are segmented by thresholding a specific channel or if absent, by dilating nuclear ROI seeds.\nRegion growing is performed for a defined number of iterations, or if iterations is set to 0, sheer Voronoi tesselation is applied. \nA self-trained model or trained model (cellpose) can also be applied to detect cell regions.\n", 12, "#999999");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Cell Channel", cells_channel,0,4," ");
		Dialog.setInsets(0,0,0);
		Dialog.addChoice("Segmentation Method", cells_segmentation_methods, cells_segmentation_method);
		Dialog.setInsets(0,0,0);
		Dialog.addCheckbox("Exclude Nuclei",exclude_nuclei);
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Preprocessing steps:\n",13,"#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Gaussian Filter Radius ",cells_filter_scale,0,3,"");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
		Dialog.setInsets(0,0,0);	
		Dialog.addMessage("Threshold settings:\n",13,"#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addChoice("Threshold Method", threshold_methods, cells_threshold);
		Dialog.addToSameRow();
		Dialog.addNumber("Fixed Threshold", cells_fixed_threshold_value, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Dilation Settings:\n",13,"#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Grow cycles", iterations, 0, 5, "");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------------------------------------------------------------------- ", 14, "#dddddd");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Cellpose Settings:\n",13,"#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addDirectory("Conda Cellpose Environment:", "C:\\PROGRA~1\\FIJI-W~1\\.conda-envs\\cellpose\\");
		Dialog.addNumber("Expected diameter", cells_diameter, 0, 5, "");
		Dialog.show();
		
		cells_channel 					= Dialog.getNumber();		print("Cell Channel:",cells_channel);
		cells_segmentation_method		= Dialog.getChoice();		print("Cell Segmentation Method:",cells_segmentation_method);
		if(cells_segmentation_method=="Trained Model")
		{
			model_dir = getDirectory("Where is the trained cell model?");
			list  = getFileList(model_dir);
			for(i=0;i<list.length;i++)
			{
				path = model_dir+list[i];
				if (endsWith(list[i], ".model"))
				{
					model = path;
					print("location of the cell classification model:",model);
				}			
			}
		}
		exclude_nuclei					= Dialog.getCheckbox();		print("Exclude Nuclear Area From Cell Analysis", exclude_nuclei);
		cells_filter_scale				= Dialog.getNumber();		print("Cell Filter Scale:", cells_filter_scale);
		cells_threshold					= Dialog.getChoice();		print("Cell Autothreshold:",cells_threshold);
		cells_fixed_threshold_value		= Dialog.getNumber();		print("Fixed Threshold Value:",cells_fixed_threshold_value);
		iterations						= Dialog.getNumber();		print("Region Growing Iterations:",iterations);
		cells_cellpose_conda_env		= Dialog.getString();		print("Cellpose env:",cells_cellpose_conda_env);
		cells_diameter					= Dialog.getNumber();		print("Cellpose diameter:",cells_diameter);

	}
	
	if(segment_spots)
	{
		Dialog.createNonBlocking("CellBlocks Settings");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------   Spot parameters  ---------------------------------------", 14, "#F13A3A");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Detection of spot-like structures by thresholding after Laplace/Gauss enhancement\nSet channel to 0, if not applicable. If spot channel A and B are present, colocalize allows detecting reciprocal overlap.\nWhen applying a fixed threshold in combination with laplace/multi-scale enhancement, negative threshold values should be used. ", 12, "#999999");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------------------------------------------------------------- ", 14, "#dddddd");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Channel A Settings:\n",13,"#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Spot Channel A", spots_a_channel, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addChoice("Segmentation Method", spot_segmentation_methods, spots_a_segmentation_method);
		Dialog.addToSameRow();
		Dialog.addNumber("Filter Scale", spots_a_filter_scale, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addChoice("Threshold Method", threshold_methods, spots_a_threshold);
		Dialog.addToSameRow();
		Dialog.addNumber("Fixed Threshold", spots_a_fixed_threshold_value, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Min. Spot Size", spots_a_min_area, 0, 4, "pixels");
		Dialog.addToSameRow();
		Dialog.addNumber("Max. Spot Size", spots_a_max_area, 0, 4, "pixels");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------------------------------------------------------------- ", 14, "#dddddd");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Channel B Settings:\n",13,"#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Spot Channel B", spots_b_channel, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addChoice("Segmentation Method", spot_segmentation_methods, spots_b_segmentation_method);
		Dialog.addToSameRow();
		Dialog.addNumber("Filter Scale", spots_b_filter_scale, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addChoice("Threshold Method", threshold_methods, spots_b_threshold);
		Dialog.addToSameRow();
		Dialog.addNumber("Fixed Threshold", spots_b_fixed_threshold_value, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Min. Spot Size", spots_b_min_area, 0, 4, "px");
		Dialog.addToSameRow();
		Dialog.addNumber("Max. Spot Size", spots_b_max_area, 0, 4, "px");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------------------------------------------------------------- ", 14, "#dddddd");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Channel C Settings:\n",13,"#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Spot Channel C", spots_c_channel, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addChoice("Segmentation Method", spot_segmentation_methods, spots_c_segmentation_method);
		Dialog.addToSameRow();
		Dialog.addNumber("Filter Scale", spots_c_filter_scale, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addChoice("Threshold Method", threshold_methods, spots_c_threshold);
		Dialog.addToSameRow();
		Dialog.addNumber("Fixed Threshold", spots_c_fixed_threshold_value, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Min. Spot Size", spots_c_min_area, 0, 4, "px");
		Dialog.addToSameRow();
		Dialog.addNumber("Max. Spot Size", spots_c_max_area, 0, 4, "px");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("---------------------------------------------------------------------------------------------- ", 14, "#dddddd");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("Colocalization:\n",13,"#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addCheckbox("Colocalize Spots (Only applicable for 2 spot channels A and B)",colocalize_spots);
		Dialog.show();
		
		spots_a_channel					= Dialog.getNumber();		print("Spot Channel A:",spots_a_channel);
		spots_a_segmentation_method		= Dialog.getChoice();		print("Spot Segmentation Method:",spots_a_segmentation_method);
		spots_a_filter_scale 			= Dialog.getNumber();		print("Spot Filter Size:",spots_a_filter_scale);
		spots_a_threshold 				= Dialog.getChoice();		print("Spot AutoThreshold:",spots_a_threshold);
		spots_a_fixed_threshold_value  	= Dialog.getNumber();		print("Fixed Threshold Value:",spots_a_fixed_threshold_value);
		spots_a_min_area	 			= Dialog.getNumber();		print("Min. spot size:", spots_a_min_area);
		spots_a_max_area 				= Dialog.getNumber();		print("Max. spot size:",spots_a_max_area);
		
		spots_b_channel					= Dialog.getNumber();		print("Spot Channel B:",spots_b_channel);
		spots_b_segmentation_method		= Dialog.getChoice();		print("Spot Segmentation Method:",spots_b_segmentation_method);
		spots_b_filter_scale 			= Dialog.getNumber();		print("Spot Filter Scale:",spots_b_filter_scale);
		spots_b_threshold 				= Dialog.getChoice();		print("Spot AutoThreshold:",spots_b_threshold);
		spots_b_fixed_threshold_value  	= Dialog.getNumber();		print("Fixed Threshold Value:",spots_b_fixed_threshold_value);
		spots_b_min_area	 			= Dialog.getNumber();		print("Min. Spot Size:", spots_b_min_area);
		spots_b_max_area 				= Dialog.getNumber();		print("Max. Spot Size:",spots_b_max_area);
		
		spots_c_channel					= Dialog.getNumber();		print("Spot Channel C:",spots_c_channel);
		spots_c_segmentation_method		= Dialog.getChoice();		print("Spot Segmentation Method:",spots_c_segmentation_method);
		spots_c_filter_scale 			= Dialog.getNumber();		print("Spot Filter Scale:",spots_c_filter_scale);
		spots_c_threshold 				= Dialog.getChoice();		print("Spot AutoThreshold:",spots_c_threshold);
		spots_c_fixed_threshold_value  	= Dialog.getNumber();		print("Fixed Threshold Value:",spots_c_fixed_threshold_value);
		spots_c_min_area	 			= Dialog.getNumber();		print("Min. Spot Size:", spots_c_min_area);
		spots_c_max_area 				= Dialog.getNumber();		print("Max. Spot Size:",spots_c_max_area);
		
		colocalize_spots 				= Dialog.getCheckbox();		print("Colocalize spot channels",colocalize_spots); 
		
		print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
	}
	
	if(tracking)
	{
		Dialog.createNonBlocking("Trackmate Settings");
		Dialog.setInsets(0,0,0);
		Dialog.addMessage("-------------------------------------------   Trackmate parameters  --------------------------------------------", 14, "#E95F55");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Trackmate Channel ", trackmate_channel,0,4," ");
		Dialog.setInsets(0,0,0);
		Dialog.addNumber("Max Distance  ",trackmate_maxDist,0,4,"");
		Dialog.setInsets(0,0,0);
		Dialog.addCheckbox("Gap Closing",trackmate_gapClosing);
		Dialog.addToSameRow();
		Dialog.addNumber("Max Frame Gap", trackmate_maxFrameGap, 0, 4, "");
		Dialog.addToSameRow();
		Dialog.addNumber("Max Distance Gap", trackmate_maxDistGap, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addCheckbox("Track Merging",trackmate_trackMerging);
		Dialog.addToSameRow();
		Dialog.addNumber("Max Distance Merging", trackmate_maxDistMerging, 0, 4, "");
		Dialog.setInsets(0,0,0);
		Dialog.addCheckbox("Track Splitting",trackmate_trackSplitting);
		Dialog.addToSameRow();
		Dialog.addNumber("Max Distance Splitting", trackmate_maxDistSplitting, 0, 4, "");
		Dialog.show();
		
		trackmate_channel 				= Dialog.getNumber();		print("Trackmate:", trackmate_channel);
		trackmate_maxDist				= Dialog.getNumber();		print("Trackmate MaxDist:", trackmate_maxDist);
		trackmate_gapClosing			= Dialog.getCheckbox();		print("Trackmate Gap Closing:", trackmate_gapClosing);
		trackmate_maxFrameGap			= Dialog.getNumber();		print("Trackmate Max Frame Gap:", trackmate_maxFrameGap);
		trackmate_maxDistGap			= Dialog.getNumber();		print("Trackmate Max Dist Gap:", trackmate_maxDistGap);
		trackmate_trackMerging			= Dialog.getCheckbox();		print("Trackmate Merging:", trackmate_trackMerging);
		trackmate_maxDistMerging		= Dialog.getNumber();		print("Trackmate Max Dist Merging:", trackmate_maxDistMerging);
		trackmate_trackSplitting		= Dialog.getCheckbox();		print("Trackmate Merging:", trackmate_trackSplitting);
		trackmate_maxDistSplitting		= Dialog.getNumber();		print("Trackmate Max Dist Merging:", trackmate_maxDistSplitting);

	}
}

function calibrateImage(id)
{
	getPixelSize(unit, pixelWidth, pixelHeight);
	if(unit!=micron && unit!="microns" && unit!="micron")run("Properties...", " unit="+micron+" pixel_width="+pixel_size+" pixel_height="+pixel_size);
	else pixel_size = pixelWidth;
}

function decalibrateImage(id)
{
	getPixelSize(unit, pixelWidth, pixelHeight);
	if(unit!="pixel")run("Properties...", " unit=pixel pixel_width=1 pixel_height=1");
}

function segmentNuclei(id,c,sel)
{
	// input = multichannel image, output = roiset of nuclear ROIs and if(sel==1) mask incl. border objects
	// output = an image (mid) that contains all ROIs (also touching borders) and roiset of full nuclei
	mid = 0;
	selectImage(id);
	image_width = getWidth;
	image_height = getHeight;
	if(Stack.isHyperstack)run("Duplicate...", "title=copy duplicate channels="+c);	
	else{setSlice(c);run("Duplicate...","title=copy ");}
	cid = getImageID; // the nuclear channel image to be turned into a binary image
	resetMinAndMax; //reset contrast to prevent different results between single and batch mode
	calibrateImage(cid);
	
	// preprocess the image
	selectImage(cid);
	if(nuclei_clahe)run("Enhance Local Contrast (CLAHE)", "blocksize=100 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
	if(nuclei_background)run("Subtract Background...", "rolling="+round(30/pixel_size));
	if(nuclei_preprocess_method == "Gauss")run("Gaussian Blur...", "sigma="+nuclei_filter_scale);
	else if(nuclei_preprocess_method == "Laplace")
	{
		run("FeatureJ Laplacian", "compute smoothing="+nuclei_filter_scale); // scale to be adapted depending on nuclei size and SNR
		selectImage(cid); close;
		selectImage("copy Laplacian");
		rename("copy");
		cid = getImageID;
		selectImage(cid);
	}else if (nuclei_preprocess_method == "Median") run("Median...", "radius="+nuclei_filter_scale);
	
	//Segmentation
	if(nuclei_segmentation_method != "Stardist")
	{
		if(nuclei_threshold=="Fixed")
		{
			if(nuclei_preprocess_method == "Laplace")
			{
				setAutoThreshold("Default ");
				getThreshold(mit,mat); 
				setThreshold(mit,nuclei_fixed_threshold_value);
			}
			else 
			{
				setAutoThreshold("Default dark");
				getThreshold(mit,mat); 
				setThreshold(nuclei_fixed_threshold_value, mat);
			}
		}
		else {
			if(nuclei_preprocess_method == "Laplace")setAutoThreshold(nuclei_threshold); 
			else setAutoThreshold(nuclei_threshold+" dark"); 
		}
		getThreshold(mit,mat); print("Nuclei Threshold:",mit,mat);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Fill Holes");
		if(nuclei_watershed)run("Watershed");
	}
	else if(nuclei_segmentation_method == "Stardist")
	{
		selectImage(cid);
		run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], "
		+"args=['input':"+'copy'+", 'modelChoice':'Versatile (fluorescent nuclei)',"
		+"'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99',"
		+"'probThresh':'"+nuclei_probability+"', 'nmsThresh':'"+nuclei_overlap+"', 'outputType':'ROI Manager', 'nTiles':'1', "
		+"'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', "
		+"'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
		selectImage(cid); close;
		newImage("copy", "8-bit black", image_width, image_height, 1);
		calibrateImage(cid);
		cid = getImageID;
		selectImage(cid);
		selectImage("copy");
		nr_rois = roiManager("count");
		for(r = 0; r < nr_rois; r++)
		{
			roiManager("select",r);
			run("Enlarge...", "enlarge=1");
			run("Clear");
			run("Enlarge...", "enlarge=-1");
			run("Fill");
		}
		roiManager("Deselect");
		roiManager("reset");
		setThreshold(1,255);
		run("Convert to Mask");
	}
	run("Set Measurements...", "area centroid mean integrated redirect=None decimal=2");
	if(sel)
	{
		selectImage(cid);
		run("Analyze Particles...", "size="+nuclei_min_area+"-"+nuclei_max_area+" circularity="+nuclei_min_circularity+"-1.00 show=Masks clear include");
		if(isOpen("Mask of copy"))
		{
			selectWindow("Mask of copy"); 
			mid = getImageID;   // the full mask of all particles (for more accurate cell segmentation)
		}
	}
	selectImage(cid);
	// only apply rim to the nuclei you actually want to analyze
	if(rim>0)run("Specify...", "width="+(image_width-image_width*rim/100)+" height="+(image_height-image_height*rim/100)+" x="+image_width*rim/200+" y="+image_height*rim/200);
	run("Analyze Particles...", "size="+nuclei_min_area+"-"+nuclei_max_area+" circularity="+nuclei_min_circularity+"-1.00 show=Nothing exclude clear include add");
	rmc = roiManager("count"); print(rmc,"Nuc. ROI");
	if(rmc==0 && isOpen(mid)){selectImage(mid); close; mid=0;}
	for(i=0;i<rmc;i++)
	{
		roiManager("select",i);
		if(i<9)roiManager("Rename","000"+i+1);
		else if(i<99)roiManager("Rename","00"+i+1);	
		else if(i<999)roiManager("Rename","0"+i+1);	
		else roiManager("Rename",i+1);
	}
	run("Clear Results");
	roiManager("deselect"); 
	roiManager("Measure");
	selectImage(cid); close; 
	return mid;
}

function flatfield_correct(id){
	//	flatField does a flatfield field correction, using an image of fluorescent plastic
	//	if flatfield contains different channels and input image only one, c directs to the correct channel to select in the flatfield stack
	selectImage(id);
	title = getTitle;
	flatpath = dir+"flatfield.tif";
	open(flatpath);
	fid = getImageID;
	selectImage(fid);
	getRawStatistics(n,flatmean);
	imageCalculator("Divide create 32-bit stack", id,fid); 
	selectImage(fid); close;
	selectImage(id); close;
	selectWindow("Result of "+title);
	id = getImageID;
	selectImage(id);
	rename(title);  
	run("Multiply...","value="+flatmean+" stack");
	return id;
}

function segmentRegions(id, mid, c, iterations){
	selectImage(mid); 
	run("Select None");
	name = getTitle;
	
	// generate voronoi regions from all detected nuclei (including edges) to have some rough boundaries between touching cells
	run("Duplicate...","title=voronoi");
	vid = getImageID;
	selectImage(vid);
	run("Voronoi");
	setThreshold(1, 255);
	run("Convert to Mask");
	run("Invert");
	
	// generate dilated nuclei (using more accurate EDM mapping (by x iterations) requires the biovioxxel package) - now just using the enlarge function
	if(cells_segmentation_method=="Dilation" && iterations != 0)
	{
		selectImage(mid);
		run("Duplicate...","title=dilate");
		did = getImageID;
		selectImage(did); 
		//run("EDM Binary Operations", "iterations="+iterations+" operation=dilate"); 
		run("Create Selection"); 
		run("Enlarge...", "enlarge="+iterations+" pixel");
		roiManager("Add");
		run("Select All");
		run("Fill");
		sel = roiManager("count")-1;
		roiManager("select", sel);
		run("Clear", "slice");
		roiManager("Delete");
		run("Select None");
		run("Invert LUT");
		imageCalculator("AND create", "voronoi","dilate");
		selectImage(did); close; 
		selectImage(vid); close;
		selectWindow("Result of voronoi");
		if(!is("Inverting LUT"))run("Invert LUT");
		//run("Invert");
		vid = getImageID;
		selectImage(vid);
		rename("Cell_ROI");
	}
	
	// voronoi
	if(cells_segmentation_method=="Dilation" && iterations == 0)
	{
		selectImage(vid);
		rename("Cell_ROI");
	}

	// use a cellular counterstain to make accurate cell ROIs
	if(cells_segmentation_method!="Dilation"){
		selectImage(id);
		run("Select None");
		if(Stack.isHyperstack)run("Duplicate...", "title=copy duplicate channels="+c);	
		else{setSlice(c);run("Duplicate...","title=copy ");}
		cid = getImageID;
		selectImage(cid);
		resetMinAndMax; //reset contrast to prevent different results between single and batch mode
		if(cells_filter_scale > 0)run("Gaussian Blur...", "sigma="+cells_filter_scale);
		if(cells_segmentation_method=="Trained Model")
		{
			print("Applying trained model, takes time!"); //model needs to be in the FIJI/scripts foldr along with the Trained_Glia_Segmentation.bsh script in teh FIJI/scripts folder
			run("Trained Cell Segmentation","model="+model+" image="+cid);
			selectImage(cid); close;
			selectWindow("Classification result");
			rename("copy");
			cid = getImageID();		
			setAutoThreshold("Default "); 	
		}
		else if(cells_segmentation_method=="Threshold")
		{
			if(cells_threshold=="Fixed"){
				setAutoThreshold("Default dark");
				getThreshold(mit,mat); 
				setThreshold(cells_fixed_threshold_value,mat);
			}
			else {
				setAutoThreshold(cells_threshold+" dark"); 
			}
		}
		else if(cells_segmentation_method=="Cellpose"){
			print("Cellpose Start");

			//Create RGB image for cellpose: R=1, G=2, B=3
			selectImage(id);
			run("Select None");
			if(Stack.isHyperstack)run("Duplicate...", "title=Nuclei_Red duplicate channels="+nuclei_channel);	
			else{ setSlice(nuclei_channel); run("Duplicate...","title=Nuclei_Red ");}
			redid=getImageID();
			selectImage(id);
			run("Select None");
			if(Stack.isHyperstack)run("Duplicate...", "title=Cells_Green duplicate channels="+cells_channel);	
			else{setSlice(cells_channel);run("Duplicate...","title=Cells_Green ");}
			greenid=getImageID();
			
			run("Merge Channels...", "c1=[Nuclei_Red] c2=[Cells_Green] create");
			compid=getImageID();
			getDimensions(w, h, channelRGB, s, f);
			for(i=1;i<=channelRGB;i++){
				Stack.setChannel(i);
				resetMinAndMax;
				run("Enhance Contrast", "saturated=0.35");
			}
			run("Make Composite");
			run("RGB Color");
			rgbid=getImageID();
			rename("RGB");
			selectImage(cid); close;

			//Run Cellpose and exclude roi borders from label map
			run("Cellpose ..." ,"imp=RGB  conda_env_path="+cells_cellpose_conda_env+" env_type=conda diameter="+cells_diameter+" model=cyto3 model_path= ch1=2 ch2=1 additional_flags=--use_gpu" );
			selectWindow("RGB-cellpose");
			cid = getImageID();
			rename("copy");
			selectImage(rgbid); close;
			selectImage(compid); close;
			setForegroundColor(0, 0, 0);
			getRawStatistics(nPixels, mean, min, max, std, histogram);	
			maxMask=max;
			minPixels=(nuclei_min_area/(pixel_size*pixel_size))/10;  //min pixel number equal to 1/10 of min nuc area	
			maxPixels=nPixels;		
			for(i=1; i<=maxMask; i++)
			{
				selectImage(cid);
				setThreshold(i, i, "raw");
				run("Create Selection");
				getRawStatistics(nPixels, mean, min, max, std, histogram);	
				
				if(nPixels > minPixels && nPixels!=maxPixels){
					run("Draw", "slice");
				}
			}
			setThreshold(1, maxMask, "raw");
			setForegroundColor(255, 255, 255);
			print("Cellpose End");
		}
		selectImage(cid);
		getThreshold(mit,mat); 
		print("Cell Threshold:",mit,mat);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		//run("Fill Holes");	
		
		if(cells_segmentation_method!="Cellpose")
		{
			imageCalculator("AND create", "voronoi","copy"); // apply the voronoi bounderies to the cell ROIs
			selectImage(cid); close; 
			selectImage(vid); close;
			selectWindow("Result of voronoi");
			vid = getImageID;
		}else { //cellpose
			selectImage(vid); close;
			selectImage(cid);
			vid=getImageID();
		}
		selectImage(vid);
		rename("Cell_ROI");
	}
	
	// keep only the non-excluded nuclei (pos nuclei)
	newImage("posnuclei", "16-bit Black", image_width, image_height, 1); 
	pid = getImageID;
	selectImage(pid); 
	roiManager("Deselect");
	roiManager("Fill");
	run("Convert to Mask");
	
	// fuse cell and nuclei image to avoid non-overlapping ROI (not with cellpose)
	if(cells_segmentation_method!="Cellpose"){
		imageCalculator("OR create", "Cell_ROI","posnuclei"); 
		selectImage(vid); close;
		selectWindow("Result of Cell_ROI");
		rename("Cells");
		vid = getImageID;
	}else{
		selectImage(vid);
		rename("Cells");
	}
	
	// make labeled nuclei centroid mask
	newImage("centroid", "16-bit Black", image_width, image_height, 1); 
	pidc=getImageID();
	calibrateImage(pidc);
	run("16-bit"); //Needed if > 255 nuclei detected
	rmc = roiManager("count"); // rmc = number of nuclei
	print(rmc,"retained nuclei");
	selectImage(pidc);
	run("Set Measurements...", "centroid redirect=None decimal=4");
	roiManager("measure");
	for(i=0;i<rmc;i++)
	{
		Mx=getResult("X", i)/pixel_size;
		My=getResult("Y", i)/pixel_size;
	 	makeOval(Mx-2, My-2, 4, 4);
		run("Set...", "value="+i+1);		
	}
	run("Select None");
	
	// Add cell rois and rename with matching nuclear index 
	selectImage(vid);
	run("Analyze Particles...", "size="+nuclei_min_area+"-Infinity circularity=0.00-1.00 show=Nothing add");
	rmcb = roiManager("count"); // number of cell regions larger than a nucleus 
	print(rmcb-rmc,"Number of detected cell regions larger than a min. nuclear area"); 
	selectImage(pidc);
	for(i=rmcb-1;i>=rmc;i--)
	{
		roiManager("select",i);
		getRawStatistics(np,mean,min,max);
		if(max==0){roiManager("delete");} 				// no nuc so not retained
		else if(max<10)roiManager("Rename","000"+max);	// assigned to correct nuc
		else if(max<100)roiManager("Rename","00"+max);	
		else if(max<1000)roiManager("Rename","0"+max);	
		else roiManager("Rename",max);
	}	
	selectImage(pidc); close();
	
	rmcc = roiManager("count"); //all cell regions with one nucleus	
	print(rmcc-rmc,"Number of unique cell regions that overlap with a nucleus"); 
	
	// exclude nuclei
	if(rmcc>rmc)
	{
		if(exclude_nuclei) //define cytoplasmic regions (cells without nuclei)
		{
			//Each Nucleus has a cell region, since the nuclei and cell image were merged
			//Check for cells that are equal in size to nucleus --> No cytoplasm --> Do not calculate XOR --> No Cytoplasm region added --> 0 in summary file
			roiManager("Sort");
			index = 0;
			for(i=0;i<rmc;i++)
			{
				index=i*2;
				roiManager("select",index); 
				roi_name_a = Roi.getName();
				getRawStatistics(np_a); //area
				roiManager("select", index+1); 
				roi_name_b = Roi.getName(); 
				getRawStatistics(np_b); //area
				if (matches(roi_name_a, roi_name_b) && np_a!=np_b)
				{ 
					couple = newArray(index,index+1);
					roiManager("select",couple); 
					roiManager("XOR"); 
					roiManager("Add");
					roiManager("select",roiManager("count")-1);
					roiManager("Rename",roi_name_a);
				}else if(matches(roi_name_a, roi_name_b) && np_a==np_b)
				{
					print("Matched with Cell ROI",roi_name_b,"But discarded due to equal size (no cytoplasm detected)");
				}
			}
			roiManager("select",Array.getSequence(rmcc));
			roiManager("Delete"); 			
		} 
		else if(!exclude_nuclei)
		{
			roiManager("select",Array.getSequence(rmc)); 
			roiManager("Delete"); //remove all nuclei ROIs and retain cell ROIs
		} 
		run("Select None");
		cell_nr = roiManager("count");		
	}
	else 
	{
		cell_nr = 0;
	}
	print(cell_nr, "Number of unique cell regions retained with area larger than a nucleus");
	selectImage(mid); close;
	selectImage(vid); close;
	selectImage(pid); close;
	if(isOpen("copy")){selectWindow("copy");close;}
	return cell_nr;
}

function segmentSpots(id,c,args)
{
	spot_channel				= args[0];
	spot_segmentation_method	= args[1];
	spot_threshold_method		= args[2];
	spot_fixed_threshold_value	= args[3];
	scale						= args[4];
	spot_min_area				= args[5];
	spot_max_area				= args[6];
	selectImage(id);
	run("Select None");
	if(Stack.isHyperstack)run("Duplicate...", "title=copy duplicate channels="+c);	
	else{setSlice(c);run("Duplicate...","title=copy ");}
	cid = getImageID;
	decalibrateImage(cid);
	selectImage(cid);
	resetMinAndMax; //reset contrast to prevent different results between single and batch mode
	title = getTitle;
	//run("Enhance Local Contrast (nuclei_clahe)", "blocksize=125 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
	if(spot_segmentation_method=="Gauss")
	{
		run("Duplicate...","title=Gauss");
		run("Gaussian Blur...", "sigma="+scale);
		lap = getImageID;
	}
	else if(spot_segmentation_method=="Laplace")
	{
		run("FeatureJ Laplacian", "compute smoothing="+scale);
		lap = getImageID;
	}
	else if(spot_segmentation_method=="Multi-Scale") 
	{
		e = 0;
		while(e<scale)
		{			
			e++;
			selectImage(cid);
			run("FeatureJ Laplacian", "compute smoothing="+e);
			selectWindow(title+" Laplacian");
			run("Multiply...","value="+e*e);
			rename("scale "+e);
			eid = getImageID;
			if(e>1)
			{
				selectImage(eid);run("Select All");run("Copy");close;
				selectImage(fid);run("Add Slice");run("Paste");
			}
			else fid = getImageID;
		}
		selectImage(fid);
		run("Z Project...", "start=1 projection=[Sum Slices]");
		lap = getImageID;
		selectImage(fid); close;
	}
	selectImage(lap);	
	if(spot_threshold_method=="Fixed")
	{
		if(spot_segmentation_method == "Laplace" || spot_segmentation_method == "Multi-Scale")
		{
			setAutoThreshold("Default ");
			getThreshold(mit,mat); 
			setThreshold(mit,spot_fixed_threshold_value);
		}
		else 
		{
			setAutoThreshold("Default dark");
			getThreshold(mit,mat); 
			setThreshold(spot_fixed_threshold_value, mat);
		}	
	}
	else 
	{
		if(spot_segmentation_method=="Gauss")setAutoThreshold(spot_threshold_method + " dark");
		else setAutoThreshold(spot_threshold_method+" ");
	}
	getThreshold(mit,mat); 
	print("Threshold:",mit,mat);
	run("Set Measurements...", "  area min mean redirect=["+title+"] decimal=4");
	run("Analyze Particles...", "size="+spot_min_area+"-"+spot_max_area+" circularity=0.00-1.00 show=Nothing display clear include add");
	snr = roiManager("count"); print(snr,"spots");
	if(snr>10000){print("excessive number, hence reset"); snr=0; roiManager("reset");}
	//to avoid excessive spot finding when there are no true spots
	selectImage(lap); close;
	selectImage(cid); close;
	return snr;
}

function analyzeRegions(id)
{
	erase(0); 
	mask = 0;
	readout = 1;
	//	analyze cell rois
	selectImage(id);
	calibrateImage(id);
	
	newImage("Mask", "32-bit Black",image_width, image_height, 1); 	//	reference image for spot assignments
	mask = getImageID; 
	
	if(File.exists(cells_roi_set))
	{
		run("Set Measurements...", "area mean standard modal min centroid center perimeter shape integrated median skewness kurtosis redirect=None decimal=4");
		roiManager("Open",cells_roi_set);
		rmc = roiManager("count");
		selectImage(id);
		for(c=1;c<=channels;c++)
		{
			setSlice(c);
			roiManager("deselect");
			roiManager("Measure");
		}

		if(texture_analysis){
			textureAnalysis(id);
		}

		sortResults(); // organize results per channel
		
		selectImage(mask);
		for(j=0;j<rmc;j++)
		{
			roiManager("select",j);
			index = getInfo("roi.name");
			run("Set...", "value="+0-index);							//	negative values for cytoplasm, positive for nuclei
			setResult("Nuclei",j,index);
		}	
		saveAs("Measurements",cells_results);
		erase(0);
	}	
	//	analyze nuclear rois
	if(File.exists(nuclei_roi_set))
	{
		run("Set Measurements...", "area mean standard modal min centroid center perimeter shape feret's integrated median skewness kurtosis redirect=None decimal=4");
		roiManager("Open",nuclei_roi_set);
		rmc = roiManager("count");
		selectImage(id);
		for(c=1;c<=channels;c++)
		{
			setSlice(c);
			roiManager("deselect");
			roiManager("Measure");
		}
		
		if(texture_analysis){
			textureAnalysis(id);
		}
	
		sortResults(); //organise results per channel
				
		selectImage(mask);
		for(j=0;j<rmc;j++)
		{
			roiManager("select",j);
			index = getInfo("roi.name");
			run("Set...", "value="+index);					//	negative values for cytoplasm, positive for nuclei
			setResult("Cell",j,index);
		}	
		run("Select None");
		updateResults;
		saveAs("Measurements",nuclei_results);
		erase(0);
	}	
		
	//	rudimentary colocalization analysis by binary overlap of spot ROIs requires bianry masks of spots
	if(colocalize_spots && File.exists(spots_a_roi_set) && File.exists(spots_b_roi_set))
	{
		roiManager("reset");
		roiManager("Open",spots_a_roi_set);
		selectImage(mask);
		run("Add Slice");
		setForegroundColor(255,255,255);
		setSlice(2);
		roiManager("Fill");
		roiManager("reset");
		roiManager("Open",spots_b_roi_set);
		selectImage(mask);
		run("Add Slice");
		setSlice(3);
		roiManager("Fill");
		run("Select None");
		roiManager("reset");
	}
	//	analyze spot rois
	if(File.exists(spots_a_roi_set))
	{
		selectImage(mask); 
		ms = nSlices;
		run("Set Measurements...", "  area mean min redirect=None decimal=4");
		roiManager("Open",spots_a_roi_set);
		spot_nr = roiManager("count");
		selectImage(id);
		for(c=1;c<=channels;c++)
		{
			setSlice(c);
			roiManager("deselect");
			roiManager("Measure");
		}
		sortResults();
		IJ.renameResults("Results","Temp");
		// determine the location of the spots (cell vs. nucleus)
		selectImage(mask); setSlice(1);
		roiManager("deselect");
		roiManager("Measure");
		nindices = newArray(spot_nr);
		cindices = newArray(spot_nr);	
		
		for(j=0;j<spot_nr;j++)
		{
			min = getResult("Min",j);
			max = getResult("Max",j);
			if(max>0){
				nindices[j] = max; 
				if(exclude_nuclei){
					if(min > 0){cindices[j] = 0;}
					else{cindices[j] = -min;}
				}
				else{cindices[j] = max;}
			}else if(min<0){nindices[j] = 0; cindices[j] = -min;}
		}	
		run("Clear Results");
		// determine the colocalizing spots (one pixel overlap is sufficient)
		if(colocalize_spots && ms==3)
		{
			selectImage(mask); setSlice(3);
			roiManager("Measure");
			overlaps = newArray(spot_nr);
			for(j=0;j<spot_nr;j++)
			{
				max = getResult("Max",j);
				if(max>0){overlaps[j]=1;}
			}	
			selectWindow("Results"); run("Close");
		}
		IJ.renameResults("Temp","Results");
		for(j=0;j<spot_nr;j++)
		{
			if(colocalize_spots && ms==3)setResult("Coloc",j,overlaps[j]);
			setResult("Nucleus",j,nindices[j]);
			setResult("Cell",j,cindices[j]);
		}
		updateResults;
		saveAs("Measurements",spots_a_results);
		erase(0);
	}
	if(File.exists(spots_b_roi_set))
	{
		selectImage(mask); 
		ms = nSlices;
		run("Set Measurements...", "  area mean min redirect=None decimal=4");
		roiManager("Open",spots_b_roi_set);
		spot_nr = roiManager("count");
		selectImage(id);
		for(c=1;c<=channels;c++)
		{
			setSlice(c);
			roiManager("deselect");
			roiManager("Measure");
		}
		sortResults();
		IJ.renameResults("Results","Temp");
		selectImage(mask);setSlice(1); 
		roiManager("deselect");
		roiManager("Measure");
		nindices = newArray(spot_nr);
		cindices = newArray(spot_nr);	
		for(j=0;j<spot_nr;j++)
		{
			min = getResult("Min",j);
			max = getResult("Max",j);
			if(max>0){
				nindices[j] = max; 
				if(exclude_nuclei){
					if(min > 0){cindices[j] = 0;}
					else{cindices[j] = -min;}
				}
				else{cindices[j] = max;}
			}else if(min<0){nindices[j] = 0; cindices[j] = -min;}
		}	
		run("Clear Results");
		// determine the colocalizing spots (one pixel overlap is sufficient)
		if(colocalize_spots && ms==3)
		{
			selectImage(mask); setSlice(2);
			roiManager("Measure");
			overlaps = newArray(spot_nr);
			for(j=0;j<spot_nr;j++)
			{
				max = getResult("Max",j);
				if(max>0){overlaps[j]=1;}
			}	
			selectWindow("Results"); run("Close");
		}
		IJ.renameResults("Temp","Results");
		for(j=0;j<spot_nr;j++)
		{
			if(colocalize_spots && ms==3)setResult("Coloc",j,overlaps[j]);
			setResult("Nucleus",j,nindices[j]);
			setResult("Cell",j,cindices[j]);
		}
		updateResults;
		saveAs("Measurements",spots_b_results);
		erase(0);
	}
	if(File.exists(spots_c_roi_set))
	{
		selectImage(mask); 
		ms = nSlices;
		run("Set Measurements...", "  area mean min redirect=None decimal=4");
		roiManager("Open",spots_c_roi_set);
		spot_nr = roiManager("count");
		selectImage(id);
		for(c=1;c<=channels;c++)
		{
			setSlice(c);
			roiManager("deselect");
			roiManager("Measure");
		}
		sortResults();
		IJ.renameResults("Results","Temp");
		selectImage(mask);setSlice(1); 
		roiManager("deselect");
		roiManager("Measure");
		nindices = newArray(spot_nr);
		cindices = newArray(spot_nr);	
		for(j=0;j<spot_nr;j++)
		{
			min = getResult("Min",j);
			max = getResult("Max",j);
			if(max>0){
				nindices[j] = max; 
				if(exclude_nuclei){
					if(min > 0){cindices[j] = 0;}
					else{cindices[j] = -min;}
				}
				else{cindices[j] = max;}
			}else if(min<0){nindices[j] = 0; cindices[j] = -min;}
		}	
		run("Clear Results");
		IJ.renameResults("Temp","Results");
		for(j=0;j<spot_nr;j++)
		{
			setResult("Nucleus",j,nindices[j]);
			setResult("Cell",j,cindices[j]);
		}
		updateResults;
		saveAs("Measurements",spots_c_results);
		erase(0);
	}
	
	if(isOpen(mask)){selectImage(mask); close;}
	else readout = 0;
	return readout;
}

function textureAnalysis (id){
	IJ.renameResults("Results","Temp");
	run("Clear Results");
	rmc=roiManager("count");
	id=getImageID();
	run("Select None");
	
	angSecMom=newArray(0);
	invDiffMom=newArray(0);
	contrast=newArray(0);
	energy=newArray(0);
	entropy=newArray(0);
	homogeneity=newArray(0);
	variance=newArray(0);
	shade=newArray(0);
	prominence=newArray(0);
	inertia=newArray(0);
	correlation=newArray(0);
	
	var angles=newArray(0,45,90,135);
	for(c=1;c<=channels;c++){
		selectImage(id);
		if(Stack.isHyperstack){
			run("Duplicate...", "title=copy duplicate channels="+c);	
		}else{
			setSlice(c);
			run("Duplicate...","title=copy ");
		}

		resetMinAndMax;
		run("8-bit");
		idCh=getImageID();

		for(a=0;a<angles.length;a++){
			for(i=0; i<rmc;i++){
				selectImage(idCh);
				roiManager("select", i);
				run("GLCM Texture3", "enter=1 select="+angles[a]+" symmetrical angular contrast correlation inverse entropy energy inertia homogeneity prominence variance shade");
			}
			
		}
		selectImage(idCh);close;
	}
		
	for(i=0;i<nResults;i++){
		angSecMom=Array.concat(angSecMom,getResult("Angular Second Moment", i));
		invDiffMom=Array.concat(invDiffMom,getResult("Inverse Difference Moment", i));
		contrast=Array.concat(contrast,getResult("Contrast", i));
		energy=Array.concat(energy,getResult("Energy", i));
		entropy=Array.concat(entropy,getResult("Entropy", i));
		homogeneity=Array.concat(homogeneity,getResult("Homogeneity", i));
		variance=Array.concat(variance,getResult("Variance", i));
		shade=Array.concat(shade,getResult("Shade", i));
		prominence=Array.concat(prominence,getResult("Prominence", i));
		inertia=Array.concat(inertia,getResult("Inertia", i));
		correlation=Array.concat(correlation,getResult("Correlation", i));
	}
	
	angSecMom_av=newArray(rmc*c);
	invDiffMom_av=newArray(rmc*c);
	contrast_av=newArray(rmc*c);
	energy_av=newArray(rmc*c);
	entropy_av=newArray(rmc*c);
	homogeneity_av=newArray(rmc*c);
	variance_av=newArray(rmc*c);
	shade_av=newArray(rmc*c);
	prominence_av=newArray(rmc*c);
	inertia_av=newArray(rmc*c);
	correlation_av=newArray(rmc*c);

	for(c=1;c<=channels;c++){
		for(i=0; i<rmc;i++){
			angSecMom_sum=0;
			invDiffMom_sum=0;
			contrast_sum=0;
			energy_sum=0;
			entropy_sum=0;
			homogeneity_sum=0;
			variance_sum=0;
			shade_sum=0;
			prominence_sum=0;
			inertia_sum=0;
			correlation_sum=0;
			for(a=0; a<angles.length;a++){
				index=((c-1)*angles.length*rmc)+(a*rmc)+i;
				
				angSecMom_sum=angSecMom_sum+angSecMom[index];
				invDiffMom_sum=invDiffMom_sum+invDiffMom[index];
				contrast_sum=contrast_sum+contrast[index];
				energy_sum=energy_sum+energy[index];
				entropy_sum=entropy_sum+entropy[index];
				homogeneity_sum=homogeneity_sum+homogeneity[index];
				variance_sum=variance_sum+variance[index];
				shade_sum=shade_sum+shade[index];
				prominence_sum=prominence_sum+prominence[index];
				inertia_sum=inertia_sum+inertia[index];
				correlation_sum=correlation_sum+correlation[index];
			}
			index=((c-1)*rmc)+i;
			
			angSecMom_av[index]=angSecMom_sum/angles.length;
			invDiffMom_av[index]=invDiffMom_sum/angles.length;
			contrast_av[index]=contrast_sum/angles.length;
			energy_av[index]=energy_sum/angles.length;
			entropy_av[index]=entropy_sum/angles.length;
			homogeneity_av[index]=homogeneity_sum/angles.length;
			variance_av[index]=variance_sum/angles.length;
			shade_av[index]=shade_sum/angles.length;
			prominence_av[index]=prominence_sum/angles.length;
			inertia_av[index]=inertia_sum/angles.length;
			correlation_av[index]=correlation_sum/angles.length;
		}
	}

	selectWindow("Results"); run("Close");
	IJ.renameResults("Temp","Results");

	for(c=1;c<=channels;c++){
		for(i=0; i<rmc;i++){
			index=(c-1)*rmc+i;
			setResult("AngularSecondMoment", index, angSecMom_av[index]);
			setResult("InverseDifferenceMoment", index, invDiffMom_av[index]);
			setResult("Contrast", index, contrast_av[index]);
			setResult("Energy", index, energy_av[index]);
			setResult("Entropy", index, entropy_av[index]);
			setResult("Homogeneity", index, homogeneity_av[index]);
			setResult("Variance", index, variance_av[index]);
			setResult("Shade", index, shade_av[index]);
			setResult("Prominence", index, prominence_av[index]);
			setResult("Inertia", index, inertia_av[index]);
			setResult("Correlation", index, correlation_av[index]);	
		}
	}
	updateResults();
}


function sortResults()
{
	resultLabels = getResultLabels();
	matrix = results2matrix(resultLabels);
	matrix2results(matrix,resultLabels,channels);
}

function getResultLabels()
{
	selectWindow("Results");
	ls 				= split(getInfo(),'\n');
	rr 				= split(ls[0],'\t'); 
	nparams 		= rr.length-1;			
	resultLabels 	= newArray(nparams);
	for(j=1;j<=nparams;j++){resultLabels[j-1]=rr[j];}
	return resultLabels;
}

function results2matrix(resultLabels)
{
	h = nResults;
	w = resultLabels.length;
	newImage("Matrix", "32-bit Black",w, h, 1);
	matrix = getImageID;
	for(j=0;j<w;j++)
	{
		for(r=0;r<h;r++)
		{
			v = getResult(resultLabels[j],r);
			selectImage(matrix);
			setPixel(j,r,v);
		}
	}
	run("Clear Results");
	return matrix;
}

function matrix2results(matrix,resultLabels,channels)
{
	selectImage(matrix);
	w = getWidth;
	h = getHeight;
	for(c=0;c<channels;c++)
	{
		start = c*h/channels;
		end = c*h/channels+h/channels;
		for(k=0;k<w;k++)
		{
			for(j=start;j<end;j++)
			{
				selectImage(matrix);
				p = getPixel(k,j);
				setResult(resultLabels[k]+"_MC"+c+1,j-start,p); // MC for measurement channel
			}
		}
	}
	selectImage(matrix); close;
	updateResults;
}

function toggleOverlay()
{	
	run("Select None"); 
	roiManager("deselect");
	roiManager("Show All without labels");
	if(Overlay.size == 0)run("From ROI Manager");
	else run("Remove Overlay");
}

function summarizeResults()
{
	// 	open nuclei results
	run("Results... ", "open=["+nuclei_results+"]");
	nnr 			= nResults;
	nindices		= newArray(nnr);
	resultLabels 	= getResultLabels();
	matrix 			= results2matrix(resultLabels);
	selectWindow("Results"); 
	run("Close");
	for(r=0;r<nnr;r++)
	{
		for(s=0;s<resultLabels.length;s++)
		{
			selectImage(matrix);
			p = getPixel(s,r);
			if(resultLabels[s]!="Cell" && resultLabels[s]!="X_MC1" && resultLabels[s]!="Y_MC1")setResult("Nucl_SC"+nuclei_channel+"_"+resultLabels[s],r,p); // Label all nuclear measured parameters except for the cell or X and Y indices with a "Nucl" prefix
			else if(resultLabels[s]=="X_MC1")setResult("X",r,p);  //exception for X,Y coordinates for ease of tracing-back
			else if(resultLabels[s]=="Y_MC1")setResult("Y",r,p); 
			else setResult(resultLabels[s],r,p);
		}
	}
	updateResults;
	selectImage(matrix); close;
	
	//	append cellular results
	if(File.exists(cells_results))
	{	
		// once in a while a cell index is different from a nuclear index
		for(r=0;r<nnr;r++){nindices[r]=getResult("Cell",r)-1;} 
		IJ.renameResults("Results","Temp");
		run("Results... ", "open=["+cells_results+"]");
		cnr				= nResults;
		cindices		= newArray(cnr);
		for(r=0;r<cnr;r++){cindices[r]=getResult("Nuclei",r)-1;}
		 
		//Append results based on roi index in cell results 
		resultLabels = getResultLabels();
		matrix = results2matrix(resultLabels);
		selectWindow("Results"); run("Close");
		IJ.renameResults("Temp","Results");
		for(r=0;r<cnr;r++) 
		{
			for(s=0;s<resultLabels.length;s++)
			{
				if(resultLabels[s]!="Nuclei" && resultLabels[s]!="X_MC1" && resultLabels[s]!="Y_MC1")
				{
					selectImage(matrix);
					p = getPixel(s,r);
					setResult("Cell_SC"+cells_channel+"_"+resultLabels[s],cindices[r],p); // Label all cytoplasmic measured parameters with a "Cell" prefix
				}
			}
		}
		updateResults;
		selectImage(matrix); close;
	}	
	//	append summarized spot results
	if(File.exists(spots_a_results))
	{
		IJ.renameResults("Results","Temp");
		run("Results... ", "open=["+spots_a_results+"]");
		// if distance measurement was done for spots add them here
		updateResults;
		snr 			= nResults;
		nindices 		= newArray(snr);
		cindices 		= newArray(snr);
		for(j=0;j<snr;j++)
		{
			nindices[j] = getResult("Nucleus",j)-1;
			cindices[j] = getResult("Cell",j)-1;
		}	
		resultLabels = getResultLabels();
		matrix = results2matrix(resultLabels);
		selectWindow("Results"); run("Close");
		IJ.renameResults("Temp","Results");
		for(s=0;s<resultLabels.length;s++)
		{
			if(resultLabels[s] != "Nucleus" && resultLabels[s] != "Cell")
			{
				nvalues 	= newArray(nnr);
				cvalues 	= newArray(nnr);
				nnumber 	= newArray(nnr);
				cnumber 	= newArray(nnr);
				for(r=0;r<snr;r++)
				{
					selectImage(matrix);
					p = getPixel(s,r);
					if(nindices[r]>=0)
					{
						nvalues[nindices[r]] += p;  
						nnumber[nindices[r]] += 1;	
					}
					if(cindices[r]>=0)
					{
						cvalues[cindices[r]] += p;  
						cnumber[cindices[r]] += 1;	
					}
				}
				
				for(r=0;r<nnr;r++)
				{
					setResult("Spot_SC"+spots_a_channel+"_NrPerNuc",r,nnumber[r]);
					setResult("Spot_SC"+spots_a_channel+"_"+resultLabels[s]+"_SumPerNuc",r,nvalues[r]);              
					setResult("Spot_SC"+spots_a_channel+"_"+resultLabels[s]+"_MeanPerNuc",r,nvalues[r]/nnumber[r]);
					if(segment_cells)
					{
						setResult("Spot_SC"+spots_a_channel+"_NrPerCell",r,cnumber[r]);
						setResult("Spot_SC"+spots_a_channel+"_"+resultLabels[s]+"_SumPerCell",r,cvalues[r]);
						setResult("Spot_SC"+spots_a_channel+"_"+resultLabels[s]+"_MeanPerCell",r,cvalues[r]/cnumber[r]);
					}
				}
			}
		}
		selectImage(matrix); close;
		updateResults();
	}
	if(File.exists(spots_b_results))
	{
		IJ.renameResults("Results","Temp");
		run("Results... ", "open=["+spots_b_results+"]");
		// if distance measurement was done for spots add them here
		updateResults;
		snr 			= nResults;
		nindices 		= newArray(snr);
		cindices 		= newArray(snr);
		for(j=0;j<snr;j++)
		{
			nindices[j] = getResult("Nucleus",j)-1;
			cindices[j] = getResult("Cell",j)-1;
		}	
		resultLabels = getResultLabels();
		matrix = results2matrix(resultLabels);
		selectWindow("Results"); run("Close");
		IJ.renameResults("Temp","Results");
		for(s=0;s<resultLabels.length;s++)
		{
			if(resultLabels[s] != "Nucleus" && resultLabels[s] != "Cell")
			{
				nvalues 	= newArray(nnr);
				cvalues 	= newArray(nnr);
				nnumber 	= newArray(nnr);
				cnumber 	= newArray(nnr);
				for(r=0;r<snr;r++)
				{
					selectImage(matrix);
					p = getPixel(s,r);
					if(nindices[r]>=0)
					{
						nvalues[nindices[r]] += p;  
						nnumber[nindices[r]] += 1;	
					}
					if(cindices[r]>=0)
					{
						cvalues[cindices[r]] += p;  
						cnumber[cindices[r]] += 1;	
					}
				}
				for(r=0;r<nnr;r++)
				{
					setResult("Spot_SC"+spots_b_channel+"_NrPerNuc",r,nnumber[r]);
					setResult("Spot_SC"+spots_b_channel+"_"+resultLabels[s]+"_SumPerNuc",r,nvalues[r]);              
					setResult("Spot_SC"+spots_b_channel+"_"+resultLabels[s]+"_MeanPerNuc",r,nvalues[r]/nnumber[r]);
					if(segment_cells)
					{
						setResult("Spot_SC"+spots_b_channel+"_NrPerCell",r,cnumber[r]);
						setResult("Spot_SC"+spots_b_channel+"_"+resultLabels[s]+"_SumPerCell",r,cvalues[r]);
						setResult("Spot_SC"+spots_b_channel+"_"+resultLabels[s]+"_MeanPerCell",r,cvalues[r]/cnumber[r]);
					}
				}
			}
		}
		selectImage(matrix); close;
		updateResults();
	}
	if(File.exists(spots_c_results))
	{
		IJ.renameResults("Results","Temp");
		run("Results... ", "open=["+spots_c_results+"]");
		// if distance measurement was done for spots add them here
		updateResults;
		snr 			= nResults;
		nindices 		= newArray(snr);
		cindices 		= newArray(snr);
		for(j=0;j<snr;j++)
		{
			nindices[j] = getResult("Nucleus",j)-1;
			cindices[j] = getResult("Cell",j)-1;
		}	
		resultLabels = getResultLabels();
		matrix = results2matrix(resultLabels);
		selectWindow("Results"); run("Close");
		IJ.renameResults("Temp","Results");
		for(s=0;s<resultLabels.length;s++)
		{
			if(resultLabels[s] != "Nucleus" && resultLabels[s] != "Cell")
			{
				nvalues 	= newArray(nnr);
				cvalues 	= newArray(nnr);
				nnumber 	= newArray(nnr);
				cnumber 	= newArray(nnr);
				for(r=0;r<snr;r++)
				{
					selectImage(matrix);
					p = getPixel(s,r);
					if(nindices[r]>=0)
					{
						nvalues[nindices[r]] += p;  
						nnumber[nindices[r]] += 1;	
					}
					if(cindices[r]>=0)
					{
						cvalues[cindices[r]] += p;  
						cnumber[cindices[r]] += 1;	
					}
				}
				for(r=0;r<nnr;r++)
				{
					setResult("Spot_SC"+spots_c_channel+"_NrPerNuc",r,nnumber[r]);
					setResult("Spot_SC"+spots_c_channel+"_"+resultLabels[s]+"_SumPerNuc",r,nvalues[r]);              
					setResult("Spot_SC"+spots_c_channel+"_"+resultLabels[s]+"_MeanPerNuc",r,nvalues[r]/nnumber[r]);
					if(segment_cells)
					{
						setResult("Spot_SC"+spots_c_channel+"_NrPerCell",r,cnumber[r]);
						setResult("Spot_SC"+spots_c_channel+"_"+resultLabels[s]+"_SumPerCell",r,cvalues[r]);
						setResult("Spot_SC"+spots_c_channel+"_"+resultLabels[s]+"_MeanPerCell",r,cvalues[r]/cnumber[r]);
					}
				}
			}
		}
		selectImage(matrix); close;
		updateResults();
	}
	selectWindow("Results"); saveAs("Measurements",results);
}

function labelMap(prefix,id)
{
	selectImage(id);
	Stack.getDimensions(w,h,channels,slices,frames); 
	
	newImage("ResultsNuc", "16-bit black", w, h, frames);
	lidn=getImageID();
	
	newImage("ResultsCell", "16-bit black", w, h, frames);
	lidc=getImageID();
	
	if(segment_nuclei){
		selectImage(lidn);
		for(f=1;f<=frames;f++){
			print("Frame: "+f+" /"+frames);
			setFileNames(prefix,f);
			if(File.exists(nuclei_roi_set)){	
				selectImage(lidn);
				Stack.setSlice(f);
				roiManager("Open",nuclei_roi_set);
				rmc = roiManager("count");
				for(i=0;i<rmc;i++){
					roiManager("select",i);
					index=i+1;
					run("Set...", "value="+index);		
				}
				roiManager("reset");
			}
		}
	}

	if(segment_cells){
		selectImage(lidc);
		for(f=1;f<=frames;f++){
			print("Frame: "+f+" /"+frames);
			setFileNames(prefix,f);
			if(File.exists(cells_roi_set)){	
				selectImage(lidc);
				Stack.setSlice(f);
				roiManager("Open",cells_roi_set);
				rmc = roiManager("count");
				for(i=0;i<rmc;i++){
					roiManager("select",i);
					index=i+1;
					run("Set...", "value="+index);		
				}
				roiManager("reset");
			}
		}
	}
	if(segment_spots && spots_a_channel>0){
		newImage("ResultsSpotsA", "16-bit black", w, h, frames);
		lidsa=getImageID();
		for(f=1;f<=frames;f++){
			print("Frame: "+f+" /"+frames);
			setFileNames(prefix,f);
			if(File.exists(spots_a_roi_set)){	
				selectImage(lidsa);
				Stack.setSlice(f);
				roiManager("Open",spots_a_roi_set);
				rmc = roiManager("count");
				for(i=0;i<rmc;i++){
					roiManager("select",i);
					index=i+1;
					run("Set...", "value="+index);		
				}
				roiManager("reset");
			}
		}
	}
	if(segment_spots && spots_b_channel>0){
		newImage("ResultsSpotsB", "16-bit black", w, h, frames);
		lidsb=getImageID();
		for(f=1;f<=frames;f++){
			print("Frame: "+f+" /"+frames);
			setFileNames(prefix,f);
			if(File.exists(spots_b_roi_set)){	
				selectImage(lidsb);
				Stack.setSlice(f);
				roiManager("Open",spots_b_roi_set);
				rmc = roiManager("count");
				for(i=0;i<rmc;i++){
					roiManager("select",i);
					index=i+1;
					run("Set...", "value="+index);		
				}
				roiManager("reset");
			}
		}
	}
	if(segment_spots && spots_c_channel>0){
		newImage("ResultsSpotsC", "16-bit black", w, h, frames);
		lidsc=getImageID();
		for(f=1;f<=frames;f++){
			print("Frame: "+f+" /"+frames);
			setFileNames(prefix,f);
			if(File.exists(spots_c_roi_set))
			{	
				selectImage(lidsc);
				Stack.setSlice(f);
				roiManager("Open",spots_c_roi_set);
				rmc = roiManager("count");
				for(i=0;i<rmc;i++){
					roiManager("select",i);
					index=i+1;
					run("Set...", "value="+index);		
				}
				roiManager("reset");
			}
		}
	}

	if(segment_spots && spots_a_channel>0 && spots_b_channel>0 && spots_c_channel>0){
		run("Concatenate...", "image1=ResultsNuc image2=ResultsCell image3=ResultsSpotsA image4=ResultsSpotsB image5=ResultsSpotsC");
		run("Stack to Hyperstack...", "order=xytcz channels=5 slices=1 frames="+frames+" display=Grayscale");
		run("Remove Overlay");
		saveAs("tif", labelmap);
		close;
	}else if (segment_spots && spots_a_channel>0 && spots_b_channel>0 && spots_c_channel<=0){
		run("Concatenate...", "image1=ResultsNuc image2=ResultsCell image3=ResultsSpotsA image4=ResultsSpotsB");
		run("Stack to Hyperstack...", "order=xytcz channels=4 slices=1 frames="+frames+" display=Grayscale");
		run("Remove Overlay");
		saveAs("tif", labelmap);
		close;
	}else if (segment_spots && spots_a_channel>0 && spots_b_channel<=0 && spots_c_channel<=0){
		run("Concatenate...", "image1=ResultsNuc image2=ResultsCell image3=ResultsSpotsA");
		run("Stack to Hyperstack...", "order=xytcz channels=3 slices=1 frames="+frames+" display=Grayscale");
		run("Remove Overlay");
		saveAs("tif", labelmap);
		close;
	}else if (segment_cells && !segment_spots){
		run("Concatenate...", "open image1=ResultsNuc image2=ResultsCell");
		run("Stack to Hyperstack...", "order=xytcz channels=2 slices=1 frames="+frames+" display=Grayscale");
		run("Remove Overlay");
		saveAs("tif", labelmap);
		close;
	}else if (segment_nuclei) {
		selectImage(lidn);
		run("Remove Overlay");
		saveAs("tif", labelmap);
		close;
		selectImage(lidc);
		close;
	}
}