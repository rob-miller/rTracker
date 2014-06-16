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
/*
{
    notifyReminderViewController *parentNRVC;
    NSArray *soundFiles;
}
*/

@property (nonatomic,strong) notifyReminderViewController *parentNRVC;
@property (nonatomic,strong) NSArray *soundFiles;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIPickerView *soundPicker;


- (IBAction)btnDone:(id)sender;
- (IBAction)btnHelp:(id)sender;
- (IBAction)btnTest:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnTestOutlet;

@end
