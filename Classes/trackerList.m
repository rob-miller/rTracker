/***************
 trackerList.m
 Copyright 2010-2016 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

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
	
	NSString *sql = @"create table if not exists toplevel (rank integer, id integer unique, name text, priv integer, remindercount integer);";
    [self toExecSql:sql];
    // assume all old users have updated columns by now
    //sql = @"alter table toplevel add column remindercount int";  // new column added for reminders
    //[self toExecSqlIgnErr:sql];
    
	//self.sql = @"select count(*) from toplevel;";
	//DBGLog(@"toplevel at open contains %d entries",[self toQry2Int:sql]);

	sql = @"create table if not exists info (name text unique, val integer);";
    [self toExecSql:sql];
    
    sql = @"select max(val) from info where name='rtdb_version'";
    int dbVer = [self toQry2Int:sql];
    if (0 == dbVer) {  // 0 means no entry so need to initialise
        DBGLog(@"rtdb_version not set");
        sql = [NSString stringWithFormat: @"insert into info (name, val) values ('rtdb_version',%i);",RTDB_VERSION];
        [self toExecSql:sql];
    } else {
        
        if (1 == dbVer) {
            // fix info table to be unique on name
            sql = @"select max(val) from info where name='samples_version'";
            int samplesVer = [self toQry2Int:sql];
            sql = @"select max(val) from info where name='demos_version'";
            int demosVer = [self toQry2Int:sql];
            sql = @"drop table info";
            [self toExecSql:sql];
            sql = @"create table if not exists info (name text unique, val integer);";
            [self toExecSql:sql];
            sql = [NSString stringWithFormat: @"insert into info (name, val) values ('rtdb_version',%i);",RTDB_VERSION];  // upgraded now
            [self toExecSql:sql];
            sql = [NSString stringWithFormat: @"insert into info (name, val) values ('demos_version',%i);",demosVer];
            [self toExecSql:sql];
            sql = [NSString stringWithFormat: @"insert into info (name, val) values ('samples_version',%i);",samplesVer];
            [self toExecSql:sql];
        }
    }

    
	//self.sql = nil;
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
	
	NSString *sql = [NSString stringWithFormat:@"select id, name, priv, remindercount from toplevel where priv <= %i order by rank;",[privacyV getPrivacyValue]];
	[self toQry2AryISII:self.topLayoutIDs s1:self.topLayoutNames i2:self.topLayoutPriv i3:self.topLayoutReminderCount sql:sql];
	//self.sql = nil;
	DBGLog(@"loadTopLayoutTable finished, priv=%i tlt= %@",[privacyV getPrivacyValue],self.topLayoutNames);
    //DBGTLIST(self);
}

- (void) addToTopLayoutTable:(trackerObj*) tObj {
    DBGLog(@"%@ toid %ld",tObj.trackerName, (long)tObj.toid);
    
    [self.topLayoutIDs addObject:@(tObj.toid)];
    [self.topLayoutNames addObject:tObj.trackerName];
    [self.topLayoutPriv addObject:@([[tObj.optDict valueForKey:@"privacy"] intValue])];
    [self.topLayoutReminderCount addObject:@([tObj enabledReminderCount])];
    
    [self confirmToplevelEntry:tObj];
}

/*
 ensure there is accurate entry in db table toplevel for passed trackerObj
 */
- (void) confirmToplevelEntry:(trackerObj *) tObj {
	//self.sql = @"select * from toplevel";
	//[self toQry2Log];
    //DBGLog(@"%@ toid %d",tObj.trackerName, tObj.toid);
	//DBGTLIST(self);
	NSString *sql = [NSString stringWithFormat:@"select rank from toplevel where id=%ld;",(long)tObj.toid];
    NSInteger rank = [self toQry2Int:sql];  // returns 0 if not found
	if (rank == 0) {
        DBGLog(@"rank not found");
	} else {
        sql = [NSString stringWithFormat:@"select count(*) from toplevel where rank=%li;",(long)rank];
        if (1 < [self toQry2Int:sql]) {
            DBGLog(@"too many at rank %li",(long)rank);
            rank = 0;
        }
    }
	if (rank == 0) {
        sql = @"select max(rank) from toplevel;";   // so put at end
        rank = [self toQry2Int:sql] +1;
        DBGLog(@"rank adjust, set to %ld",(long)rank);
    }
    
    dbgNSAssert(tObj.toid,@"confirmTLE: toid=0");
    int privVal = [[tObj.optDict valueForKey:@"privacy"] intValue];
    privVal = (privVal ? privVal : PRIVDFLT);  // default is 1 not 0;
	sql = [NSString stringWithFormat: @"insert or replace into toplevel (rank, id, name, priv, remindercount) values (%li, %li, \"%@\", %i, %i);",
				(long)rank, (long)tObj.toid, [rTracker_resource toSqlStr:tObj.trackerName], privVal,[tObj enabledReminderCount]];
    [self toExecSql:sql];
}

- (void) reorderFromTLT {
    //DBGTLIST(self);
	int nrank=0;
	for (NSString *tracker in self.topLayoutNames) {
		//DBGLog(@" %@ to rank %d",tracker,nrank);
		NSString *sql = [NSString stringWithFormat :@"update toplevel set rank = %d where name = \"%@\";",nrank+1,[ rTracker_resource toSqlStr:tracker]];
        [self toExecSql:sql];  // better if used bind vars, but this keeps access in tObjBase
		nrank++;
	}
    //DBGTLIST(self);
}

- (void) reloadFromTLT {
    //DBGTLIST(self);
	int nrank=0;
	NSString *sql = [NSString stringWithFormat:@"delete from toplevel where priv <= %d;",[privacyV getPrivacyValue] ];
    [self toExecSql:sql];
	for (NSString *tracker in self.topLayoutNames) {
		NSInteger tid = [(self.topLayoutIDs)[nrank] intValue];
		NSInteger priv = [(self.topLayoutPriv)[nrank] intValue];
		NSInteger rc = [(self.topLayoutReminderCount)[nrank] intValue];
        
		//DBGLog(@" %@ id %d to rank %d",tracker,tid,nrank);
		sql = [NSString stringWithFormat: @"insert into toplevel (rank, id, name, priv,remindercount) values (%i, %ld, \"%@\", %ld, %ld);",nrank+1,(long)tid,[rTracker_resource toSqlStr:tracker], (long)priv,(long)rc];  // rank in db always non-0
        [self toExecSql:sql];  // better if used bind vars, but this keeps access in tObjBase
		nrank++;
	}
}

- (NSInteger) getTIDfromIndex:(NSUInteger)ndx {
	return [(self.topLayoutIDs)[ndx] intValue];
}

- (int) getPrivFromLoadedTID:(NSInteger)tid {
    
    NSInteger ndx = [self.topLayoutIDs indexOfObject:@(tid)];
    if (NSNotFound == ndx) {
        return MAXPRIV;
    }
    return [(self.topLayoutPriv)[ndx] intValue];
}

- (BOOL) checkTIDexists:(NSNumber*)tid {
    NSString *sql =[NSString stringWithFormat:@"select id from toplevel where id=%d",[tid intValue]];
    int rslt = [self toQry2Int:sql];
    return (0 != rslt);
}

// return tid for first matching name
- (NSInteger) getTIDfromName:(NSString *)str {
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
    NSString *sql=[NSString stringWithFormat:@"select id from toplevel where name=\"%@\" order by rank",[rTracker_resource toSqlStr:str]];
    [self toQry2AryI:i1 sql:sql];
    NSArray *ra = [NSArray arrayWithArray:i1];
    return ra;
}

////
//
// 26.xi.12 previously this would modify dictionary to set its TID to non-conflicting value, now calls updateTID to move existing trackers with conflicting TID to new TID
//
////
- (void) fixDictTID:(NSDictionary*)tdict {
    NSNumber *tid = tdict[@"tid"];
    [self minUniquev:[tid intValue]];
    
    if ([self checkTIDexists:tid]) {
        //[tdict setValue:[NSNumber numberWithInt:[self getUnique]] forKey:@"tid"];
        //DBGLog(@"  changed to: %@",[tdict objectForKey:@"tid"]);
        [self updateTID:[tid intValue] new:[self getUnique]];
    }
}

- (void) updateTLtid:(NSInteger)old new:(NSInteger)new {
    NSString *sql;
    if (-1 == new) {
        sql = [NSString stringWithFormat:@"delete from toplevel where id=%ld",(long)old];
    } else if (old == new) {
        return;
    } else {
        sql = [NSString stringWithFormat:@"update toplevel set id=%ld where id=%ld",(long)new, (long)old ];
    }
    [self toExecSql:sql];  
    //self.sql = nil;
    
    [self loadTopLayoutTable];
    
    DBGLog(@"changed toplevel TID %lD to %ld",(long)old,(long)new);
}

- (void) updateTID:(NSInteger)old new:(NSInteger)new {

    if (old == new) return;
    if ([self checkTIDexists:@(new)]) {
        [self updateTID:new new:[self getUnique]];
    }
    trackerObj *to = [[trackerObj alloc] init:old];
    [to clearScheduledReminders];  // remove any reminders with old tid
    
    // rename file
    NSString *oldFname= [NSString stringWithFormat:@"trkr%ld.sqlite3",(long)old];
    NSString *newFname= [NSString stringWithFormat:@"trkr%ld.sqlite3",(long)new];
    NSError *error;

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm moveItemAtPath:[rTracker_resource ioFilePath:oldFname access:DBACCESS]
                    toPath:[rTracker_resource ioFilePath:newFname access:DBACCESS] error:&error] != YES) {
        DBGErr(@"Unable to move file %@ to %@: %@", oldFname, newFname, [error localizedDescription]);
    } else {
        // update toplevel if file rename went ok;
        [self updateTLtid:old new:new];
    }
    
    NSString *upReminders = [NSString stringWithFormat:@"update reminders set tid=%ld", (long) new];

    to = [[trackerObj alloc] init:new];
    [to toExecSql:upReminders];
    [to setReminders];
}


#pragma mark -
#pragma mark tracker manipulation methods

- (void) reorderTLT : (NSUInteger) fromRow toRow:(NSUInteger)toRow
{
	DBGTLIST(self);

	id tName = (self.topLayoutNames)[fromRow];
	id tID = (self.topLayoutIDs)[fromRow];
    id tPriv = (self.topLayoutPriv)[fromRow];
	id tRC= (self.topLayoutReminderCount)[fromRow];
    
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
    if (row >= [self.topLayoutIDs count]) return;
    
	int tid = [(self.topLayoutIDs)[row] intValue];
	trackerObj *to = [[trackerObj alloc] init:tid];
    DBGLog(@"delete tracker all name:%@ id:%ldd rowtext= %@", to.trackerName,(long) (long)to.toid, [self.topLayoutNames objectAtIndex:row] );
    [to clearScheduledReminders];
	[to deleteTrackerDB];
    
    [self toExecSql:[NSString stringWithFormat:@"delete from toplevel where id=%d and name='%@'",tid, to.trackerName]];

	[self.topLayoutNames removeObjectAtIndex:row];
	[self.topLayoutIDs removeObjectAtIndex:row];
    [self.topLayoutPriv removeObjectAtIndex:row];
    [self.topLayoutReminderCount removeObjectAtIndex:row];
}

- (void) deleteTrackerAllTID:(NSNumber*)nsnTID name:(NSString*)name {
    NSUInteger row = [self.topLayoutIDs indexOfObject:nsnTID];
	int tid = [nsnTID intValue];
	trackerObj *to = [[trackerObj alloc] init:tid];
    
    if ((NSNotFound != row) && ([name isEqualToString:to.trackerName])) {
        [self deleteTrackerAllRow:row];
    }
}

- (void) deleteTrackerRecordsRow:(NSUInteger)row
{
	int tid = [(self.topLayoutIDs)[row] intValue];
	trackerObj *to = [[trackerObj alloc] init:tid];
	[to deleteTrackerRecordsOnly];
}

- (void) exportAll {
    float ndx=1.0;
    [privacyV jumpMaxPriv];  // reasonable to do this now with default encryption enabled
    
    NSString *sql = @"select id from toplevel";  // ignore current (self) list because subject to privacy
    NSMutableArray *idSet = [[NSMutableArray alloc] init];
    [self toQry2AryI:idSet sql:sql];
    float all = [idSet count];
    
    for (NSNumber *tid in idSet) {
        trackerObj *to = [[trackerObj alloc] init:[tid intValue]];
        [to saveToItunes];
        
        [rTracker_resource setProgressVal:(ndx/all)];
        ndx += 1.0;
    }
    
    [privacyV restorePriv];
}

- (void) confirmToplevelTIDs {
    [privacyV jumpMaxPriv];  // reasonable to do this now with default encryption enabled
    
    NSString *sql = @"select id from toplevel";  // ignore current (self) list because subject to privacy
    NSMutableArray *idSet = [[NSMutableArray alloc] init];
    [self toQry2AryI:idSet sql:sql];
    
    for (NSNumber *tid in idSet) {
        trackerObj *to = [[trackerObj alloc] init:[tid intValue]];
        [self confirmToplevelEntry:to];
    }
    
    [privacyV restorePriv];
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
    NSString *sql = @"select id, name from toplevel order by id";
    NSMutableArray *i1 = [[NSMutableArray alloc]init];
    NSMutableArray *s1 = [[NSMutableArray alloc]init];
    [self toQry2AryIS:i1 s1:s1 sql:sql];
    NSMutableDictionary *dictTid2Ndx = [[NSMutableDictionary alloc]init];
    NSUInteger c = [i1 count];
    NSUInteger i;
    for (i=0;i<c;i++) {
        dictTid2Ndx[i1[i]] = @(i);
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
                dictTid2Filename[@(ftid)] = fn;
                NSNumber *ftidNdx = dictTid2Ndx[@(ftid)];
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
            NSString *tltidFilename = dictTid2Filename[tlTid];
            if (tltidFilename) {
                DBGLog(@"tid %@ name %@ file %@",tlTid,[s1 objectAtIndex:i],tltidFilename);
            } else {
                NSString *tname = s1[i];
                DBGLog(@"tid %@ name %@ no file found - delete from tlist",tlTid,tname);
                NSString *sql = [NSString stringWithFormat:@"delete from toplevel where id=%@ and name='%@'",tlTid, tname];
                [self toExecSql:sql];
            }
            i++;
        }
    }
    
    //self.sql = nil;
    
}

- (void) restoreTracker:(NSString*)fn ndx:(NSUInteger)ndx {
    NSInteger ftid = [[fn substringFromIndex:ndx] intValue];
    trackerObj *to;
    NSInteger newTid = ftid;
    
    if ([self checkTIDexists:@(ftid)]) {
        newTid = [self getUnique];
    }
    NSString *newFn = [NSString stringWithFormat:@"trkr%ld.sqlite3",(long)newTid];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;

    while ([fm fileExistsAtPath:[rTracker_resource ioFilePath:newFn access:DBACCESS]]) {
        newTid = [self getUnique];
        newFn = [NSString stringWithFormat:@"trkr%ld.sqlite3",(long)newTid];
    }

    // RTM TODO ADDRESS: what if fn = newFN here?
    
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
    NSString *sql = @"select id, name from toplevel order by id";
    NSMutableArray *i1 = [[NSMutableArray alloc]init];
    NSMutableArray *s1 = [[NSMutableArray alloc]init];
    [self toQry2AryIS:i1 s1:s1 sql:sql];
    NSMutableDictionary *dictTid2Ndx = [[NSMutableDictionary alloc]init];
    NSUInteger c = [i1 count];
    NSUInteger i;
    for (i=0;i<c;i++) {
        dictTid2Ndx[i1[i]] = @(i);
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
                dictTid2Filename[@(ftid)] = fn;
                NSNumber *ftidNdx = dictTid2Ndx[@(ftid)];
                if (ftidNdx) {
                    //DBGLog(@"%@ iv: %d toplevel: %@",fn, ftid, [s1 objectAtIndex:[ftidNdx unsignedIntegerValue]]);
                } else {
                    [self restoreTracker:fn ndx:4];
                    didRecover = YES;
                }
                
            } else if ([fn hasPrefix:@"stash_trkr"]) {
                [self restoreTracker:fn ndx:10];
                didRecover=YES;
            }
        }
        NSNumber *tlTid;
        i=0;
        for (tlTid in i1) {
            NSString *tltidFilename = dictTid2Filename[tlTid];
            if (tltidFilename) {
                //DBGLog(@"tid %@ name %@ file %@",tlTid,[s1 objectAtIndex:i],tltidFilename);
            } else {
                NSString *tname = s1[i];
                DBGLog(@"tid %@ name %@ no file found - delete from tlist",tlTid,tname);
                NSString *sql = [NSString stringWithFormat:@"delete from toplevel where id=%@ and name='%@'",tlTid, tname];
                [self toExecSql:sql];
            }
            i++;
        }
    }
    
    //self.sql = nil;
    
    return didRecover;
}


- (void) updateShortcutItems {

    NSUInteger sciCount = SCICOUNTDFLT;   //[rTracker_resource getSCICount];
    NSMutableArray *newShortcutItems = [NSMutableArray arrayWithCapacity:sciCount];
    NSMutableArray *idArray = [NSMutableArray arrayWithCapacity:sciCount];
    NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:sciCount];
    
    NSString *sql = [NSString stringWithFormat:@"select id, name from toplevel where priv <= %i order by rank limit %d;",MINPRIV,(unsigned int)sciCount];
    [self toQry2AryIS:idArray s1:nameArray sql:sql];
    
    if (! nameArray) return;   // no trackers, no names on first start
    NSUInteger c = [nameArray count];
    if (! c) return;   // no trackers, no names on first start
    
    NSUInteger i;
    for (i=0; i<sciCount && i<c; i++) {
        UIApplicationShortcutItem *si = [[UIApplicationShortcutItem alloc]
                                         initWithType:@"open" localizedTitle:[nameArray objectAtIndex:i]
                                         localizedSubtitle:NULL icon:NULL
                                         userInfo:@{ @"tid":[idArray objectAtIndex:i] } ];

        [newShortcutItems addObject:si];
    }

    [UIApplication sharedApplication].shortcutItems = newShortcutItems;
    
}

@end
