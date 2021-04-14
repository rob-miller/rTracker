/***************
 useTrackerController.m
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
//  useTrackerController.m
//  rTracker
//
//  Created by Robert Miller on 03/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//


#import "useTrackerController.h"
#import "graphTrackerVC.h"
#import "rTracker-constants.h"
#import "privacyV.h"
#import "rTracker-resource.h"
#import "dbg-defs.h"
#import "voState.h"

#if ADVERSION
#import "adSupport.h"
#import "rt_IAPHelper.h"
#endif

//#import "trackerCalViewController.h"

@interface useTrackerController ()
- (void) updateTrackerTableView;
- (void) updateTableCells:(valueObj*)inVO;
@end

@implementation useTrackerController

@synthesize tracker=_tracker;

@synthesize prevDateBtn=_prevDateBtn, postDateBtn=_postDateBtn, currDateBtn=_currDateBtn, delBtn=_delBtn, calBtn=_calBtn, flexibleSpaceButtonItem=_flexibleSpaceButtonItem, fixed1SpaceButtonItem=_fixed1SpaceButtonItem;
@synthesize tableView=_tableView;

@synthesize dpvc=_dpvc, dpr=_dpr, needSave=_needSave, didSave=_didSave, saveFrame=_saveFrame, fwdRotations=_fwdRotations, rejectable=_rejectable, viewDisappearing=_viewDisappearing, tlist=_tlist;
@synthesize saveBtn=_saveBtn, menuBtn=_menuBtn, alertResponse=_alertResponse, saveTargD=_saveTargD,tsCalVC=_tsCalVC, searchSet=_searchSet;
@synthesize searchBtn=_searchBtn;
@synthesize rvcTitle=_rvcTitle;

@synthesize gt=_gt;

#if ADVERSION && (!DISABLE_ADS)
@synthesize adSupport=_adSupport;
#endif

//BOOL keyboardIsShown=NO;

#pragma mark -
#pragma mark core object methods and support


# pragma mark -
# pragma mark view support

- (void) showSaveBtn {
	if (self.needSave && self.navigationItem.rightBarButtonItem != self.saveBtn) {
		[self.navigationItem setRightBarButtonItem:self.saveBtn animated:YES ];
	} else if (!self.needSave && self.navigationItem.rightBarButtonItem != self.menuBtn) {
		[self.navigationItem setRightBarButtonItem:self.menuBtn animated:YES ];
	}
}

#pragma mark -
#pragma mark tracker data updated event handling -- rtTrackerUpdatedNotification

- (void) updateTableCells:(valueObj*)inVO {
	NSMutableArray *iparr = [[NSMutableArray alloc] init];
    int n=0;
    
	for (valueObj *vo in self.tracker.valObjTable) {
        if (VOT_FUNC == vo.vtype) {
            vo.display = nil;  // always redisplay
            [iparr addObject:[[NSIndexPath indexPathWithIndex:0] indexPathByAddingIndex:n]];
        } else if ((inVO.vid == vo.vid) && (nil == vo.display)) {
            [iparr addObject:[[NSIndexPath indexPathWithIndex:0] indexPathByAddingIndex:n]];
        }
        n++;
	}
    // n.b. we hardcode number of sections in a tracker tableview here
    if (self.isViewLoaded && self.view.window)
        [self.tableView reloadRowsAtIndexPaths:iparr withRowAnimation:UITableViewRowAnimationNone];

}

#if ADVERSION
// handle rtPurchasedNotification
- (void) updatePurchased:(NSNotification*)n {
    [rTracker_resource doQuickAlert:@"Purchase Successful" msg:@"Thank you!" delay:2 vc:self];
#if !DISABLE_ADS
    if (nil != _adSupport) {
        if ([self.adSupport.bannerView isDescendantOfView:self.view]) {
            [self.adSupport.bannerView removeFromSuperview];
        }
        self.adSupport = nil;
    }
#endif
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[rTracker_resource getLaunchImageName]]];
    CGRect tableFrame = bg.frame;
    tableFrame.size.height = [rTracker_resource get_visible_size:self].height;// - ( 2 * statusBarHeight ) ;
    [self.tableView setFrame:tableFrame];
    self.tableView.backgroundView = bg;
    [self.tableView setNeedsDisplay];
    //[self.tableView reloadData];
}
#endif

// handle rtTrackerUpdatedNotification

- (void) updateUTC:(NSNotification*)n {
    DBGLog(@"UTC update notification from tracker %@", ((trackerObj*)[n object]).trackerName);
	valueObj *vo=nil;
    id obj = [n object];
	if ([obj isMemberOfClass:[valueObj class]]) {
		vo = (valueObj*) [n object];
        DBGLog(@"updated vo %@",vo.valueName);
    }

    [self updateTableCells:vo];
    self.needSave=YES;
	[self showSaveBtn];
    
    // write temp tracker here
    [self.tracker saveTempTrackerData];
    
    // delete on save or cancel button
    // load if present in viewdidload [?]
    // delete all on program start    [?]

}


#if ADVERSION && (!DISABLE_ADS)

- (void)viewDidLayoutSubviews
{
    if (![rTracker_resource getPurchased]) {
        [self.adSupport layoutAnimated:self tableview:self.tableView animated:[UIView areAnimationsEnabled]];
        //[self.adSupport layoutAnimated:self tableview:self.tableView animated:NO];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self.adSupport layoutAnimated:self tableview:self.tableView animated:YES];
    //[self.adSupport layoutAnimated:self tableview:self.tableView animated:NO];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self.adSupport layoutAnimated:self tableview:self.tableView animated:YES];
    //[self.adSupport layoutAnimated:self tableview:self.tableView animated:NO];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    //[self.adSupport stopTimer];
    return YES;
}
/*
 - (void)bannerViewActionDidFinish:(ADBannerView *)banner
 {
 //[self.adSupport startTimer];
 }
 */

- (adSupport*) adSupport
{
    if (![rTracker_resource getPurchased]) {
        if (_adSupport == nil) {
            _adSupport = [[adSupport alloc] init];
        }
    }
    return _adSupport;
}

#endif


-(void)loadView {
    // Ensure that we don't load an .xib file for this viewcontroller
    self.view = [UIView new];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
	//DBGLog(@"utc: viewDidLoad dpvc=%d", (self.dpvc == nil ? 0 : 1));
    self.fwdRotations = YES;
    self.needSave = NO;
    
    //for (valueObj *vo in self.tracker.valObjTable) {
    //	[vo display];
    //}

    keyboardIsShown = NO;

    // navigationbar setup
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"< %@",self.rvcTitle] //@"< rTracker"  // rTracker ... tracks ?
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(btnCancel)];
    self.navigationItem.leftBarButtonItem = backButton;

    // toolbar setup
    [self updateToolBar];
    
    // title setup
    self.title = self.tracker.trackerName;

    // tableview setup
    //UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[rTracker_resource getLaunchImageName]]];
    UIImageView *bg = [[UIImageView alloc] initWithImage:[rTracker_resource get_background_image:self]];
    
    //CGRect statusBarFrame = [self.navigationController.view.window convertRect:UIApplication.sharedApplication.statusBarFrame toView:self.navigationController.view];
    //CGFloat statusBarHeight = statusBarFrame.size.height;
    
    CGRect tableFrame = bg.frame;
    tableFrame.size.height = [rTracker_resource get_visible_size:self].height; //- ( 2 * statusBarHeight ) ;
    
#if ADVERSION
    if (![rTracker_resource getPurchased]) {
#if !DISABLE_ADS

        tableFrame.size.height -= self.adSupport.bannerView.frame.size.height;
        DBGLog(@"ad h= %f  tfh= %f ",self.adSupport.bannerView.frame.size.height,tableFrame.size.height);
#endif
    }
#endif
    
    DBGLog(@"tvf origin x %f y %f size w %f h %f",tableFrame.origin.x,tableFrame.origin.y,tableFrame.size.width,tableFrame.size.height);
    self.tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];  // because getLaunchImageName worked out size! //self.saveFrame
    
    //self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    bg.tag = BGTAG;
    [self.view addSubview:bg];
    [self.view sendSubviewToBack:bg];

    [self setViewMode];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];

    // swipe gesture recognizer
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewSwipeLeft:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipe];

    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewSwipeRight:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];

    /*
     * cannot seem to work alongside tableview swipe
     *
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewSwipeUp:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipe];
    */
    
    self.tracker.vc = self;
    self.alertResponse=0;
    self.saveTargD=0;
    
    //load temp tracker data here if available
    if ([self.tracker loadTempTrackerData]) {
        self.needSave=YES;
        [self showSaveBtn];
    }
    
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self setViewMode];
    [self.tableView setNeedsDisplay];
    [self.view setNeedsDisplay];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
/*
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

    DBGLog(@"utc unload %@",self.tracker.trackerName);
	
	UIView *haveView = [self.view viewWithTag:kViewTag2];
	if (haveView) 
		[haveView removeFromSuperview];
	self.dpvc = nil;
    self.dpr = nil;
	self.table = nil;
	
	self.title = nil;
	self.prevDateBtn = nil;
	self.currDateBtn = nil;
	self.postDateBtn = nil;
	self.delBtn = nil;
	self.calBtn = nil;
	
	self.fixed1SpaceButtonItem = nil;
	self.flexibleSpaceButtonItem = nil;
	
	self.toolbarItems = nil;
	self.navigationItem.rightBarButtonItem = nil;	
	self.navigationItem.leftBarButtonItem = nil;
	
	self.dpr.action = DPA_CANCEL;
	
	self.tracker.vc = nil;
	
	[super viewDidUnload];
}
*/

- (void) setViewMode {
    [rTracker_resource setViewMode:self];
    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            // if darkMode
            self.tableView.backgroundView = nil;
            self.tableView.backgroundColor = [UIColor systemBackgroundColor];
            return;
        }
     }

    self.tableView.backgroundColor = [UIColor clearColor];

}

- (void) viewWillAppear:(BOOL)animated {
    
    //DBGLog(@"utc: view will appear");
    
    self.viewDisappearing=NO;

    CGRect f = [rTracker_resource getKeyWindowFrame];
    
    if (f.size.width > f.size.height) {  // already in landscape view
        [self doGT];
    } else {
        if (f.size.width != self.tableView.frame.size.width) {
            f.origin.x = 0.0; f.origin.y = 0.0;
            self.tableView.frame = f;
            [self setViewMode];
            [self.tracker rescanMaxLabel];
            [self.tableView reloadData];
        }
        
        if (self.dpr) {
            switch (self.dpr.action) {
                case DPA_NEW:
                    [self.tracker resetData];
                    //[self updateTrackerTableView];  // moved below
                    self.tracker.trackerDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.tracker noCollideDate:(int)[self.dpr.date timeIntervalSince1970]]];
                    //[self updateToolBar];
                    break;
                case DPA_SET:
                {
                    if ([self.tracker hasData]) {
                        [self.tracker changeDate:self.dpr.date];
                        self.needSave = YES;
                    } else {
                        self.tracker.trackerDate = self.dpr.date;
                    }
                    //[self updateToolBar];
                    break;
                }
                case DPA_GOTO:
                {
                    int targD = 0;
                    if (nil != self.dpr.date) {  // set to nil to cause reset tracker, ready for new
                        targD = (int) [self.dpr.date timeIntervalSince1970];
                        if (! [self.tracker loadData:targD]) {
                            self.tracker.trackerDate = self.dpr.date;
                            targD = (int) [self.tracker prevDate];
                            if (!targD)
                                targD = (int) [self.tracker postDate];
                        }
                    }
                    [self setTrackerDate:targD];
                    break;
                }
                case DPA_GOTO_POST:  // for TimesSquare calendar which gives date with time=midnight (= beginning of day)
                {
                    int targD = 0;
                    if (nil != self.dpr.date) {  // set to nil to cause reset tracker, ready for new
                        targD = (int) [self.dpr.date timeIntervalSince1970];
                        if (! [self.tracker loadData:targD]) {
                            self.tracker.trackerDate = self.dpr.date;
                            targD = (int) [self.tracker postDate];
                            if (!targD)
                                targD = 0;  // if no post date, must mean today so new tracker
                            //targD = [self.tracker prevDate];
                        }
                    }
                    [self setTrackerDate:targD];
                    break;
                }
                case DPA_CANCEL:
                    break;
                default:
                    dbgNSAssert(0,@"failed to determine dpr action");
                    break;
            }
            self.dpr.date = nil;
            self.dpvc = nil;
            self.dpr = nil;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tracker
                                                 selector:@selector(trackerUpdated:)
                                                     name:rtValueUpdatedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateUTC:)
                                                     name:rtTrackerUpdatedNotification
                                                   object:self.tracker];

#if ADVERSION
        if (![rTracker_resource getPurchased]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updatePurchased:)
                                                         name:rtPurchasedNotification
                                                       object:nil];
        }
#endif
        
        //DBGLog(@"add kybd will show notifcation");
        keyboardIsShown = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:self.view.window];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:self.view.window];
        
        
        [self showSaveBtn];
        [self updateTrackerTableView];  // need to force redisplay and set sliders, so reload in viewdidappear not so noticeable
        
        [self.navigationController setToolbarHidden:NO animated:NO];
        
        [self updateToolBar];
        
    
#if ADVERSION
    if (![rTracker_resource getPurchased]) {
#if !DISABLE_ADS
        [self.adSupport initBannerView:self];
        [self.view addSubview:self.adSupport.bannerView];
#endif
    }
#endif
    }
    
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    
    //DBGLog(@"utc view did appear!");
    // in case we just regained active after interruption -- sadly view still seen if done in viewWillAppear
    if ((nil != self.tracker)
        && ([self.tracker getPrivacyValue] > [privacyV getPrivacyValue])) {
        //[self.navigationController popViewControllerAnimated:YES];
        [self.tracker.activeControl resignFirstResponder];
        
        if ([rTracker_resource getSavePrivate]) {
            [self btnCancel];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    //[self updateTrackerTableView];  // need for ios5 after set date in graph and return
    [self.tableView reloadData];
    self.didSave=NO;
    
    if (![rTracker_resource getToldAboutSwipe]) { // if not yet told
        if (0 != [self.tracker prevDate]) {  //  and have previous data
            [rTracker_resource alert:@"Swipe control" msg:@"Swipe for earlier entries" vc:self];
            [rTracker_resource setToldAboutSwipe:true];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toldAboutSwipe"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
#if ADVERSION
    if (![rTracker_resource getPurchased]) {
#if !DISABLE_ADS
        [self.adSupport layoutAnimated:self tableview:self.tableView animated:NO];
#endif
    }
#endif

    [super viewDidAppear:animated];

    
}



- (void) viewWillDisappear :(BOOL)animated
{
    self.viewDisappearing=YES;
/*
 if (self.needSave) {
        self.alertResponse=CSCANCEL;
        [self alertChkSave];
    }
 */
    
    DBGLog(@"utc view disappearing");
    //already done [self.tracker.activeControl resignFirstResponder];

    // unregister this tracker for value updated notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self.tracker 
                                                    name:rtValueUpdatedNotification
                                                  object:nil];

	//unregister for tracker updated notices
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:rtTrackerUpdatedNotification
                                                  object:nil];  

#if ADVERSION
    //unregister for purchase notices
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:rtPurchasedNotification
                                                    object:nil];
#endif
    
    //DBGLog(@"remove kybd will show notifcation");
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
    
    /* 
     // failed effort to use default back button
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
     */
    
    [super viewWillDisappear:animated];
}

/*
 // failed effort to use default back button
 - (void)willMoveToParentViewController:(UIViewController *)parent {
     if (parent == nil) {
         DBGLog(@"will move to parent view controller");
         if (self.needSave) {
             self.alertResponse=CSLEAVE;
             [self alertLeaving];
             return; // don't disappear yet...
         } else {
             [self leaveTracker];
         }
         
     }
}
*/

- (void) rejectTracker {
    DBGLog(@"rejecting input tracker %ld %@  prevTID= %ld", (long)self.tracker.toid,self.tracker.trackerName, (long)self.tracker.prevTID);
    [self.tlist updateTLtid:(int)self.tracker.toid new:(int)self.tracker.prevTID];  // revert topLevel to before
    [self.tracker deleteTrackerDB];
    [rTracker_resource unStashTracker:(int)self.tracker.prevTID];  // this view and tracker going away now so dont need to clear rejectable or prevTID
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (self.rejectable && self.viewDisappearing) {
        [self rejectTracker];
    }
}


# pragma mark view rotation methods
/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // only for pre ios 6.0
    
    // Return YES for supported orientations
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"utc should rotate to interface orientation portrait?");
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"utc should rotate to interface orientation portrait upside down?");
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"utc should rotate to interface orientation landscape left?");
 
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) {//if 5
                [self doGT];
            }
 
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"utc should rotate to interface orientation landscape right?");
 
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) { //if 5
                [self doGT];
            }
 
			break;
		default:
			DBGWarn(@"utc rotation query but can't tell to where?");
			break;			
	}
	
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown );
}
*/
/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	switch (fromInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"utc did rotate from interface orientation portrait");
 
            //if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
                [self doGT];
            //}
 
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"utc did rotate from interface orientation portrait upside down");
            [self doGT];
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"utc did rotate from interface orientation landscape left");
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"utc did rotate from interface orientation landscape right");
			break;
		default:
			DBGWarn(@"utc did rotate but can't tell from where");
			break;			
	}
}
*/
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if ( self.isViewLoaded && self.view.window ) {

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever  -- willRotateTo
         
         switch (orientation) {
             case UIInterfaceOrientationPortrait:
                 DBGLog(@"utc will rotate to interface orientation portrait");
                 break;
             case UIInterfaceOrientationPortraitUpsideDown:
                 DBGLog(@"utc will rotate to interface orientation portrait upside down");
                 break;
             case UIInterfaceOrientationLandscapeLeft:
                 DBGLog(@"utc will rotate to interface orientation landscape left");
                 //[self.tracker.activeControl resignFirstResponder];
                 //[self doGT];
                 break;
             case UIInterfaceOrientationLandscapeRight:
                 DBGLog(@"utc will rotate to interface orientation landscape right");
                 //[self.tracker.activeControl resignFirstResponder];
                 //[self doGT];
                 break;
             default:
                 DBGWarn(@"utc will rotate but can't tell to where");
                 break;
         }
         
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever -- didRotateTo
         switch (orientation) {
             case UIInterfaceOrientationPortrait:
                 DBGLog(@"utc did rotate to interface orientation portrait");
                 break;
             case UIInterfaceOrientationPortraitUpsideDown:
                 DBGLog(@"utc did rotate to interface orientation portrait upside down");
                 break;
             case UIInterfaceOrientationLandscapeLeft:
                 DBGLog(@"utc did rotate to interface orientation landscape left");
                 [self.tracker.activeControl resignFirstResponder];
                 [self doGT];
                 break;
             case UIInterfaceOrientationLandscapeRight:
                 DBGLog(@"utc did rotate to interface orientation landscape right");
                 [self.tracker.activeControl resignFirstResponder];
                 [self doGT];
                 break;
             default:
                 DBGWarn(@"utc did rotate but can't tell to where");
                 break;
         }
     }];
    }

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}
/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"utc will rotate to interface orientation portrait duration: %f sec",duration);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"utc will rotate to interface orientation portrait upside down duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"utc will rotate to interface orientation landscape left duration: %f sec", duration);
            [self.tracker.activeControl resignFirstResponder];
 
            // if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) { [self doGT]; }
 
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"utc will rotate to interface orientation landscape right duration: %f sec", duration);
            [self.tracker.activeControl resignFirstResponder];
 
            // if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) { [self doGT]; }
 
			break;
		default:
			DBGWarn(@"utc will rotate but can't tell to where duration: %f sec", duration);
			break;			
	}
}
*/

// * not ios6
// YES should be default anyway so no need to subclass  ??
/*
- (BOOL) automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
 
    DBGLog(@"autoFwdRot returning %d",self.fwdRotations);
    //return self.fwdRotations;
    return YES;
}
 */

/* YES is default
- (BOOL) shouldAutomaticallyForwardRotationMethods {
    return YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}
 */


- (void) doGT {
    DBGLog(@"start present graph");

	graphTrackerVC *gt;
    gt = [[graphTrackerVC alloc] init];
    gt.modalPresentationStyle = UIModalPresentationFullScreen;  // need for iPad, this is default for 'horizontally compact environment'
    
    gt.tracker = self.tracker;
    if ([self.tracker hasData]) {
        self.dpr.date = self.tracker.trackerDate;
        self.dpr.action = DPA_GOTO;
    }
    gt.dpr = self.dpr;
    gt.parentUTC = self;
    
    self.gt = gt;
    
    //gt.modalPresentationStyle = UIModalPresentationFullScreen;
    //self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    self.fwdRotations = NO;
    [self presentViewController:gt animated:YES completion:NULL];

    DBGLog(@"graph up");
}

BOOL alreadyReturning=NO;    // graphTrackerVC viewWillTransitionToSize() called when we dismissVieControllerAnimated() below, so don't call a second time
- (void) returnFromGraph {
    if (alreadyReturning) return;
    alreadyReturning = YES;
    DBGLog(@"start return from graph");
    self.fwdRotations=YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
    alreadyReturning = NO;
    DBGLog(@"graph down");
}

/*

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"utc will animate rotation to interface orientation portrait duration: %f sec",duration);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"utc will animate rotation to interface orientation portrait upside down duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"utc will animate rotation to interface orientation landscape left duration: %f sec", duration);

            if ( SYSTEM_VERSION_LESS_THAN(@"5.0") ) {// if not 5
                [self doGT];
            }
            
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"utc will animate rotation to interface orientation landscape right duration: %f sec", duration);

            if ( SYSTEM_VERSION_LESS_THAN(@"5.0") ) { // if not 5
                [self doGT];
            }
			
			break;
		default:
			DBGWarn(@"utc will animate rotation but can't tell to where. duration: %f sec", duration);
			break;			
	}
}
*/


# pragma mark -
# pragma mark keyboard notifications

/*
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	DBGLog(@"utc: tf begin editing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	DBGLog(@"utc: tf end editing");
}

//UITextField *activeField;
*/

- (void)keyboardWillShow:(NSNotification *)n
{
    DBGLog(@"UTC keyboardwillshow");
    
	CGPoint coff = self.tableView.contentOffset;
	//DBGLog(@"coff x=%f y=%f",coff.x,coff.y);
    //DBGLog(@"k will show, y= %f",viewFrame.origin.y);
    
	CGFloat boty;

#if DEBUGLOG
    UIControl *ac = self.tracker.activeControl;
    UIView *acsv = ac.viewForBaselineLayout;
    CGRect vf = acsv.frame;
    DBGLog(@"frame1: %f %f %f %f",vf.origin.x,vf.origin.y,vf.size.width,vf.size.height);
    acsv = ac.superview;
    vf = acsv.frame;
    DBGLog(@"frame2: %f %f %f %f",vf.origin.x,vf.origin.y,vf.size.width,vf.size.height);
    acsv = ac.superview.superview;
    vf = acsv.frame;
    DBGLog(@"frame3: %f %f %f %f",vf.origin.x,vf.origin.y,vf.size.width,vf.size.height);
    acsv = ac.superview.superview.superview;
    vf = acsv.frame;
    DBGLog(@"frame4: %f %f %f %f",vf.origin.x,vf.origin.y,vf.size.width,vf.size.height);

    acsv = self.view;
    vf = acsv.frame;
    DBGLog(@"self frame: %f %f %f %f",vf.origin.x,vf.origin.y,vf.size.width,vf.size.height);
    
#endif
    /*
    if (kIS_LESS_THAN_IOS7) {
        boty = self.tracker.activeControl.superview.superview.frame.origin.y - coff.y;
        // activeField.superview.superview.frame.origin.y - coff.y ;
        //+ activeField.superview.superview.frame.size.height + MARGIN;
    } else if (kIS_LESS_THAN_IOS8) {
        boty = self.tracker.activeControl.superview.superview.superview.frame.origin.y - coff.y;
        boty += self.tracker.activeControl.superview.superview.superview.frame.size.height;
    } else {  // ios 8 and above
     */
        boty = self.tracker.activeControl.superview.superview.frame.origin.y + self.tracker.activeControl.superview.superview.frame.size.height - coff.y;
    //}

    DBGLog(@"dispatching to wsk, boty= %f kis=%d",boty,keyboardIsShown);
    [rTracker_resource willShowKeyboard:n view:self.view boty:boty];

    
    /*
    if (keyboardIsShown) { // need bit more logic to handle additional scrolling for another textfield
        return;
    }
	
	//DBGLog(@"handling keyboard will show: %@",[n object]);
	self.saveFrame = self.view.frame;
	
    NSDictionary* userInfo = [n userInfo];
	
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];  //FrameBeginUserInfoKey 
    CGSize keyboardSize = [boundsValue CGRectValue].size;
	
	CGRect viewFrame = self.view.frame;
	CGPoint coff = self.table.contentOffset;
	DBGLog(@"coff x=%f y=%f",coff.x,coff.y);
	DBGLog(@"k will show, y= %f",viewFrame.origin.y);

	CGFloat boty;
    
    if (kIS_LESS_THAN_IOS7) {
        boty = self.tracker.activeControl.superview.superview.frame.origin.y - coff.y;
        // activeField.superview.superview.frame.origin.y - coff.y ;
        //+ activeField.superview.superview.frame.size.height + MARGIN;
    } else {
        boty = self.tracker.activeControl.superview.superview.superview.frame.origin.y - coff.y;
        boty += self.tracker.activeControl.superview.superview.superview.frame.size.height;
    }
    CGFloat topk = viewFrame.size.height - keyboardSize.height;  // - viewFrame.origin.y;
	if (boty <= topk) {
		DBGLog(@"activeField visible, do nothing  boty= %f  topk= %f",boty,topk);
	} else {
		DBGLog(@"activeField hidden, scroll up  boty= %f  topk= %f",boty,topk);
		
		viewFrame.origin.y -= (boty - topk);
		//viewFrame.size.height -= self.navigationController.toolbar.frame.size.height;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kAnimationDuration];
		
		[self.view setFrame:viewFrame];
		
		[UIView commitAnimations];
	}
	
    keyboardIsShown = YES;
	*/
}
- (void)keyboardWillHide:(NSNotification *)n
{
	DBGLog(@"handling keyboard will hide");
    [rTracker_resource willHideKeyboard];
    
	/*
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self.view setFrame:self.saveFrame];
	
	[UIView commitAnimations];
	
    keyboardIsShown = NO;
     */
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#if DEBUGLOG
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	DBGLog(@"I am touched at %f, %f.",touchPoint.x, touchPoint.y);
#endif
    
	[self.tracker.activeControl resignFirstResponder];
}

#pragma mark -
#pragma mark top toolbar button factories
//- (void)testAction:(id)sender {
//	DBGLog(@"test button pressed");
/*
 *  fn= period[full tank]:(delta[odometer]/postSum[fuel])
 *
 *  keywords
 *      period(x)	x= non-null vo | time interval string : define begin,end timestamps; default if not spec'd is each pair of dates
 *			-> gen array T0[] and array T1[]
 *		delta(x)	x= non-null vo : return vo(time1) - vo(time0)
 *			-> ('select val where id=%id and date=%t1' | vo.value) - 'select val where id=%id and date=%t0'
 *		postsum(x)	x= vo : return sum of vo(>time0)...vo(=time1)
 *			-> 'select val where id=%id and date > %t0 and date <= %t1' ... sum
 *		presum(x)	x= vo : return sum of vo(=time0)...vo(<time1)
 *			-> 'select val where id=%id and date >= %t0 and date < %t1' ... sum
 *		sum(x)		x= vo : return sum of vo(=time0)...vo(=time1)
 *			-> 'select val where id=%id and date >= %t0 and date <= %t1' ... sum
 *		avg(x)      x= vo : return avg of vo(=time0)...vo(=time1)
 *			-> 'select val where id=%id and date > %t0 and date <= %t1' ... avg
 *		
 * -> vo => convert to vid
 * -> separately define period: none | event pair | event + (plus,minus,centered) time interval 
 *                            : event = vo not null or hour / week day / month day
 *
 * ... can't do plus/minus/centered, value will be plotted on T1
 */
//NSString *myfn = @"period[full tank]:(delta[odometer]/postSum[fuel])";
//	
//}

/*
 - (UIBarButtonItem*)testBtn {
 if (testBtn == nil) {
 testBtn = [[UIBarButtonItem alloc]
 initWithTitle:@"test"
 style:UIBarButtonItemStylePlain
 target:self
 action:@selector(testAction:)];
 }
 
 return testBtn;
 
 }
 */

- (UIBarButtonItem*) saveBtn {
    if (_saveBtn == nil) {
        _saveBtn =[[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                  target:self
                  action:@selector(btnSave)];
    }
    return _saveBtn;
}

- (UIBarButtonItem*) menuBtn {
    if (_menuBtn == nil) {
        if (self.rejectable) {
            _menuBtn = [[UIBarButtonItem alloc]
                       initWithTitle:@"Accept"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(btnAccept)];
            _menuBtn.tintColor=[UIColor greenColor];
        } else {
            _menuBtn = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                       //initWithTitle:@"menuBtn"
                       //style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(btnMenu)];
        } /*
           // can export or duplicate last to now
           else {
            _menuBtn = [[UIBarButtonItem alloc]
                       initWithTitle:@"Export"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(iTunesExport)];
        }
           */
    }

    return  _menuBtn;
}


#pragma mark -
#pragma mark datepicker support

- (void) clearVoDisplay {
	for (valueObj *vo in self.tracker.valObjTable) {
        //if (vo.vtype == VOT_FUNC)
        vo.display = nil;  // always redisplay
	}
    
}
- (void) updateTrackerTableView {
    // see related updateTableCells above
	//DBGLog(@"utc: updateTrackerTableView");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        for (valueObj *vo in self.tracker.valObjTable) {
            //if (vo.vtype == VOT_FUNC)
            vo.display = nil;  // always redisplay
        }
        
        [self.tableView reloadData];
    });
    
	//[(UITableView *) self.view reloadData];
	//	[self.tableView reloadData];  // if we were a uitableviewcontroller not uiviewcontroller
}

- (void) updateToolBar {
	//[self setToolbarItems:nil animated:YES];
    
	NSMutableArray *tbi=[[NSMutableArray alloc] init];
	
	int prevD = (int)[self.tracker prevDate];
	int postD = (int)[self.tracker postDate];
	int lastD = (int)[self.tracker lastDate];
	int currD = (int) [self.tracker.trackerDate timeIntervalSince1970];
/*
	DBGLog(@"prevD = %d %@",prevD,[NSDate dateWithTimeIntervalSince1970:prevD]);
	DBGLog(@"currD = %d %@",currD,[NSDate dateWithTimeIntervalSince1970:currD]);
	DBGLog(@"postD = %d %@",postD,[NSDate dateWithTimeIntervalSince1970:postD]);
	DBGLog(@"lastD = %d %@",lastD,[NSDate dateWithTimeIntervalSince1970:lastD]);
*/	
	self.currDateBtn = nil;

	if (postD != 0 || (lastD == currD)) {
		[tbi addObject:self.delBtn];
	} else {
        [tbi addObject:self.fixed1SpaceButtonItem];
    }
    
    [tbi addObject:self.flexibleSpaceButtonItem];
    
	[tbi addObject:self.currDateBtn];
	
    [tbi addObject:self.flexibleSpaceButtonItem];
    if ((prevD !=0) || (postD !=0) || (lastD == currD)) {
        [tbi addObject:self.calBtn];
	} else {
        [tbi addObject:self.fixed1SpaceButtonItem];
    }
    [tbi addObject:self.flexibleSpaceButtonItem];
    
    if (nil != self.searchSet) {
        [tbi addObject:self.searchBtn];
    } else {
        [tbi addObject:self.fixed1SpaceButtonItem];
        
    }
    [tbi addObject:self.flexibleSpaceButtonItem];
    
	if (postD != 0 || (lastD == currD)) {
        [tbi addObject:self.skip2EndBtn];
	} else {
        [tbi addObject:self.fixed1SpaceButtonItem];
    }

	//[tbi addObject:[self testBtn]];
	 
	[self setToolbarItems:tbi animated:YES];
}

-(void) dispatchHandleModifiedTracker:(NSInteger)choice {
    
    if (0 == choice) {  // cancel
        return;
    }
    
    if (self.alertResponse) {
        if (1 == choice) {  // save
            [self saveActions];
        } else if (2 == choice) {  // discard
        }
        self.needSave=NO;
        if (CSSETDATE==self.alertResponse) {
            int tsdate = self.saveTargD;
            self.alertResponse=0;
            self.saveTargD=0;
            [self setTrackerDate:tsdate];
        } else if (CSCANCEL==self.alertResponse) {
            self.alertResponse=0;
            [self btnCancel];
            //[self dealloc];
        } else if (CSSHOWCAL==self.alertResponse) {
            self.alertResponse=0;
            [self btnCal];
            /*
             // failed effort to use default back button
             } else if (CSLEAVE==self.alertResponse) {
             [self leaveTracker];
             //[super viewWillDisappear:YES];
             */
        }
    }
}

- (void) handleDeleteEntry:(NSInteger)choice {
    
    if (0 == choice) {
        DBGLog(@"cancelled");
    } else {
        int targD = (int)[self.tracker prevDate];
        if (!targD) {
            targD = (int)[self.tracker postDate];
        }
        [self.tracker deleteCurrEntry];
        [self setTrackerDate: targD];
    }
}

- (void) duplicateEntry {
    self.tracker.trackerDate = [[NSDate alloc] init];
    self.needSave = YES;
    
    [self showSaveBtn];
    
    // write temp tracker here
    [self.tracker saveTempTrackerData];
    [self updateToolBar];
    [self updateTrackerTableView];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:rtTrackerUpdatedNotification object:self]; // not sure why this doesn't work here....
    
}

- (IBAction)iTunesExport {
    
    DBGLog(@"exporting tracker:");
#if DEBUGLOG
    [self.tracker describe];
#endif
    //[rTracker_resource startProgressBar:self.view navItem:self.navigationItem disable:YES];
    CGRect navframe = [[self.navigationController navigationBar] frame];
    [rTracker_resource startProgressBar:self.view navItem:self.navigationItem disable:YES  yloc:(navframe.size.height + navframe.origin.y) ];
    //[rTracker_resource startProgressBar:self.navigationController.view navItem:self.navigationItem disable:YES];
    [NSThread detachNewThreadSelector:@selector(doPlistExport) toTarget:self withObject:nil];
}

- (void) handleExportTracker:(NSString*)buttonTitle {
    
    if ([emCancel isEqualToString:buttonTitle]) {
        DBGLog(@"cancelled");
    } else if ([emItunesExport isEqualToString:buttonTitle]) {
        [self iTunesExport];
    } else if ([emDuplicate isEqualToString:buttonTitle]) {
        [self duplicateEntry];
    } else {
        [self openMail:buttonTitle];
    }
    
}

/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title hasSuffix:@"modified"]) {          // tracker modified and trying to leave without save
        [self dispatchHandleModifiedTracker:buttonIndex];
    } else if ([alertView.title hasPrefix:@"Really"]) {     // pessed delete button for entry
        [self handleDeleteEntry:buttonIndex];
    }else {                                                 // export menu
        [self handleExportTracker:[alertView buttonTitleAtIndex:buttonIndex]];
    }
}
 */
/*
xxx stuck here - how to get back to setTrackerDate or btnCancel ?

save targD somewhere
if targd exists then do settrackerdate
else do btnCancel/btnSave
*/

- (void) alertChkSave {
    NSString *title = [self.tracker.trackerName stringByAppendingString:@" modified"]; // 'modified' needed by handler
    NSString *msg = @"Save this record before leaving?";
    NSString *btn0 = @"Cancel";
    NSString *btn1 = @"Save";
    NSString *btn2 = @"Discard";
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:btn0 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self dispatchHandleModifiedTracker:0]; }];
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:btn1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self dispatchHandleModifiedTracker:1]; }];
    UIAlertAction* discardAction = [UIAlertAction actionWithTitle:btn2 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self dispatchHandleModifiedTracker:2]; }];
    
    [alert addAction:saveAction];
    [alert addAction:discardAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
 // failed effort to use default back button
- (void) alertLeaving {
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc]
             initWithTitle:[self.tracker.trackerName stringByAppendingString:@" modified"]
             message:@"Save this record before leaving?"
             delegate:self
             cancelButtonTitle:@"Discard"
             otherButtonTitles: @"Save",nil];
    
    [alert show];
    
}
*/

- (void) setTrackerDate:(int) targD {
	
    if (self.needSave) {
        self.alertResponse=CSSETDATE;
        self.saveTargD=targD;
        [self alertChkSave];
        return;
    }
    
	if (targD == 0) {
		DBGLog(@" setTrackerDate: %d = reset to now",targD);
		[self.tracker resetData];
	} else if (targD < 0) {
		DBGLog(@"setTrackerDate: %d = no earlier date", targD);
	} else {
		DBGLog(@" setTrackerDate: %d = %@",targD, [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)targD]);
		[self.tracker loadData:targD];
	}
	self.needSave=NO;  // dumping anything not saved by going to another date.
	[self showSaveBtn];
	[self updateToolBar];
	[self updateTrackerTableView];
}

#pragma mark -
#pragma mark button press action methods
- (void)applicationWillResignActive:(UIApplication *)application {
    DBGLog(@"HEY!");
}

- (void)leaveTracker {
    [self.tracker removeTempTrackerData];
    if (self.didSave) {
        [self.tracker setReminders];  // saved data may change reminder action so wipe and set again
        self.didSave=NO;
    } else {
        [self.tracker confirmReminders];  // else just confirm any enabled reminders have one scheduled
    }
    // took out because need default 'back button' = "<name>'s tracks" but can't set action only for that button -- need to catch in viewWillDisappear  -- FAILED
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCancel {   // back button
    
	DBGLog(@"btnCancel was pressed!");
    if (self.needSave) {
        self.alertResponse=CSCANCEL;
        [self alertChkSave];
        return;
    }

    [self leaveTracker];
}

- (void) saveActions {
    if (self.rejectable) {
        if (self.tracker.prevTID) {
            [rTracker_resource rmStashedTracker:(int)self.tracker.prevTID];
            self.tracker.prevTID=0;
        }
        self.rejectable=NO;
        [self checkPrivWarn];
    }
    
	[self.tracker saveData];
    self.needSave=NO;
    
}
    
- (void)btnSave {
	//DBGLog(@"btnSave was pressed! tracker name= %@ toid= %d",self.tracker.trackerName, self.tracker.toid);
    [self saveActions];

    if (nil != self.searchSet) {  // don't leave if have search set, just update save button to indicate save not needed
		[self showSaveBtn];  // also don't clear form as below
        return;
    }
    
	if ([(self.tracker.optDict)[@"savertn"] isEqualToString:@"0"]) {  // default:1
        // do not return to tracker list after save, so generate clear form
		if (![self.toolbarItems containsObject:self.postDateBtn])
			[self.tracker resetData];
		[self updateToolBar];
		[self updateTrackerTableView];
        self.needSave=NO;
		[self showSaveBtn];
    } else {
        [self leaveTracker];
        // added here after removing from leaveTracker
        // but FAILED
        // [self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)handleViewSwipeUp:(UISwipeGestureRecognizer *)gesture {
    if (self.needSave) {
        [self btnSave];
    } else {
        [self btnCancel];
    }
}

- (void) doPlistExport {
    @autoreleasepool {
    //DBGLog(@"start export");
    
        [self.tracker saveToItunes];
        safeDispatchSync(^{
            [rTracker_resource finishProgressBar:self.view navItem:self.navigationItem disable:YES];
        });
        [rTracker_resource alert:@"Tracker saved" msg:[NSString stringWithFormat:@"%@_out.csv and _out.plist files have been saved to the rTracker Documents directory on this device.  Access them through iTunes on your PC/Mac, or with a program like iExplorer from Macroplant.com.  Import by changing the names to _in.csv and _in.plist, and read about .rtcsv file import capabilities in the help pages.",self.tracker.trackerName] vc:self];

    }
}

NSString *emCancel = @"Cancel";
NSString *emEmailCsv = @"email CSV";
NSString *emEmailTracker = @"email Tracker";
NSString *emEmailTrackerData = @"email Tracker+Data";
NSString *emItunesExport = @"save for PC (iTunes)";
NSString *emDuplicate = @"duplicate entry to now";


- (IBAction)btnMenu {
    
    //int prevD = (int)[self.tracker prevDate];
    int postD = (int)[self.tracker postDate];
    int lastD = (int)[self.tracker lastDate];
    int currD = (int) [self.tracker.trackerDate timeIntervalSince1970];
    /*
     DBGLog(@"prevD = %d %@",prevD,[NSDate dateWithTimeIntervalSince1970:prevD]);
     DBGLog(@"currD = %d %@",currD,[NSDate dateWithTimeIntervalSince1970:currD]);
     DBGLog(@"postD = %d %@",postD,[NSDate dateWithTimeIntervalSince1970:postD]);
     DBGLog(@"lastD = %d %@",lastD,[NSDate dateWithTimeIntervalSince1970:lastD]);
     */
    self.currDateBtn = nil;
    
    NSString *title = [NSString stringWithFormat:@"%@ tracker",self.tracker.trackerName];
    NSString *msg = nil;
    // NSString *btn5 = (postD != 0 || (lastD == currD)) ? emDuplicate : nil;

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ecsvAction = [UIAlertAction actionWithTitle:emEmailCsv style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleExportTracker:emEmailCsv]; }];
    UIAlertAction* etAction = [UIAlertAction actionWithTitle:emEmailTracker style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleExportTracker:emEmailTracker]; }];
    UIAlertAction* etdAction = [UIAlertAction actionWithTitle:emEmailTrackerData style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleExportTracker:emEmailTrackerData]; }];
    UIAlertAction* iteAction = [UIAlertAction actionWithTitle:emItunesExport style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleExportTracker:emItunesExport]; }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:emCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleExportTracker:emCancel]; }];
    if ([MFMailComposeViewController canSendMail]) {
        [alert addAction:ecsvAction];
        [alert addAction:etAction];
        [alert addAction:etdAction];
    }
    [alert addAction:iteAction];
    if (postD != 0 || (lastD == currD)) {
        UIAlertAction* dupAction = [UIAlertAction actionWithTitle:emDuplicate style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleExportTracker:emDuplicate]; }];
        [alert addAction:dupAction];
    }
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}


- (void) privAlert:(NSInteger)tpriv vpm:(NSInteger)vpm {
    NSString *msg;
    if (vpm > tpriv) {
        if (tpriv > PRIVDFLT) {
            msg = [NSString stringWithFormat:@"Set a privacy level greater than %ld to see the %@ tracker, and greater than %ld to see all items in it",(long)tpriv,self.tracker.trackerName, (long)vpm];
        } else {
            msg = [NSString stringWithFormat:@"Set a privacy level greater than %ld to see all items in the %@ tracker",(long)vpm, self.tracker.trackerName];
        }
    } else {
        msg = [NSString stringWithFormat:@"Set a privacy level greater than %ld to see the %@ tracker",(long)tpriv,self.tracker.trackerName];
    }
    [rTracker_resource alert:@"Privacy alert" msg:msg vc:self];
}

- (void) checkPrivWarn {
    NSInteger tpriv = [(self.tracker.optDict)[@"privacy"] integerValue];
    NSInteger vprivmax = PRIVDFLT;
    
	for (valueObj *vo in self.tracker.valObjTable) {
        vo.vpriv = [(vo.optDict)[@"privacy"] integerValue];
        if (vo.vpriv > vprivmax) {
            vprivmax = vo.vpriv;
        }
    }
    
    if ((tpriv > PRIVDFLT) || (vprivmax > PRIVDFLT)) {
        [self privAlert:tpriv vpm:vprivmax];
    }
    
}

- (IBAction)btnAccept {

#if ADVERSION
    if (![rTracker_resource getPurchased]) {
        if (ADVER_TRACKER_LIM < [self.tlist.topLayoutIDs count]) {
            //[rTracker_resource buy_rTrackerAlert];
            [rTracker_resource replaceRtrackerA:self];
            return;
        }
    }
#endif
    
    DBGLog(@"accepting tracker");
    if (self.tracker.prevTID) {
        [rTracker_resource rmStashedTracker:(int)self.tracker.prevTID];
        self.tracker.prevTID=0;
    }
    self.rejectable=NO;
    //[self.tlist loadTopLayoutTable];
    [self checkPrivWarn];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleViewSwipeRight:(UISwipeGestureRecognizer *)gesture {
    if (!self.tracker.swipeEnable)
        return;
	int targD = (int)[self.tracker prevDate];
	if (targD == 0) {
		targD = -1;
	} 
	[self setTrackerDate:targD];

    if (targD >0)
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:(UITableViewRowAnimationRight)];
}

- (void)handleViewSwipeLeft:(UISwipeGestureRecognizer *)gesture {
    if (!self.tracker.swipeEnable)
        return;
    int targD = (int)[self.tracker postDate];
	[self setTrackerDate:targD];
    if (targD >0)
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:(UITableViewRowAnimationLeft)];
    
}

-(void)btnSkip2End {
    [self setTrackerDate:0];
}
- (datePickerVC*) dpvc
{ 
	if (_dpvc == nil) {
        _dpvc = [[datePickerVC alloc] init];
	}
	return _dpvc;
}

- (dpRslt*) dpr
{ 
	if (_dpr == nil) {
		_dpr = [[dpRslt alloc] init];;
	}
	return _dpr;
}

// not called
//- (void)presentationControllerDidDismiss:(UIPresentationController *)dpvc {
//    [self handleDPR];
//}

- (void) btnCurrDate {
	//DBGLog(@"pressed date becuz its a button, should pop up a date picker....");
	
	self.dpvc.myTitle = [NSString stringWithFormat:@"Date for %@", self.tracker.trackerName];
	self.dpr.date = self.tracker.trackerDate;
    self.dpvc.dpr = self.dpr;
    //CGRect f = self.view.frame;
    
	self.dpvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.dpvc.presentationController.delegate = self;  // need for ios 13 to access viewWillAppear as presentationControllerDidDismiss not firing
    [self presentViewController:self.dpvc animated:YES completion:NULL];

    /*
	
    CGRect viewFrame = self.view.frame;
	
	UIView *haveView = [self.view viewWithTag:kViewTag2];

	if (haveView) {
		if (haveView.frame.origin.y == self.view.frame.size.height) {// is hidden
			viewFrame.origin.y = self.view.frame.origin.y + 100;
			self.table.userInteractionEnabled = NO;
		} else {  // is up
			viewFrame.origin.y = self.view.frame.size.height;
			self.table.userInteractionEnabled = YES;
		}
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kAnimationDuration];
		
		[haveView setFrame:viewFrame];		
		[UIView commitAnimations];
		
		//[viewToRemove removeFromSuperview];
	} else {
		viewFrame.origin.y = viewFrame.size.height;
		
		UIView *myView = [[UIView alloc] initWithFrame:viewFrame];
		myView.backgroundColor = [UIColor whiteColor];
		myView.tag = kViewTag2;
		
		[self buildDatePickerView:myView];
		

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:kAnimationDuration];
		
		self.table.userInteractionEnabled = NO;

		[self.view addSubview:myView];
		//viewFrame.size.height -=100;
		viewFrame.origin.y = self.view.frame.origin.y + 100;
		[myView setFrame:viewFrame];
		
		[UIView commitAnimations];
	}
	 
	 */
	
}

- (void) btnDel {
    NSString *title = @"Delete entry";
    NSString* msg = [NSString stringWithFormat:@"Really delete %@ entry %@?",self.tracker.trackerName,
                       [self.tracker.trackerDate descriptionWithLocale:[NSLocale currentLocale]]];
    NSString *btn0 = @"Cancel";
    NSString *btn1 = @"Yes, delete";
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:btn0 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleDeleteEntry:0]; }];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:btn1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleDeleteEntry:1]; }];
    
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];

}


#pragma mark -
#pragma mark timesSquare calendar vc


-(void) btnCal {
    DBGLog(@"cal btn");
    if (self.needSave) {
        self.alertResponse=CSSHOWCAL;
        [self alertChkSave];
        return;
    }

	//self.dpvc.myTitle = [NSString stringWithFormat:@"Date for %@", self.tracker.trackerName];
	self.dpr.date = self.tracker.trackerDate;
    self.tsCalVC.dpr = self.dpr;
    self.tsCalVC.tracker = self.tracker;
    self.tsCalVC.parentUTC = self;
    self.tsCalVC.presentationController.delegate = self;  // need for ios 13 to access viewWillAppear as presentationControllerDidDismiss not firing
    
	self.tsCalVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	//
    //if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
        [self presentViewController:self.tsCalVC animated:YES completion:NULL];
    //} else {
    //    [self presentModalViewController:self.tsCalVC animated:YES];
    //}
}

- (trackerCalViewController*) tsCalVC {
    if (nil == _tsCalVC) {
        _tsCalVC = [[trackerCalViewController alloc] init];
    }
    return _tsCalVC;
}



#pragma mark -
#pragma mark UIBar button getters
/*

- (UIBarButtonItem *) prevDateBtn {
	if (_prevDateBtn == nil) {
		_prevDateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:@"<-" // @"Prev"    // @"<"
					   style:UIBarButtonItemStylePlain
					   target:self
					   action:@selector(btnPrevDate)];
        _prevDateBtn.tintColor = [UIColor darkGrayColor];
	}
	return _prevDateBtn;
}

- (UIBarButtonItem *) postDateBtn {
	if (_postDateBtn == nil) {
		_postDateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:@"->" // @"Next"    //@">"
					   style:UIBarButtonItemStylePlain
					   target:self
					   action:@selector(btnPostDate)];
        _postDateBtn.tintColor = [UIColor darkGrayColor];
	}
	
	return _postDateBtn;
}

*/
 
- (UIBarButtonItem *) currDateBtn {
	//DBGLog(@"currDateBtn called");
	if (_currDateBtn == nil) {
        
        NSString *datestr = [NSDateFormatter localizedStringFromDate:self.tracker.trackerDate
													   dateStyle:NSDateFormatterShortStyle 
													   timeStyle:NSDateFormatterShortStyle];

		//DBGLog(@"creating button");
		_currDateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:datestr
					   style:UIBarButtonItemStylePlain
					   target:self
					   action:@selector(btnCurrDate)];
	}
	
	return _currDateBtn;
}

- (UIBarButtonItem *) flexibleSpaceButtonItem {
	if (_flexibleSpaceButtonItem == nil) {
		_flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
								   target:nil action:nil];
	}
	return _flexibleSpaceButtonItem;
}

- (UIBarButtonItem *) fixed1SpaceButtonItem {
	if (_fixed1SpaceButtonItem == nil) {
		_fixed1SpaceButtonItem = [[UIBarButtonItem alloc]
								 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
								 target:nil action:nil];
		_fixed1SpaceButtonItem.width = (CGFloat) 32.0;
	}
	
	return _fixed1SpaceButtonItem;
}


- (UIBarButtonItem *) calBtn {
	if (_calBtn == nil) {
		_calBtn = [[UIBarButtonItem alloc]
                   initWithTitle:@"📆" // @"\u2630" //@"Cal"
				  style:UIBarButtonItemStylePlain
				  target:self
				  action:@selector(btnCal)];
        _calBtn.tintColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0];
        //_calBtn.tintColor = [UIColor greenColor];
        [_calBtn setTitleTextAttributes:@{
                                          NSFontAttributeName: [UIFont systemFontOfSize:28.0]
                                          //,NSForegroundColorAttributeName: [UIColor greenColor]
                                          } forState:UIControlStateNormal];
	}
	
	return _calBtn;
}

- (UIBarButtonItem *) searchBtn {
    if (_searchBtn == nil) {
        _searchBtn = [[UIBarButtonItem alloc]
                   initWithTitle:@"🔍" //@"Cal"
                   style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(btnSearch)];
        _searchBtn.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.8 alpha:1.0];
        //_searchBtn.tintColor = [UIColor greenColor];
        [_searchBtn setTitleTextAttributes:@{
                                          NSFontAttributeName: [UIFont systemFontOfSize:28.0]
                                          //,NSForegroundColorAttributeName: [UIColor greenColor]
                                          } forState:UIControlStateNormal];
    }
    
    return _searchBtn;
}

-(void) btnSearch {
    [rTracker_resource alert:@"Search results" msg:[NSString stringWithFormat:@"%ld entries highlighted in calendar and graph views",(long)[self.searchSet count]] vc:self];
}

- (UIBarButtonItem *) delBtn {
	if (_delBtn == nil) {
		_delBtn = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
				  //initWithTitle:@"\u2612" //@"Del"
				  //style:UIBarButtonItemStylePlain
				  target:self
				  action:@selector(btnDel)];
        _delBtn.tintColor = [UIColor redColor];
        //[_delBtn setTitleTextAttributes:@{
         //                                 NSFontAttributeName: [UIFont systemFontOfSize:28.0]
         //                                 ,NSForegroundColorAttributeName: [UIColor redColor]
         //                                 } forState:UIControlStateNormal];
	}
	
	return _delBtn;
}

- (UIBarButtonItem *) skip2EndBtn {
    if (_skip2EndBtn == nil) {
        _skip2EndBtn = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                   //initWithTitle:@"\u2b72" //@"Cal"
                   //style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(btnSkip2End)];
        //_calBtn.tintColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0];
        //_calBtn.tintColor = [UIColor greenColor];
        //[_calBtn setTitleTextAttributes:@{
        //                                  NSFontAttributeName: [UIFont systemFontOfSize:28.0]
        //                                  ,NSForegroundColorAttributeName: [UIColor blueColor]
        //                                  } forState:UIControlStateNormal];
    }
    
    return _skip2EndBtn;
}
    

#pragma mark -
#pragma mark mail support

- (BOOL) attachTrackerData:(MFMailComposeViewController*)mailer key:(NSString*)key {
    BOOL result;
    NSString *fp = [self.tracker getPath:RTRKext];
    NSString *mimetype=@"application/rTracker";
    NSError *err;
    NSString *fname=[self.tracker.trackerName stringByAppendingString:RTRKext];
    
    if ([key isEqualToString:emEmailCsv]) {
        if ((result = [self.tracker writeCSV])) {
            fp = [self.tracker getPath:CSVext];
            mimetype = @"text/csv";
            fname=[self.tracker.trackerName stringByAppendingString:CSVext];
        }
    } else if ([key isEqualToString:emEmailTrackerData]) {
        result = [self.tracker writeRtrk:YES];
    } else if ([key isEqualToString:emEmailTracker]) {
        result = [self.tracker writeRtrk:NO];
    } else {
        DBGLog(@"no match for key %@",key);
        result=NO;
    }
    
    if (result) {
        NSData *fileData = [NSData dataWithContentsOfFile:fp options:NSDataReadingUncached error:&err];
        if (nil != fileData) {
            [mailer addAttachmentData:fileData mimeType:mimetype fileName:fname];
        } else {
            result=NO;
        }
    }
    
    return result;
}

- (void) openMail:(NSString*)btnTitle {
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    if ([self.tracker.optDict objectForKey:@"dfltEmail"]) {
        NSArray *toRecipients = @[(self.tracker.optDict)[@"dfltEmail"]];
        [mailer setToRecipients:toRecipients];
    }
    NSString *emailBody;
    NSString *ext;
    
    if ([emEmailCsv isEqualToString:btnTitle]) {
        if ([rTracker_resource getRtcsvOutput]) {
            emailBody = [self.tracker.trackerName stringByAppendingString:@" tracker data file in rtCSV format attached.  Generated by <a href=\"http://rob-miller.github.io/rTracker/rTracker/iPhone/pages/rTracker-main.html\">rTracker</a>."];
        } else {
            emailBody = [self.tracker.trackerName stringByAppendingString:@" tracker data file in CSV format attached.  Generated by <a href=\"http://rob-miller.github.io/rTracker/rTracker/iPhone/pages/rTracker-main.html\">rTracker</a>."];
        }
        [mailer setSubject:[self.tracker.trackerName stringByAppendingString:@" tracker CSV data"] ];
        ext = CSVext;
    } else {
        if ([emEmailTrackerData isEqualToString:btnTitle]) {
            emailBody = [self.tracker.trackerName stringByAppendingString:@" tracker with data attached.  Open with <a href=\"http://rob-miller.github.io/rTracker/rTracker/iPhone/pages/rTracker-main.html\">rTracker</a>."];
            [mailer setSubject:[self.tracker.trackerName stringByAppendingString:@" tracker with data"] ];
            
        } else {
            emailBody = [self.tracker.trackerName stringByAppendingString:@" tracker attached.  Open with <a href=\"http://rob-miller.github.io/rTracker/rTracker/iPhone/pages/rTracker-main.html\">rTracker</a>."];
            [mailer setSubject:[self.tracker.trackerName stringByAppendingString:@" tracker"] ];
        }
        ext = RTRKext;
    }
    
    [mailer setMessageBody:emailBody isHTML:YES];
    if ([self attachTrackerData:mailer key:btnTitle]) {
        [self presentViewController:mailer animated:YES completion:NULL];
        //[self presentModalViewController:mailer animated:YES];
    }
#if RELEASE
    [rTracker_resource deleteFileAtPath:[self.tracker getPath:ext]];
#else
    DBGErr(@"leaving rtrk at path: %@", [self.tracker getPath:ext]);
#endif
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            DBGLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            DBGLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            DBGLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            DBGLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            DBGLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:NULL ];
    // some say this way but don't think so: [controller dismissViewControllerAnimated:YES completion:NULL ];
    //[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//return 0;  //[rTrackerAppDelegate.topLayoutTable count];
	return [self.tracker.valObjTable count];
}


//#define MARGIN 7.0f

#define CHECKBOX_WIDTH 40.0f


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	valueObj *vo = (valueObj *) (self.tracker.valObjTable)[row];
    //DBGLog(@"uvc table cell at index %d label %@",row,vo.valueName);
	
	return [vo.vos voTVCell:tableView];
    /*
    UITableViewCell *tvc = [vo.vos voTVCell:tableView];
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgnd-cell1-320-56.png"]];
    [tvc setBackgroundView:bg];
    [bg release];

    return tvc;
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    valueObj *vo = (valueObj *) (self.tracker.valObjTable)[row];
    return [vo.vos voTVCellHeight];
    /*
	NSInteger vt = ((valueObj*) (self.tracker.valObjTable)[[indexPath row]]).vtype;
	if ( vt == VOT_CHOICE || vt == VOT_SLIDER )
		return CELL_HEIGHT_TALL;
	return CELL_HEIGHT_NORMAL;
     */
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];

    valueObj *vo = (valueObj*) (self.tracker.valObjTable)[[indexPath row]];

#if DEBUGLOG
	NSUInteger row = [indexPath row];
	//valueObj *vo = (valueObj *) [self.tracker.valObjTable  objectAtIndex:row];
	DBGLog(@"selected row %lu : %@", (unsigned long)row, vo.valueName);
#endif

    if (VOT_INFO == vo.vtype) {
        NSString *url = [(vo.optDict)[@"infourl"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        if (! [@"" isEqualToString:url]) {
            NSRange urlCheck = [url rangeOfString:@"://"];
            if (urlCheck.location == NSNotFound) {
                url = [@"http://" stringByAppendingString:url];
            }
            DBGLog(@"vot_info: selected -> fire url: %@",url);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                    if (!success) {
                        if ([url localizedCaseInsensitiveContainsString:@"http://"] || [url localizedCaseInsensitiveContainsString:@"https://"]) {
                            [rTracker_resource alert:@"Failed to open URL" msg:[NSString stringWithFormat:@"Failed to open the URL %@ - network problem?",url] vc:self];
                        } else {
                            [rTracker_resource alert:@"Failed to open URL" msg:[NSString stringWithFormat:@"Failed to open the URL %@ - perhaps the supporting app is not installed??",url] vc:self];
                        }
                    }
                }];
            /* openurl deprecated ios 9.0
            if (! [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] ]) {
                if ([url localizedCaseInsensitiveContainsString:@"http://"] || [url localizedCaseInsensitiveContainsString:@"https://"]) {
                    [rTracker_resource alert:@"Failed to open URL" msg:[NSString stringWithFormat:@"Failed to open the URL %@ - network problem?",url] vc:self];
                } else {
                    [rTracker_resource alert:@"Failed to open URL" msg:[NSString stringWithFormat:@"Failed to open the URL %@ - perhaps the supporting app is not installed??",url] vc:self];
                }
            }
             */
        }
    }
    

    
}




@end
