/***************
 notifyReminderViewController.h
 Copyright 2013-2021 Robert T. Miller
 
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
//  notifyReminderViewController.h
//  rTracker
//
//  Created by Rob Miller on 07/08/2013.
//  Copyright (c) 2013 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerObj.h"
#import "notifyReminder.h"

/*
 weekdays : 7 bits
 monthdays : 31 bits
 everyVal : int
 everyMode : int (5) (3-4 bits?)
 
 start : int (1440)
 until : int (1440)
 times : int
 
 bools:
 fromLast
 until
 interval/random
 
 message : nsstring
 
 sound : alert/banner : badge  -- can only be alert/banner; badge is for all pending rTracker notifications, sound to be done but just one
 
 enable / disable toggle ?
 
 */

@interface notifyReminderViewController : UIViewController <UITextFieldDelegate>

{
    NSUInteger weekdays[7];
/*
    trackerObj *tracker;
    notifyReminder *nr;
    //BOOL tmpReminder;         // nr.rid=0 // displayed reminder is only in view controller, no entry in tracker.reminders
    
    NSArray *weekdayBtns;
    NSArray *everyTrackerNames;
    UIImage *chkImg;
    UIImage *unchkImg;
    NSUInteger firstWeekDay;
    NSUInteger everyTrackerNdx;
    uint8_t everyMode;
    NSString *lastDefaultMsg;
    BOOL delayDaysState;
*/
}


@property (nonatomic,strong) trackerObj *tracker;
@property (nonatomic,strong) notifyReminder *nr;
//@property (nonatomic) BOOL tmpReminder;

@property (nonatomic,strong) NSArray *weekdayBtns;
@property (nonatomic,strong) NSArray *everyTrackerNames;
@property (nonatomic,strong) UIImage *chkImg;
@property (nonatomic,strong) UIImage *unchkImg;
@property (nonatomic,strong) NSString *lastDefaultMsg;

@property (nonatomic) NSUInteger firstWeekDay;
@property (nonatomic) NSUInteger everyTrackerNdx;
@property (nonatomic) uint8_t everyMode;
@property (nonatomic) BOOL delayDaysState;

@property (nonatomic,strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *prevBarButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *nextAddBarButton;

- (IBAction)prevBtn:(id)sender;
- (IBAction)nextAddBtn:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *msgTF;

@property (nonatomic, strong) IBOutlet UIButton *enableButton;
- (IBAction)enableBtn:(id)sender;

@property (nonatomic,strong) IBOutlet UIButton *delayDaysButton;
- (IBAction)delayDaysBtn:(id)sender;

@property (nonatomic,strong) IBOutlet UILabel *thenOnLabel;

@property (nonatomic,strong) IBOutlet UIButton *wdButton1;
@property (nonatomic,strong) IBOutlet UIButton *wdButton2;
@property (nonatomic,strong) IBOutlet UIButton *wdButton3;
@property (nonatomic,strong) IBOutlet UIButton *wdButton4;
@property (nonatomic,strong) IBOutlet UIButton *wdButton5;
@property (nonatomic,strong) IBOutlet UIButton *wdButton6;
@property (nonatomic,strong) IBOutlet UIButton *wdButton7;

- (IBAction) wdBtn:(id)sender;


@property (nonatomic,strong) IBOutlet UILabel *monthDaysLabel;
@property (nonatomic,strong) IBOutlet UITextField *monthDays;

- (IBAction)monthDaysChange:(id)sender;

@property (nonatomic,strong) IBOutlet UITextField *everyTF;
@property (nonatomic,strong) IBOutlet UIButton *everyButton;
@property (nonatomic,strong) IBOutlet UIButton *fromLastButton;
@property (nonatomic,strong) IBOutlet UILabel *fromLastLabel;
@property (nonatomic,strong) IBOutlet UIButton *everyTrackerButton;

- (IBAction)everyTFChange:(id)sender;
- (IBAction)everyBtn:(id)sender;
- (IBAction)fromLastBtn:(id)sender;
- (IBAction)everyTrackerBtn:(id)sender;

- (IBAction)TFdidBeginEditing:(id)sender;

@property (nonatomic,unsafe_unretained) UITextField *activeField;   //just a pointer, no retain

//@property (nonatomic,retain) IBOutlet UISegmentedControl *weekMonthEvery;
//- (IBAction)weekMonthEveryChange:(id)sender;


@property (nonatomic,strong) IBOutlet UITextField *startHr;
@property (nonatomic,strong) IBOutlet UITextField *startMin;
@property (nonatomic,strong) IBOutlet UISlider *startSlider;
@property (nonatomic,strong) IBOutlet UILabel *startTimeAmPm;
@property (nonatomic,strong) IBOutlet UILabel *startLabel;

//start
- (IBAction)startHrChange:(id)sender;
- (IBAction)startMinChange:(id)sender;
- (IBAction)startSliderAction:(id)sender;

@property (nonatomic,strong) IBOutlet UITextField *finishHr;
@property (nonatomic,strong) IBOutlet UITextField *finishMin;
@property (nonatomic,strong) IBOutlet UISlider *finishSlider;
@property (nonatomic,strong) IBOutlet UILabel *finishTimeAmPm;
@property (nonatomic,strong) IBOutlet UILabel *finishLabel;
@property (nonatomic,strong) IBOutlet UILabel *finishColon;


@property (nonatomic,strong) IBOutlet UITextField *repeatTimes;
@property (nonatomic,strong) IBOutlet UILabel *repeatTimesLabel;
@property (nonatomic,strong) IBOutlet UIButton *intervalButton;

- (IBAction) enableFinishBtn:(id)sender;
@property (nonatomic,strong) IBOutlet UIButton *enableFinishButton;

 //fin
- (IBAction)finishHrChange:(id)sender;
- (IBAction)finishMinChange:(id)sender;
/*
- (IBAction)finishSliderAction:(id)sender;
- (IBAction)timesChange:(id)sender;
- (IBAction) intervalBtn:(id)sender;
*/


@property (nonatomic,strong) IBOutlet UIToolbar *toolBar;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *gearButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *btnDoneOutlet;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *btnHelpOutlet;

- (IBAction)btnDone:(id)sender;
- (IBAction)btnGear:(id)sender;
- (IBAction)btnHelp:(id)sender;


@end
