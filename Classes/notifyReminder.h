//
//  notifyReminder.h
//  rTracker
//
//  Created by Rob Miller on 07/11/2013.
//  Copyright (c) 2013 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "trackerObj.h"

/*
 weekdays : 7 bits
 monthdays : 31 bits
 everyMode : int (5) (3-4 bits?)
 */

//#define EV_MINUTES (0x01 << 0)  // default 0 is valid as minutes
#define EV_HOURS   (0x01 << 0)
#define EV_DAYS    (0x01 << 1)
#define EV_WEEKS   (0x01 << 2)
#define EV_MONTHS  (0x01 << 3)

#define EV_MASK (EV_HOURS | EV_DAYS | EV_WEEKS | EV_MONTHS)


/*
 bools:
 fromSave
 until
 interval/random
 
 everyVal : int
 start : int (1440)
 until : int (1440)
 times : int
 
 message : nsstring
 
 sound : alert/banner : badge  -- can only be alert/banner; badge is for all pending rTracker notifications, sound to be done but just one
 
 enable / disable toggle ?
 
 */

@interface notifyReminder : NSObject {

    int rid;
    
    uint32_t monthDays;
    uint8_t weekDays;
    uint8_t everyMode;
    
    int everyVal;
    int start;        // -1 for not used
    int until;
    int times;
    

    NSString *msg;
    
    BOOL timesRandom;
    BOOL reminderEnabled;
    BOOL untilEnabled;
    
    NSInteger tid;
    NSInteger vid;   // 0 => tracker OR not used if start valid
    
    UILocalNotification *localNotif;
    trackerObj *to;
}

@property (nonatomic) int rid;

@property (nonatomic) uint32_t monthDays;
@property (nonatomic) uint8_t weekDays;
@property (nonatomic) uint8_t everyMode;

@property (nonatomic) int everyVal;
@property (nonatomic) int start;
@property (nonatomic) int until;
@property (nonatomic) int times;

@property (nonatomic) NSInteger tid;
@property (nonatomic) NSInteger vid;

@property (nonatomic,retain) NSString *msg;

@property (nonatomic) BOOL timesRandom;
@property (nonatomic) BOOL reminderEnabled;
@property (nonatomic) BOOL untilEnabled;

@property (nonatomic,retain) UILocalNotification *localNotif;
@property (nonatomic,retain) trackerObj *to;

-(id) init:(trackerObj*) tObjIn;

-(void) clearNR;
-(void) save;
-(void) delete;

-(void) nextRid;
-(void) prevRid;

- (BOOL) haveNextReminder;
- (BOOL) havePrevReminder;

@end
