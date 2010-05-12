//
//  trackerObj.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <string.h>
//#import <stdlib.h>

#import "trackerObj.h"
#import "valueObj.h"


@implementation trackerObj

@synthesize trackerName;
@synthesize valObjTable;

+ (NSString *) makeSafeStr : (NSString *) inStr {
	NSString *outStr;
	
	//NSLog(@"enter makeSafeStr: %@",inStr);
	
	char *newp = strdup([inStr UTF8String]);
	char *outp = newp;
	
	while (*newp) {
		if ((*newp >= 'a' && *newp <= 'z') ||
			(*newp >= 'A' && *newp <= 'Z') ||
			(*newp >= '0' && *newp <= '1')) {
		} else {
			*newp = '_';
		}
		newp++;
	}
	
	//NSLog(@" processed: %s",outp);
	
	outStr = [[ NSString alloc] initWithUTF8String :outp];
	
	NSLog(@"makeSafeStr finished: .%@. -> .%@.",inStr,outStr);
	free( outp );
	
	return outStr;
}

- (void) setTrackerName:(NSString *) newValue {
	if (newValue != trackerName) {
		[trackerName release];
		trackerName = [trackerObj makeSafeStr :newValue];
	}
}

- (id)init {
	//safeTName = [NSString alloc];
	NSLog(@"init trackerObj %@",trackerName);
	//dbName = [[NSString alloc] initWithFormat:@"%@.sqlite3",safeTName];
	if (self = [super init]) {
	}
	return self;
}

- (void) dealloc {
	NSLog(@"dealloc tObj: %@",trackerName);
	
	[super dealloc];
	[trackerName release];
}


/*
- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"trackerObj: notified app will terminate");
	if (dbValues != nil) {
		sqlite3_close(dbValues);
		dbValues = nil;
		NSLog(@"closed dbValues");
	}
}
*/

@end
