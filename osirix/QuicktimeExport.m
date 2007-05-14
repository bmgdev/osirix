/*=========================================================================
  Program:   OsiriX

  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - GPL
  
  See http://homepage.mac.com/rossetantoine/osirix/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

#import <QTKit/QTKit.h>
#import "QuicktimeExport.h"
#import "Wait.h"
#import "WaitRendering.h"

NSString * documentsDirectory();

@implementation QuicktimeExport

- (id) initWithSelector:(id) o :(SEL) s :(long) f
{
	[super init];
	
	[NSBundle loadNibNamed:@"QuicktimeExport" owner:self];
	
	object = o;
	selector = s;
	numberOfFrames = f;
	
	return self;
}

#if !__LP64__
- (NSArray *)availableComponents
{
	//{
//		NSMutableArray		*results = nil;
//	ComponentDescription	cd = {};
//	Component		 c = NULL;
//	Handle			 nameHandle = NewHandle(0);
//	
//	if ( nameHandle == NULL )
//		return( nil );
//	cd.componentType = MovieExportType;
//	cd.componentSubType = 0;
//	cd.componentManufacturer = 0;
//	cd.componentFlags = canMovieExportFiles;
//	cd.componentFlagsMask = canMovieExportFiles;
//
//	while((c = FindNextComponent(c, &cd)))
//	{
//		ComponentDescription	exportCD = {};
//		
//		if ( GetComponentInfo( c, &exportCD, nameHandle, NULL, NULL ) == noErr )
//		{
//			HLock( nameHandle );
//			NSString	*nameStr = [[[NSString alloc] initWithBytes:(*nameHandle)+1 length:(int)**nameHandle encoding:NSMacOSRomanStringEncoding] autorelease];
//			HUnlock( nameHandle );
//			
//			exportCD.componentType = CFSwapInt32HostToBig(exportCD.componentType);
//			exportCD.componentSubType = CFSwapInt32HostToBig(exportCD.componentSubType);
//			exportCD.componentManufacturer = CFSwapInt32HostToBig(exportCD.componentManufacturer);
//				
//			NSString *type = [[[NSString alloc] initWithBytes:&exportCD.componentType length:sizeof(OSType) encoding:NSMacOSRomanStringEncoding] autorelease];
//			NSString *subType = [[[NSString alloc] initWithBytes:&exportCD.componentSubType length:sizeof(OSType) encoding:NSMacOSRomanStringEncoding] autorelease];
//			NSString *manufacturer = [[[NSString alloc] initWithBytes:&exportCD.componentManufacturer length:sizeof(OSType) encoding:NSMacOSRomanStringEncoding] autorelease];
//			
//			NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//				nameStr, @"name", [NSValue valueWithPointer:c], @"component",
//				type, @"type", subType, @"subtype", manufacturer, @"manufacturer", nil];
//			
//			NSLog( [dictionary description]);
//			
//			if ( results == nil ) {
//				results = [NSMutableArray array];
//			}
//			
//			[results addObject:dictionary];
//		}
//	}
//	
//	DisposeHandle( nameHandle );
//
//	}
	NSMutableArray *array = [NSMutableArray array];


	ComponentDescription cd;
	Component c;
	
	cd.componentType = MovieExportType;
	cd.componentSubType = kQTFileTypeMovie;
	cd.componentManufacturer = kAppleManufacturer;
	cd.componentFlags = hasMovieExportUserInterface;
	cd.componentFlagsMask = hasMovieExportUserInterface;
	c = FindNextComponent( 0, &cd );
	
	if( c)
	{
		Handle name = NewHandle(4);
		ComponentDescription exportCD;
		
		if (GetComponentInfo(c, &exportCD, name, nil, nil) == noErr)
		{
			//unsigned char *namePStr = (unsigned char*) *name;
			//NSString *nameStr = [[NSString alloc] initWithBytes:&namePStr[1] length:namePStr[0] encoding:NSUTF8StringEncoding];
			NSString *nameStr = [[NSString alloc] initWithString: @"Quicktime Movie"];
			
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
				nameStr, @"name",
				[NSData dataWithBytes:&c length:sizeof(c)], @"component",
				[NSNumber numberWithLong:exportCD.componentType], @"type",
				[NSNumber numberWithLong:exportCD.componentSubType], @"subtype",
				[NSNumber numberWithLong:exportCD.componentManufacturer], @"manufacturer",
				nil];
			[array addObject:dictionary];
			[nameStr release];
		}
		
		DisposeHandle(name);
	}

	cd.componentType = MovieExportType;
	cd.componentSubType = 'ASF_';
	cd.componentManufacturer = 'TELE';
	cd.componentFlags = hasMovieExportUserInterface;
	cd.componentFlagsMask = hasMovieExportUserInterface;
	c = FindNextComponent( 0, &cd );
	
	if( c)
	{
		Handle name = NewHandle(4);
		ComponentDescription exportCD;
		
		if (GetComponentInfo(c, &exportCD, name, nil, nil) == noErr)
		{
			//unsigned char *namePStr = (unsigned char*) *name;
			//NSString *nameStr = [[NSString alloc] initWithBytes:&namePStr[1] length:namePStr[0] encoding:NSUTF8StringEncoding];
			NSString *nameStr = [[NSString alloc] initWithString: @"WMV Movie"];
			
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
				nameStr, @"name",
				[NSData dataWithBytes:&c length:sizeof(c)], @"component",
				[NSNumber numberWithLong:exportCD.componentType], @"type",
				[NSNumber numberWithLong:exportCD.componentSubType], @"subtype",
				[NSNumber numberWithLong:exportCD.componentManufacturer], @"manufacturer",
				nil];
			[array addObject:dictionary];
			[nameStr release];
		}
		
		DisposeHandle(name);
	}

	cd.componentType = MovieExportType;
	cd.componentSubType = kQTFileTypeAVI;
	cd.componentManufacturer = kAppleManufacturer;
	cd.componentFlags = hasMovieExportUserInterface;
	cd.componentFlagsMask = hasMovieExportUserInterface;
	c = FindNextComponent( 0, &cd );
	
	if( c)
	{
		Handle name = NewHandle(4);
		ComponentDescription exportCD;
		
		if (GetComponentInfo(c, &exportCD, name, nil, nil) == noErr)
		{
			//unsigned char *namePStr = (unsigned char*) *name;
			//NSString *nameStr = [[NSString alloc] initWithBytes:&namePStr[1] length:namePStr[0] encoding:NSUTF8StringEncoding];
			NSString *nameStr = [[NSString alloc] initWithString: @"AVI Movie"];
			
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
				nameStr, @"name",
				[NSData dataWithBytes:&c length:sizeof(c)], @"component",
				[NSNumber numberWithLong:exportCD.componentType], @"type",
				[NSNumber numberWithLong:exportCD.componentSubType], @"subtype",
				[NSNumber numberWithLong:exportCD.componentManufacturer], @"manufacturer",
				nil];
			[array addObject:dictionary];
			[nameStr release];
		}
		
		DisposeHandle(name);
	}
	
	cd.componentType = MovieExportType;
	cd.componentSubType = kQTFileTypeMP4;
	cd.componentManufacturer = kAppleManufacturer;
	cd.componentFlags = hasMovieExportUserInterface;
	cd.componentFlagsMask = hasMovieExportUserInterface;
	c = FindNextComponent( 0, &cd );
	
	if( c)
	{
		Handle name = NewHandle(4);
		ComponentDescription exportCD;
		
		if (GetComponentInfo(c, &exportCD, name, nil, nil) == noErr)
		{
			//unsigned char *namePStr = (unsigned char*) *name;
			//NSString *nameStr = [[NSString alloc] initWithBytes:&namePStr[1] length:namePStr[0] encoding:NSUTF8StringEncoding];
			
			NSString *nameStr = [[NSString alloc] initWithString: @"MPEG4 Movie"];
			
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
				nameStr, @"name",
				[NSData dataWithBytes:&c length:sizeof(c)], @"component",
				[NSNumber numberWithLong:exportCD.componentType], @"type",
				[NSNumber numberWithLong:exportCD.componentSubType], @"subtype",
				[NSNumber numberWithLong:exportCD.componentManufacturer], @"manufacturer",
				nil];
			[array addObject:dictionary];
			[nameStr release];
		}
		
		DisposeHandle(name);
	}
	
	return array;
}

- (NSData *)getExportSettings:(QTMovie*) aMovie component:(NSDictionary*) component
{
	Component c;
	
	memcpy(&c, [[component objectForKey:@"component"] bytes], sizeof(c));
	
	MovieExportComponent exporter = OpenComponent(c);
	Boolean canceled;
	
	Movie theMovie = [aMovie quickTimeMovie] ;
	TimeValue duration = GetMovieDuration(theMovie) ;
	
	ComponentResult err;
	
	NSString	*prefString = [NSString stringWithFormat:@"Quicktime Export:%d", [[component valueForKey:@"subtype"] unsignedLongValue]];
	NSLog( prefString);
	
	NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey: prefString];
	char	*ptr = (char*) [data bytes];
	
	if( data) MovieExportSetSettingsFromAtomContainer (exporter, &ptr);
	
	err = MovieExportDoUserDialog(exporter, theMovie, NULL, 0, duration, &canceled);
	if(err)
	{
		NSLog(@"Got error %d when calling MovieExportDoUserDialog");
		CloseComponent(exporter);
		return nil;
	}
	if(canceled)
	{
		CloseComponent(exporter);
		return nil;
	}
	
	QTAtomContainer settings;
	err = MovieExportGetSettingsAsAtomContainer(exporter, &settings);
	if(err)
	{
		NSLog(@"Got error %d when calling MovieExportGetSettingsAsAtomContainer");
		CloseComponent(exporter);
		return nil;
	}
	
	data = [NSData dataWithBytes:*settings length:GetHandleSize(settings)];	
	[[NSUserDefaults standardUserDefaults] setObject:data forKey: prefString];
	
	DisposeHandle(settings);

	CloseComponent(exporter);
	
	return data;
}
#else
- (NSArray *)availableComponents
{
	return [NSArray array];
}

- (NSData *)getExportSettings:(QTMovie*) aMovie component:(NSDictionary*) component
{
	return 0L;
}
#endif

- (BOOL) writeMovie:(QTMovie *)movie toFile:(NSString *)file withComponent:(NSDictionary *)component withExportSettings:(NSData *)exportSettings
{
	NSDictionary *attributes = 0L;
	
	if( component && exportSettings)
	{
		attributes = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], QTMovieExport,
			[component objectForKey:@"subtype"], QTMovieExportType,
			[component objectForKey:@"manufacturer"], QTMovieExportManufacturer,
			exportSettings, QTMovieExportSettings,
			nil];
	}
	else
	{
		attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]  forKey:QTMovieFlatten];
	}
	
	WaitRendering *wait = [[WaitRendering alloc] init: NSLocalizedString(@"Movie encoding...", nil)];
	[wait showWindow:self];
	
	BOOL result = [movie writeToFile:file withAttributes:attributes];
	if( !result) NSLog(@"Couldn't write movie to file");
	
	[wait close];
	[wait release];
}

- (IBAction) setRate:(id) sender
{
	[rateValue setStringValue: [NSString stringWithFormat:@"%d im/s", [sender intValue]]];
}

- (IBAction) changeExportType:(id) sender
{
	if( [exportTypes count])
	{
		unsigned long subtype = [[[exportTypes objectAtIndex: [type indexOfSelectedItem]] valueForKey:@"subtype"] unsignedLongValue];
		
		if( subtype == kQTFileTypeMovie)  [panel setRequiredFileType:@"mov"];
		if( subtype == kQTFileTypeAVI)	[panel setRequiredFileType:@"avi"];
		if( subtype == kQTFileTypeMP4)	[panel setRequiredFileType:@"mpg4"];
		if( subtype == 'ASF_')	[panel setRequiredFileType:@"wmv"];
		
		[[NSUserDefaults standardUserDefaults] setInteger:[type indexOfSelectedItem] forKey:@"selectedMenuQuicktimeExport"];
	}
}

- (NSString*) createMovieQTKit:(BOOL) openIt :(BOOL) produceFiles :(NSString*) name
{
	NSString		*fileName;
	long			result;

	exportTypes = [self availableComponents];
	
	panel = [NSSavePanel savePanel];
	
	if( produceFiles)
	{
		result = NSFileHandlingPanelOKButton;
		
		[[NSFileManager defaultManager] removeFileAtPath: [documentsDirectory() stringByAppendingFormat:@"/TEMP/IPHOTO/"] handler: 0L];
		[[NSFileManager defaultManager] createDirectoryAtPath: [documentsDirectory() stringByAppendingFormat:@"/TEMP/IPHOTO/"] attributes: 0L];
		
		fileName = [documentsDirectory() stringByAppendingFormat:@"/TEMP/OsiriXMovie.mov"];
	}
	else
	{
		[panel setCanSelectHiddenExtension:YES];
		[panel setRequiredFileType:@"mov"];
		
		[panel setAccessoryView: view];
		[type removeAllItems];
		
		if( [exportTypes count])
			[type addItemsWithTitles: [exportTypes valueForKey: @"name"]];
		
		[type selectItemAtIndex: [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedMenuQuicktimeExport"]];
		[self changeExportType: self];
		
		result = [panel runModalForDirectory:0L file:name];
		
		fileName = [panel filename];
	}
	
	if( result == NSFileHandlingPanelOKButton)
	{
		int				maxImage, myState, curSample = 0;
		QTTime			curTime;
		QTMovie			*mMovie = 0L;
		BOOL			aborted = NO;
		
		if( produceFiles == NO)
		{
			[[QTMovie movie] writeToFile: [fileName stringByAppendingString:@"temp"] withAttributes: 0L];
			
			mMovie = [QTMovie movieWithFile:[fileName stringByAppendingString:@"temp"] error:nil];
			[mMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
			
			long long timeValue = 600 / [rateSlider intValue];
			long timeScale = 600;
			
			curTime = QTMakeTime(timeValue, timeScale);
		}
		
		Wait    *wait = [[Wait alloc] initWithString: @"Movie Export"];
		[wait showWindow:self];
		
		// For each sample...
		maxImage = numberOfFrames;
		
		[wait setCancel:YES];
		[[wait progress] setMaxValue:maxImage];
		
		NSDictionary *myDict = [NSDictionary dictionaryWithObject: @"jpeg" forKey: QTAddImageCodecType];
		
		for (curSample = 0; curSample < maxImage; curSample++) 
		{
			NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
			
			[wait incrementBy:1];
			
			NSImage	*im = [object performSelector: selector withObject: [NSNumber numberWithLong: curSample] withObject:[NSNumber numberWithLong: numberOfFrames]];
			
			if( im)
			{
				if( produceFiles == NO)
				{
					[mMovie addImage:im forDuration:curTime withAttributes: myDict];
				}
				else
				{
					NSString *curFile = [documentsDirectory() stringByAppendingFormat:@"/TEMP/IPHOTO/OsiriX%4d.tif", curSample];
					
					[[im TIFFRepresentation] writeToFile:curFile atomically:YES];
				}
							
				[im release];
			}
			
			if( [wait aborted])
			{
				curSample = maxImage;
				aborted = YES;
			}
			[pool release];
		}
		[wait close];
		[wait release];
		
		if( produceFiles == NO && aborted == NO)
		{
			[[NSFileManager defaultManager] removeFileAtPath:fileName handler:0L];
			
			if( aborted == NO)
			{
				NSData	*exportSettings = 0L;
				id		component = 0L;
				
				if( [exportTypes count])
				{
					exportSettings = [self getExportSettings: mMovie component: [exportTypes objectAtIndex: [type indexOfSelectedItem]]];
					component = [exportTypes objectAtIndex: [type indexOfSelectedItem]];
				}
				
				[self writeMovie:mMovie toFile:fileName withComponent: component withExportSettings: exportSettings];
				
				if( openIt)
				{
					NSWorkspace *ws = [NSWorkspace sharedWorkspace];
					[ws openFile:fileName];
				}
			}
			[[NSFileManager defaultManager] removeFileAtPath:[fileName stringByAppendingString:@"temp"] handler:0L];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"OsiriXNewMovieSaved" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileName, @"path", nil]];
		return fileName;
	}
	
	return 0L;
}
//#endif

@end
