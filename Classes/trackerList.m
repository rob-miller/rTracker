//
//  trackerList.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "trackerList.h"
#import "privacyV.h"
#import "dbg-defs.h"

@implementation trackerList

@synthesize topLayoutNames, topLayoutIDs, topLayoutPriv;
//@synthesize tObj;

/******************************
 *
 * trackerList db tables
 *
 *   toplevel: rank(int) ; id(int) ; name(text) ; priv(int)
 *      primarily for entry listbox of tracker names
 *
 ******************************/ 

#pragma mark -
#pragma mark core object methods and support

- (void) initTDb {
	int c;
	
	DBGLog(@"Initializing top level dtabase!");
	self.dbName=@"topLevel.sqlite3";
	[self getTDb];
	
	self.sql = @"create table if not exists toplevel (rank integer, id integer unique, name text, priv integer);";
	[self toExecSql];
	self.sql = @"select count(*) from toplevel;";
	c = [self toQry2Int];
	DBGLog(@"toplevel at open contains %d entries",c);
	
	self.sql = nil;	
}	

- (id) init {
	DBGLog(@"init trackerList");
	
	if ((self = [super init])) {
		topLayoutNames = [[NSMutableArray alloc] init];
		//self.topLayoutNames = [[NSMutableArray alloc] init];
		topLayoutIDs = [[NSMutableArray alloc] init];
		//self.topLayoutIDs = [[NSMutableArray alloc] init];
		[self initTDb];
	} 
	return self;
}

- (void) dealloc {
	DBGLog(@"trackerlist dealloc");
	self.topLayoutNames = nil;
	[topLayoutNames release];
	self.topLayoutIDs = nil;
	[topLayoutIDs release];
	[super dealloc];
}

#pragma mark -
#pragma mark TopLayoutTable <-> db support 

- (void) loadTopLayoutTable {
	[self.topLayoutNames removeAllObjects];
	[self.topLayoutIDs removeAllObjects];

	//self.sql = @"select * from toplevel";
	//[self toQry2Log];
	
	self.sql = [NSString stringWithFormat:@"select id, name, priv from toplevel where priv <= %i order by rank;",[privacyV getPrivacyValue]];
	[self toQry2AryISI:self.topLayoutIDs s1:self.topLayoutNames i2:self.topLayoutPriv];
	self.sql = nil;
	DBGLog(@"loadTopLayoutTable finished, tlt= %@",self.topLayoutNames);
}

- (void) confirmTopLayoutEntry:(trackerObj *) tObj {
	//self.sql = @"select * from toplevel";
	//[self toQry2Log];
	
	self.sql = [NSString stringWithFormat:@"select rank from toplevel where id=%d;",tObj.toid];
	int rank = [self toQry2Int];  // returns 0 if not found
	if (rank == 0) {
		rank = [self.topLayoutNames count] +1;  // so put at end
	}
	dbgNSAssert(tObj.toid,@"confirmTLE: toid=0");
	self.sql = [NSString stringWithFormat: @"insert or replace into toplevel (rank, id, name, priv) values (%i, %i, \"%@\", %i);",
				rank, tObj.toid, tObj.trackerName, [[tObj.optDict valueForKey:@"privacy"] intValue]]; 
	[self toExecSql];
	self.sql = nil;
	
	// call loadTopLayoutTable before using:  [topLayoutTable insertObject:name atIndex:rank];
}

- (void) reorderFromTLT {
	int nrank=0;
	for (NSString *tracker in self.topLayoutNames) {
		DBGLog(@" %@ to rank %d",tracker,nrank);
		self.sql = [NSString stringWithFormat :@"update toplevel set rank = %d where name = \"%@\";",nrank,tracker];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		nrank++;
	}
	self.sql = nil;
}

- (void) reloadFromTLT {
	int nrank=0;
	self.sql = [NSString stringWithFormat:@"delete from toplevel where priv <= %d;",[privacyV getPrivacyValue] ];
	[self toExecSql];
	for (NSString *tracker in self.topLayoutNames) {
		NSInteger tid = [[self.topLayoutIDs objectAtIndex:nrank] intValue];
		NSInteger priv = [[self.topLayoutPriv objectAtIndex:nrank] intValue];
		
		DBGLog(@" %@ id %d to rank %d",tracker,tid,nrank);
		self.sql = [NSString stringWithFormat: @"insert into toplevel (rank, id, name, priv) values (%i, %d, \"%@\", %d);",nrank,tid,tracker, priv];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		self.sql = nil;
		nrank++;
	}
}

- (int) getTIDfromIndex:(NSUInteger)ndx {
	return [[self.topLayoutIDs objectAtIndex:ndx] intValue];
}

- (int) getTIDfromName:(NSString *)str {
    int ndx=0;
    for (NSString *tname in self.topLayoutNames) {
        if ([tname isEqualToString:str])
            return [self getTIDfromIndex:ndx];
        ndx++;
    }
    return 0;
}

/*
 // discard for now, write each tracker as csv ile
 
#pragma mark -
#pragma mark write tracker list xls file

- (void) writeTListXLS:(NSFileHandle*)nsfh {
	
	for (id *tID in self.topLayoutIDs) {
		trackerObj *to = [[trackerObj alloc] init:[(NSNumber*)tID intValue]];
		[to writeTrackerXLS:nsfh];
		[to release];
	}
}
*/

#pragma mark -
#pragma mark tracker manipulation methods

- (void) reorderTLT : (NSUInteger) fromRow toRow:(NSUInteger)toRow
{
	
	id tName = [[self.topLayoutNames objectAtIndex:fromRow] retain];
	id tID = [[self.topLayoutIDs objectAtIndex:fromRow] retain];
	
	[self.topLayoutNames removeObjectAtIndex:fromRow];
	[self.topLayoutIDs removeObjectAtIndex:fromRow];
	
	[self.topLayoutNames insertObject:tName atIndex:toRow];
	[self.topLayoutIDs insertObject:tID atIndex:toRow];
	
	[tName release];
	[tID release];
}

- (trackerObj *) copyToConfig : (trackerObj *) srcTO {
	DBGLog(@"copyToConfig: src id= %d %@",srcTO.toid,srcTO.trackerName);
	trackerObj *newTO = [trackerObj alloc];
	newTO.toid = [self getUnique];
	newTO = [newTO init];
	
	NSString *oTN = srcTO.trackerName;
	//NSString *nTN = [[NSString alloc] initWithString:oTN];
	//newTO.trackerName = nTN;
	// release as well
	newTO.trackerName = [NSString stringWithString:oTN];
	
	//NSEnumerator *enumer = [srcTO.valObjTable objectEnumerator];
	//valueObj *vo;
	//while (vo = (valueObj *) [enumer nextObject]) {
	for (valueObj *vo in srcTO.valObjTable) {
		valueObj *newVO = [newTO copyVoConfig:vo];
		[newTO addValObj:newVO];
		[newVO release];
	}
	
	[newTO saveConfig];
	DBGLog(@"copyToConfig: copy id= %d %@",newTO.toid,newTO.trackerName);
	
	return newTO;
}

- (void) deleteTrackerAllRow:(NSUInteger)row
{
	int tid = [[self.topLayoutIDs objectAtIndex:row] intValue];
	trackerObj *to = [[trackerObj alloc] init:tid];
	[to deleteTrackerDB];
	[to release];
	[self.topLayoutNames removeObjectAtIndex:row];
	[self.topLayoutIDs removeObjectAtIndex:row];
}

- (void) deleteTrackerRecordsRow:(NSUInteger)row
{
	int tid = [[self.topLayoutIDs objectAtIndex:row] intValue];
	trackerObj *to = [[trackerObj alloc] init:tid];
	[to deleteTrackerRecordsOnly];
	[to release];
}


@end
