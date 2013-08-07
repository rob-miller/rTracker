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
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;

@property (nonatomic,retain) IBOutlet UITextField *startHr;
@property (nonatomic,retain) IBOutlet UITextField *startMin;
@property (nonatomic,retain) IBOutlet UITextField *finishHr;
@property (nonatomic,retain) IBOutlet UITextField *finishMin;

@property (nonatomic,retain) IBOutlet UITextField *repeatTimes;
@property (nonatomic,retain) IBOutlet UISlider *finishSlider;
@property (nonatomic,retain) IBOutlet UIButton *intervalButton;

-(IBAction) wdBtn:(id)sender;
-(IBAction) enableFinishBtn:(id)sender;
-(IBAction) intervalBtn:(id)sender;

-(IBAction)startSliderAction:(id)sender;
-(IBAction)finishSliderAction:(id)sender;

- (IBAction)hrChange:(id)sender;
- (IBAction)minChange:(id)sender;
- (IBAction)timesChange:(id)sender;

@end
