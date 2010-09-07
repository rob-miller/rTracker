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


@interface useTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource>
//UITableViewController 
{
	trackerObj *tracker;
	UITableView *table;
}

@property(nonatomic,retain) trackerObj *tracker;
@property (nonatomic, retain) IBOutlet UITableView *table;

@end
