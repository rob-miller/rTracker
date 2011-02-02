//
//  useTrackerController.h
//  rTracker
//
//  this screen presents the list of value objects for a specified tracker
//
//  Created by Robert Miller on 03/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerObj.h"
#import "valueObj.h"

#import "datePickerVC.h"


@interface useTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate>
//UITableViewController 
{
	trackerObj *tracker;
	datePickerVC *dpvc;
	CGRect saveFrame;
}

@property(nonatomic,retain) trackerObj *tracker;
@property (nonatomic, retain) datePickerVC *dpvc;
@property (nonatomic) CGRect saveFrame;

// UI element properties 

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) UIBarButtonItem *prevDateBtn;
@property (nonatomic, retain) UIBarButtonItem *postDateBtn;
@property (nonatomic, retain) UIBarButtonItem *currDateBtn;
@property (nonatomic, retain) UIBarButtonItem *delBtn;
@property (nonatomic, retain) UIBarButtonItem *flexibleSpaceButtonItem;
@property (nonatomic, retain) UIBarButtonItem *fixed1SpaceButtonItem;
@property (nonatomic, retain) UIBarButtonItem *testBtn;

//@property (nonatomic,assign) UITextField *activeField;   // just a pointer, no retain

- (void) updateToolBar;
- (void) setTrackerDate:(int) targD;

@end
