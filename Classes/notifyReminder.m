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

@implementation notifyReminder

@synthesize rid, monthDays, weekDays, everyMode, everyVal, start, until, times, msg, localNotif, tid, to;

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
    self.to.sql = @"create table if not exists reminders (rid int, monthDays int, weekDays int, everyMode int, everyVal int, start int, until int, times int, msg text, unique ( rid ) on conflict replace);";
    [self.to toExecSql];
}

- (void) nextRid {
    self.to.sql = [NSString stringWithFormat:@"select rid, monthDays, weekDays, everyMode, everyVal, start, until, times, msg from reminders where rid > %d order by rid limit 1", self.rid];
    int arr[8];
    self.msg = [self.to toQry2I8aS1:arr];
    self.rid = arr[0];
    self.monthDays = arr[1];
    self.weekDays = arr[2];
    self.everyMode = arr[3];
    self.everyVal = arr[4];
    self.start = arr[5];
    self.until = arr[6];
    self.times = arr[7];
}
@end
