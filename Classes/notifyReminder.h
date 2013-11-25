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
    int start;
    int until;
    int times;

    NSString *msg;

    NSInteger tid;
    
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

@property (nonatomic,retain) NSString *msg;
@property (nonatomic,retain) UILocalNotification *localNotif;
@property (nonatomic,retain) trackerObj *to;

-(id) init:(trackerObj*) tObjIn;
-(void) nextRid;

@end
