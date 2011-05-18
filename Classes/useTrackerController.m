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
- (void) updateTableCells;
@end

@implementation useTrackerController

@synthesize tracker;

@synthesize prevDateBtn, postDateBtn, currDateBtn, delBtn, flexibleSpaceButtonItem, fixed1SpaceButtonItem;
@synthesize table, dpvc, dpr, needSave, saveFrame;
@synthesize saveBtn, exportBtn;

//BOOL keyboardIsShown=NO;

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
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
    self.exportBtn = nil;
    
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
	} else if (!self.needSave && self.navigationItem.rightBarButtonItem != self.exportBtn) {
		[self.navigationItem setRightBarButtonItem:self.exportBtn animated:YES ];
	}
}

#pragma mark -
#pragma mark tracker data updated event handling -- rtTrackerUpdatedNotification

- (void) updateTableCells {
	NSMutableArray *iparr = [[NSMutableArray alloc] init];
    int n=0;
    
	for (valueObj *vo in self.tracker.valObjTable) {
        if (vo.vtype == VOT_FUNC) {
            vo.display = nil;  // always redisplay
            [iparr addObject:[[NSIndexPath indexPathWithIndex:0] indexPathByAddingIndex:n]];
        } else if (vo.display == nil) {
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
    DBGLog(@"UTC update notification from tracker");
    [self updateTableCells];
    self.needSave=YES;
	[self showSaveBtn];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	//DBGLog(@"utc: viewDidLoad dpvc=%d", (self.dpvc == nil ? 0 : 1));
	
	self.title = tracker.trackerName;
	self.needSave = NO;
    
	//for (valueObj *vo in self.tracker.valObjTable) {
	//	[vo display];
	//}
	
			
	[self updateToolBar];
	keyboardIsShown = NO;
	
	self.tracker.vc = self;

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(updateUTC:) 
												 name:rtTrackerUpdatedNotification 
											   object:self.tracker];
	
	
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

	//unregister for tracker updated notices
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:rtTrackerUpdatedNotification
                                                  object:nil];  
	
	
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

- (void) viewWillAppear:(BOOL)animated
{
	if (self.dpr) {
		switch (self.dpr.action) {
			case DPA_NEW:
				[self.tracker resetData];
				self.tracker.trackerDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.tracker noCollideDate:(int)[self.dpr.date timeIntervalSince1970]]];
				//break;
			case DPA_SET:
			{
				if ([self.tracker hasData]) {
					[self.tracker changeDate:self.dpr.date];
				}  
				self.tracker.trackerDate = self.dpr.date;
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
				NSAssert(0,@"failed to determine dpr action");
				break;
		}
		self.dpr.date = nil;
		self.dpvc = nil;
		[dpvc release];
        self.dpr = nil;
        [dpr release];
	}

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
	//DBGLog(@"useTrackerController: viewWillAppear privacy= %d", [privacyV getPrivacyValue]);
	
}

- (void) viewWillDisappear :(BOOL)animated
{
    //DBGLog(@"remove kybd will show notifcation");
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
	
}

# pragma mark view rotation methods

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"utc should rotate to interface orientation landscape right?");
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
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"utc will rotate to interface orientation landscape right duration: %f sec", duration);
			break;
		default:
			DBGWarn(@"utc will rotate but can't tell to where duration: %f sec", duration);
			break;			
	}
}

- (void) doGT {
	graphTrackerVC *gt;
    gt = [[graphTrackerVC alloc] init];
    gt.tracker = self.tracker;
    if ([self.tracker hasData]) {
        self.dpr.date = self.tracker.trackerDate;
        self.dpr.action = DPA_GOTO;
    }
    gt.dpr = self.dpr;
    [self presentModalViewController:gt animated:YES];
    [gt release];
}
#if (1) 
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"utc will animate rotation to interface orientation portrait duration: %f sec",duration);
			[self dismissModalViewControllerAnimated:YES];
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"utc will animate rotation to interface orientation portrait upside down duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"utc will animate rotation to interface orientation landscape left duration: %f sec", duration);

			[self doGT];
            
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"utc will animate rotation to interface orientation landscape right duration: %f sec", duration);

			[self doGT];
			
			break;
		default:
			DBGWarn(@"utc will animate rotation but can't tell to where. duration: %f sec", duration);
			break;			
	}
}
#else 
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	DBGLog(@"utc will animate first half rotation to interface orientation duration: %@",duration);
}
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	DBGLog(@"utc will animate second half rotation to interface orientation duration: %@",duration);
}
#endif



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
	//DBGLog(@"coff x=%f y=%f",coff.x,coff.y);
	//DBGLog(@"k will show, y= %f",viewFrame.origin.y);
	CGFloat boty = self.tracker.activeControl.superview.superview.frame.origin.y - coff.y;  // activeField.superview.superview.frame.origin.y - coff.y ;  //+ activeField.superview.superview.frame.size.height + MARGIN;
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
	
}
- (void)keyboardWillHide:(NSNotification *)n
{
	DBGLog(@"handling keyboard will hide");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self.view setFrame:self.saveFrame];
	
	[UIView commitAnimations];
	
    keyboardIsShown = NO;	
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

- (UIBarButtonItem*) exportBtn {
    if (exportBtn == nil) {
        exportBtn = [[UIBarButtonItem alloc]
                     initWithTitle:@"Export"
                     style:UIBarButtonItemStyleBordered
                     target:self
                     action:@selector(btnExport)];
    }
    return  exportBtn;
}


#pragma mark -
#pragma mark datepicker support

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

	DBGLog(@"prevD = %d %@",prevD,[NSDate dateWithTimeIntervalSince1970:prevD]);
	DBGLog(@"currD = %d %@",currD,[NSDate dateWithTimeIntervalSince1970:currD]);
	DBGLog(@"postD = %d %@",postD,[NSDate dateWithTimeIntervalSince1970:postD]);
	DBGLog(@"lastD = %d %@",lastD,[NSDate dateWithTimeIntervalSince1970:lastD]);
	
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

- (void) setTrackerDate:(int) targD {
	
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

- (IBAction)btnCancel {
	//DBGLog(@"btnCancel was pressed!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)btnSave {
	//DBGLog(@"btnSave was pressed! tracker name= %@ toid= %d",self.tracker.trackerName, self.tracker.toid);
	[self.tracker saveData];
	if ([[self.tracker.optDict objectForKey:@"savertn"] isEqualToString:@"0"]) {  // default:1
        // do not return to tracker list after save, so generate clear form
		if (![self.toolbarItems containsObject:postDateBtn])
			[self.tracker resetData];
		[self updateToolBar];
		[self updateTrackerTableView];
        self.needSave=NO;
		[self showSaveBtn];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction)btnExport {
	//DBGLog(@"btnExport was pressed!");
    //NSString *fname = [[NSString stringWithFormat:@"%@_out.csv",self.tracker.trackerName]
    //                   stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *fname = [NSString stringWithFormat:@"%@_out.csv",self.tracker.trackerName];

	NSString *fpath = [rTracker_resource ioFilePath:fname access:YES];
	[[NSFileManager defaultManager] createFileAtPath:fpath contents:nil attributes:nil];
	NSFileHandle *nsfh = [NSFileHandle fileHandleForWritingAtPath:fpath];
	
	//[nsfh writeData:[@"hello, world." dataUsingEncoding:NSUTF8StringEncoding]];
    
	[self.tracker writeTrackerCSV:nsfh];
	[nsfh closeFile];
	//[nsfh release];
    
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
		dpvc = [[datePickerVC alloc] init];;
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
	[self presentModalViewController:self.dpvc animated:YES];

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
					   initWithTitle:@"<"
					   style:UIBarButtonItemStyleBordered
					   target:self
					   action:@selector(btnPrevDate)];
	}
	return prevDateBtn;
}

- (UIBarButtonItem *) postDateBtn {
	if (postDateBtn == nil) {
		postDateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:@">"
					   style:UIBarButtonItemStyleBordered
					   target:self
					   action:@selector(btnPostDate)];
	}
	
	return postDateBtn;
}

- (UIBarButtonItem *) currDateBtn {
	//DBGLog(@"currDateBtn called");
	NSString *datestr = [NSDateFormatter localizedStringFromDate:tracker.trackerDate 
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
				  initWithTitle:@"del"
				  style:UIBarButtonItemStyleBordered
				  target:self
				  action:@selector(btnDel)];
	}
	
	return delBtn;
}


#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)checkTrackerEntryDelete clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	DBGLog(@"checkTrackerDelete buttonIndex= %d",buttonIndex);
	
	if (buttonIndex == checkTrackerEntryDelete.destructiveButtonIndex) {
		int targD = [self.tracker prevDate];
		if (!targD) {
			targD = [self.tracker postDate];
		}
		[self.tracker deleteCurrEntry];
		[self setTrackerDate: targD];
	} else {
		DBGLog(@"cancelled");
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
	
#if DEBUGLOG
	NSUInteger row = [indexPath row];
	valueObj *vo = (valueObj *) [self.tracker.valObjTable  objectAtIndex:row];
	DBGLog(@"selected row %d : %@", row, vo.valueName);
#endif
    
}




@end
