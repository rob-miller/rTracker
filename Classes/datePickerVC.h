//
/***************
 datePickerVC.h
 Copyright 2010-2021 Robert T. Miller
 
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
