//
//  addTrackerController.h
//  rTracker
//
//  Created by Robert Miller on 15/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerList.h"
#import "trackerObj.h"
#import "valueObj.h"

@interface addTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

{

	UITextField	*nameField;
	trackerList *tlist;
	trackerObj *tempTrackerObj;
	UITableView *table;
	
}

@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) trackerList *tlist;
@property (nonatomic, retain) trackerObj *tempTrackerObj;
@property (nonatomic, retain) IBOutlet UITableView *table;

//- (IBAction) textFieldDoneEditing:(id)sender;
//- (IBAction) backgroundTap:(id)sender;

//- (IBAction)btnAddValue;

@end
