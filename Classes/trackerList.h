//
//  trackerList.h
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"

#import "tObjBase.h"

#define layoutDbFilename @"layout.sqlite3"

@interface trackerList : tObjBase {
	
	NSMutableArray *topLayoutTable;
	
}

@property (nonatomic,retain) NSMutableArray *topLayoutTable;

- (id) init;
- (void) dealloc;

//- (void)applicationWillTerminate:(NSNotification *)notification;

//- (NSString *) docsDir;
//- (NSString *) layoutDbFilePath;
//- (NSString *) valuesDbFilePath;
//- (void) openDatabases;

- (void)loadTopLayoutTable;
- (void)addTopLayoutEntry:(int)rank name:(NSString *)name;
- (void)reorderFromTLT;



@end
