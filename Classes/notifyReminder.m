//
//  notifyReminder.m
//  rTracker
//
//  Created by Rob Miller on 07/11/2013.
//  Copyright (c) 2013 Robert T. Miller. All rights reserved.
//

#import "notifyReminder.h"

#import "tObjBase.h"
#import "trackerObj.h"

#import "dbg-defs.h"

@implementation notifyReminder

@synthesize rid, monthDays, weekDays, everyMode, everyVal, start, until, times, timesRandom, msg, reminderEnabled, untilEnabled, localNotif, tid, vid, to;

#define UNTILFLAG   (0x01<<0)
#define TIMESRFLAG  (0x01<<1)
#define ENABLEFLAG  (0x01<<2)

- (id)init {
	
	if ((self = [super init])) {
	}
	
	return self;
}

- (id)init:(trackerObj*) tObjIn {
	if ((self = [self init])) {
		//DBGLog(@"init trackerObj id: %d",tid);
		self.to = tObjIn;
        [self initReminderTable];
        [self nextRid];
	}
	return self;
}

- (void) initReminderTable {
    self.to.sql = @"create table if not exists reminders (rid int, monthDays int, weekDays int, everyMode int, everyVal int, start int, until int, flags int, times int, msg text, tid int, vid int, unique(rid) on conflict replace)";
    [self.to toExecSql];
    self.to.sql=nil;
}

- (void) save {
    if (! self.rid) self.rid = [self.to getUnique];
    unsigned int flags=0;
    if (self.timesRandom) flags |= TIMESRFLAG;
    if (self.reminderEnabled) flags |= ENABLEFLAG;
    if (self.untilEnabled) flags |= UNTILFLAG;
    
    self.to.sql = [NSString stringWithFormat:
                   @"insert or replace into reminders (rid, monthDays, weekDays, everyMode, everyVal, start, until, times, flags, tid, vid, msg) values (%d, %d, %d, %d,%d, %d, %d, %d, %d, %d, %d, '%@')",
                   self.rid,self.monthDays,self.weekDays,self.everyMode,self.everyVal,self.start, self.until, self.times, flags, self.tid,self.vid, self.msg];
    [self.to toExecSql];
    self.to.sql = nil;
}

- (void) delete {
    if (!self.rid) return;
    self.to.sql = [NSString stringWithFormat:@"delete from reminders where rid=%d",self.rid];
    [self.to toExecSql];
    self.to.sql = nil;
}

- (void) neighbourRid:(char)test {
    unsigned int flags=0;
    //self.to.sql = @"select count(*) from reminders;";
    //int c = [self.to toQry2Int];
    //DBGLog(@"c= %d",c);

    self.to.sql = [NSString stringWithFormat:@"select rid, monthDays, weekDays, everyMode, everyVal, start, until, times, flags, tid, vid, msg from reminders where rid %c %d order by rid limit 1", test, self.rid];
    int arr[13];
    NSString *tmp = [self.to toQry2I11aS1:arr];
    
    if (arr[0] && (arr[0] != self.rid)) {
        self.rid = arr[0];
        self.monthDays = arr[1];
        self.weekDays = arr[2];
        self.everyMode = arr[3];
        self.everyVal = arr[4];
        self.start = arr[5];
        self.until = arr[6];
        self.times = arr[7];
        flags = arr[8];
        self.tid = arr[9];
        self.vid = arr[10];
        
        self.timesRandom = (flags & TIMESRFLAG ? YES : NO);
        self.reminderEnabled = ( flags & ENABLEFLAG ? YES : NO );
        self.untilEnabled = (flags & UNTILFLAG ? YES : NO );
        
        self.msg = tmp;
    } else {
        [self clearNR];
    }
    self.to.sql=nil;
}

- (void) nextRid {
    return [self neighbourRid:'>'];
}

- (void) prevRid { // rtm here xxx needs to get last one if rid is 0
    if (self.rid) return [self neighbourRid:'<'];
    return [self neighbourRid:'>'];  // if curr rid = 0 (empty nr) then any
}

- (BOOL) neighbourTest:(char)test {
    self.to.sql = [NSString stringWithFormat:@"select count(*) from reminders where rid %c %d",test,self.rid];
    int rslt = [self.to toQry2Int];
    self.to.sql=nil;
    return (rslt>0);
}

- (BOOL) haveNextReminder {
    return [self neighbourTest:'>'];
}
- (BOOL) havePrevReminder {
    if (self.rid) return [self neighbourTest:'<'];
    return [self neighbourTest:'>'];
}

- (void) clearNR {
    self.rid=0;
    self.monthDays=0;
    self.weekDays=0;
    self.everyMode=0;
    self.everyVal=0;
    self.start = (7 * 60);
    self.until = (23 * 60);
    self.untilEnabled = NO;
    self.times = 0;
    if (self.to) {
        self.msg = self.to.trackerName;
        self.tid = self.to.toid;
    } else {
        self.msg = nil;
        self.tid = 0;
    }
    
    self.timesRandom = NO;
    self.reminderEnabled = YES;
    self.untilEnabled = NO;
    self.vid = 0;
}
@end
