# CellBlocks_Temporal
ImageJ/Fiji macro set dedicated to in silico cytometric analysis of time series. Flexible high content analysis to measure descriptive features about cell and nucleus as well as intracellular spots. Demands a nuclear channel to facilitate segmentation of individual nuclei and conditional expansion to segment cellular regions of influence. Spots are tracked using Trackmate [^1] and linked to Cellblocks [^2] data.


### Citation
Please cite these papers if you are using this script in your research:
* De Vos WH, Van Neste L, Dieriks B, Joss GH, Van Oostveldt P. High content image cytometry in the context of subnuclear organization. Cytometry A. 2010 Jan;77(1):64-75. doi: 10.1002/cyto.a.20807. PMID: 19821512.
* De Puysseleyr L, De Puysseleyr K, Vanrompay D, De Vos WH. Quantifying the growth of chlamydia suis in cell culture using high-content microscopy. Microsc Res Tech. 2017 Apr;80(4):350-356. doi: 10.1002/jemt.22799. Epub 2016 Nov 12. PMID: 27862609.
* Peeters S, Kim H, Timmer R, Decuypere I, Ergot L, Joy M, Oksvold CP, Verschuuren M, De Beuckeleer S, De Cock L, Nuyttens T, De Waele J, Piel M, De Smet F, Hu H, Gabriele S, De Vos WH, Campsteijn C. BAF mobility tunes nuclear mechanics to enable confined invasion in glioblastoma. Submitted

### Required plugins:

FeatureJ and imagescience plugins (E. Meijering):<br />
http://www.imagescience.org/meijering/software/featurej/ <br />
Stardist[^3] and CSBDeep plugins (overlapping nuclei segmentation): <br />
https://imagej.net/StarDist <br />
Trackmate[^2] : <br />
https://imagej.net/plugins/trackmate/ <br />

[^1]: https://github.com/DeVosLab/CellBlocks/tree/main
[^2]: Ershov, D., Phan, M.-S., Pylvänäinen, J. W., Rigaud, S. U., Le Blanc, L., Charles-Orszag, A., … Tinevez, J.-Y. (2022). TrackMate 7: integrating state-of-the-art segmentation algorithms into tracking pipelines. Nature Methods, 19(7), 829–832. doi:10.1038/s41592-022-01507-1
[^3]: Uwe Schmidt, Martin Weigert, Coleman Broaddus, and Gene Myers. Cell Detection with Star-convex Polygons. International Conference on Medical Image Computing and Computer-Assisted Intervention (MICCAI), Granada, Spain, September 2018. <br />

   
