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
#import "rTracker-resource.h"

@implementation notifyReminder

@synthesize rid=_rid, monthDays=_monthDays, weekDays=_weekDays, everyMode=_everyMode, everyVal=_everyVal, start=_start, until=_until, times=_times, timesRandom=_timesRandom, msg=_msg, soundFileName=_soundFileName, reminderEnabled=_reminderEnabled, untilEnabled=_untilEnabled, fromLast=_fromLast, saveDate=_saveDate, localNotif=_localNotif, tid=_tid, vid=_vid;

#define UNTILFLAG   (0x01<<0)
#define TIMESRFLAG  (0x01<<1)
#define ENABLEFLAG  (0x01<<2)
#define FROMLASTFLAG  (0x01<<3)

- (id)init {
	
	if ((self = [super init])) {
        self.localNotif = nil;
        self.saveDate = (int) [[NSDate date] timeIntervalSince1970];
        self.soundFileName = nil;
	}
	
	return self;
}
/*
- (id)init:(trackerObj*) tObjIn {
	if ((self = [self init])) {
		//DBGLog(@"init trackerObj id: %d",tid);
		self.to = tObjIn;
        [self initReminderTable];
        [self nextRid];
	}
	return self;
}
*/

- (id)init:(NSNumber*)inRid to:(trackerObj*)to {
	if ((self = [self init])) {
		//DBGLog(@"init trackerObj id: %d",tid);
        //[self initReminderTable];
        [self loadRid:[NSString stringWithFormat:@"rid=%d",[inRid intValue]] to:to];
	}
    DBGLog(@"%@",self);
	return self;
    
}

- (id) initWithDict:(NSDictionary*)dict {

    if((self = [super init])) {
        self.rid = [[dict objectForKey:@"rid"] intValue];
        self.monthDays = (uint32_t) [[dict objectForKey:@"monthDays"] unsignedIntValue];
        self.weekDays = (uint8_t) [[dict objectForKey:@"weekDays"] unsignedIntValue];
        self.everyMode = (uint8_t) [[dict objectForKey:@"everyMode"] unsignedIntValue];
        self.everyVal = [[dict objectForKey:@"everyVal"] intValue];
        self.start = [[dict objectForKey:@"start"] intValue];
        self.until = [[dict objectForKey:@"until"] intValue];
        self.times = [[dict objectForKey:@"times"] intValue];
        self.msg = (NSString*) [dict objectForKey:@"msg"];
        self.soundFileName = (NSString*) [dict objectForKey:@"soundFile"];
        
        [self putFlags:[[dict objectForKey:@"flags"] unsignedIntValue]];
        
        self.tid = [[dict objectForKey:@"tid"] intValue];
        self.vid = [[dict objectForKey:@"vid"] intValue];
        
        self.saveDate = [[dict objectForKey:@"saveDate"] intValue];
    }
    DBGLog(@"%@",self);
    return self;
}

- (void)dealloc {
	DBGLog(@"nr dealloc");
    
    
}

- (void) save:(trackerObj*)to {
    unsigned int flags= [self getFlags];

    DBGLog(@"%@",self);
    to.sql = [NSString stringWithFormat:
                   @"insert or replace into reminders (rid, monthDays, weekDays, everyMode, everyVal, start, until, times, flags, tid, vid, saveDate, msg, soundFileName) values (%d, %d, %d, %d,%d, %d, %d, %d, %d, %d, %d, %d, '%@', '%@')",
                   self.rid,self.monthDays,self.weekDays,self.everyMode,self.everyVal,self.start, self.until, self.times, flags, self.tid,self.vid, self.saveDate, self.msg, self.soundFileName];
    DBGLog(@"save sql= %@",to.sql);
    [to toExecSql];
    to.sql = nil;
}
/*
 // not used - db updates only on tracker saveConfig
- (void) delete:(trackerObj*)to {
    if (!self.rid) return;
    to.sql = [NSString stringWithFormat:@"delete from reminders where rid=%d",self.rid];
    [to toExecSql];
    to.sql = nil;
}
*/
- (unsigned int) getFlags {
    unsigned int flags=0;
    if (self.timesRandom) flags |= TIMESRFLAG;
    if (self.reminderEnabled) flags |= ENABLEFLAG;
    if (self.untilEnabled) flags |= UNTILFLAG;
    if (self.fromLast) flags |= FROMLASTFLAG;
    return flags;
}

- (void) putFlags:(unsigned int)flags {
    self.timesRandom = (flags & TIMESRFLAG ? YES : NO);
    self.reminderEnabled = ( flags & ENABLEFLAG ? YES : NO );
    self.untilEnabled = (flags & UNTILFLAG ? YES : NO );
    self.fromLast = (flags & FROMLASTFLAG ? YES : NO );
}

- (void) loadRid:(NSString*)sqlWhere to:(trackerObj*)to {

    to.sql = [NSString stringWithFormat:@"select rid, monthDays, weekDays, everyMode, everyVal, start, until, times, flags, tid, vid, saveDate, msg from reminders where %@",sqlWhere];
    int arr[12];
    unsigned int flags=0;
    NSString *tmp = [to toQry2I12aS1:arr];
    //DBGLog(@"read msg: %@",tmp);
    if (0 != arr[0]) {   // && (arr[0] != self.rid)) {
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
        self.saveDate = arr[11];
        
        [self putFlags:flags];
        
        self.msg = tmp;

        to.sql = [NSString stringWithFormat:@"select soundFileName from reminders where %@",sqlWhere];
        self.soundFileName = [to toQry2Str];
        if ([@"(null)" isEqualToString:self.soundFileName]) {
            self.soundFileName=nil;
        }
        
} else {
        [self clearNR];
        self.rid = 0;
        self.saveDate = (int) [[NSDate date] timeIntervalSince1970];
        self.msg = to.trackerName;
        self.tid = to.toid;
    }
    
    to.sql=nil;

    DBGLog(@"%@",self);
}

- (NSDictionary*) dictFromNR {
    int flags = [self getFlags];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:self.rid],@"rid",
            [NSNumber numberWithUnsignedInt:self.monthDays],@"monthDays",
            [NSNumber numberWithUnsignedInt:self.weekDays],@"weekDays",
            [NSNumber numberWithUnsignedInt:self.everyMode],@"everyMode",
            [NSNumber numberWithInt:self.everyVal],@"everyVal",
            [NSNumber numberWithInt:self.start],@"start",
            [NSNumber numberWithInt:self.until],@"until",
            [NSNumber numberWithInt:self.times],@"times",
            self.msg,@"msg",
            self.soundFileName,@"soundFile",
            [NSNumber numberWithUnsignedInt:flags],@"flags",
            [NSNumber numberWithInt:self.tid],@"tid",
            [NSNumber numberWithInt:self.vid],@"vid",
            [NSNumber numberWithInt:self.saveDate],@"saveDate",
            nil];
}
/*
- (void) neighbourRid:(char)test {

    [self loadRid:[NSString stringWithFormat:@"rid %c %d order by rid limit 1", test, self.rid]];
    
    //self.to.sql = @"select count(*) from reminders;";
    //int c = [self.to toQry2Int];
    //DBGLog(@"c= %d",c);

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
*/

- (void) clearNR {
    //self.rid=0; // need to keep if set
    self.monthDays=0;
    self.weekDays=0;
    self.everyMode=0;
    self.everyVal=0;
    self.start = (7 * 60);
    self.until = (23 * 60);
    self.untilEnabled = NO;
    self.times = 0;
    //if (nil != to) {
    //    self.msg = to.trackerName;
    //    self.tid = to.toid;
    //} else {
        self.msg = nil;
        self.tid = 0;
    //}
    //self.soundFileName=nil;
    self.timesRandom = NO;
    self.reminderEnabled = YES;
    self.untilEnabled = NO;
    self.fromLast = NO; 
    self.vid = 0;
    //self.saveDate=0;  // need to keep if set
}

-(int) hrVal:(int)val {
    return val/60;
}

-(int) mnVal:(int)val {
    return val % 60;
}



-(NSString*)timeStr:(int)val {
    if (-1 == val) {
        return @"-";
    }
    return [NSString stringWithFormat:@"%02d:%02d",[self hrVal:val],[self mnVal:val]];
}

- (NSString*) description {
    NSString *desc = [NSString stringWithFormat:@"nr:%d ",self.rid];

    if (self.start > -1) {
        desc = [desc stringByAppendingString:[NSString stringWithFormat:@"start %@ ",[self timeStr:self.start]]];
    }
    
    if (self.untilEnabled) {
        desc = [desc stringByAppendingString:[NSString stringWithFormat:@"until %@ ",[self timeStr:self.until]]];
    }
    
    if (self.monthDays) {
        int i;
        NSMutableArray *nma = [[NSMutableArray alloc] initWithCapacity:32];
        for (i=0;i<32;i++) {
            if (self.monthDays & (0x01 << i)) {
                [nma addObject:[NSString stringWithFormat:@"%d",i+1]];
            }
        }
        desc = [desc stringByAppendingString:[NSString stringWithFormat:@"monthDays:%@ ",[nma componentsJoinedByString:@","]]];

    } else if (self.everyVal) {

        switch (self.everyMode) {
            case EV_HOURS:
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"every %d Hours ",self.everyVal]];
                break;
            case EV_DAYS:
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"every %d Days ",self.everyVal]];
                break;
            case EV_WEEKS:
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"every %d Weeks ",self.everyVal]];
                break;
            case EV_MONTHS:
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"every %d Months ",self.everyVal]];
                break;
            default:   // EV_MINUTES
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"every %d Minutes ",self.everyVal]];
                break;
        }
        
        if (self.fromLast) {
            if (self.vid) {
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"from last vid:%d ",self.vid]];
            } else {
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"from last tracker:%d ",self.tid]];
            }
        }


    } else {   // if (self.nr.weekDays)  = default if nothing set
        desc = [desc stringByAppendingString:@"weekdays: "];
        
        NSUInteger weekdays[7];
        NSUInteger firstWeekDay;
        firstWeekDay = [[NSCalendar currentCalendar] firstWeekday];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *wdNames[7];
        
        int i;
        for (i=0;i<7;i++) {
            NSUInteger wd = firstWeekDay +i;
            if (wd > 7) {
                wd -= 7;
            }
            weekdays[i] = wd-1;  // firstWeekDay is 1-indexed, switch to 0-indexed
            wdNames[i] = [[dateFormatter shortWeekdaySymbols] objectAtIndex:weekdays[i]];
        }
        
        for (i=0;i<7;i++) {
            if ((BOOL) (0 != (self.weekDays & (0x01 << weekdays[i])))) {
                desc = [desc stringByAppendingString:[NSString stringWithFormat:@"%@ ",wdNames[i]]];
            }
        }
    }

    desc = [desc stringByAppendingString:[NSString stringWithFormat:@"msg:'%@' ",self.msg]];
    desc = [desc stringByAppendingString:[NSString stringWithFormat:@"saveDate:'%@' ",[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) self.saveDate]]];

    if (nil == self.soundFileName) {
        desc = [desc stringByAppendingString:@"default sound "];
    } else {
        desc = [desc stringByAppendingString:[NSString stringWithFormat:@"soundfile %@ ",self.soundFileName]];
    }
    
    if (self.reminderEnabled) {
        desc = [desc stringByAppendingString:@"enabled"];
    } else {
        desc = [desc stringByAppendingString:@"disabled"];
    }

    return desc;
}

-(void) create {
    if (nil == self.localNotif) {
        if (nil == (self.localNotif = [[UILocalNotification alloc] init])) {
        //if (nil == (self.localNotif = [[UILocalNotification alloc] init])) {
            return;
        }
    }
    
    
    self.localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    self.localNotif.alertBody = self.msg;
    self.localNotif.alertAction = NSLocalizedString(@"rTracker reminder", nil);
    
    if (nil == self.soundFileName) {
        self.localNotif.soundName = UILocalNotificationDefaultSoundName;
    } else {
        self.localNotif.soundName = self.soundFileName;
    }
    self.localNotif.applicationIconBadgeNumber = 1;
    
    //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.tid] forKey:@"tid"];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.tid],@"tid",[NSNumber numberWithInt:self.rid],@"rid",nil];
    self.localNotif.userInfo = infoDict;
    DBGLog(@"created.");
}

-(void) cancel {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        if (([[userInfoCurrent objectForKey:@"tid"] integerValue] == self.tid)
            && ([[userInfoCurrent objectForKey:@"rid"] integerValue] == self.rid))
        {
            [app cancelLocalNotification:oneEvent];
        }
    }
}

-(void) schedule:(NSDate*) targDate {
    [self cancel];  // safety net -- should only happen if REMINDERDBG is set due to setReminder on 'done'
    if (nil == self.localNotif)
        [self create];
    if (nil == self.localNotif)
        return;
    
    self.localNotif.fireDate = targDate;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotif];
    DBGLog(@"scheduled");
}

-(void) playSound {
    [rTracker_resource playSound:self.soundFileName];
}

/*
-(void) present {
    if (nil == self.localNotif)
        [self create];
    if (nil == self.localNotif)
        return;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:self.localNotif];
    DBGLog(@"presented.");
}
*/

@end
