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


@interface configTlistController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
//@interface configTlistController : UITableViewController
/*
 {
	trackerList *tlist;
}
*/

@property (nonatomic, strong) trackerList *tlist;

// UI element properties 
@property (nonatomic, strong) IBOutlet UITableView *table;

@property (nonatomic,strong) NSIndexPath *deleteIndexPath; // remember row to delete if user confirms in checkTrackerDelete alert

//- (IBAction) btnExport;
- (IBAction) modeChoice:(id)sender;

@end
