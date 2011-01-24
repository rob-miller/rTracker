//
//  datePicker.h
//  rTracker
//
//  this support screen enables the user to specify a date/time to navigate, create or edit  entries for a tracker
//
//  Created by Robert Miller on 14/10/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DPA_CANCEL		0
#define DPA_NEW			1
#define DPA_SET			2
#define DPA_GOTO		3

#define SEG_DATE		0
#define SEG_TIME		1

@interface datePickerVC : UIViewController {

	NSString *myTitle;
	NSDate *date;

	NSInteger action;
	
	UINavigationBar *navBar;
	UIToolbar *toolBar;
	UIDatePicker *datePicker;
	UIButton *newBtn,*setBtn,*gotoBtn;
}

@property (nonatomic,retain) NSString *myTitle;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic) NSInteger action;

@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic,retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,retain) IBOutlet UIButton *newBtn;
@property (nonatomic,retain) IBOutlet UIButton *setBtn;
@property (nonatomic,retain) IBOutlet UIButton *gotoBtn;

- (IBAction) newBtnAction;
- (IBAction) setBtnAction;
- (IBAction) gotoBtnAction;
- (IBAction) dateModeChoice:(id)sender;


@end
