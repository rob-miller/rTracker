//
//  useTrackerController.h
//  rTracker
//
//  this screen presents the list of value objects for a specified tracker
//
//  Created by Robert Miller on 03/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "trackerObj.h"
#import "valueObj.h"

#import "datePickerVC.h"
#import "dpRslt.h"

#import "trackerList.h"

#import "trackerCalViewController.h"


@interface useTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>
//UITableViewController 
/*
 {
	trackerObj *tracker;
	datePickerVC *dpvc;
    dpRslt *dpr;
	CGRect saveFrame;
    BOOL needSave;
    BOOL didSave;
    BOOL fwdRotations;
    BOOL rejectable;
    BOOL viewDisappearing;
    trackerList *tlist;
    int alertResponse;
    int saveTargD;
    
    trackerCalViewController *tsCalVC;
}
*/

#define CSCANCEL    1
#define CSSETDATE   2

@property(nonatomic,strong) trackerObj *tracker;
@property (nonatomic, strong) datePickerVC *dpvc;
@property (nonatomic, strong) dpRslt *dpr;
@property (nonatomic) CGRect saveFrame;
@property (nonatomic) BOOL needSave;
@property (nonatomic) BOOL didSave;
@property (nonatomic) BOOL fwdRotations;
@property (nonatomic) BOOL rejectable;
@property (nonatomic) BOOL viewDisappearing;
@property (nonatomic, strong) trackerList *tlist;
@property (nonatomic) int alertResponse;
@property (nonatomic) int saveTargD;
@property (nonatomic,strong) trackerCalViewController *tsCalVC;

// UI element properties 

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) UIBarButtonItem *prevDateBtn;
@property (nonatomic, strong) UIBarButtonItem *postDateBtn;
@property (nonatomic, strong) UIBarButtonItem *currDateBtn;
@property (nonatomic, strong) UIBarButtonItem *calBtn;
@property (nonatomic, strong) UIBarButtonItem *delBtn;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpaceButtonItem;
@property (nonatomic, strong) UIBarButtonItem *fixed1SpaceButtonItem;
//@property (nonatomic, retain) UIBarButtonItem *testBtn;

@property (nonatomic,strong) UIBarButtonItem *saveBtn;
@property (nonatomic,strong) UIBarButtonItem *menuBtn;

//@property (nonatomic,assign) UITextField *activeField;   // just a pointer, no retain

- (void) updateUTC:(NSNotification*)n;

- (void) updateToolBar;
- (void) setTrackerDate:(int) targD;
- (void) doGT;
- (void) returnFromGraph;
- (void) rejectTracker;

//- (BOOL) automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers;


@end
