//
//  trackerObj.h
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"

#define valuesDbFilename @"values.sqlite3"

@interface trackerObj : NSObject {

	//sqlite3	*dbValues;

	NSString *name;
}

- (id)init;
- (void)applicationWillTerminate:(NSNotification *)notification;

@end
