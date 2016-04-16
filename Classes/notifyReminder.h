/***************
 notifyReminder.h
 Copyright 2013-2016 Robert T. Miller
 
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
//  notifyReminder.h
//  rTracker
//
//  Created by Rob Miller on 07/11/2013.
//  Copyright (c) 2013 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import "trackerObj.h"

/*
 weekdays : 7 bits
 monthdays : 31 bits
 everyMode : int (5) (3-4 bits?)
 */

//#define EV_MINUTES (0x01 << 0)  // default 0 is valid as minutes
#define EV_MINUTES 0
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

@interface notifyReminder : NSObject
/*{

    int rid;
    
    uint32_t monthDays;
    uint8_t weekDays;
    uint8_t everyMode;
    
    int everyVal;
    int start;        // -1 for not used
    int until;
    int times;
    

    NSString *msg;
    NSString *soundFileName;
    
    BOOL timesRandom;
    BOOL reminderEnabled;
    BOOL untilEnabled;
    BOOL fromLast;
    
    NSInteger tid;
    NSInteger vid;   // 0 => tracker OR not used if start valid
    
    int saveDate;
    
    UILocalNotification *localNotif;
    
    //trackerObj *to;
}*/


@property (nonatomic) NSInteger rid;

@property (nonatomic) uint32_t monthDays;
@property (nonatomic) uint8_t weekDays;
@property (nonatomic) uint8_t everyMode;

@property (nonatomic) NSInteger everyVal;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger until;
@property (nonatomic) NSInteger times;

@property (nonatomic) NSInteger tid;
@property (nonatomic) NSInteger vid;

@property (nonatomic,strong) NSString *msg;
@property (nonatomic,strong) NSString *soundFileName;

@property (nonatomic) BOOL timesRandom;
@property (nonatomic) BOOL reminderEnabled;
@property (nonatomic) BOOL untilEnabled;
@property (nonatomic) BOOL fromLast;
@property (nonatomic) NSInteger saveDate;

@property (nonatomic,strong) UILocalNotification *localNotif;

//@property (nonatomic,retain) trackerObj *to;

//-(id) init:(trackerObj*) tObjIn;
-(id) init:(NSNumber*) inRid to:(id)to;
-(id) initWithDict:(NSDictionary*)dict;
-(void) dealloc;

-(void) clearNR;
-(void) save:(id)to;
//-(void) delete:(id)to;

- (void) loadRid:(NSString*)sqlWhere to:(id)to;
- (NSDictionary*) dictFromNR;

-(NSInteger) hrVal:(NSInteger)val;
-(NSInteger) mnVal:(NSInteger)val;

-(NSString*)timeStr:(NSInteger)val;
-(NSString*) description;

-(void) create;
-(void) schedule:(NSDate*) targDate;
-(void) playSound;

//-(void) present;


/*
-(void) nextRid;
-(void) prevRid;

- (BOOL) haveNextReminder;
- (BOOL) havePrevReminder;
*/

@end
