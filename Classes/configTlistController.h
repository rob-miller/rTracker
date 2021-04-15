/***************
 configTlistController.h
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

//
//  configTlistController.h
//  rTracker
//
//  from this screen the user can move, delete, copy, or select for edit (modify) one of the existing trackers
//
//  Created by Robert Miller on 06/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerList.h"

#define SegmentEdit 0
#define SegmentCopy 1
#define SegmentMoveDelete 2


@interface configTlistController : UIViewController <UITableViewDelegate, UITableViewDataSource>
//@interface configTlistController : UITableViewController
/*
 {
	trackerList *tlist;
}
*/

@property (nonatomic, strong) trackerList *tlist;

// UI element properties 
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSIndexPath *deleteIndexPath; // remember row to delete if user confirms in checkTrackerDelete alert

//- (IBAction) btnExport;
- (IBAction) modeChoice:(id)sender;

@end
