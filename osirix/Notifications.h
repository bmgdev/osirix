/*=========================================================================
  Program:   OsiriX

  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - GPL
  
  See http://www.osirix-viewer.com/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

#import <Cocoa/Cocoa.h>

extern NSString* OsirixUpdateWLWWMenuNotification;
extern NSString* OsirixChangeWLWWNotification;
extern NSString* OsirixROIChangeNotification;
extern NSString* OsirixCloseViewerNotification;
extern NSString* OsirixUpdate2dCLUTMenuNotification;
extern NSString* OsirixUpdate2dWLWWMenuNotification;
extern NSString* OsirixLLMPRResliceNotification;
extern NSString* OsirixROIVolumePropertiesChangedNotification;
extern NSString* OsirixVRViewDidBecomeFirstResponderNotification;
extern NSString* OsirixUpdateVolumeDataNotification;
extern NSString* OsirixRevertSeriesNotification;
extern NSString* OsirixOpacityChangedNotification;
extern NSString* OsirixDefaultToolModifiedNotification;
extern NSString* OsirixDefaultRightToolModifiedNotification;
extern NSString* OsirixUpdateConvolutionMenuNotification;
extern NSString* OsirixCLUTChangedNotification;
extern NSString* OsirixUpdateCLUTMenuNotification;
extern NSString* OsirixUpdateOpacityMenuNotification;
extern NSString* OsirixRecomputeROINotification;
extern NSString* OsirixStopPlayingNotification;
extern NSString* OsirixChatBroadcastNotification;
extern NSString* OsirixSyncSeriesNotification;
extern NSString* OsirixReportModeChangedNotification;
extern NSString* OsirixDeletedReportNotification;
extern NSString* OsirixServerArrayChangedNotification;
extern NSString* OsirixGLFontChangeNotification;
extern NSString* OsirixAddToDBNotification;
extern NSString* OsirixNewStudySelectedNotification;
extern NSString* OsirixDidLoadNewObjectNotification;
extern NSString* OsirixRTStructNotification;
extern NSString* OsirixAlternateButtonPressedNotification;
extern NSString* OsirixROISelectedNotification;
extern NSString* OsirixRemoveROINotification;
extern NSString* OsirixROIRemovedFromArrayNotification;
extern NSString* OsirixChangeFocalPointNotification;
extern NSString* OsirixWindow3dCloseNotification;
extern NSString* OsirixDisplay3dPointNotification;
extern NSString* OsirixPluginDownloadInstallDidFinishNotification;
extern NSString* OsirixXMLRPCMessageNotification;
extern NSString* OsirixDragMatrixImageMovedNotification;
extern NSString* OsirixNotification;
extern NSString* OsiriXFileReceivedNotification;
extern NSString* OsirixDCMSendStatusNotification;
extern NSString* OsirixDCMUpdateCurrentImageNotification;
extern NSString* OsirixDCMViewIndexChangedNotification;
extern NSString* OsirixRightMouseUpNotification;
extern NSString* OsirixMouseDownNotification;
extern NSString* OsirixVRCameraDidChangeNotification;
extern NSString* OsirixSyncNotification;
extern NSString* OsirixAddROINotification;
extern NSString* OsirixRightMouseDownNotification;
extern NSString* OsirixRightMouseDraggedNotification;
extern NSString* OsirixLabelGLFontChangeNotification;
extern NSString* OsirixDrawTextInfoNotification;
extern NSString* OsirixDrawObjectsNotification;
extern NSString* OsirixDCMViewDidBecomeFirstResponderNotification;
extern NSString* OsirixPerformDragOperationNotification;
extern NSString* OsirixViewerWillChangeNotification;
extern NSString* OsirixViewerDidChangeNotification;
extern NSString* OsirixUpdateViewNotification;
extern NSString* KFSplitViewDidCollapseSubviewNotification;
extern NSString* KFSplitViewDidExpandSubviewNotification;
extern NSString* BLAuthenticatedNotification;
extern NSString* BLDeauthenticatedNotification;

/**
 * OsirixPopulatedContextualMenuNotification
 * object: NSMenu*
 * userInfo:
 *  - key [ViewerController className]
 *		the ViewerController the rightclick occurred in
 *	- key [ROI className], optional
 *		the rightclicked ROI
 **/
extern NSString* OsirixPopulatedContextualMenuNotification;
