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

@interface datePickerVC : UIViewController
/*{

	NSString *myTitle;
    dpRslt *dpr;
	//NSDate *date;
	//NSInteger action;
}
*/

@property (nonatomic,strong) NSString *myTitle;
//@property (nonatomic,retain) NSDate *date;
//@property (nonatomic) NSInteger action;
@property(nonatomic,strong) dpRslt *dpr;

// UI element properties 
@property (nonatomic,strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic,strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic,strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,strong) IBOutlet UIButton *entryNewBtn;
//@property (nonatomic,strong) IBOutlet UIButton *entryCopyBtn;
@property (nonatomic,strong) IBOutlet UIButton *dateSetBtn;
@property (nonatomic,strong) IBOutlet UIButton *dateGotoBtn;
//@property (nonatomic,strong) IBOutlet UISegmentedControl *dtSegmentedControl;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *cancelBtn;
- (IBAction) btnCancel:(UIButton*)btn;

- (IBAction) entryNewBtnAction;
//- (IBAction) entryCopyBtnAction;
- (IBAction) dateSetBtnAction;
- (IBAction) dateGotoBtnAction;
//- (IBAction) dateModeChoice:(id)sender;


@end
