//
//  CIALayoutController.m
//  ImageAnnotations
//
//  Created by joris on 25/06/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import "CIALayoutControllerDCMTK.h"
#import "CIALayoutController.h"
#import "CIADICOMField.h"

#import "OSICustomImageAnnotations.h"

@implementation CIALayoutController

- (id)initWithWindow:(NSWindow *)window
{
	NSLog(@"CIALayoutController init");
	self = [super initWithWindow:window];
	if (self != nil)
	{
		annotationsArray = [[NSMutableArray array] retain];
		DICOMFieldsArray = [[NSMutableArray array] retain];
		DICOMFieldsTitlesArray = [[NSMutableArray array] retain];
		databaseStudyFieldsArray = [[NSMutableArray array] retain];
		databaseSeriesFieldsArray = [[NSMutableArray array] retain];
		databaseImageFieldsArray = [[NSMutableArray array] retain];
		selectedAnnotation = nil;
		annotationNumber = 1;
		
		if([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CUSTOM_IMAGE_ANNOTATIONS"])
			annotationsLayoutDictionary = [[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CUSTOM_IMAGE_ANNOTATIONS"]] retain];
		else
			annotationsLayoutDictionary = [[NSMutableDictionary dictionary] retain];
			
		currentModality = @"All";
				
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationMouseDragged:) name:@"CIAAnnotationMouseDraggedNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationMouseDown:) name:@"CIAAnnotationMouseDownNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationMouseUp:) name:@"CIAAnnotationMouseUpNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:@"NSControlTextDidChangeNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidBeginEditing:) name:@"NSControlTextDidBeginEditingNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeSelection:) name:@"NSTextViewDidChangeTypingAttributesNotification" object:nil];
	}
	return self;
}

- (void)awakeFromNib
{
NSLog(@"CIALayoutController awakeFromNib");
	int i;
	
//	NSArray *modalities = [NSArray arrayWithObjects:NSLocalizedString(@"All", nil), NSLocalizedString(@"CR", nil), NSLocalizedString(@"CT", nil), NSLocalizedString(@"DX", nil), NSLocalizedString(@"ES", nil), NSLocalizedString(@"MG", nil), NSLocalizedString(@"MR", nil), NSLocalizedString(@"NM", nil), NSLocalizedString(@"OT", nil),NSLocalizedString(@"PT", nil),NSLocalizedString(@"RF", nil),NSLocalizedString(@"SC", nil),NSLocalizedString(@"US", nil),NSLocalizedString(@"XA", nil), nil];
//	
//	[modalitiesPopUpButton removeAllItems];
//	
//	for (i=0; i<[modalities count]; i++)
//	{
//		[modalitiesPopUpButton addItemWithTitle:[modalities objectAtIndex:i]];
//	}

	[[[prefPane contentTokenField] cell] setWraps:YES];
	[[prefPane dicomNameTokenField] setTokenStyle:NSPlainTextTokenStyle];

	[[prefPane contentTokenField] setDelegate:self];

	// DICOM popup button
	[self prepareDICOMFieldsArrays];

	NSMenu *DICOMFieldsMenu = [[prefPane DICOMFieldsPopUpButton] menu];
	[DICOMFieldsMenu setAutoenablesItems:NO];
	
	for (i=0; i<[[DICOMFieldsMenu itemArray] count]; i++)
		[DICOMFieldsMenu removeItemAtIndex:i];
	
	NSMenuItem *item;
	item = [[NSMenuItem alloc] init];
	[item setTitle:@"DICOM Fields"];
	[item setEnabled:NO];
	[DICOMFieldsMenu addItem:item];
	for (i=0; i<[DICOMFieldsArray count]; i++)
	{
		item = [[NSMenuItem alloc] init];
		[item setTitle:[[DICOMFieldsArray objectAtIndex:i] title]];
		[item setRepresentedObject:[DICOMFieldsArray objectAtIndex:i]];
		[DICOMFieldsMenu addItem:item];
		[item release];
	}
	
	[[prefPane DICOMFieldsPopUpButton] setMenu:DICOMFieldsMenu];
	
	// Database popup button
	[self prepareDatabaseFields];
	
	NSMenu *databaseFieldsMenu = [[prefPane databaseFieldsPopUpButton] menu];
	[databaseFieldsMenu setAutoenablesItems:NO];

	for (i=0; i<[[databaseFieldsMenu itemArray] count]; i++)
		[databaseFieldsMenu removeItemAtIndex:i];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:@"Study level"];
	[item setEnabled:NO];
	[databaseFieldsMenu addItem:item];
	for (i=0; i<[databaseStudyFieldsArray count]; i++)
	{
		item = [[NSMenuItem alloc] init];
		[item setTitle:[NSString stringWithFormat:@"\t%@",[databaseStudyFieldsArray objectAtIndex:i]]];
		[item setRepresentedObject:[NSString stringWithFormat:@"study.%@",[databaseStudyFieldsArray objectAtIndex:i]]];
		[databaseFieldsMenu addItem:item];
		[item release];
	}

	[databaseFieldsMenu addItem:[NSMenuItem separatorItem]];	
	item = [[NSMenuItem alloc] init];
	[item setTitle:@"Series level"];
	[item setEnabled:NO];
	[databaseFieldsMenu addItem:item];
	for (i=0; i<[databaseSeriesFieldsArray count]; i++)
	{
		item = [[NSMenuItem alloc] init];
		[item setTitle:[NSString stringWithFormat:@"\t%@",[databaseSeriesFieldsArray objectAtIndex:i]]];
		[item setRepresentedObject:[NSString stringWithFormat:@"series.%@",[databaseSeriesFieldsArray objectAtIndex:i]]];
		[databaseFieldsMenu addItem:item];
		[item release];
	}
	
	[databaseFieldsMenu addItem:[NSMenuItem separatorItem]];
	item = [[NSMenuItem alloc] init];
	[item setTitle:@"Image level"];
	[item setEnabled:NO];
	[databaseFieldsMenu addItem:item];
	for (i=0; i<[databaseImageFieldsArray count]; i++)
	{
		item = [[NSMenuItem alloc] init];
		[item setTitle:[NSString stringWithFormat:@"\t%@",[databaseImageFieldsArray objectAtIndex:i]]];
		[item setRepresentedObject:[NSString stringWithFormat:@"image.%@",[databaseImageFieldsArray objectAtIndex:i]]];
		[databaseFieldsMenu addItem:item];
		[item release];
	}
	
	// Specials popup button
	NSMenu *specialFieldsMenu = [[prefPane specialFieldsPopUpButton] menu];

	for (i=0; i<[[specialFieldsMenu itemArray] count]; i++)
		[specialFieldsMenu removeItemAtIndex:i];

	NSMutableArray *fields = [self specialFieldsTitles];

	for (i=0; i<[fields count]; i++)
	{
		item = [[NSMenuItem alloc] init];
		[item setTitle:[fields objectAtIndex:i]];
		[item setRepresentedObject:[fields objectAtIndex:i]];
		[specialFieldsMenu addItem:item];
		[item release];
	}

	[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
	[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
	[self setCustomDICOMFieldEditingEnable:NO];
	[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
	[[prefPane specialFieldsPopUpButton] setEnabled:NO];
	[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
	[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];
	
	[self loadAnnotationLayoutForModality:currentModality];
}

- (void)dealloc
{
	NSLog(@"CIALayoutController dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[annotationsArray release];
	[DICOMFieldsArray release];
	[DICOMFieldsTitlesArray release];
	[databaseStudyFieldsArray release];
	[databaseSeriesFieldsArray release];
	[databaseImageFieldsArray release];
	[annotationsLayoutDictionary release];
	[super dealloc];
}

- (IBAction)addAnnotation:(id)sender;
{
	NSPoint center = NSMakePoint(NSMidX([layoutView bounds]), NSMidY([layoutView bounds]));
	CIAAnnotation *anAnnotation = [[CIAAnnotation alloc] initWithFrame:NSMakeRect(center.x - 75.0/2.0, center.y - 11, 75, 22)];

	if([annotationsArray count]==0) annotationNumber = 1;
	[anAnnotation setTitle:[NSString stringWithFormat:@"%@ %d", [anAnnotation title], annotationNumber++]];

	[self selectAnnotation:anAnnotation];
	[annotationsArray addObject:anAnnotation];
	[layoutView addSubview:anAnnotation];
	[layoutView setNeedsDisplay:YES];
	[anAnnotation release];
	[self setCustomDICOMFieldEditingEnable:YES];
}

- (IBAction)removeAnnotation:(id)sender;
{
	if(selectedAnnotation)
	{
		CIAPlaceHolder *placeHolder = [selectedAnnotation placeHolder];
	
		[annotationsArray removeObject:selectedAnnotation];
		[selectedAnnotation removeFromSuperview];
		[layoutView setNeedsDisplay:YES];

		if([selectedAnnotation placeHolder])
		{
			[placeHolder setHasFocus:NO];
			[placeHolder removeAnnotation:selectedAnnotation];
			[placeHolder updateFrameAroundAnnotations];
			[placeHolder alignAnnotations];
			[layoutView setNeedsDisplay:YES];
		}
		
		selectedAnnotation = nil;
		[[prefPane titleTextField] setStringValue:@""];
		[[prefPane contentTokenField] setStringValue:@""];
		
		[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
		[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
		[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
		[[prefPane specialFieldsPopUpButton] setEnabled:NO];
		[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
		[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	unichar c = [[theEvent characters] characterAtIndex:0];
	if(c==NSDeleteCharacter)
	{
		[self removeAnnotation:self];
		return;
	}
	[super keyDown:theEvent];
}

- (IBAction)setTitle:(id)sender;
{
	if(selectedAnnotation)
	{
		[selectedAnnotation setTitle:[sender stringValue]];
		
		[[selectedAnnotation placeHolder] updateFrameAroundAnnotations];
		[layoutView updatePlaceHolderOrigins];
		[[selectedAnnotation placeHolder] alignAnnotations];
						
		[layoutView setNeedsDisplay:YES];
	}
}

- (void)annotationMouseDragged:(NSNotification *)aNotification;
{
	CIAAnnotation *annotation = (CIAAnnotation*)[aNotification object];
	if([annotation placeHolder])[[annotation placeHolder] removeAnnotation:annotation];

	NSArray *placeHolders = [layoutView placeHolderArray];	
	int i;
	for (i=0; i<[placeHolders count]; i++)
	{
		[[placeHolders objectAtIndex:i] alignAnnotations];
		[[placeHolders objectAtIndex:i] updateFrameAroundAnnotations];
		[[placeHolders objectAtIndex:i] alignAnnotations];
		[layoutView setNeedsDisplay:YES];
	}
	
	[self highlightPlaceHolderForAnnotation:annotation];
}

- (void)annotationMouseDown:(NSNotification *)aNotification;
{
	CIAAnnotation *annotation = (CIAAnnotation*)[aNotification object];
	[self selectAnnotation:annotation];
	[self highlightPlaceHolderForAnnotation:annotation];
}

- (void)annotationMouseUp:(NSNotification *)aNotification;
{
	CIAAnnotation *annotation = (CIAAnnotation*)[aNotification object];

	BOOL annotationOutOfPlaceHolder = YES;
	
	NSArray *placeHolders = [layoutView placeHolderArray];
	CIAPlaceHolder *currentPlaceHolder;
	int i;
	for (i=0; i<[placeHolders count]; i++)
	{
		currentPlaceHolder = [placeHolders objectAtIndex:i];
		if([currentPlaceHolder hasFocus])
		{
			// if current place holder contains annotation, we are going to insert the new annotation inbetween the other
			int index=-1;

			if([[currentPlaceHolder annotationsArray] count])
			{
				CIAAnnotation *annotation1, *annotation2;
				
				if([[[currentPlaceHolder annotationsArray] objectAtIndex:0] frame].origin.y <= [annotation frame].origin.y)
					index = 0;
					
				int j;
				for (j=0; j<[[currentPlaceHolder annotationsArray] count]-1; j++)
				{
					annotation1 = [[currentPlaceHolder annotationsArray] objectAtIndex:j];
					annotation2 = [[currentPlaceHolder annotationsArray] objectAtIndex:j+1];
					if([annotation1 frame].origin.y == [annotation frame].origin.y)
						index = j;
					else if([annotation1 frame].origin.y > [annotation frame].origin.y && [annotation2 frame].origin.y <= [annotation frame].origin.y)
						index = j+1;
				}
			}
			
			if(index>=0)
				[currentPlaceHolder insertAnnotation:annotation atIndex:index];
			else
				[currentPlaceHolder addAnnotation:annotation];
			annotationOutOfPlaceHolder = NO;
			break;
		}
	}
	
	if(annotationOutOfPlaceHolder)
	{
		[[annotation placeHolder] removeAnnotation:annotation];
		[[annotation placeHolder] alignAnnotations];
	}
	
	for (i=0; i<[placeHolders count]; i++)
	{
		[[placeHolders objectAtIndex:i] alignAnnotations];
		[[placeHolders objectAtIndex:i] updateFrameAroundAnnotations];
		[[placeHolders objectAtIndex:i] alignAnnotations];
		[layoutView setNeedsDisplay:YES];
	}
}

- (void)highlightPlaceHolderForAnnotation:(CIAAnnotation*)anAnnotation;
{
	NSRect annotationFrame = [anAnnotation frame];
	float annotationFrameArea = annotationFrame.size.width * annotationFrame.size.height;
	
	NSArray *placeHolders = [layoutView placeHolderArray];
	NSMutableArray *highlightedPlaceHolders = [NSMutableArray arrayWithCapacity:0];
	int i;
	for (i=0; i<[placeHolders count]; i++)
	{
		NSRect interserctionRect = NSIntersectionRect(annotationFrame, [[placeHolders objectAtIndex:i] frame]);
		if(interserctionRect.size.width*interserctionRect.size.height >= 0.1*annotationFrameArea)
		{
			[[placeHolders objectAtIndex:i] setHasFocus:YES];
			[highlightedPlaceHolders addObject:[placeHolders objectAtIndex:i]];
		}
		else
			[[placeHolders objectAtIndex:i] setHasFocus:NO];
	}
	
	int numberOfHighlightedPlaceHolders = [highlightedPlaceHolders count];
	if(numberOfHighlightedPlaceHolders>1) // more than one place holder is highlighted
	{
		NSEvent *currentEvent = [[NSApplication sharedApplication] currentEvent];
		NSPoint mouseLocationInWindow = [currentEvent locationInWindow];
		NSPoint mouseLocationInView = [layoutView convertPoint:mouseLocationInWindow fromView:nil];
		
		float distanceToMouse[numberOfHighlightedPlaceHolders];
		float placeHolderCenter;
		for (i=0; i<numberOfHighlightedPlaceHolders; i++)
		{
			placeHolderCenter = [[highlightedPlaceHolders objectAtIndex:i] frame].origin.x + [[highlightedPlaceHolders objectAtIndex:i] frame].size.width/2.0;
			distanceToMouse[i] = fabsf(mouseLocationInView.x - placeHolderCenter);
		}

		float minDistance = MAXFLOAT;
		int index = -1;
		for (i=0; i<numberOfHighlightedPlaceHolders; i++)
		{
			if(distanceToMouse[i] < minDistance)
			{
				minDistance = distanceToMouse[i];
				index = i;
			}
		}
		
		for (i=0; i<numberOfHighlightedPlaceHolders; i++)
		{
			if(i!=index)
				[[highlightedPlaceHolders objectAtIndex:i] setHasFocus:NO];
		}
	}
}

- (void)selectAnnotation:(CIAAnnotation*)anAnnotation;
{
	if(anAnnotation==selectedAnnotation) return;
	
//	[[[prefPane mainView] window] makeFirstResponder:[prefPane titleTextField]];
	
//	[[prefPane contentTokenField] sendAction:[[prefPane contentTokenField] action] to:[[prefPane contentTokenField] target]]; // bug...
	[self validateTokenTextField:self];
	
	int i;
	for (i=0; i<[annotationsArray count]; i++)
	{
		[[annotationsArray objectAtIndex:i] setIsSelected:NO];
	}
	[anAnnotation setIsSelected:YES];

	[self willChangeValueForKey:@"selectedAnnotation"];
	selectedAnnotation = anAnnotation;
	[self didChangeValueForKey:@"selectedAnnotation"];
	
	[[prefPane titleTextField] setStringValue:[anAnnotation title]];
	[[prefPane titleTextField] setEnabled:YES];
	[[prefPane contentTokenField] setObjectValue:[anAnnotation content]];
	[[prefPane contentTokenField] setEnabled:YES];
	
	[layoutView addSubview:anAnnotation]; // in order to bring the Annotation to front
	[layoutView setNeedsDisplay:YES];
	[self resizeTokenField];
	
	[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
	[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
	[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
	[[prefPane specialFieldsPopUpButton] setEnabled:NO];
	[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
	[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];

}

- (CIAAnnotation*)selectedAnnotation;
{
	return selectedAnnotation;
}

- (IBAction)addFieldToken:(id)sender;
{
	[[prefPane contentTokenField] sendAction:[[prefPane contentTokenField] action] to:[[prefPane contentTokenField] target]];
	
//	[self willChangeValueForKey:@"selectedAnnotation"];
	[selectedAnnotation willChangeValueForKey:@"content"];
//	[[selectedAnnotation content] addObject:[[sender selectedItem] title]];


	// see if there is a selected Token in the NSTokenField
	BOOL aTokenIsSelected = NO;
	int tokenIndexInContent;
	NSRange range = [[[prefPane contentTokenField] currentEditor] selectedRange];
	if(range.length==1) // one and only one is selected
	{
		//NSString *selectedString = [[[[prefPane contentTokenField] objectValue] subarrayWithRange:range] objectAtIndex:0];
		aTokenIsSelected = YES;
		tokenIndexInContent = range.location;
	}

	NSString *formatString;	
	if([sender isEqualTo:[prefPane DICOMFieldsPopUpButton]])
	{
		formatString = @"DICOM_%@";
		if(!aTokenIsSelected)
			[selectedAnnotation insertObject:[NSString stringWithFormat:formatString, [[[sender selectedItem] representedObject] name]] inContentAtIndex:[selectedAnnotation countOfContent]];
		else
		{
			[selectedAnnotation removeObjectFromContentAtIndex:tokenIndexInContent];
			[selectedAnnotation insertObject:[NSString stringWithFormat:formatString, [[[sender selectedItem] representedObject] name]] inContentAtIndex:tokenIndexInContent];
		}
//		int index = [sender indexOfSelectedItem]-1;
//		[[prefPane dicomGroupTextField] setStringValue:[NSString stringWithFormat:@"0x%04x", [[DICOMFieldsArray objectAtIndex:index] group]]];
//		[[prefPane dicomElementTextField] setStringValue:[NSString stringWithFormat:@"0x%04x", [[DICOMFieldsArray objectAtIndex:index] element]]];
//		[[prefPane dicomNameTokenField] setStringValue:[[DICOMFieldsArray objectAtIndex:index] name]];
	}
	else if([sender isEqualTo:[prefPane databaseFieldsPopUpButton]])
	{
		formatString = @"DB_%@";		
		if(!aTokenIsSelected)
			[selectedAnnotation insertObject:[NSString stringWithFormat:formatString,[[sender selectedItem] representedObject]] inContentAtIndex:[selectedAnnotation countOfContent]];
		else
		{
			[selectedAnnotation removeObjectFromContentAtIndex:tokenIndexInContent];
			[selectedAnnotation insertObject:[NSString stringWithFormat:formatString,[[sender selectedItem] representedObject]] inContentAtIndex:tokenIndexInContent];
		}
	}
	else if([sender isEqualTo:[prefPane specialFieldsPopUpButton]])
	{
		formatString = @"Special_%@";
		if(!aTokenIsSelected)
			[selectedAnnotation insertObject:[NSString stringWithFormat:formatString,[[sender selectedItem] title]] inContentAtIndex:[selectedAnnotation countOfContent]];
		else
		{
			[selectedAnnotation removeObjectFromContentAtIndex:tokenIndexInContent];
			[selectedAnnotation insertObject:[NSString stringWithFormat:formatString,[[sender selectedItem] title]] inContentAtIndex:tokenIndexInContent];
		}
	}
	else if([sender isEqualTo:[prefPane addCustomDICOMFieldButton]])
	{
		if([[[prefPane dicomGroupTextField] stringValue] isEqualToString:@""] || [[[prefPane dicomElementTextField] stringValue] isEqualToString:@""])
		{
			NSRunAlertPanel(@"Custom DICOM Field", @"Please provide a value for both \"Group\" and \"Element\" fields.", @"OK", nil, nil);
			return;
		}
		
		if([[prefPane DICOMFieldsPopUpButton] indexOfSelectedItem]==0)
		{
			// custom field
			if([[[prefPane dicomNameTokenField] stringValue] isEqualToString:@""])
			{
				formatString = @"DICOM_%@_%@";
				if(!aTokenIsSelected)
					[selectedAnnotation insertObject:[NSString stringWithFormat:formatString, [[prefPane dicomGroupTextField] stringValue], [[prefPane dicomElementTextField] stringValue]] inContentAtIndex:[selectedAnnotation countOfContent]];
				else
				{
					[selectedAnnotation removeObjectFromContentAtIndex:tokenIndexInContent];
					[selectedAnnotation insertObject:[NSString stringWithFormat:formatString, [[prefPane dicomGroupTextField] stringValue], [[prefPane dicomElementTextField] stringValue]] inContentAtIndex:tokenIndexInContent];
				}
			}
			else
			{
				formatString = @"DICOM_%@_%@_%@";
				if(!aTokenIsSelected)
					[selectedAnnotation insertObject:[NSString stringWithFormat:formatString, [[prefPane dicomGroupTextField] stringValue], [[prefPane dicomElementTextField] stringValue], [[prefPane dicomNameTokenField] stringValue]] inContentAtIndex:[selectedAnnotation countOfContent]];
				else
				{
					[selectedAnnotation removeObjectFromContentAtIndex:tokenIndexInContent];
					[selectedAnnotation insertObject:[NSString stringWithFormat:formatString, [[prefPane dicomGroupTextField] stringValue], [[prefPane dicomElementTextField] stringValue], [[prefPane dicomNameTokenField] stringValue]] inContentAtIndex:tokenIndexInContent];
				}
			}
		}
		else
		{
			// field in the list
			formatString = @"DICOM_%@";
			if(!aTokenIsSelected)
				[selectedAnnotation insertObject:[NSString stringWithFormat:formatString, [[[[prefPane DICOMFieldsPopUpButton] selectedItem] representedObject] name]] inContentAtIndex:[selectedAnnotation countOfContent]];
			else
			{
				[selectedAnnotation removeObjectFromContentAtIndex:tokenIndexInContent];
				[selectedAnnotation insertObject:[NSString stringWithFormat:formatString, [[[[prefPane DICOMFieldsPopUpButton] selectedItem] representedObject] name]] inContentAtIndex:tokenIndexInContent];
			}
		}
		[[prefPane dicomGroupTextField] setStringValue:@""];
		[[prefPane dicomElementTextField] setStringValue:@""];
		[[prefPane dicomNameTokenField] setStringValue:@""];
		[[prefPane dicomGroupTextField] setNeedsDisplay:YES];
		[[prefPane dicomElementTextField] setNeedsDisplay:YES];
		[[prefPane dicomNameTokenField] setNeedsDisplay:YES];
	}
	else if([sender isEqualTo:[prefPane addDICOMFieldButton]])
	{
		[selectedAnnotation insertObject:@"DICOM_" inContentAtIndex:[selectedAnnotation countOfContent]];
		[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
		[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
		[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
		[[prefPane specialFieldsPopUpButton] setEnabled:NO];
		[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
		[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];
		aTokenIsSelected = NO;
	}
	else if([sender isEqualTo:[prefPane addDatabaseFieldButton]])
	{
		[selectedAnnotation insertObject:@"DB_" inContentAtIndex:[selectedAnnotation countOfContent]];
		[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
		[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
		[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
		[[prefPane specialFieldsPopUpButton] setEnabled:NO];
		[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
		[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];
		aTokenIsSelected = NO;
	}
	else if([sender isEqualTo:[prefPane addSpecialFieldButton]])
	{
		[selectedAnnotation insertObject:@"Special_" inContentAtIndex:[selectedAnnotation countOfContent]];
		[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
		[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
		[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
		[[prefPane specialFieldsPopUpButton] setEnabled:NO];
		[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
		[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];
		aTokenIsSelected = NO;
	}
	
	[[prefPane contentTokenField] setObjectValue:[selectedAnnotation content]];

	[selectedAnnotation didChangeValueForKey:@"content"];
//	[self didChangeValueForKey:@"selectedAnnotation"];

	[self resizeTokenField];
	NSLog(@"[selectedAnnotation content] : %@", [selectedAnnotation content]);
	
	if(!aTokenIsSelected)
	{
		// select added token
		NSLog(@"! aTokenIsSelected");
		[[self window] makeFirstResponder:[prefPane contentTokenField]];
		[[[prefPane contentTokenField] currentEditor] setSelectedRange:NSMakeRange([[selectedAnnotation content] count]-1, 1)];
		NSLog(@"[[[prefPane contentTokenField] currentEditor] selectedRange] : %d", [[[prefPane contentTokenField] currentEditor] selectedRange].location);
	}
	
	[[prefPane contentTokenField] display];
}

- (IBAction)validateTokenTextField:(id)sender;
{
	[[selectedAnnotation content] setArray:[[prefPane contentTokenField] objectValue]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification;
{
	NSLog(@"controlTextDid Change");
//	[self resizeTokenField];
//   [[prefPane contentTokenField] sendAction:[[prefPane contentTokenField] action] to:[[prefPane contentTokenField] target]];
}

- (void)resizeTokenField;
{
	return;
	int i;
	NSRect oldTokenFieldFrame = [[prefPane contentTokenField] frame];
	NSSize cellSize = [[[prefPane contentTokenField] cell] cellSizeForBounds:[[prefPane contentTokenField] bounds]];
	NSLog(@"cellSize.height : %f", cellSize.height);
NSLog(@"[[[[self window] contentView] subviews] count] : %d", [[[[self window] contentView] subviews] count]);
//	for (i=0; i<[[[[self window] contentView] subviews] count]; i++)
//	{
//		if([[[[self window] contentView] subviews] objectAtIndex:i]!=[prefPane contentTokenField] && [[[[self window] contentView] subviews] objectAtIndex:i]!=[prefPane contentBox])
//			[[[[[self window] contentView] subviews] objectAtIndex:i] setFrameOrigin:NSMakePoint([[[[[self window] contentView] subviews] objectAtIndex:i] frame].origin.x, [[[[[self window] contentView] subviews] objectAtIndex:i] frame].origin.y-oldTokenFieldFrame.size.height+cellSize.height)];
//	}

	NSBox *globalPaneBox = [[[[self window] contentView] subviews] objectAtIndex:0];
	
	for (i=0; i<[[globalPaneBox subviews] count]; i++)
	{
		NSView *currentView = [[globalPaneBox subviews] objectAtIndex:i];
		//if(currentView!=[prefPane contentTokenField] && currentView!=[prefPane contentBox])
		if(currentView==[prefPane contentTokenField] || currentView==[prefPane contentBox])
		{
			NSLog(@"currentView : %@", currentView);
			[currentView setFrameOrigin:NSMakePoint([currentView frame].origin.x, [currentView frame].origin.y-oldTokenFieldFrame.size.height+cellSize.height)];
		}
	}

[[[[[self window] contentView] subviews] objectAtIndex:0] display];

//	[editingBox setFrame:NSMakeRect([editingBox frame].origin.x, [editingBox frame].origin.y+oldTokenFieldFrame.size.height-cellSize.height, [editingBox frame].size.width, [editingBox frame].size.height-oldTokenFieldFrame.size.height+cellSize.height)];
	//+oldTokenFieldFrame.size.height-cellSize.height
	[[prefPane contentTokenField] setFrame:NSMakeRect(oldTokenFieldFrame.origin.x, oldTokenFieldFrame.origin.y, oldTokenFieldFrame.size.width, cellSize.height)];
	NSLog(@"[[prefPane contentTokenField] frame].size.height : %f", [[prefPane contentTokenField] frame].size.height);
	
//	for (i=0; i<[[editingBox subviews] count]; i++)
//	{
//		[[[editingBox subviews] objectAtIndex:i] setFrameOrigin:NSMakePoint([[[editingBox subviews] objectAtIndex:i] frame].origin.x, [[[editingBox subviews] objectAtIndex:i] frame].origin.y-oldTokenFieldFrame.size.height+cellSize.height)];
//	}

	NSPoint loc = [selectedAnnotation mouseDownLocation];
	loc.y -= oldTokenFieldFrame.size.height-cellSize.height;
	[selectedAnnotation setMouseDownLocation:loc];

	[[self window] setFrame:NSMakeRect([[self window] frame].origin.x, [[self window] frame].origin.y+oldTokenFieldFrame.size.height-cellSize.height, [[self window] frame].size.width, [[self window] frame].size.height-oldTokenFieldFrame.size.height+cellSize.height) display:YES];
	

//	[selectedAnnotation recomputeMouseDownLocation];
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	NSLog(@"controlTextDid Begin Editing");
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSLog(@"controlTextDid End Editing");
//	[[prefPane contentTokenField] sendAction:[[prefPane contentTokenField] action] to:[[prefPane contentTokenField] target]];
	if([[aNotification object] isEqualTo:[prefPane dicomGroupTextField]])
	{
		if(![[[prefPane dicomGroupTextField] stringValue] hasPrefix:@"0x"])
			[[prefPane dicomGroupTextField] setStringValue:[NSString stringWithFormat:@"0x%04d", [[prefPane dicomGroupTextField] intValue]]];
	}
	else if([[aNotification object] isEqualTo:[prefPane dicomElementTextField]])
	{
		if(![[[prefPane dicomElementTextField] stringValue] hasPrefix:@"0x"])
			[[prefPane dicomElementTextField] setStringValue:[NSString stringWithFormat:@"0x%04d", [[prefPane dicomElementTextField] intValue]]];
		
		int i;
		for (i=0; i<[DICOMFieldsArray count]; i++)
		{
			if ([[NSString stringWithFormat:@"0x%04x", [[DICOMFieldsArray objectAtIndex:i] group]] isEqualToString:[[prefPane dicomGroupTextField] stringValue]] && [[NSString stringWithFormat:@"0x%04x", [[DICOMFieldsArray objectAtIndex:i] element]] isEqualToString:[[prefPane dicomElementTextField] stringValue]])
			{
				[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:i+1]; // +1 because item at index 0 contains no DICOM fields (it says "DICOM Fields")
				[[prefPane dicomNameTokenField] setStringValue:[[DICOMFieldsArray objectAtIndex:i] name]];
				break;
			}
			else
			{
				[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
				[[prefPane dicomNameTokenField] setStringValue:@""];
			}
		}
	}
	else
		[self resizeTokenField];
}

- (NSArray *)tokenField:(NSTokenField *)tokenField readFromPasteboard:(NSPasteboard *)pboard
{
	NSLog(@"tokenField: readFromPasteboard:");
	NSLog(@"[pboard name] : %@", [pboard name]);
	NSLog(@"[pboard types] : %@", [pboard types]);
	NSLog(@"[pboard stringForType:NSStringPboardType] : %@", [pboard stringForType:NSStringPboardType]);
	
	NSLog(@"tokenField : %@", tokenField);
	NSLog(@"[[tokenField cell] objectValue] : %@", [[tokenField cell] objectValue]);
	
	// handles drag & drop of several tokens
	return [[pboard stringForType:NSStringPboardType] componentsSeparatedByString:@", "];
	
//	return [NSArray arrayWithObject:[pboard stringForType:NSStringPboardType]];
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(unsigned)index
{
	NSLog(@"tokenField: shouldAddObjects: atIndex: %d", index);
	NSLog(@"tokens: %@", tokens);
//	NSLog(@"[[tokenField cell] objectValue] : %@", [[tokenField cell] objectValue]);
	[self performSelector:@selector(resizeTokenField) withObject:nil afterDelay:0.1];
	return tokens;
}

- (void)prepareDatabaseFields;
{
	NSManagedObjectModel *currentModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"/Users/joris/Development/osirix/osirix/build/Development/OsiriX.app/Contents/Resources/OsiriXDB_DataModel.mom"]];
	NSArray *studies = [[[[currentModel entitiesByName] objectForKey:@"Study"] attributesByName] allKeys];
	NSArray *series = [[[[currentModel entitiesByName] objectForKey:@"Series"] attributesByName] allKeys];
	NSArray *images = [[[[currentModel entitiesByName] objectForKey:@"Image"] attributesByName] allKeys];

	[databaseStudyFieldsArray addObjectsFromArray:studies];
	[databaseSeriesFieldsArray addObjectsFromArray:series];
	[databaseImageFieldsArray addObjectsFromArray:images];
}

- (NSMutableArray*)specialFieldsTitles;
{
	NSMutableArray *specialFieldsTitles = [NSMutableArray array];
	[specialFieldsTitles addObject:@"Image Size"];
	[specialFieldsTitles addObject:@"Viewport Size"];
	[specialFieldsTitles addObject:@"Winwow Level / Window Width"];
	[specialFieldsTitles addObject:@"Image Number"];
	[specialFieldsTitles addObject:@"Images Count"];
	[specialFieldsTitles addObject:@"Zoom"];
	[specialFieldsTitles addObject:@"Rotation Angle"];
	[specialFieldsTitles addObject:@"Mouse Position (px)"];
	[specialFieldsTitles addObject:@"Mouse Position Value"];
	[specialFieldsTitles addObject:@"Mouse Position (mm)"];
	[specialFieldsTitles addObject:@"Orientation"];
	[specialFieldsTitles addObject:@"OsiriX Label"];
	return specialFieldsTitles;
}

// auto completion
- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(int)tokenIndex indexOfSelectedItem:(int *)selectedIndex
{
	int i;
	NSMutableArray *resultArray = [NSMutableArray array];
	NSRange comparisonRange = NSMakeRange(0, [substring length]);
	
	if([tokenField isEqualTo:[prefPane contentTokenField]])
	{
		[resultArray addObject:substring];
		
		NSArray *titles = DICOMFieldsArray;
		NSString *currentTitle;

		for (i=0; i<[titles count]; i++)
		{
			currentTitle = [[titles objectAtIndex:i] name];
			if([currentTitle compare:substring options:NSCaseInsensitiveSearch range:comparisonRange]==NSOrderedSame)
				[resultArray addObject:[NSString stringWithFormat:@"DICOM_%@", currentTitle]];
		}
		
		titles = databaseStudyFieldsArray;
		for (i=0; i<[titles count]; i++)
		{
			currentTitle = [titles objectAtIndex:i];
			if([currentTitle compare:substring options:NSCaseInsensitiveSearch range:comparisonRange]==NSOrderedSame)
				[resultArray addObject:[NSString stringWithFormat:@"DB_study.%@", currentTitle]];
		}
		titles = databaseSeriesFieldsArray;
		for (i=0; i<[titles count]; i++)
		{
			currentTitle = [titles objectAtIndex:i];
			if([currentTitle compare:substring options:NSCaseInsensitiveSearch range:comparisonRange]==NSOrderedSame)
				[resultArray addObject:[NSString stringWithFormat:@"DB_series.%@", currentTitle]];
		}
		titles = databaseImageFieldsArray;
		for (i=0; i<[titles count]; i++)
		{
			currentTitle = [titles objectAtIndex:i];
			if([currentTitle compare:substring options:NSCaseInsensitiveSearch range:comparisonRange]==NSOrderedSame)
				[resultArray addObject:[NSString stringWithFormat:@"DB_image.%@", currentTitle]];
		}
		
		titles = [[prefPane specialFieldsPopUpButton] itemTitles];
		for (i=0; i<[[[prefPane specialFieldsPopUpButton] itemTitles] count]; i++)
		{
			currentTitle = [titles objectAtIndex:i];
			if([currentTitle compare:substring options:NSCaseInsensitiveSearch range:comparisonRange]==NSOrderedSame)
				[resultArray addObject:[NSString stringWithFormat:@"Special_%@", currentTitle]];
		}
	}
	else if([tokenField isEqualTo:[prefPane dicomNameTokenField]])
	{
		NSString *currentTitle;
		for (i=0; i<[DICOMFieldsArray count]; i++)
		{
			currentTitle = [[DICOMFieldsArray objectAtIndex:i] name];
			if([currentTitle compare:substring options:NSCaseInsensitiveSearch range:comparisonRange]==NSOrderedSame)
				[resultArray addObject:[[DICOMFieldsArray objectAtIndex:i] name]];
		}
	}

	return resultArray;
}

- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
	if([[prefPane contentTokenField] currentEditor]==[aNotification object])
	{
		NSArray *ranges = [[aNotification object] selectedRanges];
		if([ranges count]==1)
		{
			NSRange selectedRange = [[ranges objectAtIndex:0] rangeValue];
			NSLog(@"selectedRange : %d, %d", selectedRange.location, selectedRange.length);
			if(selectedRange.length==1)
			{
				NSString *selectedString = [[[[prefPane contentTokenField] objectValue] subarrayWithRange:selectedRange] objectAtIndex:0];
				if([selectedString hasPrefix:@"DICOM_"])
				{
					[[prefPane DICOMFieldsPopUpButton] setEnabled:YES];
					[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
					[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
					[[prefPane specialFieldsPopUpButton] setEnabled:NO];					
					[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
					[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];
					
					if([selectedString length]>=7)
					{
						BOOL found = NO;
						selectedString = [selectedString substringFromIndex:6];
						int i;
						for (i=0; i<[DICOMFieldsArray count]; i++)
						{
							if([[[DICOMFieldsArray objectAtIndex:i] name] isEqualToString:selectedString])
							{
//								[[prefPane dicomGroupTextField] setStringValue:[NSString stringWithFormat:@"0x%04x", [[DICOMFieldsArray objectAtIndex:i] group]]];
//								[[prefPane dicomElementTextField] setStringValue:[NSString stringWithFormat:@"0x%04x", [[DICOMFieldsArray objectAtIndex:i] element]]];
//								[[prefPane dicomNameTokenField] setStringValue:[[DICOMFieldsArray objectAtIndex:i] name]];
								[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:i+1];
								[[prefPane DICOMFieldsPopUpButton] setEnabled:YES];
								found = YES;
								break;
							}
						}
						
						if(!found)
						{
							// this is a custom DICOM field, with this format : DICOM_0x0001_0x0001 or DICOM_0x0001_0x0001_name
//							NSString *groupString = [selectedString substringWithRange:NSMakeRange(0,6)];
//							NSString *elementString = [selectedString substringWithRange:NSMakeRange(7,6)];
//							[[prefPane dicomGroupTextField] setStringValue:groupString];
//							[[prefPane dicomElementTextField] setStringValue:elementString];
//
//							NSString *name;
//							if([selectedString length]==13)
//								name = @"";
//							else
//								name = [selectedString substringFromIndex:14];
//							[[prefPane dicomNameTokenField] setStringValue:name];
							
							[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
							[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
						}
					}
				}
				else if([selectedString hasPrefix:@"DB_"])
				{
					[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
					[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
					[[prefPane databaseFieldsPopUpButton] setEnabled:YES];
					[[prefPane specialFieldsPopUpButton] setEnabled:NO];
					[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];

					if([selectedString length]>=4)
					{
						selectedString = [selectedString substringFromIndex:3];
						[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:[[[prefPane databaseFieldsPopUpButton] menu] indexOfItemWithRepresentedObject:selectedString]];
					}
					else
					{
						[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
					}
				}
				else if([selectedString hasPrefix:@"Special_"])
				{
					[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
					[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
					[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
					[[prefPane specialFieldsPopUpButton] setEnabled:YES];
					[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];

					if([selectedString length]>=9)
					{
						selectedString = [selectedString substringFromIndex:8];
						[[prefPane specialFieldsPopUpButton] selectItemAtIndex:[[[prefPane specialFieldsPopUpButton] menu] indexOfItemWithRepresentedObject:selectedString]];
					}
					else
					{
						[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
					}
				}
				else
				{
					[[prefPane DICOMFieldsPopUpButton] setEnabled:NO];
					[[prefPane DICOMFieldsPopUpButton] selectItemAtIndex:0];
					[[prefPane databaseFieldsPopUpButton] setEnabled:NO];
					[[prefPane databaseFieldsPopUpButton] selectItemAtIndex:0];
					[[prefPane specialFieldsPopUpButton] setEnabled:NO];
					[[prefPane specialFieldsPopUpButton] selectItemAtIndex:0];

				}
			}
		}
	}
}

- (void)setCustomDICOMFieldEditingEnable:(BOOL)boo;
{
	[[prefPane dicomNameTokenField] setEnabled:boo];
	[[prefPane dicomGroupTextField] setEnabled:boo];
	[[prefPane dicomElementTextField] setEnabled:boo];
	
	[[prefPane dicomNameTokenField] setStringValue:@""];
	[[prefPane dicomGroupTextField] setStringValue:@""];
	[[prefPane dicomElementTextField] setStringValue:@""];

	NSColor *textColor;
	if(boo)
		textColor = [NSColor blackColor];
	else
		textColor = [NSColor grayColor];
		
	[[prefPane groupLabel] setTextColor:textColor];
	[[prefPane elementLabel] setTextColor:textColor];
	[[prefPane nameLabel] setTextColor:textColor];
}

- (IBAction)saveAnnotationLayout:(id)sender;
{
	//[self saveAnnotationLayoutForModality:[[modalitiesPopUpButton selectedItem] title]];
}

- (void)saveAnnotationLayoutForModality:(NSString*)modality;
{
	NSArray *placeHolders = [layoutView placeHolderArray];
	NSArray *keys = [NSArray arrayWithObjects:@"LowerLeft", @"LowerMiddle", @"LowerRight", @"MiddleLeft", @"MiddleRight", @"TopLeft", @"TopMiddle", @"TopRight", nil];
	NSMutableDictionary *layoutViewDict = [NSMutableDictionary dictionary];

	CIAPlaceHolder *placeHolder;
	NSMutableArray *annotations;
	int i, j, k, n;
	for (i=0; i<8; i++)
	{
		placeHolder = [placeHolders objectAtIndex:i];
		
		annotations = [NSMutableArray array];
		for (j=0; j<[[placeHolder annotationsArray] count]; j++)
		{
			NSMutableDictionary *annot = [NSMutableDictionary dictionary];
			[annot setObject:[[[placeHolder annotationsArray] objectAtIndex:j] title] forKey:@"title"];
			[annot setObject:[[[placeHolder annotationsArray] objectAtIndex:j] content] forKey:@"content"];
			
			NSMutableArray *contentToSave = [NSMutableArray array];
			
			NSArray* contentArray = [[[placeHolder annotationsArray] objectAtIndex:j] content];
			for (n=0; n<[contentArray count]; n++)
			{
				NSString *currentField = [contentArray objectAtIndex:n];
				NSRange comparisonRange;
				if([currentField hasPrefix:@"DICOM_"])
				{
					[annot setObject:@"DICOM" forKey:@"type"];
					
					comparisonRange = NSMakeRange(0, [@"DICOM_" length]);
					NSString *currentTitle;
					for (k=0; k<[DICOMFieldsArray count]; k++)
					{
						currentTitle = [[DICOMFieldsArray objectAtIndex:i] name];
						if([currentTitle compare:currentField options:NSCaseInsensitiveSearch range:comparisonRange]==NSOrderedSame)
						{
							NSDictionary *dicomFieldDict = [NSDictionary dictionaryWithObjectsAndKeys:@"group", [[DICOMFieldsArray objectAtIndex:i] group], @"element", [[DICOMFieldsArray objectAtIndex:i] element], @"name", [[DICOMFieldsArray objectAtIndex:i] name], @"tolenTitle", currentField, nil];
							[contentToSave addObject:dicomFieldDict];
							break;
						}
					}
				}
				else if([currentField hasPrefix:@"DB_"])
				{
					[annot setObject:@"DB" forKey:@"type"];
				}
				else if([currentField hasPrefix:@"Special_"])
				{
					[annot setObject:@"Special" forKey:@"type"];
				}
			}
			
			[annot setObject:contentToSave forKey:@"fullContent"]; // fullContent contains more details than "content" -> use it for display in the DCM view
			
			[annotations addObject:annot];
		}
		
		[layoutViewDict setObject:annotations forKey:[keys objectAtIndex:i]];
	}
	
	[annotationsLayoutDictionary setObject:layoutViewDict forKey:modality];
	
	[[NSUserDefaults standardUserDefaults] setObject:annotationsLayoutDictionary forKey:@"CUSTOM_IMAGE_ANNOTATIONS"];
	
	NSLog(@"annotationsLayoutDictionary : %@", annotationsLayoutDictionary);
}

- (IBAction)switchModality:(id)sender;
{
	[self validateTokenTextField:self];
	selectedAnnotation = nil;
//	[self saveAnnotationLayoutForModality:currentModality];
	currentModality = [[sender selectedItem] title];
	[self loadAnnotationLayoutForModality:currentModality];

	[[prefPane titleTextField] setStringValue:@""];
	[[prefPane contentTokenField] setStringValue:@""];
}

- (void)loadAnnotationLayoutForModality:(NSString*)modality;
{
	[self removeAllAnnotations];
	
	NSDictionary *palceHoldersForModality = [annotationsLayoutDictionary objectForKey:modality];
	NSArray *keys = [NSArray arrayWithObjects:@"LowerLeft", @"LowerMiddle", @"LowerRight", @"MiddleLeft", @"MiddleRight", @"TopLeft", @"TopMiddle", @"TopRight", nil];
	NSArray *placeHolders = [layoutView placeHolderArray];
	
	CIAPlaceHolder *placeHolder;
	NSArray *annotations;
	CIAAnnotation *anAnnotation;
	int i, j, n=0;
	for (i=0; i<8; i++)
	{
		annotations = [palceHoldersForModality objectForKey:[keys objectAtIndex:i]];
		placeHolder = [placeHolders objectAtIndex:i];
		for (j=0; j<[annotations count]; j++)
		{
			n++;
			anAnnotation = [[CIAAnnotation alloc] initWithFrame:NSMakeRect(10.0, 10.0, 75, 22)];
			[anAnnotation setTitle:[[annotations objectAtIndex:j] objectForKey:@"title"]];
			[anAnnotation setContent:[[annotations objectAtIndex:j] objectForKey:@"content"]];
			[anAnnotation setPlaceHolder:placeHolder];
			[placeHolder addAnnotation:anAnnotation];
			
			[annotationsArray addObject:anAnnotation];
			[layoutView addSubview:anAnnotation];

			[anAnnotation release];
		}

		[[placeHolders objectAtIndex:i] alignAnnotations];
		[[placeHolders objectAtIndex:i] updateFrameAroundAnnotations];
		[[placeHolders objectAtIndex:i] alignAnnotations];
	}
	
	if(n==0 && ![modality isEqualTo:@"All"])
		[self loadAnnotationLayoutForModality:@"All"];

	[layoutView setNeedsDisplay:YES];
}

- (void)removeAllAnnotations;
{
	NSArray *placeHolders = [layoutView placeHolderArray];
	int i;
	for (i=0; i<[placeHolders count]; i++)
	{
		[[[placeHolders objectAtIndex:i] annotationsArray] removeAllObjects];
		[[placeHolders objectAtIndex:i] setHasFocus:NO];
	}

	for (i=0; i<[annotationsArray count]; i++)
	{
		[[annotationsArray objectAtIndex:i] removeFromSuperview];
	}
	
	[annotationsArray removeAllObjects];
	[layoutView setNeedsDisplay:YES];
}

//- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject
//{
//	if([[representedObject className] isEqualToString:@"NSCFString"])
//	{
//		if(![representedObject hasPrefix:@"DICOM_"] && ![representedObject hasPrefix:@"DB_"] && ![representedObject hasPrefix:@"Special_"])
//		{
//			return NSPlainTextTokenStyle;
//		}
//		else
//			return NSRoundedTokenStyle;
//	}
//	return NSRoundedTokenStyle;
//}

- (void)setLayoutView:(CIALayoutView*)view;
{
	layoutView = view;
}

- (void)setPrefPane:(OSICustomImageAnnotations*)aPrefPane;
{
	prefPane = aPrefPane;
}

@end
