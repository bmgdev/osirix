/*=========================================================================
  Program:   OsiriX

  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - LGPL
  
  See http://www.osirix-viewer.com/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

#define MAX4D 500

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@class DCMView;
@class OpacityTransferView;
@class ColorTransferView;
@class MyPoint;
@class ROI;
@class DCMPix;
@class ThickSlabController;
@class StudyView;
@class SeriesView;
@class ImageView;
//@class CurvedMPR;
@class DICOMExport;
@class KeyObjectPopupController;
@class VRController;
@class OrthogonalMPRViewer;
@class OrthogonalMPRPETCTViewer;
@class SRController;
@class EndoscopyViewer;
@class MPRController;
@class CPRController;
@class ViewerController;


@interface NSObject(OsiriXPluginDraggingDestination)
- (BOOL)performPluginDragOperation:(id <NSDraggingInfo>)sender destination:(ViewerController*)vc;
@end

#import "Schedulable.h"
#import "Scheduler.h"
#import "StaticScheduler.h"
#import "OSIWindowController.h"

enum
{
	eSagittalPos = 0,		// 0
	eSagittalNeg,			// 1
	eCoronalPos,			// 2
	eCoronalNeg,			// 3
	eAxialPos,				// 4
	eAxialNeg				// 5
};

/** \brief Window Controller for 2D Viewer*/

@interface ViewerController : OSIWindowController  <Schedulable>
{
	NSLock	*ThreadLoadImageLock;
	NSLock	*roiLock;
	NSConditionLock *subLoadingThread, *flipDataThread;
	NSThread *loadingThread;
	
	IBOutlet StudyView		*studyView;
			SeriesView		*seriesView;

	IBOutlet NSSplitView	*splitView;
	IBOutlet NSMatrix		*previewMatrix;
	IBOutlet NSScrollView	*previewMatrixScrollView;
	BOOL					matrixPreviewBuilt;
	float					highLighted;
	int						lastHighLightedRow;
	NSTimer					*highLightedTimer;
	
    IBOutlet NSWindow       *quicktimeWindow;
	IBOutlet NSMatrix		*quicktimeMode;
	IBOutlet NSSlider		*quicktimeInterval, *quicktimeFrom, *quicktimeTo;
	IBOutlet NSTextField	*quicktimeIntervalText, *quicktimeFromText, *quicktimeToText, *quicktimeNumber;
	IBOutlet NSBox			*quicktimeBox;
	IBOutlet NSButton		*quicktimeAllViewers;
	
	DCMView					*imageView;
	
	IBOutlet NSView         *orientationView;
	IBOutlet NSMatrix		*orientationMatrix;
	
	short					currentOrientationTool, originalOrientation;
	
    IBOutlet NSSlider       *slider, *speedSlider;
	IBOutlet NSButton		*loopButton;
    IBOutlet NSView         *speedView;
    IBOutlet NSView         *toolsView;
    IBOutlet NSView         *WLWWView;
    IBOutlet NSView         *ReconstructionView;
	IBOutlet NSView         *ConvView;
	IBOutlet NSView         *FusionView;
	IBOutlet NSView			*BlendingView;
	IBOutlet NSView			*movieView, *serieView, *patientView, *iPhotoView, *keyImages, *PagePad;
	IBOutlet NSView         *RGBFactorsView;
	IBOutlet NSTextField    *speedText;
    IBOutlet NSPopUpButton  *wlwwPopup;
    IBOutlet NSPopUpButton  *convPopup;
    IBOutlet NSPopUpButton  *clutPopup;
	IBOutlet NSPopUpButton  *OpacityPopup;
	
	IBOutlet NSView			*propagateSettingsView;
	
	IBOutlet NSView         *subCtrlView;
			 BOOL			enableSubtraction;
	IBOutlet NSButton		*subCtrlOnOff;
			 long			subCtrlMaskID;
			 NSPoint		subCtrlMinMax;
			 BOOL			subCtrlMinMaxComputed;
	IBOutlet NSTextField	*subCtrlMaskText;

			 NSPoint		subCtrlOffset;
	IBOutlet NSButton		*sc1;
	IBOutlet NSButton		*sc2;
	IBOutlet NSButton		*sc3;
	IBOutlet NSButton		*sc4;
	IBOutlet NSButton		*sc5;
	IBOutlet NSButton		*sc6;
	IBOutlet NSButton		*sc7;
	IBOutlet NSButton		*sc8;
	IBOutlet NSButton		*sc9;
	
    IBOutlet NSSlider       *subCtrlSum;
    IBOutlet NSSlider       *subCtrlPercent;
	IBOutlet NSButton		*subCtrlSharpenButton;
	IBOutlet NSButton		*shutterOnOff;
	IBOutlet NSView			*shutterView;
			 NSString		*contextualDictionaryPath; //JF20070102
			 
			 long			speedometer;
		 
	IBOutlet NSView			*StatusView;
	IBOutlet NSButton		*CommentsField;
	IBOutlet NSPopUpButton	*StatusPopup;
	IBOutlet NSWindow		*CommentsWindow;
	IBOutlet NSTextField    *CommentsEditField;
	
	IBOutlet NSButton		*keyImageCheck;
	
	IBOutlet NSWindow		*ThickIntervalWindow;
    IBOutlet NSTextField    *customInterval;
    IBOutlet NSTextField    *customXSpacing;
	IBOutlet NSTextField    *customYSpacing;
	IBOutlet NSMatrix		*customVectors, *customOrigin;

    IBOutlet NSWindow       *setWLWWWindow;
    IBOutlet NSTextField    *wlset, *fromset;
    IBOutlet NSTextField    *wwset, *toset;
			
    IBOutlet NSWindow       *addWLWWWindow;
    IBOutlet NSTextField    *newName;
    IBOutlet NSTextField    *wl;
    IBOutlet NSTextField    *ww;
	IBOutlet NSMatrix		*toolsMatrix;
    
	IBOutlet NSWindow       *roiSetPixWindow;
	IBOutlet NSTextField    *maxValueText, *minValueText, *newValueText;
	IBOutlet NSMatrix		*InOutROI, *AllROIsRadio, *newValueMatrix;
	IBOutlet NSButton		*checkMaxValue, *checkMinValue, *setROI4DSeries;

//	IBOutlet NSWindow       *curvedMPRWindow;
//	IBOutlet NSTextField	*curvedMPRtext;
//	IBOutlet NSSlider		*curvedMPRslid;
//	IBOutlet NSButton		*curvedMPRper;
//	IBOutlet NSSlider		*curvedMPRsize;
//	IBOutlet NSTextField	*curvedMPRsizeText;
//	IBOutlet NSSlider		*curvedMPRinterval;
//	IBOutlet NSTextField	*curvedMPRintervalText;
//	IBOutlet NSMatrix		*curvedMPRaxis;
	
	IBOutlet NSWindow       *blendingTypeWindow;
	IBOutlet NSButton		*blendingTypeMultiply, *blendingTypeSubtract;
	IBOutlet NSSegmentedControl		*blendingTypeRGB;
	IBOutlet NSPopUpButton  *blendingPlugins;
	IBOutlet NSButton		*blendingResample;
	
	IBOutlet NSWindow       *roiPropaWindow;
	IBOutlet NSMatrix		*roiPropaMode, *roiPropaDim, *roiPropaCopy;
	IBOutlet NSTextField	*roiPropaDest;
	
	IBOutlet NSWindow		*roiApplyWindow;
	IBOutlet NSMatrix		*roiApplyMatrix;
	
	IBOutlet NSWindow       *addConvWindow;
	IBOutlet NSMatrix		*convMatrix, *sizeMatrix;
	IBOutlet NSTextField    *matrixName, *matrixNorm;
	
	IBOutlet NSWindow       *addCLUTWindow;
	IBOutlet NSTextField    *clutName;
	IBOutlet ColorTransferView  *clutView;

	IBOutlet NSWindow       *dcmExportWindow;
	IBOutlet NSMatrix		*dcmSelection, *dcmFormat;
	IBOutlet NSSlider		*dcmInterval, *dcmFrom, *dcmTo;
	IBOutlet NSTextField	*dcmIntervalText, *dcmFromText, *dcmToText, *dcmNumber;
	IBOutlet NSBox			*dcmBox;
	IBOutlet NSButton		*dcmAllViewers;
	IBOutlet NSTextField	*dcmSeriesName;
	
	IBOutlet NSWindow       *imageExportWindow;
	IBOutlet NSMatrix		*imageSelection, *imageFormat;
	IBOutlet NSButton		*imageAllViewers;
	
	IBOutlet NSWindow		*displaySUVWindow;
	IBOutlet NSForm			*suvForm;
	IBOutlet NSMatrix		*suvConversion;
	
	IBOutlet NSWindow       *addOpacityWindow;
	IBOutlet NSTextField    *OpacityName;
	IBOutlet OpacityTransferView  *OpacityView;
	
	IBOutlet NSTextField    *movieTextSlide;
	IBOutlet NSButton		*moviePlayStop;
	IBOutlet NSSlider       *movieRateSlider;
	IBOutlet NSSlider       *moviePosSlider;
	
	IBOutlet NSPopUpButton  *blendingPopupMenu;
	IBOutlet NSTextField    *blendingPercentage;
	IBOutlet NSSlider       *blendingSlider;
	ViewerController		*blendingController;
	
	IBOutlet NSTextField    *roiRenameName;
	IBOutlet NSMatrix		*roiRenameMatrix;
	IBOutlet NSWindow		*roiRenameWindow;
	
	NSString				*curConvMenu, *curWLWWMenu, *curCLUTMenu, *backCurCLUTMenu, *curOpacityMenu;
	
	IBOutlet NSTextField    *stacksFusion;
	IBOutlet NSSlider       *sliderFusion;
	IBOutlet NSButton		*activatedFusion;
	IBOutlet NSPopUpButton  *popFusion, *popupRoi, *ReconstructionRoi;
	
	IBOutlet NSMatrix		*buttonToolMatrix;
	
	NSMutableArray			*fileList[ MAX4D];
    NSMutableArray          *pixList[ MAX4D], *roiList[ MAX4D], *copyRoiList[ MAX4D];
	NSData					*volumeData[ MAX4D];
	short					curMovieIndex, maxMovieIndex, orientationVector;
    NSToolbar               *toolbar;
	
	float					direction;
	
	float					factorPET2SUV;
	
	volatile float			loadingPercentage;
    
	volatile BOOL			ThreadLoadImage, stopThreadLoadImage;
	NSTimeInterval			loadingPauseDelay;
    BOOL                    FullScreenOn;
    NSWindow                *FullScreenWindow;
    NSWindow                *StartingWindow;
    NSView                  *contentView;
    
    NSTimer					*timer, *movieTimer, *timeriChat;
    NSTimeInterval			lastTime, lastTimeFrame;
	NSTimeInterval			lastMovieTime;
	
	NSMutableArray			*ROINamesArray;
	
	ThickSlabController		*thickSlab;
	
//	CurvedMPR				*curvedController;
	
	DICOMExport				*exportDCM;
	
	BOOL					windowWillClose;
	BOOL					postprocessed;
	
	NSRect					standardRect;
	
	// Brush ROI Filter
	IBOutlet NSWindow		*brushROIFilterOptionsWindow;
	IBOutlet NSSlider		*structuringElementRadiusSlider;
	IBOutlet NSTextField	*structuringElementRadiusTextField;
	IBOutlet NSButton		*brushROIFilterOptionsAllWithSameName;
	IBOutlet NSButton		*brushROIFilterOptionsOKButton;
	NSString				*morphoFunction;
	BOOL					morphoFunctionPreviewApplied;
	IBOutlet NSPopUpButton	*keyImagePopUpButton;
	
//	KeyObjectPopupController *keyObjectPopupController;
	BOOL					displayOnlyKeyImages;
	
	int						qt_to, qt_from, qt_interval, qt_dimension, current_qt_interval, qt_allViewers;
	
	IBOutlet NSView			*reportTemplatesView;
	IBOutlet NSImageView	*reportTemplatesImageView;
	IBOutlet NSPopUpButton	*reportTemplatesListPopUpButton;
	
	NSConditionLock			*processorsLock;
	
	IBOutlet NSWindow		*printWindow;
	IBOutlet NSMatrix		*printSelection;
	IBOutlet NSMatrix		*printFormat;
	IBOutlet NSSlider		*printInterval, *printFrom, *printTo;
	IBOutlet NSTextField	*printIntervalText, *printFromText, *printToText;
	IBOutlet NSBox			*printBox;
	IBOutlet NSMatrix		*printSettings;
	IBOutlet NSColorWell	*printColor;
	IBOutlet NSPopUpButton	*printLayout;
	IBOutlet NSTextField	*printText, *printPagesToPrint;
	
	NSMutableArray			*undoQueue, *redoQueue;
	
	BOOL					SyncButtonBehaviorIsBetweenStudies, titledGantry, updateTilingViews, stopViewFrameDidChangeNotification;
	
	volatile BOOL			checkEverythingLoaded;
	
	float					resampleRatio;
	
//	NSRect					savedWindowsFrame;
//	BOOL					windowIsMovedByTheUser;
	
	ViewerController		*registeredViewer;
	ViewerController        *blendedWindow;
	
	NSMutableArray			*retainedToolbarItems;
	
	BOOL					nonVolumicDataWarningDisplayed;
	
	IBOutlet NSView			*display12bitToolbarItemView;
	IBOutlet NSMatrix		*display12bitToolbarItemMatrix;
	NSTimer					*t12BitTimer;
	
	NSCalendarDate			*injectionDateTime;
	IBOutlet NSWindow		*injectionTimeWindow;
}
@property(retain) NSCalendarDate *injectionDateTime;
@property(readonly) short currentOrientationTool;
@property(readonly) volatile float loadingPercentage;
@property NSTimeInterval loadingPauseDelay;
@property(readonly) NSTimer	*timer;
@property(readonly) NSButton *keyImageCheck;
@property(readonly) NSSlider *speedSlider;

/** Accessors for plugins using blending window */
@property(readonly) NSWindow *blendingTypeWindow;
@property(readonly) NSButton *blendingTypeMultiply;
@property(readonly) NSButton *blendingTypeSubtract;
@property(readonly) NSSegmentedControl *blendingTypeRGB;
@property(readonly) NSPopUpButton *blendingPlugins;
@property(readonly) NSButton *blendingResample;

/** Return the 'dragged' window, the destination window is contained in the 'viewerController' object of the 'PluginFilter' object */
@property(retain) ViewerController *blendedWindow;

/** Array of all 2D Viewers */
+ (NSMutableArray*) getDisplayed2DViewers;
+ (NSMutableArray*) get2DViewers;
+ (NSArray*) getDisplayedSeries;
+ (BOOL) isFrontMost2DViewer: (NSWindow*) ww;
+ (ViewerController*) frontMostDisplayed2DViewer;
+ (void) closeAllWindows;

/**  Create a new 2D Viewer
* @param pixList Array of DCMPix objects
* @param fileList Array of files for DCMPix objects 
* @param volumeData NSData object containing the volume data 
*/
+ (ViewerController *) newWindow:(NSMutableArray*)pixList :(NSMutableArray*)fileList :(NSData*) volumeData;
+ (ViewerController *) newWindow:(NSMutableArray*)pixList :(NSMutableArray*)fileList :(NSData*) volumeData frame: (NSRect) frame;

/**  Create a new 2D Viewer
* @param pixList Array of DCMPix objects
* @param fileList Array of files for DCMPix objects 
* @param volumeData NSData object containing the volume data 
*/
- (ViewerController *) newWindow:(NSMutableArray*)pixList :(NSMutableArray*)fileList :(NSData*) volumeData;

/** Notifcation to close Viewer */
- (void) CloseViewerNotification: (NSNotification*) note;

/** Change Series 
* @param newPixList Array of DCMPix objects to used instead
* @param newDcmList Array of file strings
* @param newData NSData of new volume data
*/
- (void) replaceSeriesWith:(NSMutableArray*)newPixList :(NSMutableArray*)newDcmList :(NSData*) newData;

/** Return the 'dragged' window, the destination window is contained in the 'viewerController' object of the 'PluginFilter' object */
- (ViewerController*) blendedWindow;

/**  Display a Wait window with the message
* @param message  The message for the Wait window to display */
- (id) startWaitWindow :(NSString*) message;


/**  Display a Wait window with the message  progress length of max
* @param message  The message for the Wait window to display
* @param max  Progress bar max */
- (id) startWaitProgressWindow :(NSString*) message :(long) max;

/**  Increment the Wait window progress bar
* @param waitWindow  The Wait Window
* @param val  Amount to increment the Wait window 
*/
- (void) waitIncrementBy:(id) waitWindow :(long) val;


/** End the wait window */
- (void) endWaitWindow:(id) waitWindow;

/** Refresh the current displayed image */
- (void) needsDisplayUpdate;

/** Return the memory pointer that contains the ENTIRE series (a unique memory block for all images)  */
- (float*) volumePtr;
- (float*) volumePtr: (long) i;
- (NSData*)volumeData;
- (NSData*)volumeData:(long) i;

/**  Return the image pane object */
- (DCMView*) imageView;
- (NSArray*) imageViews;

/**  Return the array of DCMPix objects */
- (NSMutableArray*) pixList;
- (NSMutableArray*) pixList: (long) i;

/** Return the array of DicomImage objects */
- (NSMutableArray*) fileList;
- (NSMutableArray*) fileList: (long) i;

/** Return the array of ROI objects */
- (NSMutableArray*) roiList;
- (NSMutableArray*) roiList: (long) i;
- (void) setRoiList: (long) i array:(NSMutableArray*) a;

/**  Create a new MyPoint object */
- (MyPoint*) newPoint: (float) x :(float) y;

/** Create a new ROI object */
- (ROI*) newROI: (long) type;

/** Check if the ROI belongs to this viewer */
- (BOOL) containsROI:(ROI*)roi;

/** Are the data volumic: same height same width same orientation */
- (BOOL) isDataVolumic;
- (BOOL) isDataVolumicIn4D:(BOOL) check4D checkEverythingLoaded:(BOOL) c;
- (BOOL) isDataVolumicIn4D:(BOOL) check4D;
- (BOOL) isDataVolumicIn4D: (BOOL) check4D checkEverythingLoaded:(BOOL) c tryToCorrect: (BOOL) tryToCorrect;
- (void) displayAWarningIfNonTrueVolumicData;

/** Delete ALL ROI objects for  current series */
- (IBAction) roiDeleteAll:(id) sender;

/**  methods to access global variables */
+ (int) numberOf2DViewer;

/** Adds to undo queue
*  @param string  The type of undo
*  This method calls - (id) prepareObjectForUndo:(NSString*) string get the undo object
*/
- (void) addToUndoQueue:(NSString*) string;
- (void) removeLastItemFromUndoQueue;

/** Prepare for Undo
*  returns the undo object
*  @param string  The type of undo
*/
- (id) prepareObjectForUndo:(NSString*) string;

/** Redo
* Gets the last object in the redo queue
* and Redo action  */
- (IBAction) redo:(id) sender;

/** Undo
** Gets the last object in the undo queue 
*  Undo action*/
- (IBAction) undo:(id) sender;

/** Get path for current image */
- (void) updateRepresentedFileName;

/** Stops or aborts any open modal window */
- (IBAction) closeModal:(id) sender;

/** Brings ROI to front of ROI array for current image.
* If roi is in a group, the whole group is brought to the front
* @param roi The ROI that should be up front
*/
- (void)bringToFrontROI:(ROI*)roi;
- (void)sendToBackROI:(ROI*) roi;

/** Change fusion status
* Called by an action.
*/
- (void) activateFusion:(id) sender;

/** Action to Propagte current settings */
- (void) copySettingsToOthers: (id)sender;

/** Set the postprocessed flag */
- (void) setPostprocessed:(BOOL) v;
- (BOOL) isPostprocessed;

/** returns postprocessed status */
- (BOOL) postprocessed;

/** Apply the opacity setting
* @param str The name of the opacity setting.  Should be one of the menu item name from the opacity menu 
*/
- (void) ApplyOpacityString:(NSString*) str;

/** Refreshed window width and window level */
- (void) refresh;

/** Action to sset up non DICOM printing */
- (IBAction) setPagesToPrint:(id) sender;

/** Action to start printing.  Called when print window is ordered out */
- (IBAction) endPrint:(id) sender;

+ (int) getToolEquivalentToHotKey:(int) h;
+ (int) getHotKeyEquivalentToTool:(int) h;
//- (IBAction) startMSRG:(id) sender;
//- (IBAction) startMSRGWithAutomaticBounding:(id) sender;
//arg: this function will automatically scan the buffer to create a textured ROI (tPlain) for all slices
// param forValue: this param defines the region to extract in the stack buffer
- (void)addRoiFromFullStackBuffer:(unsigned char*)buff forSpecificValue:(unsigned char)value withColor:(RGBColor)aColor;
- (void)addRoiFromFullStackBuffer:(unsigned char*)buff forSpecificValue:(unsigned char)value withColor:(RGBColor)aColor withName:(NSString*)name;
//arg: Use this to extract all the rois from the
- (void)addRoiFromFullStackBuffer:(unsigned char*)buff;
- (void)addPlainRoiToCurrentSliceFromBuffer:(unsigned char*)buff;
- (void)addRoiFromFullStackBuffer:(unsigned char*)buff withName:(NSString*)name;
- (void)addPlainRoiToCurrentSliceFromBuffer:(unsigned char*)buff withName:(NSString*)name;
- (void)addPlainRoiToCurrentSliceFromBuffer:(unsigned char*)buff forSpecificValue:(unsigned char)value withColor:(RGBColor)aColor withName:(NSString*)name;
- (ROI*)addLayerRoiToCurrentSliceWithImage:(NSImage*)image referenceFilePath:(NSString*)path layerPixelSpacingX:(float)layerPixelSpacingX layerPixelSpacingY:(float)layerPixelSpacingY;
- (ROI*)createLayerROIFromROI:(ROI*)roi;
- (void)createLayerROIFromSelectedROI;
- (IBAction)createLayerROIFromSelectedROI:(id)sender;
- (NSLock*) roiLock;
- (void) brushTool:(id) sender;
- (IBAction) setButtonTool:(id) sender;
- (IBAction) shutterOnOff:(id) sender;
- (void) setLoadingPause:(BOOL) lp;
- (void) setImageIndex:(long) i;
- (void) setImage:(NSManagedObject*) image;
- (long) imageIndex;
- (IBAction) editSUVinjectionTime:(id)sender;
- (IBAction) ok:(id)sender;
- (IBAction) cancel:(id)sender;
- (void) viewerControllerInit;
- (IBAction) ConvertToRGBMenu:(id) sender;
- (BOOL) updateTilingViewsValue;
- (void) setUpdateTilingViewsValue:(BOOL) v;
- (IBAction) ConvertToBWMenu:(id) sender;
- (NSScreen*) get3DViewerScreen: (ViewerController*) v;
- (void) place3DViewerWindow:(NSWindowController*) viewer;
- (IBAction) export2PACS:(id) sender;
- (void) print:(id) sender;
- (IBAction) roiDeleteWithName:(NSString*) name;
- (IBAction) roiIntDeleteAllROIsWithSameName :(NSString*) name;
- (IBAction) roiDeleteAllROIsWithSameName:(id) sender;
- (IBAction) updateZVector:(id) sender;
- (void)displayDICOMOverlays: (id)sender;
- (IBAction)resampleDataBy2:(id)sender;
- (void) setStatusValue:(int) v;
- (BOOL)resampleDataBy2;
- (BOOL)resampleDataWithFactor:(float)factor;
- (BOOL)resampleDataWithXFactor:(float)xFactor yFactor:(float)yFactor zFactor:(float)zFactor;
+ (BOOL)resampleDataFromViewer:(ViewerController *)aViewer inPixArray:(NSMutableArray*)aPixList fileArray:(NSMutableArray*)aFileList data:(NSData**)aData withXFactor:(float)xFactor yFactor:(float)yFactor zFactor:(float)zFactor;
+ (BOOL)resampleDataFromViewer:(ViewerController *)aViewer inPixArray:(NSMutableArray*)aPixList fileArray:(NSMutableArray*)aFileList data:(NSData**)aData withXFactor:(float)xFactor yFactor:(float)yFactor zFactor:(float)zFactor movieIndex:(int) j;
+ (BOOL)resampleDataFromPixArray:(NSArray *)originalPixlist fileArray:(NSArray*)originalFileList inPixArray:(NSMutableArray*)aPixList fileArray:(NSMutableArray*)aFileList data:(NSData**)aData withXFactor:(float)xFactor yFactor:(float)yFactor zFactor:(float)zFactor;
- (IBAction) updateSUVValues:(id) sender;
- (IBAction) subCtrlOnOff:(id) sender;
- (IBAction) subCtrlNewMask:(id) sender;
- (IBAction) subCtrlOffset:(id) sender;
- (IBAction) subCtrlSliders:(id) sender;
- (int) threeTestsFivePosibilities: (int) f;
- (void) roiLoadFromSeries: (NSString*) filename;
- (void) offsetMatrixSetting: (int) twentyFiveCodes;
- (IBAction) mergeBrushROI: (id) sender;
- (IBAction) mergeBrushROI: (id) sender ROIs: (NSArray*) s ROIList: (NSMutableArray*) roiList;
- (IBAction) subSumSlider:(id) sender;
- (IBAction) subSharpen:(id) sender;
- (void) displayWarningIfGantryTitled;
- (void) contextualDictionaryPath:(NSString *)newContextualDictionaryPath;
- (NSString *) contextualDictionaryPath;
- (void) contextualMenuEvent:(id)sender;
- (IBAction) setAxialOrientation:(id) sender;
- (IBAction) reSyncOrigin:(id) sender;
- (void) loadROI:(long) mIndex;
- (void) saveROI:(long) mIndex;
- (void) setMatrixVisible: (BOOL) visible;
- (id) findPlayStopButton;
- (IBAction)setKeyImage:(id)sender;
- (IBAction) roiSelectDeselectAll:(id) sender;
- (BOOL) FullScreenON;
- (void) setROITool:(id) sender;
- (void) setROIToolTag:(int) roitype;
- (void) changeImageData:(NSMutableArray*)f :(NSMutableArray*)d :(NSData*) v :(BOOL) applyTransition;
- (IBAction) loadSerie:(id) sender;
- (IBAction) loadPatient:(id) sender;
- (void) loadSeries:(NSNumber*) t;
- (void) offFullScreen;
- (float) frame4DRate;
- (long) maxMovieIndex;
- (NSSlider*) moviePosSlider;
- (NSSlider*) sliderFusion;
- (IBAction) convMatrixAction:(id)sender;
- (IBAction) changeMatrixSize:(id) sender;
- (IBAction) computeSum:(id) sender;
- (IBAction) endNameWLWW:(id) sender;
- (IBAction) endSetWLWW:(id) sender;
- (IBAction) updateSetWLWW:(id) sender;
- (IBAction) endConv:(id) sender;
- (IBAction) endCLUT:(id) sender;
- (IBAction) endBlendingType:(id) sender;
- (IBAction) endQuicktime:(id) sender;
- (void) setDefaultTool:(id) sender;
- (OSErr)getFSRefAtPath:(NSString*)sourceItem ref:(FSRef*)sourceRef;
- (id) viewCinit:(NSMutableArray*)f :(NSMutableArray*) d :(NSData*) v;
- (id) initWithPix:(NSMutableArray*)f withFiles:(NSMutableArray*) d withVolume:(NSData*) v;
- (void) speedSliderAction:(id) sender;
- (void) setupToolbar;
- (NSToolbar*) toolbar;
- (void) PlayStop:(id) sender;
- (short) getNumberOfImages;
- (float) frameRate;
- (void) adjustSlider;
- (void) sliderFusionAction:(id) sender;
- (void) popFusionAction:(id) sender;
- (void) propagateSettings;
- (void) setCurWLWWMenu:(NSString*)s ;
- (float) highLighted;
- (void) setHighLighted: (float) b;
- (void) syncThumbnails;
- (void) checkBuiltMatrixPreview;

/** Used to determine in the Window Controller is a 2D Viewer.
* Always return YES
*/
- (BOOL) is2DViewer;

/** String for the currently selected CLUT menu item */
- (NSString*) curCLUTMenu;

/** String for the currently selected WLWW mewnu item */
- (NSString*) curWLWWMenu;

/** String for the currently selected Opacity menu item */
- (NSString*) curOpacityMenu;


/** Flag to indicate the the window will close */
- (BOOL) windowWillClose;


- (void) ApplyCLUTString:(NSString*) str;
- (NSSlider*) blendingSlider;
- (void) blendingSlider:(id) sender;
- (void) blendingMode:(id) sender;
- (ViewerController*) blendingController;
- (void)blendWithViewer:(ViewerController *)bc blendingType:(int)blendingType;
- (void)blendingSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)computeContextualMenu;
- (void)computeContextualMenuForROI:(ROI*)roi;

/** Modality of the study */
- (NSString*) modality;
- (void) selectFirstTilingView;
- (NSString*) studyInstanceUID;
- (void) addMovieSerie:(NSMutableArray*)f :(NSMutableArray*)d :(NSData*) v;
- (void) startLoadImageThread;
- (void) moviePosSliderAction:(id) sender;
- (void) movieRateSliderAction:(id) sender;
- (void) MoviePlayStop:(id) sender;
- (void) MovieStop:(id) sender;
- (BOOL)isPlaying4D;
- (void) checkEverythingLoaded;
- (BOOL) isEverythingLoaded;
- (IBAction) roiSetPixelsCheckButton:(id) sender;
- (IBAction) roiSetPixelsSetup:(id) sender;
- (IBAction) roiSetPixels:(ROI*)aROI :(short)allRois :(BOOL)propagateIn4D :(BOOL)outside :(float)minValue :(float)maxValue :(float)newValue;
- (IBAction) roiSetPixels:(ROI*)aROI :(short)allRois :(BOOL) propagateIn4D :(BOOL)outside :(float)minValue :(float)maxValue :(float)newValue :(BOOL) revert;
- (IBAction) roiSetPixels:(id) sender;
- (IBAction) roiPropagateSetup: (id) sender;
- (IBAction) roiPropagate:(id) sender;
- (void) loadSeriesUp;
- (void) loadSeriesDown;
- (void) showWindowTransition;
- (float) computeInterval;
+ (float) computeIntervalForDCMPix: (DCMPix*) p1 And: (DCMPix*) p2;
- (float) computeIntervalFlipNow: (NSNumber*) flipNowNumber;
- (void) computeIntervalAsync;
- (IBAction) endThicknessInterval:(id) sender;
- (void) SetThicknessInterval:(id) constructionType;
- (IBAction) blendWindows:(id) sender;

/** Action to open the OrthogonalMPRViewer */
- (IBAction) orthogonalMPRViewer:(id) sender;

- (void) showCurrentThumbnail:(id) sender;

#ifndef OSIRIX_LIGHT
/** ReSort the images displayed according to IMAGE Table field */
- (BOOL) sortSeriesByValue: (NSString*) key ascending: (BOOL) ascending;

/** ReSort the images displayed according to this group/element */
- (BOOL) sortSeriesByDICOMGroup: (int) gr element: (int) el;

/** Action to open the EndoscopyViewer */
- (IBAction) endoscopyViewer:(id) sender;

/** Action to open VRViewer (Volume Rendering) */
- (IBAction) VRViewer:(id) sender;

/** Action to open SRViewer (Surface Rendering) */
- (IBAction) SRViewer:(id) sender;
#endif

/** Action to export as JPEG */
- (void) exportJPEG:(id) sender;

/** Notification to close all windows */
- (NSMutableArray*) generateROINamesArray;
- (ThickSlabController*) thickSlabController;
- (IBAction) AddOpacity:(id) sender;
- (IBAction) endOpacity:(id) sender;
- (IBAction) updateImage:(id) sender;
//- (IBAction) HuVRViewer:(id) sender;
- (IBAction) clutAction:(id)sender;
- (void) tileWindows;
-(IBAction) export2iPhoto:(id) sender;
-(IBAction) PagePadCreate:(id) sender;
- (void) exportQuicktime:(id) sender;
- (IBAction) exportQuicktimeSlider:(id) sender;
- (IBAction) exportDICOMSlider:(id) sender;
- (IBAction) exportDICOMAllViewers:(id) sender;
- (IBAction) setComments:(id) sender;
- (IBAction) setStatus:(id) sender;
- (IBAction) endSetComments:(id) sender;
- (void) setMovieIndex: (short) i;
//- (void) setCurvedController: (CurvedMPR*) cmpr;
//- (CurvedMPR*) curvedController;
//- (IBAction) setCurvedMPRslider:(id) sender;
//- (IBAction) endCurvedMPR:(id) sender;
- (IBAction) resetImage:(id) sender;
+ (NSArray*) defaultROINames;
+ (void) setDefaultROINames: (NSArray*) names;
#ifndef OSIRIX_LIGHT
- (IBAction) endExportDICOMFileSettings:(id) sender;
- (IBAction) exportAllImages:(NSString*) seriesName;
- (float) computeVolume:(ROI*) selectedRoi points:(NSMutableArray**) pts error:(NSString**) error;
- (float) computeVolume:(ROI*) selectedRoi points:(NSMutableArray**) pts generateMissingROIs:(BOOL) generateMissingROIs error:(NSString**) error;
- (float) computeVolume:(ROI*) selectedRoi points:(NSMutableArray**) pts generateMissingROIs:(BOOL) generateMissingROIs generatedROIs:(NSMutableArray*) generatedROIs computeData:(NSMutableDictionary*) data error:(NSString**) error;
#endif
- (IBAction) keyImageCheckBox:(id) sender;
- (IBAction) keyImageDisplayButton:(id) sender;
- (void) adjustKeyImage;
- (IBAction) saveWindowsState:(id) sender;
- (IBAction) loadWindowsState:(id) sender;
- (IBAction) resetWindowsState:(id) sender;
- (void) buildMatrixPreview;
- (void) buildMatrixPreview: (BOOL) showSelected;
- (void) matrixPreviewSelectCurrentSeries;
- (void) autoHideMatrix;
- (void) exportQuicktimeIn:(long) dimension :(long) from :(long) to :(long) interval;
- (void) exportQuicktimeIn:(long) dimension :(long) from :(long) to :(long) interval :(BOOL) allViewers;
- (void) exportQuicktimeIn:(long) dimension :(long) from :(long) to :(long) interval :(BOOL) allViewers mode:(NSString*) mode;
- (IBAction) endExportImage: (id) sender;
- (IBAction) setCurrentPosition:(id) sender;
- (IBAction) setCurrentdcmExport:(id) sender;
- (IBAction) endDisplaySUV:(id) sender;
- (IBAction) endRoiRename:(id) sender;
- (IBAction) roiRename:(id) sender;
- (void) SyncSeries:(id) sender;

- (NSArray*)roisWithName:(NSString*)name;
- (NSArray*)roisWithName:(NSString*)name in4D:(BOOL)in4D;
- (NSArray*)roisWithName:(NSString*)name forMovieIndex:(int)m;

- (NSArray*) roisWithComment: (NSString*) comment;
- (NSArray*) roiNames;
- (void) deleteROI: (ROI*) roi;
- (void) deleteSeriesROIwithName: (NSString*) name;
- (void) renameSeriesROIwithName: (NSString*) name newName:(NSString*) newName;
- (void)setStandardRect:(NSRect)rect;
- (void)setWindowFrame:(NSRect)rect;
- (void)setWindowFrame:(NSRect)rect showWindow:(BOOL) showWindow;
- (void)setWindowFrame:(NSRect)rect showWindow:(BOOL) showWindow animate: (BOOL) animate;

- (void) revertSeries:(id) sender;
- (void) executeRevert;
- (NSImage*) imageForROI: (int) i;
- (void) ActivateBlending:(ViewerController*) bC;
- (void) setFusionMode:(long) m;
- (short) curMovieIndex;
#ifndef OSIRIX_LIGHT
- (id) findiChatButton;
- (IBAction) Panel3D:(id) sender;
#endif
- (void) convertPETtoSUV;
- (IBAction) fullScreenMenu:(id) sender;
-(int) imageIndexOfROI:(ROI*) c;
- (void)exportTextFieldDidChange:(NSNotification *)note;
- (short) orientationVector;
- (short) orthogonalOrientation;
// functions s that plugins can also play with globals
+ (ViewerController *) draggedController;
+ (void) setDraggedController:(ViewerController *) controller;
- (void) clear8bitRepresentations;
-(void) ApplyConvString:(NSString*) str;
- (void)checkView:(NSView *)aView :(BOOL) OnOff;
- (IBAction) applyConvolutionOnSource:(id) sender;
- (float) factorPET2SUV;
- (IBAction) flipDataSeries: (id) sender;
- (void) roiSetStartScheduler:(NSMutableArray*) roiToProceed;
- (void)setToolbarReportIconForItem:(NSToolbarItem *)item;
- (void)updateReportToolbarIcon:(NSNotification *)note;
- (IBAction) setOrientationTool:(id) sender;
- (void) setWindowTitle:(id) sender;
- (IBAction) printSlider:(id) sender;
- (void) setConv:(short*) matrix :(short) size :(short) norm;
-(BOOL) checkFrameSize;
- (IBAction) vertFlipDataSet:(id) sender;
- (IBAction) horzFlipDataSet:(id) sender;
- (void) rotateDataSet:(int) constant;
- (void) SetSyncButtonBehavior:(id) sender;
- (IBAction) roiDeleteGeneratedROIsForName:(NSString*) name;
- (IBAction) roiDeleteGeneratedROIs:(id) sender;
- (ROI*)selectedROI;
- (NSMutableArray*) selectedROIs;
- (ViewerController*) registeredViewer;
- (void) setRegisteredViewer: (ViewerController*) viewer;
- (void)setMode:(long)mode toROIGroupWithID:(NSTimeInterval)groupID;
- (void)selectROI:(ROI*)roi deselectingOther:(BOOL)deselectOther;
- (void)deselectAllROIs;
- (void) refreshToolbar;
- (void) redrawToolbar;
- (void) reloadAnnotations;
- (NSScrollView*) previewMatrixScrollView;

#pragma mark-
#pragma mark Brush ROI Filters

/** Applies the selected Brush ROI morpho filter
* @param  rois  ROI array to filter
* @param action The filter to apply: Possible values are: open, close, erode, dilate
* @param radius structuringElementRadius for the filter
* @param sendNotification Will post an OsirixROIChangeNotification notification if YES
*/
#ifndef OSIRIX_LIGHT
- (void) applyMorphology: (NSArray*) rois action:(NSString*) action	radius: (long) radius sendNotification: (BOOL) sendNotification;

/** Set the structuring radius for the brush ROI morpho filter */
- (IBAction) setStructuringElementRadius: (id) sender;


/** Action to start filter for the selected brush ROI using the filter selected with
- (IBAction) morphoSelectedBrushROI: (id) sender
*  Filters are: erode, dilate, open, close 
*/
- (IBAction) morphoSelectedBrushROIWithRadius: (id) sender;

/** Select filter for the selected brush ROI 
*  Filters are: erode, dilate, open, close 
*/
- (IBAction) morphoSelectedBrushROI: (id) sender;
#endif

/** Create a new ROI between two ROI
* Converts both ROIs into polygons, after a marching square isocontour
* @param a First ROI
* @param b Second ROI
* @param ratio Weighting used to morph between the two
*/
- (ROI*) roiMorphingBetween:(ROI*) a and:(ROI*) b ratio:(float) ratio;

/** Convert Polygon ROI to a Brush ROI.
* @param selectedROI The ROI to convert
*/
- (ROI*) convertPolygonROItoBrush:(ROI*) selectedROI;

/** Convert Brush ROI to a Polygon ROI. Returns converted ROI
* @param selectedROI The ROI to convert
* @param numPoints Number of points for the polygon
*/
- (ROI*) convertBrushROItoPolygon:(ROI*) selectedROI numPoints: (int) numPoints;

#pragma mark-
#pragma mark Registration

/** Returns an NSArray of all t2DPoint type ROI*/
- (NSMutableArray*) point2DList;


/** Computes registration between the current Viewer and another ViewerController
*  A HornRegistatration is first performed
*  ITKTransform is used for the transform.
*  At least three t2DPoint type ROI to compute
*  Each point on the moving viewer needs a twin on the fixed viewer.
*  Two points are twin brothers if and only if they have the same name.
*/
#ifndef OSIRIX_LIGHT
- (void) computeRegistrationWithMovingViewer:(ViewerController*) movingViewer;
#endif

/** Returns a new viewer with the current series resampled to match the Orientation of series in the other viewer
*  Both series must be from the same study to insure matching imageOrientationPatient and imagePositionPatient
*  @param movingViewer  The ViewerController to resample the series to match
*/
#ifndef OSIRIX_LIGHT
- (ViewerController*) resampleSeries:(ViewerController*) movingViewer;
#endif

#pragma mark-
#pragma mark Key Objects

///** Creates a Key Object note for the current key Images */
//- (IBAction)createKeyObjectNote:(id)sender;
//
///** End sheet method for creating key Object notes
//* Called internally 
//*/
//- (void)keyObjectSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode  contextInfo:(id)contextInfo;


/**  return flag indicating whether only the key images are being displayed */
- (BOOL)displayOnlyKeyImages;


/** Returns whether the image at the index is a key image
* @param index of image to check
*/
- (BOOL)isKeyImage:(int)index;




#pragma mark-
#pragma mark Convience methods for accessing values in the current imageView
/** Current ImageView window width */
-(float)curWW;

/** Current ImageView window level */
-(float)curWL;

/** Set window width and window level for current ImageView */
- (void)setWL:(float)wl  WW:(float)ww;

/** Current ImageView horizontal flip */
- (BOOL)xFlipped;

/** Current ImageView vertical flip */
- (BOOL)yFlipped;

/** Current ImageView rotation */
- (float)rotation;

/** Set rotation for current ImageView */
- (void)setRotation:(float)rotation;

/** Set origin for current ImageView */
- (void)setOrigin:(NSPoint) o;

/** Current ImageView zoom */
- (float)scaleValue;

/** Set zoom for current ImageView */
- (void)setScaleValue:(float)scaleValue;

/** Set vertical flip for current ImageView */
- (void)setYFlipped:(BOOL) v;

/** Set horizontal flip for current ImageView */
- (void)setXFlipped:(BOOL) v;


// Opening 3D Viewers
#pragma mark-
#pragma mark 3D Viewers
/** Returns the OrthogonalMPRViewer for this ViewerController; creating one if necessary */
- (OrthogonalMPRViewer *)openOrthogonalMPRViewer;

#ifndef OSIRIX_LIGHT

/** Returns the VRController for this ViewerController; creating one if necessary
* See VRController for modes
 */
- (VRController *)openVRViewerForMode:(NSString *)mode;

/** Returns the OrthogonalMPRPETCTViewer for this ViewerController; creating one if necessary */
- (OrthogonalMPRPETCTViewer *)openOrthogonalMPRPETCTViewer;

/** Returns the EndoscopyViewer for this ViewerController; creating one if necessary */
- (EndoscopyViewer *)openEndoscopyViewer;

/** Returns the SRController for this ViewerController; creating one if necessary */
- (SRController *)openSRViewer;

/** Returns the MPRController for this ViewerController; creating one if necessary */

- (MPRController *)openMPRViewer;
- (IBAction)mprViewer:(id)sender;

/** Action to open the CPRViewer */
- (id)openCPRViewer;
- (IBAction)cprViewer:(id)sender;
#endif

/** Current SeriesView */
- (SeriesView *) seriesView;

/** Tiles the DCMView in the SeriesView of the current ViewerController 
*  This tiles images within a series.
* @param rows number of rows to tile
* @param columns number of columns
*/
- (void)setImageRows:(int)rows columns:(int)columns;

/** Tile the images within the active ViewerController
* Tiling based on tag of menu item
* 16 possible arrangements
* rows = (tag / 4) + 1;
* columns =  (tag %  4) + 1; 
* - (void)setImageRows:(int)rows columns:(int)columns then called
*/
- (IBAction)setImageTiling: (id)sender;

#pragma mark-
#pragma mark Calcium scoring
/** Deprecated
* Calcium Scoring moved to a plugin
*/
#ifndef OSIRIX_LIGHT
- (IBAction)calciumScoring:(id)sender;
#endif

#pragma mark-
#pragma mark Centerline
/** Nonfunctional
* Centerline only works in Endoscopy Mode 
*/
//- (IBAction)centerline: (id)sender;

#pragma mark-
#pragma mark ROI Grouping
/**  Group selected ROI together */
- (IBAction)groupSelectedROIs:(id)sender;
/** Ungroup ROI */
- (IBAction)ungroupSelectedROIs:(id)sender;

/**  Lock selected ROI together */
- (IBAction) lockSelectedROIs:(id)sender;
/** Unlock ROI */
- (IBAction) unlockSelectedROIs:(id)sender;

- (IBAction) makeSelectedROIsUnselectable:(id)sender;
- (IBAction) makeAllROIsSelectable:(id)sender;

- (void) turnOffSyncSeriesBetweenStudies:(id) sender;

#ifndef OSIRIX_LIGHT
- (NSDictionary*) exportDICOMFileInt:(int)screenCapture withName:(NSString*)name;
- (NSDictionary*) exportDICOMFileInt:(int)screenCapture withName:(NSString*)name allViewers: (BOOL) allViewers;
#endif

#pragma mark-
#pragma mark 12 Bit
- (IBAction)enable12Bit:(id)sender;

#pragma mark-
#pragma mark Navigator
- (IBAction)navigator:(id)sender;
- (void)updateNavigator;

- (IBAction)threeDPanel:(id)sender;

@end