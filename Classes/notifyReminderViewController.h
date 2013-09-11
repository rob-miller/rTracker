//
//  notifyReminderViewController.h
//  rTracker
//
//  Created by Rob Miller on 07/08/2013.
//  Copyright (c) 2013 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerObj.h"

@interface notifyReminderViewController : UIViewController <UITextFieldDelegate>
{
    trackerObj *tracker;
}

@property (nonatomic,retain) trackerObj *tracker;

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

@property (nonatomic,retain) IBOutlet UISegmentedControl *weekMonthEvery;

- (IBAction)weekMonthEveryChange:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *startHr;
@property (nonatomic,retain) IBOutlet UITextField *startMin;
@property (nonatomic,retain) IBOutlet UISlider *startSlider;

//start
- (IBAction)hrChange:(id)sender;
- (IBAction)minChange:(id)sender;
- (IBAction)startSliderAction:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *finishHr;
@property (nonatomic,retain) IBOutlet UITextField *finishMin;
@property (nonatomic,retain) IBOutlet UISlider *finishSlider;
@property (nonatomic,retain) IBOutlet UITextField *repeatTimes;
@property (nonatomic,retain) IBOutlet UIButton *intervalButton;

- (IBAction) enableFinishBtn:(id)sender;
/*
//fin
- (IBAction)hrChange:(id)sender;
- (IBAction)minChange:(id)sender;
- (IBAction)finishSliderAction:(id)sender;
- (IBAction)timesChange:(id)sender;
- (IBAction) intervalBtn:(id)sender;
*/


//@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;

- (IBAction)btnDone:(id)sender;
- (IBAction)btnHelp:(id)sender;


@end
