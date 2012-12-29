//
//  RootViewController.h
//  rTracker
//
//  This is the first interactive screen, showing a list of the available trackers plus
// top:
//  - button to add a new tracker
//  - button to edit the list of available trackers
//
// bottom:
//  - pay button
//  - button to set privacy level
//  - button to graph multiple trackers together
//  - ??? export button ???
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import "trackerList.h"
#import "privacyV.h"

@interface RootViewController : UITableViewController {

	trackerList *tlist;
	privacyV *privacyObj;
    int32_t refreshLock;
    BOOL initialPrefsLoad;
}

@property (nonatomic,retain) trackerList *tlist;
@property (nonatomic, retain) privacyV *privacyObj;
@property (atomic) int32_t refreshLock;
@property (nonatomic) BOOL initialPrefsLoad;

// UI element properties 
@property (nonatomic, retain) UIBarButtonItem *privateBtn;
@property (nonatomic, retain) UIBarButtonItem *helpBtn;
@property (nonatomic, retain) UIBarButtonItem *addBtn;
@property (nonatomic, retain) UIBarButtonItem *editBtn;
@property (nonatomic, retain) UIBarButtonItem *flexibleSpaceButtonItem;

//@property (nonatomic, retain) UIBarButtonItem *multiGraphBtn;
//@property (nonatomic, retain) UIBarButtonItem *payBtn;

//- (void)applicationWillTerminate:(NSNotification *)notification;

- (void) loadInputFiles;
- (void) refreshView;
- (void) refreshToolBar:(BOOL)animated;
- (void) refreshEditBtn;
- (int) handleOpenFileURL:(NSURL*)url tname:(NSString*)tname;
- (void) openTracker:(int)tid;

@end
