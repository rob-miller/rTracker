//
//  notifyReminderVC2.h
//  rTracker
//
//  Created by Rob Miller on 19/04/2014.
//  Copyright (c) 2014 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "notifyReminder.h"
#import "notifyReminderViewController.h"

@interface notifyReminderVC2 : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    notifyReminderViewController *parentNRVC;
    NSArray *soundFiles;
}

@property (nonatomic,retain) notifyReminderViewController *parentNRVC;
@property (nonatomic,retain) NSArray *soundFiles;

@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (retain, nonatomic) IBOutlet UIPickerView *soundPicker;


- (IBAction)btnDone:(id)sender;
- (IBAction)btnHelp:(id)sender;
- (IBAction)btnTest:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *btnTestOutlet;

@end
