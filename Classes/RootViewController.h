//
//  RootViewController.h
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import "trackerList.h"

@interface RootViewController : UITableViewController {

	//trackerList *tlist;
}

@property (nonatomic,retain) trackerList *tlist;

- (void)applicationWillTerminate:(NSNotification *)notification;

//- (IBAction)btnAddTrackerPressed:(id)sender;
//- (IBAction)btnConfigPressed:(id)sender;
//- (IBAction)btnMultiGraphPressed:(id)sender;
//- (IBAction)btnPrivatePressed:(id)sender;

@property (nonatomic, retain) UIBarButtonItem *privateBtn;
@property (nonatomic, retain) UIBarButtonItem *multiGraphBtn;

@end
