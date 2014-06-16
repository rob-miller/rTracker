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
#import "rTracker-resource.h"

@implementation trackerList

@synthesize topLayoutNames=_topLayoutNames, topLayoutIDs=_topLayoutIDs, topLayoutPriv=_topLayoutPriv, topLayoutReminderCount=_topLayoutReminderCount;
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
	//int c;
	
	//DBGLog(@"Initializing top level dtabase!");
	self.dbName=@"topLevel.sqlite3";
	[self getTDb];
	
	self.sql = @"create table if not exists toplevel (rank integer, id integer unique, name text, priv integer, remindercount integer);";
	[self toExecSql];
    self.sql = @"alter table toplevel add column remindercount int";  // new column added for reminders
    [self toExecSqlIgnErr];
    
	//self.sql = @"select count(*) from toplevel;";
	//DBGLog(@"toplevel at open contains %d entries",[self toQry2Int]);

	self.sql = @"create table if not exists info (val integer, name text);";
	[self toExecSql];

    self.sql = @"select count(*) from info where name='rtdb_version'";
    if (0 == [self toQry2Int]) {
        DBGLog(@"rtdb_version not set");
        self.sql = [NSString stringWithFormat: @"insert into info (name, val) values ('rtdb_version',%i);",RTDB_VERSION];
        [self toExecSql];
/*
#if DEBUGLOG
    } else {
        self.sql = @"select val from info where name='rtdb_version'";
        DBGLog(@"rtdb_version= %d",[self toQry2Int]);
#endif
 */
    }
    
	self.sql = nil;	
}	

- (id) init {
	//DBGLog(@"init trackerList");
	
	if ((self = [super init])) {
		_topLayoutNames = [[NSMutableArray alloc] init];
		_topLayoutIDs = [[NSMutableArray alloc] init];
        _topLayoutPriv = [[NSMutableArray alloc] init];
        _topLayoutReminderCount = [[NSMutableArray alloc] init];
        
		[self initTDb];
	} 
	return self;
}


#pragma mark -
#pragma mark TopLayoutTable <-> db support 

- (void) loadTopLayoutTable {
    //DBGTLIST(self);
	[self.topLayoutNames removeAllObjects];
	[self.topLayoutIDs removeAllObjects];
    [self.topLayoutPriv removeAllObjects];
    [self.topLayoutReminderCount removeAllObjects];
    
	//self.sql = @"select * from toplevel";
	//[self toQry2Log];
	
	self.sql = [NSString stringWithFormat:@"select id, name, priv, remindercount from toplevel where priv <= %i order by rank;",[privacyV getPrivacyValue]];
	[self toQry2AryISII:self.topLayoutIDs s1:self.topLayoutNames i2:self.topLayoutPriv i3:self.topLayoutReminderCount];
	self.sql = nil;
	DBGLog(@"loadTopLayoutTable finished, priv=%i tlt= %@",[privacyV getPrivacyValue],self.topLayoutNames);
    //DBGTLIST(self);
}

- (void) addToTopLayoutTable:(trackerObj*) tObj {
    DBGLog(@"%@ toid %d",tObj.trackerName, tObj.toid);
    
    [self.topLayoutIDs addObject:[NSNumber numberWithInt:tObj.toid]];
    [self.topLayoutNames addObject:tObj.trackerName];
    [self.topLayoutPriv addObject:[NSNumber numberWithInt:[[tObj.optDict valueForKey:@"privacy"] intValue]]];
    [self.topLayoutReminderCount addObject:[NSNumber numberWithInt:[tObj enabledReminderCount]]];
    
    [self confirmTopLayoutEntry:tObj];
}

- (void) confirmTopLayoutEntry:(trackerObj *) tObj {
	//self.sql = @"select * from toplevel";
	//[self toQry2Log];
    //DBGLog(@"%@ toid %d",tObj.trackerName, tObj.toid);
	//DBGTLIST(self);
	self.sql = [NSString stringWithFormat:@"select rank from toplevel where id=%d;",tObj.toid];
	int rank = [self toQry2Int];  // returns 0 if not found 
	if (rank == 0) {
        DBGLog(@"rank not found");
	} else {
        self.sql = [NSString stringWithFormat:@"select count(*) from toplevel where rank=%i and priv <= %i;",rank,[privacyV getPrivacyValue]];
        if (1 < [self toQry2Int]) {
            DBGLog(@"too many at rank %i",rank);
            rank = 0;
        }
    }
	if (rank == 0) {
		rank = [self.topLayoutNames count];  // so put at end
        DBGLog(@"rank adjust, set to %d",rank);
    }
    
    dbgNSAssert(tObj.toid,@"confirmTLE: toid=0");
    int privVal = [[tObj.optDict valueForKey:@"privacy"] intValue];
    privVal = (privVal ? privVal : PRIVDFLT);  // default is 1 not 0;
	self.sql = [NSString stringWithFormat: @"insert or replace into toplevel (rank, id, name, priv, remindercount) values (%i, %i, \"%@\", %i, %i);",
				rank, tObj.toid, [rTracker_resource toSqlStr:tObj.trackerName], privVal,[tObj enabledReminderCount]];
	[self toExecSql];
	self.sql = nil;
	
	// call loadTopLayoutTable before using:  [topLayoutTable insertObject:name atIndex:rank];
}

- (void) reorderFromTLT {
    //DBGTLIST(self);
	int nrank=0;
	for (NSString *tracker in self.topLayoutNames) {
		//DBGLog(@" %@ to rank %d",tracker,nrank);
		self.sql = [NSString stringWithFormat :@"update toplevel set rank = %d where name = \"%@\";",nrank+1,[ rTracker_resource toSqlStr:tracker]];
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		nrank++;
	}
	self.sql = nil;
    //DBGTLIST(self);
}

- (void) reloadFromTLT {
    //DBGTLIST(self);
	int nrank=0;
	self.sql = [NSString stringWithFormat:@"delete from toplevel where priv <= %d;",[privacyV getPrivacyValue] ];
	[self toExecSql];
	for (NSString *tracker in self.topLayoutNames) {
		NSInteger tid = [[self.topLayoutIDs objectAtIndex:nrank] intValue];
		NSInteger priv = [[self.topLayoutPriv objectAtIndex:nrank] intValue];
		NSInteger rc = [[self.topLayoutReminderCount objectAtIndex:nrank] intValue];
        
		//DBGLog(@" %@ id %d to rank %d",tracker,tid,nrank);
		self.sql = [NSString stringWithFormat: @"insert into toplevel (rank, id, name, priv,remindercount) values (%i, %d, \"%@\", %d, %d);",nrank+1,tid,[rTracker_resource toSqlStr:tracker], priv,rc];  // rank in db always non-0
		[self toExecSql];  // better if used bind vars, but this keeps access in tObjBase
		self.sql = nil;
		nrank++;
	}
}

- (int) getTIDfromIndex:(NSUInteger)ndx {
	return [[self.topLayoutIDs objectAtIndex:ndx] intValue];
}

- (int) getPrivFromLoadedTID:(int)tid {
    
    int ndx = [self.topLayoutIDs indexOfObject:[NSNumber numberWithInt:tid]];
    if (NSNotFound == ndx) {
        return MAXPRIV;
    }
    return [[self.topLayoutPriv objectAtIndex:ndx] intValue];
    
    //return [[self.topLayoutPriv objectAtIndex:[self.topLayoutIDs indexOfObject:[NSNumber numberWithInt:tid]]] intValue];
}

- (BOOL) checkTIDexists:(NSNumber*)tid {
    self.sql = [NSString stringWithFormat:@"select id from toplevel where id=%d",[tid intValue]];
    int rslt = [self toQry2Int];
    return (0 != rslt);
}

// return tid for first matching name
- (int) getTIDfromName:(NSString *)str {
    int ndx=0;
    for (NSString *tname in self.topLayoutNames) {
        if ([tname isEqualToString:str])
            return [self getTIDfromIndex:ndx];
        ndx++;
    }
    return 0;
}

// return aaray of TIDs which match name, order by rank
- (NSArray*) getTIDFromNameDb:(NSString*)str {
    NSMutableArray *i1 = [[NSMutableArray alloc] init];
    self.sql=[NSString stringWithFormat:@"select id from toplevel where name=\"%@\" order by rank",[rTracker_resource toSqlStr:str]];
    [self toQry2AryI:i1];
    NSArray *ra = [NSArray arrayWithArray:i1];
    return ra;
}

////
//
// 26.xi.12 previously this would modify dictionary to set its TID to non-conflicting value, now calls updateTID to move existing trackers with conflicting TID to new TID
//
////
- (void) fixDictTID:(NSDictionary*)tdict {
    NSNumber *tid = [tdict objectForKey:@"tid"];
    [self minUniquev:[tid intValue]];
    
    if ([self checkTIDexists:tid]) {
        //[tdict setValue:[NSNumber numberWithInt:[self getUnique]] forKey:@"tid"];
        //DBGLog(@"  changed to: %@",[tdict objectForKey:@"tid"]);
        [self updateTID:[tid intValue] new:[self getUnique]];
    }
}

- (void) updateTLtid:(int)old new:(int)new {
    if (-1 == new) {
        self.sql = [NSString stringWithFormat:@"delete from toplevel where id=%d",old];
    } else if (old == new) {
        return;
    } else {
        self.sql = [NSString stringWithFormat:@"update toplevel set id=%d where id=%d",new, old ];
    }
    [self toExecSql];  
    self.sql = nil;
    
    [self loadTopLayoutTable];
    
    DBGLog(@"changed toplevel TID %D to %d",old,new);
}

- (void) updateTID:(int)old new:(int)new {

    if (old == new) return;
    if ([self checkTIDexists:[NSNumber numberWithInt:new]]) {
        [self updateTID:new new:[self getUnique]];
    }

    // rename file
    NSString *oldFname= [NSString stringWithFormat:@"trkr%d.sqlite3",old];
    NSString *newFname= [NSString stringWithFormat:@"trkr%d.sqlite3",new];
    NSError *error;

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm moveItemAtPath:[rTracker_resource ioFilePath:oldFname access:DBACCESS]
                    toPath:[rTracker_resource ioFilePath:newFname access:DBACCESS] error:&error] != YES) {
        DBGErr(@"Unable to move file %@ to %@: %@", oldFname, newFname, [error localizedDescription]);
    } else {
        // update toplevel if file rename went ok;
        [self updateTLtid:old new:new];
    }
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
	DBGTLIST(self);

	id tName = [self.topLayoutNames objectAtIndex:fromRow];
	id tID = [self.topLayoutIDs objectAtIndex:fromRow];
    id tPriv = [self.topLayoutPriv objectAtIndex:fromRow];
	id tRC= [self.topLayoutReminderCount objectAtIndex:fromRow];
    
	[self.topLayoutNames removeObjectAtIndex:fromRow];
	[self.topLayoutIDs removeObjectAtIndex:fromRow];
	[self.topLayoutPriv removeObjectAtIndex:fromRow];
	[self.topLayoutReminderCount removeObjectAtIndex:fromRow];
	
	[self.topLayoutNames insertObject:tName atIndex:toRow];
	[self.topLayoutIDs insertObject:tID atIndex:toRow];
	[self.topLayoutPriv insertObject:tPriv atIndex:toRow];
	[self.topLayoutReminderCount insertObject:tRC atIndex:toRow];
	
    
	//DBGTLIST(self);
}

- (trackerObj *) copyToConfig : (trackerObj *) srcTO {
	//DBGLog(@"copyToConfig: src id= %d %@",srcTO.toid,srcTO.trackerName);
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
	}
	
	[newTO saveConfig];
	//DBGLog(@"copyToConfig: copy id= %d %@",newTO.toid,newTO.trackerName);
	
	return newTO;
}

- (void) deleteTrackerAllRow:(NSUInteger)row
{
	int tid = [[self.topLayoutIDs objectAtIndex:row] intValue];
	trackerObj *to = [[trackerObj alloc] init:tid];
    DBGLog(@"delete tracker all name:%@ id:%d rowtext= %@", to.trackerName, to.toid, [self.topLayoutNames objectAtIndex:row] );
    [to clearScheduledReminders];
	[to deleteTrackerDB];
	[self.topLayoutNames removeObjectAtIndex:row];
	[self.topLayoutIDs removeObjectAtIndex:row];
    [self.topLayoutPriv removeObjectAtIndex:row];
    [self.topLayoutReminderCount removeObjectAtIndex:row];
}

- (void) deleteTrackerRecordsRow:(NSUInteger)row
{
	int tid = [[self.topLayoutIDs objectAtIndex:row] intValue];
	trackerObj *to = [[trackerObj alloc] init:tid];
	[to deleteTrackerRecordsOnly];
}

- (void) exportAll {
    float ndx=1.0;
    float all = [self.topLayoutIDs count];
    
    for (NSNumber *tid in self.topLayoutIDs) {
        trackerObj *to = [[trackerObj alloc] init:[tid intValue]];
        [to saveToItunes];
        
        [rTracker_resource setProgressVal:(ndx/all)];
        ndx += 1.0;
    }
}

- (BOOL) testConflict:(NSString*) tname {
    for (NSString *n in self.topLayoutNames) {
        if ([tname isEqualToString:n]) {
            return TRUE;
        }
    }
    return FALSE;
}

// add _n to trackername - used only when adding samples
- (void) deConflict:(trackerObj*)newTracker {
    if (! [self testConflict:newTracker.trackerName])
        return;

    int i=2;
    NSString *tstr;
    
    while ([self testConflict:(tstr = [NSString stringWithFormat:@"%@ %d",newTracker.trackerName,i++])]) ;
    newTracker.trackerName = tstr;
}

- (void) wipeOrphans {
    self.sql = @"select id, name from toplevel order by id";
    NSMutableArray *i1 = [[NSMutableArray alloc]init];
    NSMutableArray *s1 = [[NSMutableArray alloc]init];
    [self toQry2AryIS:i1 s1:s1];
    NSMutableDictionary *dictTid2Ndx = [[NSMutableDictionary alloc]init];
    NSUInteger c = [i1 count];
    NSUInteger i;
    for (i=0;i<c;i++) {
        [dictTid2Ndx setObject:[NSNumber numberWithUnsignedInt:i] forKey:[i1 objectAtIndex:i]];
    }
    
    NSError *err;
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[rTracker_resource ioFilePath:@"" access:DBACCESS] error:&err];
    NSMutableDictionary *dictTid2Filename = [[NSMutableDictionary alloc]init];
    
    if (nil == fileList) {
        DBGLog(@"error getting file list: %@",err);
    } else {
        NSString *fn;
        for (fn in fileList) {
            int ftid = [[fn substringFromIndex:4] intValue];
            if (ftid) {
                [dictTid2Filename setObject:fn forKey:[NSNumber numberWithInt:ftid]];
                NSNumber *ftidNdx = [dictTid2Ndx objectForKey:[NSNumber numberWithInt:ftid]];
                if (ftidNdx) {
                    DBGLog(@"%@ iv: %d toplevel: %@",fn, ftid, [s1 objectAtIndex:[ftidNdx unsignedIntegerValue]]);
                } else {
                    BOOL doDel=YES;
                    if (doDel) {
                        DBGLog(@"deleting orphan %d file %@",ftid,fn);
                        [rTracker_resource deleteFileAtPath:[rTracker_resource ioFilePath:fn access:DBACCESS]];
                    } else {
                        //trackerObj *to = [[trackerObj alloc]init:ftid];
                        DBGLog(@"%@ iv: %d orphan file: %@",fn, ftid, [[trackerObj alloc]init:ftid].trackerName );
                    }
                }
                
            } else if ([fn hasPrefix:@"stash_trkr"]) {
                DBGLog(@"deleting stashed tracker %@",fn);
                [rTracker_resource deleteFileAtPath:[rTracker_resource ioFilePath:fn access:DBACCESS]];
            }
        }
        NSNumber *tlTid;
        i=0;
        for (tlTid in i1) {
            NSString *tltidFilename = [dictTid2Filename objectForKey:tlTid];
            if (tltidFilename) {
                DBGLog(@"tid %@ name %@ file %@",tlTid,[s1 objectAtIndex:i],tltidFilename);
            } else {
                NSString *tname = [s1 objectAtIndex:i];
                DBGLog(@"tid %@ name %@ no file found - delete from tlist",tlTid,tname);
                self.sql = [NSString stringWithFormat:@"delete from toplevel where id=%@ and name='%@'",tlTid, tname];
                [self toExecSql];
            }
            i++;
        }
    }
    
    self.sql = nil;
    
}

- (void) restoreTracker:(NSString*)fn ndx:(NSUInteger)ndx {
    int ftid = [[fn substringFromIndex:ndx] intValue];
    trackerObj *to;
    int newTid = ftid;
    
    if ([self checkTIDexists:[NSNumber numberWithInt:ftid]]) {
        newTid = [self getUnique];
    }
    NSString *newFn = [NSString stringWithFormat:@"trkr%d.sqlite3",newTid];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;

    while ([fm fileExistsAtPath:[rTracker_resource ioFilePath:newFn access:DBACCESS]]) {
        newTid = [self getUnique];
        newFn = [NSString stringWithFormat:@"trkr%d.sqlite3",newTid];
    }
    
    if ([fm moveItemAtPath:[rTracker_resource ioFilePath:fn access:DBACCESS]
                    toPath:[rTracker_resource ioFilePath:newFn access:DBACCESS] error:&error] != YES) {
        DBGWarn(@"Unable to move file %@ to %@: %@", fn, newFn, [error localizedDescription]);  // only if gtUnique fails ?
    }

    ftid = newTid;
    
    to = [[trackerObj alloc] init:ftid];
    if (nil == to.trackerName) {
        DBGWarn(@"deleting empty tracker file %@",newFn);
        if ([fm removeItemAtPath:[rTracker_resource ioFilePath:newFn access:DBACCESS] error:&error] != YES) {
            DBGLog(@"Unable to delete file %@: %@", newFn, [error localizedDescription]); 
        }
    } else {
        NSString *newName = [@"recovered: " stringByAppendingString:to.trackerName];
        to.trackerName = newName;
        [self addToTopLayoutTable:to];
    }
}

- (BOOL) recoverOrphans {
    BOOL didRecover=NO;
    self.sql = @"select id, name from toplevel order by id";
    NSMutableArray *i1 = [[NSMutableArray alloc]init];
    NSMutableArray *s1 = [[NSMutableArray alloc]init];
    [self toQry2AryIS:i1 s1:s1];
    NSMutableDictionary *dictTid2Ndx = [[NSMutableDictionary alloc]init];
    NSUInteger c = [i1 count];
    NSUInteger i;
    for (i=0;i<c;i++) {
        [dictTid2Ndx setObject:[NSNumber numberWithUnsignedInt:i] forKey:[i1 objectAtIndex:i]];
    }
    
    NSError *err;
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[rTracker_resource ioFilePath:@"" access:DBACCESS] error:&err];
    NSMutableDictionary *dictTid2Filename = [[NSMutableDictionary alloc]init];
    
    if (nil == fileList) {
        DBGLog(@"error getting file list: %@",err);
    } else {
        NSString *fn;
        for (fn in fileList) {
            
            int ftid = [[fn substringFromIndex:4] intValue];
            if (ftid && [fn hasPrefix:@"trkr"] && [fn hasSuffix:@"sqlite3"]) {
                [dictTid2Filename setObject:fn forKey:[NSNumber numberWithInt:ftid]];
                NSNumber *ftidNdx = [dictTid2Ndx objectForKey:[NSNumber numberWithInt:ftid]];
                if (ftidNdx) {
                    DBGLog(@"%@ iv: %d toplevel: %@",fn, ftid, [s1 objectAtIndex:[ftidNdx unsignedIntegerValue]]);
                } else {
                    [self restoreTracker:fn ndx:4];
                    didRecover = YES;
                    /*
                    BOOL doDel=YES;
                    if (doDel) {
                        DBGLog(@"deleting orphan %d file %@",ftid,fn);
                        [rTracker_resource deleteFileAtPath:[rTracker_resource ioFilePath:fn access:DBACCESS]];
                    } else {
                        trackerObj *to = [[trackerObj alloc]init:ftid];
                        DBGLog(@"%@ iv: %d orphan file: %@",fn, ftid, to.trackerName );
                        [to release];
                    }
                     */
                }
                
            } else if ([fn hasPrefix:@"stash_trkr"]) {
                [self restoreTracker:fn ndx:10];
                didRecover=YES;
                //DBGLog(@"deleting stashed tracker %@",fn);
                //[rTracker_resource deleteFileAtPath:[rTracker_resource ioFilePath:fn access:DBACCESS]];
            }
        }
        NSNumber *tlTid;
        i=0;
        for (tlTid in i1) {
            NSString *tltidFilename = [dictTid2Filename objectForKey:tlTid];
            if (tltidFilename) {
                DBGLog(@"tid %@ name %@ file %@",tlTid,[s1 objectAtIndex:i],tltidFilename);
            } else {
                NSString *tname = [s1 objectAtIndex:i];
                DBGLog(@"tid %@ name %@ no file found - delete from tlist",tlTid,tname);
                self.sql = [NSString stringWithFormat:@"delete from toplevel where id=%@ and name='%@'",tlTid, tname];
                [self toExecSql];
            }
            i++;
        }
    }
    
    self.sql = nil;
    
    return didRecover;
}

@end
