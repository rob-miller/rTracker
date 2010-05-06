//
//  trackerObj.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "trackerObj.h"


@implementation trackerObj

static sqlite3 *dbValues;

+ (NSString *) valuesDbFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingFormat:valuesDbFilename];
}

+ (void) getDbValues {
	if (sqlite3_open([[trackerObj valuesDbFilePath] UTF8String], &dbValues) != SQLITE_OK) {
		sqlite3_close(dbValues);
		NSAssert(0, @"error opening dbValues");
	} else {
		NSLog(@"opened dbValues");
	}
}

- (id)init {
	if (self = [super init]) {
		if (dbValues == nil) {
			[trackerObj getDbValues];
			
			UIApplication *app = [UIApplication sharedApplication];
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(applicationWillTerminate:) 
														 name:UIApplicationWillTerminateNotification
													   object:app];
		}
	}
	return self;
}
	
- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"trackerObj: notified app will terminate");
	if (dbValues != nil) {
		sqlite3_close(dbValues);
		dbValues = nil;
		NSLog(@"closed dbValues");
	}
}


@end
