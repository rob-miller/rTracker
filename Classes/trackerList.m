//
//  trackerList.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "trackerList.h"



@implementation trackerList

@synthesize topLayoutNames, topLayoutIDs;
//@synthesize tObj;

#pragma mark -
#pragma mark Local Utilities

- (void) initTDb {
	int c;
	
	NSLog(@"Initializing top level dtabase!");
	self.dbName=@"topLevel.sqlite3";
	[self getTDb];
	
	self.sql = @"create table if not exists toplevel (rank integer, id integer unique, name text);";
	[self toExecSql];
	self.sql = @"select count(*) from toplevel;";
	c = [self toQry2Int];
	NSLog(@"toplevel at open contains %d entries",c);
	
	self.sql = nil;	
}	

#pragma mark -
#pragma mark object core 

- (id) init {
	NSLog(@"init trackerList");
	
	if (self = [super init]) {

		topLayoutNames = [[NSMutableArray alloc] init];
		topLayoutIDs = [[NSMutableArray alloc] init];
		[self initTDb];
		

		//[self getUnique];
		//[self getUnique];
		//[self loadTopLayoutTable];
	} 
	return self;
}

- (void) dealloc {
	NSLog(@"trackerlist dealloc");
	
	[topLayoutNames release];
	[topLayoutIDs release];
	[super dealloc];
}

#pragma mark -
#pragma mark External DB Access 

- (void) loadTopLayoutTable {
	[self.topLayoutNames removeAllObjects];
	[self.topLayoutIDs removeAllObjects];
	self.sql = @"select id, name from toplevel order by rank;";
	[self toQry2AryIS :(NSMutableArray *)topLayoutIDs s1: topLayoutNames];
	self.sql = nil;
	NSLog(@"loadTopLayoutTable finished, tlt= %@",self.topLayoutNames);
}

- (void) confirmTopLayoutEntry:(trackerObj *) tObj {
	int rank = [topLayoutNames count];
	NSAssert(tObj.toid,@"confirmTLE: toid=0");
	self.sql = [NSString stringWithFormat: @"insert or replace into toplevel (rank, id, name) values (%i, %i, \"%@\");",
		   rank, tObj.toid, tObj.trackerName ];
	[self toExecSql];
	//[sql release];
	self.sql = nil;
	
	// call loadTopLayoutTable before using:  [topLayoutTable insertObject:name atIndex:rank];
}

- (void) reorderFromTLT {
	int nrank=0;
	for (NSString *tracker in topLayoutNames) {
		NSLog(@" %@ to rank %d",tracker,nrank);
		self.sql = [NSString stringWithFormat :@"update toplevel set rank = %d where name = \"%@\";",nrank,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		//[sql release];
		nrank++;
	}
	self.sql = nil;
}

// TODO: fix -- dangerous - drops id
- (void) reloadFromTLT {
	int nrank=0;
	self.sql = @"delete from toplevel;";
	[self toExecSql];
	for (NSString *tracker in topLayoutNames) {
		NSInteger tid = [[topLayoutIDs objectAtIndex:nrank] intValue];

		NSLog(@" %@ id %d to rank %d",tracker,tid,nrank);
		self.sql = [NSString stringWithFormat: @"insert into toplevel (rank, id, name) values (%i, %d, \"%@\");",nrank,tid,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		self.sql = nil;
		nrank++;
	}
}



- (int) getTIDfromIndex:(NSUInteger)ndx {
	return [[self.topLayoutIDs objectAtIndex:ndx] intValue];
}

- (trackerObj *) toConfigCopy : (trackerObj *) srcTO {
	NSLog(@"toConfigCopy: src id= %d %@",srcTO.toid,srcTO.trackerName);
	trackerObj *newTO = [trackerObj alloc];
	newTO.toid = [self getUnique];
	newTO = [newTO init];
	
	NSString *oTN = srcTO.trackerName;
	NSString *nTN = [[NSString alloc] initWithString:oTN];
	newTO.trackerName = nTN;

	NSEnumerator *enumer = [srcTO.valObjTable objectEnumerator];
	valueObj *vo;
	while (vo = (valueObj *) [enumer nextObject]) {
		valueObj *newVO = [newTO voConfigCopy:vo];
		[newTO addValObj:newVO];
		[newVO release];
	}
	
	[newTO saveConfig];
	NSLog(@"toDeepCopy: copy id= %d %@",newTO.toid,newTO.trackerName);
	
	return newTO;
}

- (void) deleteTrackerAllRow:(NSUInteger)row
{
	int toid = [[self.topLayoutIDs objectAtIndex:row] intValue];
	trackerObj *to = [[trackerObj alloc] init:toid];
	[to deleteAllData];
	[to release];
	[self.topLayoutNames removeObjectAtIndex:row];
	[self.topLayoutIDs removeObjectAtIndex:row];
}

- (void) reorderTLT : (NSUInteger) fromRow toRow:(NSUInteger)toRow
{

	id tName = [[topLayoutNames objectAtIndex:fromRow] retain];
	id tID = [[topLayoutIDs objectAtIndex:fromRow] retain];
	
	[topLayoutNames removeObjectAtIndex:fromRow];
	[topLayoutIDs removeObjectAtIndex:fromRow];
	
	[topLayoutNames insertObject:tName atIndex:toRow];
	[topLayoutIDs insertObject:tID atIndex:toRow];
	
	[tName release];
	[tID release];
	
	
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
