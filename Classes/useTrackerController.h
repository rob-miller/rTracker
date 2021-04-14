/***************
 useTrackerController.h
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

#import "dbg-defs.h"

#if ADVERSION && (!DISABLE_ADS)
#import "adSupport.h"
@interface useTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIAdaptivePresentationControllerDelegate, ADBannerViewDelegate>
#else
@interface useTrackerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIAdaptivePresentationControllerDelegate>
#endif

// UIAdaptivePresentationControllerDelegate added so dpvc.presentationController.delegate can be set to trigger viewWillAppear for ios13 - hacky.

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
#define CSSHOWCAL   3
//#define CSLEAVE     4


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

@property (nonatomic,strong) NSArray *searchSet;
@property (nonatomic,strong) NSString *rvcTitle;

#if ADVERSION && (!DISABLE_ADS)
@property (nonatomic,strong) adSupport *adSupport;
#endif

// UI element properties 

//@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *prevDateBtn;
@property (nonatomic, strong) UIBarButtonItem *postDateBtn;
@property (nonatomic, strong) UIBarButtonItem *currDateBtn;
@property (nonatomic, strong) UIBarButtonItem *calBtn;
@property (nonatomic, strong) UIBarButtonItem *searchBtn;
@property (nonatomic, strong) UIBarButtonItem *delBtn;
@property (nonatomic, strong) UIBarButtonItem *skip2EndBtn;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpaceButtonItem;
@property (nonatomic, strong) UIBarButtonItem *fixed1SpaceButtonItem;
//@property (nonatomic, retain) UIBarButtonItem *testBtn;

@property (nonatomic,strong) UIBarButtonItem *saveBtn;
@property (nonatomic,strong) UIBarButtonItem *menuBtn;

@property (nonatomic,strong) UIViewController *gt;

//@property (nonatomic,assign) UITextField *activeField;   // just a pointer, no retain

- (void) updateUTC:(NSNotification*)n;

- (void) updateToolBar;
- (void) setTrackerDate:(int) targD;
- (void) doGT;
- (void) returnFromGraph;
- (void) rejectTracker;

//- (BOOL) automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers;


@end
