#Define input (small letters)
#@ ImagePlus imp
#@ String filename_xml
#@ int c
#@ float maxdist
#@ boolean gapclosing
#@ int maxframegap
#@ float maxdistgap
#@ boolean trackmerging
#@ float maxdistmerging
#@ boolean tracksplitting
#@ float maxdistsplitting

import sys
 
from ij import IJ
from ij import WindowManager
 
from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate.detection import LabelImageDetectorFactory
from fiji.plugin.trackmate.tracking.jaqaman import SparseLAPTrackerFactory
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettingsIO
from fiji.plugin.trackmate.gui.displaysettings.DisplaySettings import TrackMateObject
from fiji.plugin.trackmate.features.track import TrackIndexAnalyzer
 
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
from fiji.plugin.trackmate.io import TmXmlWriter
from fiji.plugin.trackmate.action import ExportTracksToXML
from java.io import File
 
# We have to do the following to avoid errors with UTF8 chars generated in 
# TrackMate that will mess with our Fiji Jython.
reload(sys)
sys.setdefaultencoding('utf-8')
 
#----------------------------
# Create the model object 
#----------------------------
model = Model()
logger = Logger.IJ_LOGGER
model.setLogger(logger)
 
#------------------------
# Prepare settings object
#------------------------
 
settings = Settings(imp)
 
# Configure detector - We use the Strings for the keys
settings.detectorFactory =  LabelImageDetectorFactory()
settings.detectorSettings = {
    'TARGET_CHANNEL' : c,
    'SIMPLIFY_CONTOURS' : False
}  
 
# Configure tracker - We want to allow merges and fusions
settings.trackerFactory = SparseLAPTrackerFactory()
settings.trackerSettings = settings.trackerFactory.getDefaultSettings() # almost good enough

settings.trackerSettings['LINKING_MAX_DISTANCE']    = maxdist;
settings.trackerSettings['ALLOW_GAP_CLOSING']   	= gapclosing;
settings.trackerSettings['MAX_FRAME_GAP']    		= maxframegap;
settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE']= maxdistgap;
settings.trackerSettings['ALLOW_TRACK_MERGING']     = trackmerging;
settings.trackerSettings['MERGING_MAX_DISTANCE']	= maxdistmerging;
settings.trackerSettings['ALLOW_TRACK_SPLITTING']   = tracksplitting;
settings.trackerSettings['SPLITTING_MAX_DISTANCE']  = maxdistsplitting; 
 
# Add ALL the feature analyzers known to TrackMate. They will 
# yield numerical features for the results, such as speed, mean intensity etc.
settings.addAllAnalyzers()

#-------------------
# Instantiate plugin
#-------------------
 
trackmate = TrackMate(model, settings)
 
#--------
# Process
#--------
 
ok = trackmate.checkInput()
if not ok:
    sys.exit(str(trackmate.getErrorMessage()))
 
ok = trackmate.process()
if not ok:
    sys.exit(str(trackmate.getErrorMessage()))
 
#----------------
# Display results
#----------------
 
# A selection.
selectionModel = SelectionModel( model )
 
# Read the default display settings.
ds = DisplaySettingsIO.readUserDefault()
# Color by tracks.
ds.setTrackColorBy( TrackMateObject.TRACKS, TrackIndexAnalyzer.TRACK_INDEX )
ds.setSpotColorBy( TrackMateObject.TRACKS, TrackIndexAnalyzer.TRACK_INDEX )
ds.setSpotFilled(True)
 
displayer =  HyperStackDisplayer( model, selectionModel, imp, ds )
displayer.render()
displayer.refresh()
 
# Echo results with the logger we set at start:
model.getLogger().log( str( model ) )

#----------
# Save Data
#----------
filename_save = File(filename_xml) 
writer = TmXmlWriter(filename_save, logger )
 
# Append content. Only the model is mandatory.
# writer.appendLog(log)
writer.appendModel(model)
writer.appendSettings(settings)
writer.appendDisplaySettings(ds)
 
# We want TrackMate to show the view config panel when 
# reopening this file.
writer.appendGUIState('ConfigureViews')
 
# Actually write the file.
writer.writeToFile() 