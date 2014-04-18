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

@interface useTrackerController ()
- (void) updateTrackerTableView;
- (void) updateTableCells:(valueObj*)inVO;
@end

@implementation useTrackerController

@synthesize tracker;

@synthesize prevDateBtn, postDateBtn, currDateBtn, delBtn, flexibleSpaceButtonItem, fixed1SpaceButtonItem;
@synthesize table, dpvc, dpr, needSave, didSave, saveFrame, fwdRotations, rejectable, viewDisappearing, tlist;
@synthesize saveBtn, menuBtn, alertResponse, saveTargD;

//BOOL keyboardIsShown=NO;

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
    /*
    if (self.needSave) {
        self.alertResponse=CSCANCEL;
        [self alertChkSave];
        return;
    }
*/
	self.prevDateBtn = nil;
	[prevDateBtn release];
	self.currDateBtn = nil;
	[currDateBtn release];
	self.postDateBtn = nil;
	[postDateBtn release];
	self.delBtn = nil;
	[delBtn release];
	
	//self.testBtn = nil;
	//[testBtn release];
	
	self.fixed1SpaceButtonItem = nil;
	[fixed1SpaceButtonItem release];
	self.flexibleSpaceButtonItem = nil;
	[flexibleSpaceButtonItem release];
	
    self.saveBtn = nil;
    self.menuBtn = nil;
    
	self.dpvc = nil;
	[dpvc release];
	self.dpr = nil;
	[dpr release];
	
	self.table = nil;
	[table release];
	
	self.tracker = nil;
	[tracker release];
	[super dealloc];
}


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
    // n.b. we hardcode we hardcode number of sections in a tracker tableview here
    [self.table reloadRowsAtIndexPaths:iparr withRowAnimation:UITableViewRowAnimationNone];
    
    [iparr release];
}


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
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.fwdRotations = YES;
    
	//DBGLog(@"utc: viewDidLoad dpvc=%d", (self.dpvc == nil ? 0 : 1));
	
	self.title = self.tracker.trackerName;
	self.needSave = NO;
    
	//for (valueObj *vo in self.tracker.valObjTable) {
	//	[vo display];
	//}
	
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgnd2-320-460.png"]];
    self.table.backgroundView = bg;
    [bg release];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
	[self updateToolBar];
	keyboardIsShown = NO;
	
	self.tracker.vc = self;
	
    self.alertResponse=0;
    self.saveTargD=0;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< rTracker"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(btnCancel)];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];

    
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

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
	
	self.fixed1SpaceButtonItem = nil;
	self.flexibleSpaceButtonItem = nil;
	
	self.toolbarItems = nil;
	self.navigationItem.rightBarButtonItem = nil;	
	self.navigationItem.leftBarButtonItem = nil;
	
	self.dpr.action = DPA_CANCEL;
	
	self.tracker.vc = nil;
	
	[super viewDidUnload];
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
    [self.table reloadData];
    self.didSave=NO;
    
    [super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    //DBGLog(@"utc: view will appear");

    self.viewDisappearing=NO;

	if (self.dpr) {
		switch (self.dpr.action) {
			case DPA_NEW:
				[self.tracker resetData];
                //[self updateTrackerTableView];  // moved below
				self.tracker.trackerDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.tracker noCollideDate:(int)[self.dpr.date timeIntervalSince1970]]];
				[self updateToolBar];
				break;
			case DPA_SET:
			{
				if ([self.tracker hasData]) {
					[self.tracker changeDate:self.dpr.date];
                    self.needSave = YES;
				} else {
                    self.tracker.trackerDate = self.dpr.date;
                }
				[self updateToolBar];
				break;
			}
			case DPA_GOTO:
			{
                int targD = 0;
                if (nil != self.dpr.date) {  // set to nil to cause reset tracker, ready for new
                    targD = (int) [self.dpr.date timeIntervalSince1970];
                    if (! [self.tracker loadData:targD]) {
                        self.tracker.trackerDate = self.dpr.date;
                        targD = [self.tracker prevDate];
                        if (!targD) 
                            targD = [self.tracker postDate];
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
		[dpvc release];
        self.dpr = nil;
        [dpr release];
	}

    [[NSNotificationCenter defaultCenter] addObserver:self.tracker 
                                             selector:@selector(trackerUpdated:) 
                                                 name:rtValueUpdatedNotification 
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(updateUTC:) 
												 name:rtTrackerUpdatedNotification 
											   object:self.tracker];
	

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
    
    [super viewWillAppear:animated];
	
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
    
    //DBGLog(@"utc view disappearing");
    //already done [self.tracker.activeControl resignFirstResponder];

    // unregister this tracker for value updated notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self.tracker 
                                                    name:rtValueUpdatedNotification
                                                  object:nil];

	//unregister for tracker updated notices
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:rtTrackerUpdatedNotification
                                                  object:nil];  

    //DBGLog(@"remove kybd will show notifcation");
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
    
    [super viewWillDisappear:animated];
}

/*
 - (void)willMoveToParentViewController:(UIViewController *)parent {
    DBGLog(@"will move to parent view controller");
}
*/

- (void) rejectTracker {
    DBGLog(@"rejecting input tracker %d %@  prevTID= %d", self.tracker.toid,self.tracker.trackerName, self.tracker.prevTID);
    [self.tlist updateTLtid:self.tracker.toid new:self.tracker.prevTID];  // revert topLevel to before
    [self.tracker deleteTrackerDB];
    [rTracker_resource unStashTracker:self.tracker.prevTID];  // this view and tracker going away now so dont need to clear rejectable or prevTID    
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (self.rejectable && self.viewDisappearing) {
        [self rejectTracker];
    }
}


# pragma mark view rotation methods

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


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	switch (fromInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"utc did rotate from interface orientation portrait");
            ///*
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
                [self doGT];
            }
             //*/
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"utc did rotate from interface orientation portrait upside down");
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
            /*
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
                [self doGT];
            }
            */
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"utc will rotate to interface orientation landscape right duration: %f sec", duration);
            [self.tracker.activeControl resignFirstResponder];
            /*
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
                [self doGT];
            }
            */
			break;
		default:
			DBGWarn(@"utc will rotate but can't tell to where duration: %f sec", duration);
			break;			
	}
}
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
    gt.tracker = self.tracker;
    if ([self.tracker hasData]) {
        self.dpr.date = self.tracker.trackerDate;
        self.dpr.action = DPA_GOTO;
    }
    gt.dpr = self.dpr;
    gt.parentUTC = self;
    
    self.fwdRotations = NO;
     if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
         [self presentViewController:gt animated:YES completion:NULL];
     } else {
         [self presentModalViewController:gt animated:YES];
         //[self addChildViewController:self.modalViewController];
     }
    [gt release];
    DBGLog(@"graph up");
}

- (void) returnFromGraph {
    DBGLog(@"start return from graph");
    //self.view = nil;
    self.fwdRotations=YES;
    
     if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
         [self dismissViewControllerAnimated:YES completion:NULL];
     } else {
         [self dismissModalViewControllerAnimated:YES];
     }
    //[UIViewController attemptRotationToDeviceOrientation];
    DBGLog(@"graph down");
}


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
    
	CGPoint coff = self.table.contentOffset;
	//DBGLog(@"coff x=%f y=%f",coff.x,coff.y);
    //DBGLog(@"k will show, y= %f",viewFrame.origin.y);
    
	CGFloat boty;
    
    if (kIS_LESS_THAN_IOS7) {
        boty = self.tracker.activeControl.superview.superview.frame.origin.y - coff.y;
        // activeField.superview.superview.frame.origin.y - coff.y ;
        //+ activeField.superview.superview.frame.size.height + MARGIN;
    } else {
        boty = self.tracker.activeControl.superview.superview.superview.frame.origin.y - coff.y;
        boty += self.tracker.activeControl.superview.superview.superview.frame.size.height;
    }

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
 style:UIBarButtonItemStyleBordered
 target:self
 action:@selector(testAction:)];
 }
 
 return testBtn;
 
 }
 */

- (UIBarButtonItem*) saveBtn {
    if (saveBtn == nil) {
        saveBtn =[[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                  target:self
                  action:@selector(btnSave)];
    }
    return saveBtn;
}

- (UIBarButtonItem*) menuBtn {
    if (menuBtn == nil) {
        if (self.rejectable) {
            menuBtn = [[UIBarButtonItem alloc]
                       initWithTitle:@"Accept"
                       style:UIBarButtonItemStyleBordered
                       target:self
                       action:@selector(btnAccept)];
            menuBtn.tintColor=[UIColor greenColor];
        } else if ([MFMailComposeViewController canSendMail]) {
            menuBtn = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                       //initWithTitle:@"menuBtn"
                       //style:UIBarButtonItemStyleBordered
                       target:self
                       action:@selector(btnMenu)];
        } else {
            menuBtn = [[UIBarButtonItem alloc]
                       initWithTitle:@"Export"
                       style:UIBarButtonItemStyleBordered
                       target:self
                       action:@selector(btnExport)];
        }
    }

    return  menuBtn;
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
	
	for (valueObj *vo in self.tracker.valObjTable) {
        //if (vo.vtype == VOT_FUNC)
            vo.display = nil;  // always redisplay
	}
	
    [self.table reloadData];
    
    
	//[(UITableView *) self.view reloadData];
	//	[self.tableView reloadData];  // if we were a uitableviewcontroller not uiviewcontroller
}

- (void) updateToolBar {
	NSMutableArray *tbi=[[NSMutableArray alloc] init];
	
	int prevD = [self.tracker prevDate];
	int postD = [self.tracker postDate];
	int lastD = [self.tracker lastDate];
	int currD = (int) [self.tracker.trackerDate timeIntervalSince1970];
/*
	DBGLog(@"prevD = %d %@",prevD,[NSDate dateWithTimeIntervalSince1970:prevD]);
	DBGLog(@"currD = %d %@",currD,[NSDate dateWithTimeIntervalSince1970:currD]);
	DBGLog(@"postD = %d %@",postD,[NSDate dateWithTimeIntervalSince1970:postD]);
	DBGLog(@"lastD = %d %@",lastD,[NSDate dateWithTimeIntervalSince1970:lastD]);
*/	
	self.currDateBtn = nil;
	if (prevD ==0) 
		[tbi addObject:self.fixed1SpaceButtonItem];
	else
		[tbi addObject:self.prevDateBtn];
	
	[tbi addObject:self.currDateBtn];
	
	if (postD != 0 || (lastD == currD)) {
		[tbi addObject:self.postDateBtn];
		[tbi addObject:self.flexibleSpaceButtonItem];
		[tbi addObject:self.delBtn];
	}

	//[tbi addObject:[self testBtn]];
	 
	[self setToolbarItems:tbi animated:YES];
	[tbi release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 == buttonIndex) {  // cancel
        return;
    }
    
    if (self.alertResponse) {
        if (1 == buttonIndex) {  // save
            [self saveActions];
        } else if (2 == buttonIndex) {  // discard
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
        }
    }
}
/*
xxx stuck here - how to get back to setTrackerDate or btnCancel ?

save targD somewhere
if targd exists then do settrackerdate
else do btnCancel/btnSave
*/

- (void) alertChkSave {

    UIAlertView *alert;
    alert = [[UIAlertView alloc]
             initWithTitle:[self.tracker.trackerName stringByAppendingString:@" modified"]
             message:@"Save this record before leaving?"
             delegate:self
             cancelButtonTitle:@"Cancel"
             otherButtonTitles: @"Save",@"Discard",nil];

    [alert show];
    [alert release];

}

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

-(void) setReminders {
    [self.tracker loadReminders];
    [self.tracker setReminders];
}

- (void)leaveTracker {
    if (self.didSave) {
        [self setReminders];
        self.didSave=NO;
    }
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
            [rTracker_resource rmStashedTracker:self.tracker.prevTID];
            self.tracker.prevTID=0;
        }
        self.rejectable=NO;
        [self checkPrivWarn];
    }
    
	[self.tracker saveData];
    
}
    
- (void)btnSave {
	//DBGLog(@"btnSave was pressed! tracker name= %@ toid= %d",self.tracker.trackerName, self.tracker.toid);
    [self saveActions];

	if ([[self.tracker.optDict objectForKey:@"savertn"] isEqualToString:@"0"]) {  // default:1
        // do not return to tracker list after save, so generate clear form
		if (![self.toolbarItems containsObject:postDateBtn])
			[self.tracker resetData];
		[self updateToolBar];
		[self updateTrackerTableView];
        self.needSave=NO;
		[self showSaveBtn];
	} else {
        [self leaveTracker];
	}
}

- (void) doPlistExport {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //DBGLog(@"start export");
    
    [self.tracker saveToItunes];
    [rTracker_resource finishProgressBar:self.view navItem:self.navigationItem disable:YES];

    [pool drain];
}

NSString *emEmailCsv = @"email CSV";
NSString *emEmailTracker = @"email Tracker";
NSString *emEmailTrackerData = @"email Tracker+Data";
NSString *emItunesExport = @"save for PC (iTunes)";


- (IBAction)btnMenu {
	UIActionSheet *exportMenu = [[UIActionSheet alloc]
                                              initWithTitle:[NSString stringWithFormat:
                                                             @"export %@ tracker",
                                                             self.tracker.trackerName]
                                              delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil //@"Yes, delete"
                                              otherButtonTitles:emEmailCsv,emEmailTracker,emEmailTrackerData,emItunesExport,nil];
    //[exportMenu showInView:self.view];
    //[exportMenu showFromRect:self.menuBtn.frame inView:self.view animated:YES];
	//[exportMenu showFromToolbar:self.navigationController.toolbar];
    [exportMenu showFromBarButtonItem:self.menuBtn animated:YES];
	[exportMenu release];
    
}

- (IBAction)btnExport {

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

- (void) privAlert:(NSInteger)tpriv vpm:(NSInteger)vpm {
    NSString *msg;
    if (vpm > tpriv) {
        if (tpriv > PRIVDFLT) {
            msg = [NSString stringWithFormat:@"Set a privacy level greater than %d to see the %@ tracker, and greater than %d to see all items in it",tpriv,self.tracker.trackerName, vpm];
        } else {
            msg = [NSString stringWithFormat:@"Set a privacy level greater than %d to see all items in the %@ tracker",vpm, self.tracker.trackerName];
        }
    } else {
        msg = [NSString stringWithFormat:@"Set a privacy level greater than %d to see the %@ tracker",tpriv,self.tracker.trackerName];
    }
    [rTracker_resource alert:@"Privacy alert" msg:msg];    
}

- (void) checkPrivWarn {
    NSInteger tpriv = [[self.tracker.optDict objectForKey:@"privacy"] integerValue];
    NSInteger vprivmax = PRIVDFLT;
    
	for (valueObj *vo in self.tracker.valObjTable) {
        vo.vpriv = [[vo.optDict objectForKey:@"privacy"] integerValue];
        if (vo.vpriv > vprivmax) {
            vprivmax = vo.vpriv;
        }
    }
    
    if ((tpriv > PRIVDFLT) || (vprivmax > PRIVDFLT)) {
        [self privAlert:tpriv vpm:vprivmax];
    }
    
}

- (IBAction)btnAccept {
    DBGLog(@"accepting tracker");
    if (self.tracker.prevTID) {
        [rTracker_resource rmStashedTracker:self.tracker.prevTID];
        self.tracker.prevTID=0;
    }
    self.rejectable=NO;
    //[self.tlist loadTopLayoutTable];
    [self checkPrivWarn];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) btnPrevDate {
	int targD = [self.tracker prevDate];
	if (targD == 0) {
		targD = -1;
	} 
	[self setTrackerDate:targD];
}

- (void) btnPostDate {
	[self setTrackerDate:[self.tracker postDate]];
}

- (datePickerVC*) dpvc
{ 
	if (dpvc == nil) {
        dpvc = [[datePickerVC alloc] init];
	}
	return dpvc;
}

- (dpRslt*) dpr
{ 
	if (dpr == nil) {
		dpr = [[dpRslt alloc] init];;
	}
	return dpr;
}

- (void) btnCurrDate {
	//DBGLog(@"pressed date becuz its a button, should pop up a date picker....");
	
	self.dpvc.myTitle = [NSString stringWithFormat:@"Date for %@", self.tracker.trackerName];
	self.dpr.date = self.tracker.trackerDate;
    self.dpvc.dpr = self.dpr;
    
	self.dpvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	//
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
        [self presentViewController:self.dpvc animated:YES completion:NULL];
    } else {
        [self presentModalViewController:self.dpvc animated:YES];
    }
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
	UIActionSheet *checkTrackerEntryDelete = [[UIActionSheet alloc] 
										 initWithTitle:[NSString stringWithFormat:
														@"Really delete %@ entry %@?", 
														self.tracker.trackerName, 
														[self.tracker.trackerDate descriptionWithLocale:[NSLocale currentLocale]]]
										 delegate:self 
										 cancelButtonTitle:@"Cancel"
										 destructiveButtonTitle:@"Yes, delete"
										 otherButtonTitles:nil];
	[checkTrackerEntryDelete showFromToolbar:self.navigationController.toolbar];
	[checkTrackerEntryDelete release];
}


#pragma mark -
#pragma mark UIBar button getters

- (UIBarButtonItem *) prevDateBtn {
	if (prevDateBtn == nil) {
		prevDateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:@"<-" // @"Prev"    // @"<"
					   style:UIBarButtonItemStyleBordered
					   target:self
					   action:@selector(btnPrevDate)];
        prevDateBtn.tintColor = [UIColor darkGrayColor];
	}
	return prevDateBtn;
}

- (UIBarButtonItem *) postDateBtn {
	if (postDateBtn == nil) {
		postDateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:@"->" // @"Next"    //@">"
					   style:UIBarButtonItemStyleBordered
					   target:self
					   action:@selector(btnPostDate)];
        postDateBtn.tintColor = [UIColor darkGrayColor];
	}
	
	return postDateBtn;
}

- (UIBarButtonItem *) currDateBtn {
	//DBGLog(@"currDateBtn called");
	NSString *datestr = [NSDateFormatter localizedStringFromDate:self.tracker.trackerDate 
													   dateStyle:NSDateFormatterShortStyle 
													   timeStyle:NSDateFormatterShortStyle];

	if (currDateBtn == nil) {
		//DBGLog(@"creating button");
		currDateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:datestr
					   style:UIBarButtonItemStyleBordered
					   target:self
					   action:@selector(btnCurrDate)];
	}
	
	return currDateBtn;
}

- (UIBarButtonItem *) flexibleSpaceButtonItem {
	if (flexibleSpaceButtonItem == nil) {
		flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
								   target:nil action:nil];
	}
	return flexibleSpaceButtonItem;
}

- (UIBarButtonItem *) fixed1SpaceButtonItem {
	if (fixed1SpaceButtonItem == nil) {
		fixed1SpaceButtonItem = [[UIBarButtonItem alloc]
								 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
								 target:nil action:nil];
		fixed1SpaceButtonItem.width = (CGFloat) 32.0;
	}
	
	return fixed1SpaceButtonItem;
}


- (UIBarButtonItem *) delBtn {
	if (delBtn == nil) {
		delBtn = [[UIBarButtonItem alloc]
				  initWithTitle:@"Del"
				  style:UIBarButtonItemStyleBordered
				  target:self
				  action:@selector(btnDel)];
        delBtn.tintColor = [UIColor redColor];
	}
	
	return delBtn;
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
    NSArray *toRecipients = [NSArray arrayWithObjects:[self.tracker.optDict objectForKey:@"dfltEmail"], nil];
    [mailer setToRecipients:toRecipients];
    NSString *emailBody;
    NSString *ext;
    
    if ([emEmailCsv isEqualToString:btnTitle]) {
        emailBody = [self.tracker.trackerName stringByAppendingString:@" tracker data file in CSV format attached.  Generated by <a href=\"http://www.realidata.com/cgi-bin/rTracker/iPhone/rTracker-main.pl\">rTracker</a>."];
        [mailer setSubject:[self.tracker.trackerName stringByAppendingString:@" tracker CSV data"] ];
        ext = CSVext;
    } else {
        if ([emEmailTrackerData isEqualToString:btnTitle]) {
            emailBody = [self.tracker.trackerName stringByAppendingString:@" tracker with data attached.  Open with <a href=\"http://www.realidata.com/cgi-bin/rTracker/iPhone/rTracker-main.pl\">rTracker</a>."];
            [mailer setSubject:[self.tracker.trackerName stringByAppendingString:@" tracker with data"] ];
            
        } else {
            emailBody = [self.tracker.trackerName stringByAppendingString:@" tracker attached.  Open with <a href=\"http://www.realidata.com/cgi-bin/rTracker/iPhone/rTracker-main.pl\">rTracker</a>."];
            [mailer setSubject:[self.tracker.trackerName stringByAppendingString:@" tracker"] ];
        }
        ext = RTRKext;
    }
    
    [mailer setMessageBody:emailBody isHTML:YES];
    if ([self attachTrackerData:mailer key:btnTitle]) {
        [self presentModalViewController:mailer animated:YES];
    }
    [mailer release];

    [rTracker_resource deleteFileAtPath:[self.tracker getPath:ext]];
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
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title hasPrefix:@"Really"]) {
        DBGLog(@"checkTrackerDelete buttonIndex= %d",buttonIndex);
	
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            int targD = [self.tracker prevDate];
            if (!targD) {
                targD = [self.tracker postDate];
            }
            [self.tracker deleteCurrEntry];
            [self setTrackerDate: targD];
        } else {
            DBGLog(@"cancelled");
        }
    } else {  // ([actionSheet.title hasPrefix:@"export"
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            DBGLog(@"cancelled");
        } else if ([buttonTitle isEqualToString:emItunesExport]) {
            [self btnExport];
        } else {
            [self openMail:buttonTitle];
        }
    }
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

#define CELL_HEIGHT_NORMAL (self.tracker.maxLabel.height + (3.0*MARGIN))
#define CELL_HEIGHT_TALL (2.0 * CELL_HEIGHT_NORMAL)

#define CHECKBOX_WIDTH 40.0f


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	valueObj *vo = (valueObj *) [self.tracker.valObjTable  objectAtIndex:row];
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
	NSInteger vt = ((valueObj*) [self.tracker.valObjTable objectAtIndex:[indexPath row]]).vtype;
	if ( vt == VOT_CHOICE || vt == VOT_SLIDER )
		return CELL_HEIGHT_TALL;
	return CELL_HEIGHT_NORMAL;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];

    valueObj *vo = (valueObj*) [self.tracker.valObjTable objectAtIndex:[indexPath row]];

#if DEBUGLOG
	NSUInteger row = [indexPath row];
	//valueObj *vo = (valueObj *) [self.tracker.valObjTable  objectAtIndex:row];
	DBGLog(@"selected row %d : %@", row, vo.valueName);
#endif

    if (VOT_INFO == vo.vtype) {
        NSString *url = [vo.optDict objectForKey:@"infourl"];
        NSRange urlCheck = [url rangeOfString:@"://"];
        if (urlCheck.location == NSNotFound) {
            url = [@"http://" stringByAppendingString:url];
        }
        DBGLog(@"vot_info: selected -> fire url: %@",url);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    

    
}




@end
