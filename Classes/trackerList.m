//
//  trackerList.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "trackerList.h"



@implementation trackerList

@synthesize topLayoutTable;
//@synthesize tObj;

#pragma mark -
#pragma mark Local Utilities

- (void) initTDb {
	int c;
	
	NSLog(@"Initializing top level dtabase!");
	dbName=@"topLevel.sqlite3";
	[self getTDb];
	
	sql = @"create table if not exists toplevel (rank integer, id integer unique, name text);";
	[self toExecSql];
	sql = @"select count(*) from toplevel;";
	c = [self toQry2Int];
	NSLog(@"toplevel at open contains %d entries",c);
	
	sql = nil;	
}	

#pragma mark -
#pragma mark object core 

- (id) init {
	NSLog(@"init trackerList");
	
	if (self = [super init]) {

		topLayoutTable = [[NSMutableArray alloc] init];
		[self initTDb];
		

		//[self getUnique];
		//[self getUnique];
		//[self loadTopLayoutTable];
	} 
	return self;
}

- (void) dealloc {
	NSLog(@"trackerlist dealloc");
	
	[topLayoutTable release];
	[super dealloc];
}

#pragma mark -
#pragma mark External DB Access 

- (void) loadTopLayoutTable {
	[self.topLayoutTable removeAllObjects];
	sql = @"select name from toplevel order by rank;";
	[self toQry2AryS :self.topLayoutTable];
	sql = nil;
	NSLog(@"loadTopLayoutTable finished, tlt= %@",self.topLayoutTable);
}

- (void) confirmTopLayoutEntry:(trackerObj *) tObj {
	int rank = [topLayoutTable count];

	sql = [[NSString alloc] initWithFormat: @"insert or replace into toplevel (rank, id, name) values (%i, %i, \"%@\");",
		   rank, tObj.tid, tObj.trackerName ];
	[self toExecSql];
	[sql release];
	sql = nil;
	
	// call loadTopLayoutTable before using:  [topLayoutTable insertObject:name atIndex:rank];
}

- (void) reorderFromTLT {
	int nrank=0;
	for (NSString *tracker in topLayoutTable) {
		NSLog(@" %@ to rank %d",tracker,nrank);
		sql = [[NSString alloc] initWithFormat :@"update toplevel set rank = %d where name = \"%@\";",nrank,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		[sql release];
		nrank++;
	}
}

// TODO: fix -- dangerous - drops id
- (void) reloadFromTLT {
	int nrank=0;
	sql = @"delete from toplevel;";
	[self toExecSql];
	for (NSString *tracker in topLayoutTable) {
		NSLog(@" %@ to rank %d",tracker,nrank);
		sql = [[NSString alloc] initWithFormat: @"insert into toplevel (rank, name) values (%i, \"%@\");",nrank,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		[sql release];  // this seems quite gross...
		sql = nil;
		nrank++;
		}
}



- (int) getTIDfromIndex:(NSUInteger)ndx {
	sql = [[NSString alloc] initWithFormat: @"select id from toplevel where name = \"%@\";",
		   [topLayoutTable objectAtIndex:ndx]];
	int tid = [self toQry2Int];
	[sql release];
	sql = nil;
	return tid;
}

/*
#pragma mark -
#pragma mark Notifications

- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"trackerList: notified app will terminate");
	
	//[topLayoutTable release];  // do this here or is it too early?
}
*/

@end
