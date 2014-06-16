//
//  addTrackerController.h
//  rTracker
//
//  from this screen the user creates or edits a tracker, by naming it and adding values.
//
//  Created by Robert Miller on 15/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerList.h"
#import "trackerObj.h"
#import "valueObj.h"

@interface addTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) trackerList *tlist;
@property (nonatomic, strong) trackerObj *tempTrackerObj;
@property (nonatomic) BOOL saving;

// UI element properties 
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UIBarButtonItem *copyBtn;

@property (nonatomic,strong) NSIndexPath *deleteIndexPath; // remember row to delete if user confirms in checkTrackerDelete alert
@property (nonatomic,strong) NSMutableArray *deleteVOs;    // VOs to be deleted on save

//@property (nonatomic,retain) UIActivityIndicatorView *spinner;


- (void)configureToolbarItems;

- (IBAction) nameFieldDone:(id)sender;

@end
