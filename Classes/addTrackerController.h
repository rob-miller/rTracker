//
//  addTrackerController.h
//  rTracker
//
//  Created by Robert Miller on 15/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerList.h"

@interface addTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource>

{

	UITextField	*nameField;
	trackerList *tlist;
	
}

@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) trackerList *tlist;

- (IBAction) textFieldDoneEditing:(id)sender;
//- (IBAction) backgroundTap:(id)sender;

- (IBAction)btnAddValue;

@end
