/***************
 addTrackerController.h
 Copyright 2010-2016 Robert T. Miller
 
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

@interface addTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) trackerList *tlist;
@property (nonatomic, strong) trackerObj *tempTrackerObj;
@property (nonatomic) BOOL saving;

// UI element properties 
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet UIButton *infoBtn;
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UIButton *itemCopyBtn;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segcEditTrackerEditItems;
@property (nonatomic,strong) NSIndexPath *deleteIndexPath; // remember row to delete if user confirms in checkTrackerDelete alert
@property (nonatomic,strong) NSMutableArray *deleteVOs;    // VOs to be deleted on save

//@property (nonatomic,retain) UIActivityIndicatorView *spinner;
- (IBAction) toggleEdit:(id)sender;
- (IBAction) btnSetup:(id)sender;
- (IBAction) btnCopy:(id)sender;

//- (void)configureToolbarItems;

- (IBAction) nameFieldDone:(id)sender;

@end
