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

#define SEG_DATE		0
#define SEG_TIME		1

#import "dpRslt.h"

@interface datePickerVC : UIViewController {

	NSString *myTitle;
    dpRslt *dpr;
	//NSDate *date;
	//NSInteger action;
}

@property (nonatomic,retain) NSString *myTitle;
//@property (nonatomic,retain) NSDate *date;
//@property (nonatomic) NSInteger action;
@property(nonatomic,retain) dpRslt *dpr;

// UI element properties 
@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic,retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,retain) IBOutlet UIButton *entryNewBtn;
@property (nonatomic,retain) IBOutlet UIButton *dateSetBtn;
@property (nonatomic,retain) IBOutlet UIButton *dateGotoBtn;

- (IBAction) entryNewBtnAction;
- (IBAction) dateSetBtnAction;
- (IBAction) dateGotoBtnAction;
- (IBAction) dateModeChoice:(id)sender;


@end
