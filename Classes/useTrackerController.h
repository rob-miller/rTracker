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

@interface useTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>
//UITableViewController 
{
	trackerObj *tracker;
	datePickerVC *dpvc;
    dpRslt *dpr;
	CGRect saveFrame;
    BOOL needSave;
    BOOL fwdRotations;
    BOOL rejectable;
    BOOL viewDisappearing;
    trackerList *tlist;
    int alertResponse;
    int saveTargD;
}

#define CSCANCEL    1
#define CSSETDATE   2

@property(nonatomic,retain) trackerObj *tracker;
@property (nonatomic, retain) datePickerVC *dpvc;
@property (nonatomic, retain) dpRslt *dpr;
@property (nonatomic) CGRect saveFrame;
@property (nonatomic) BOOL needSave;
@property (nonatomic) BOOL fwdRotations;
@property (nonatomic) BOOL rejectable;
@property (nonatomic) BOOL viewDisappearing;
@property (nonatomic, retain) trackerList *tlist;
@property (nonatomic) int alertResponse;
@property (nonatomic) int saveTargD;

// UI element properties 

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) UIBarButtonItem *prevDateBtn;
@property (nonatomic, retain) UIBarButtonItem *postDateBtn;
@property (nonatomic, retain) UIBarButtonItem *currDateBtn;
@property (nonatomic, retain) UIBarButtonItem *delBtn;
@property (nonatomic, retain) UIBarButtonItem *flexibleSpaceButtonItem;
@property (nonatomic, retain) UIBarButtonItem *fixed1SpaceButtonItem;
//@property (nonatomic, retain) UIBarButtonItem *testBtn;

@property (nonatomic,retain) UIBarButtonItem *saveBtn;
@property (nonatomic,retain) UIBarButtonItem *menuBtn;

//@property (nonatomic,assign) UITextField *activeField;   // just a pointer, no retain

- (void) updateUTC:(NSNotification*)n;

- (void) updateToolBar;
- (void) setTrackerDate:(int) targD;
- (void) doGT;
- (void) returnFromGraph;
- (void) rejectTracker;

//- (BOOL) automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers;


@end
