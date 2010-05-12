//
//  trackerObj.h
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"

#import "tObjBase.h"

@interface trackerObj : tObjBase {

	NSMutableArray *valObjTable;
	NSString *trackerName;
}

@property (nonatomic,retain) NSString *trackerName;
@property (nonatomic,retain) NSMutableArray *valObjTable;

+ (NSString *) makeSafeStr : (NSString *) inStr;

- (id)init;
- (void) dealloc;

//- (void)applicationWillTerminate:(NSNotification *)notification;


@end
