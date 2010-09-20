//
//  useTrackerController.h
//  rTracker
//
//  Created by Robert Miller on 03/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerObj.h"
#import "valueObj.h"


@interface useTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
//UITableViewController 
{
	trackerObj *tracker;
	//UITableView *table;

	//UIBarButtonItem *prevDateBtn;
	//UIBarButtonItem *postDateBtn;
	//UIBarButtonItem *currDateBtn;
	
}

@property(nonatomic,retain) trackerObj *tracker;
//@property (nonatomic, retain) IBOutlet UITableView *table;

@property (nonatomic, retain) UIBarButtonItem *prevDateBtn;
@property (nonatomic, retain) UIBarButtonItem *postDateBtn;
@property (nonatomic, retain) UIBarButtonItem *currDateBtn;
@property (nonatomic, retain) UIBarButtonItem *delBtn;
@property (nonatomic, retain) UIBarButtonItem *flexibleSpaceButtonItem;
@property (nonatomic, retain) UIBarButtonItem *fixed1SpaceButtonItem;


@end
