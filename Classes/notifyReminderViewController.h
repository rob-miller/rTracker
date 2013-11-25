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
 fromSave
 until
 interval/random
 
 message : nsstring
 
 sound : alert/banner : badge  -- can only be alert/banner; badge is for all pending rTracker notifications, sound to be done but just one
 
 enable / disable toggle ?
 
 */

@interface notifyReminderViewController : UIViewController <UITextFieldDelegate>
{
    trackerObj *tracker;
    notifyReminder *nr;
    
    UIImage *chkImg;
    UIImage *unchkImg;
}

@property (nonatomic,retain) trackerObj *tracker;
@property (nonatomic,retain) UIImage *chkImg;
@property (nonatomic,retain) UIImage *unchkImg;

@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *prevBarButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *nextAddBarButton;

- (IBAction)prevBtn:(id)sender;
- (IBAction)nextAddBtn:(id)sender;

@property (nonatomic,retain) IBOutlet UIButton *wdButton1;
@property (nonatomic,retain) IBOutlet UIButton *wdButton2;
@property (nonatomic,retain) IBOutlet UIButton *wdButton3;
@property (nonatomic,retain) IBOutlet UIButton *wdButton4;
@property (nonatomic,retain) IBOutlet UIButton *wdButton5;
@property (nonatomic,retain) IBOutlet UIButton *wdButton6;
@property (nonatomic,retain) IBOutlet UIButton *wdButton7;

- (IBAction) wdBtn:(id)sender;


@property (nonatomic,retain) IBOutlet UILabel *monthDaysLabel;
@property (nonatomic,retain) IBOutlet UITextField *monthDays;

- (IBAction)monthDaysChange:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *everyTF;
@property (nonatomic,retain) IBOutlet UIButton *everyButton;
@property (nonatomic,retain) IBOutlet UIButton *fromSaveButton;
@property (nonatomic,retain) IBOutlet UILabel *fromSaveLabel;

- (IBAction)everyTFChange:(id)sender;
- (IBAction)everyBtn:(id)sender;
- (IBAction)fromSaveBtn:(id)sender;
- (IBAction)TFdidBeginEditing:(id)sender;
@property (nonatomic,assign) UITextField *activeField;   //just a pointer, no retain

@property (nonatomic,retain) IBOutlet UISegmentedControl *weekMonthEvery;

- (IBAction)weekMonthEveryChange:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *startHr;
@property (nonatomic,retain) IBOutlet UITextField *startMin;
@property (nonatomic,retain) IBOutlet UISlider *startSlider;
@property (nonatomic,retain) IBOutlet UILabel *startTimeAmPm;
@property (nonatomic,retain) IBOutlet UILabel *startLabel;

//start
- (IBAction)startHrChange:(id)sender;
- (IBAction)startMinChange:(id)sender;
- (IBAction)startSliderAction:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *finishHr;
@property (nonatomic,retain) IBOutlet UITextField *finishMin;
@property (nonatomic,retain) IBOutlet UISlider *finishSlider;
@property (nonatomic,retain) IBOutlet UILabel *finishTimeAmPm;
@property (nonatomic,retain) IBOutlet UILabel *finishLabel;
@property (nonatomic,retain) IBOutlet UILabel *finishColon;


@property (nonatomic,retain) IBOutlet UITextField *repeatTimes;
@property (nonatomic,retain) IBOutlet UILabel *repeatTimesLabel;
@property (nonatomic,retain) IBOutlet UIButton *intervalButton;

- (IBAction) enableFinishBtn:(id)sender;
@property (nonatomic,retain) IBOutlet UIButton *enableFinishButton;

 //fin
- (IBAction)finishHrChange:(id)sender;
- (IBAction)finishMinChange:(id)sender;
/*
- (IBAction)finishSliderAction:(id)sender;
- (IBAction)timesChange:(id)sender;
- (IBAction) intervalBtn:(id)sender;
*/


@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;

- (IBAction)btnDone:(id)sender;
- (IBAction)btnHelp:(id)sender;


@end
