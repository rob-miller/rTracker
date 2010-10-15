//
//  useTrackerController.m
//  rTracker
//
//  Created by Robert Miller on 03/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "useTrackerController.h"
#import "graphTrackerVC.h"

@implementation useTrackerController

@synthesize tracker;

@synthesize prevDateBtn, postDateBtn, currDateBtn, delBtn, flexibleSpaceButtonItem, fixed1SpaceButtonItem;
@synthesize table, dpvc;

//const NSInteger kViewTag = 1;

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
	
	self.fixed1SpaceButtonItem = nil;
	[fixed1SpaceButtonItem release];
	self.flexibleSpaceButtonItem = nil;
	[flexibleSpaceButtonItem release];
	
	self.dpvc = nil;
	[dpvc release];
	
	self.table = nil;
	[table release];
	
	self.tracker = nil;
	[tracker release];
	[super dealloc];
}


# pragma mark -
# pragma mark view support

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	NSLog(@"utc: viewDidLoad dpvc=%d", (self.dpvc == nil ? 0 : 1));
	
	self.title = tracker.trackerName;
	
	for (valueObj *vo in self.tracker.valObjTable) {
		[vo display];
	}
	
	UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemSave
								target:self
								action:@selector(btnSave)];
	self.navigationItem.rightBarButtonItem = saveBtn;
	[saveBtn release];
			
	//self.toolbarItems = [NSArray arrayWithObjects: self.prevDateBtn, self.currDateBtn,nil];

	int pDate = [tracker prevDate];
	if (pDate == 0) {
		[self setToolbarItems:[NSArray arrayWithObjects: 
							   self.fixed1SpaceButtonItem, self.currDateBtn, 
							   nil] 
					 animated:NO];
	} else { 
		[self setToolbarItems:[NSArray arrayWithObjects: 
							   self.prevDateBtn, self.currDateBtn, 
							   nil] 
					 animated:NO];
	} 
	
	//self.dpvc = nil;
	
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
	UIView *haveView = [self.view viewWithTag:kViewTag2];
	if (haveView) 
		[haveView removeFromSuperview];
	self.dpvc = nil;
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
	
	self.dpvc.action = DPA_CANCEL;
	
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
	if (dpvc) {
		switch (self.dpvc.action) {
			case DPA_NEW:
				[self.tracker resetData];
				self.tracker.trackerDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[self.tracker noCollideDate:(int)[self.dpvc.date timeIntervalSince1970]]];
				//break;
			case DPA_SET:
			{
				if ([self.tracker hasData]) {
					[self.tracker changeDate:self.dpvc.date];
				}  
				self.tracker.trackerDate = self.dpvc.date;
				[self updateToolBar];
				break;
			}
			case DPA_GOTO:
			{
				int targD = (int) [self.dpvc.date timeIntervalSince1970];
				if (! [self.tracker loadData:targD]) {
					self.tracker.trackerDate = self.dpvc.date;
					targD = [self.tracker prevDate];
					if (!targD) 
						targD = [self.tracker postDate];
				}
				[self setTrackerDate:targD];
				break;
			}
			case DPA_CANCEL:
				break;
			default:
				NSAssert(0,@"failed to determine dpvc action");
				break;
		}
		self.dpvc.date = nil;
		self.dpvc = nil;
		[dpvc release];
	}
}
# pragma mark view rotation methods

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			NSLog(@"utc should rotate to interface orientation portrait?");
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			NSLog(@"utc should rotate to interface orientation portrait upside down?");
			break;
		case UIInterfaceOrientationLandscapeLeft:
			NSLog(@"utc should rotate to interface orientation landscape left?");
			break;
		case UIInterfaceOrientationLandscapeRight:
			NSLog(@"utc should rotate to interface orientation landscape right?");
			break;
		default:
			NSLog(@"utc rotation query but can't tell to where?");
			break;			
	}
	
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown );
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	switch (fromInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			NSLog(@"utc did rotate from interface orientation portrait");
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			NSLog(@"utc did rotate from interface orientation portrait upside down");
			break;
		case UIInterfaceOrientationLandscapeLeft:
			NSLog(@"utc did rotate from interface orientation landscape left");
			break;
		case UIInterfaceOrientationLandscapeRight:
			NSLog(@"utc did rotate from interface orientation landscape right");
			break;
		default:
			NSLog(@"utc did rotate but can't tell from where");
			break;			
	}
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			NSLog(@"utc will rotate to interface orientation portrait duration: %f sec",duration);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			NSLog(@"utc will rotate to interface orientation portrait upside down duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			NSLog(@"utc will rotate to interface orientation landscape left duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeRight:
			NSLog(@"utc will rotate to interface orientation landscape right duration: %f sec", duration);
			break;
		default:
			NSLog(@"utc will rotate but can't tell to where duration: %f sec", duration);
			break;			
	}
}
#if (1) 
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	graphTrackerVC *gt;
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			NSLog(@"utc will animate rotation to interface orientation portrait duration: %f sec",duration);
			[self dismissModalViewControllerAnimated:YES];
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			NSLog(@"utc will animate rotation to interface orientation portrait upside down duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			NSLog(@"utc will animate rotation to interface orientation landscape left duration: %f sec", duration);

			gt = [[graphTrackerVC alloc] init];
			gt.tracker = self.tracker;
			[self presentModalViewController:gt animated:YES];
			[gt release];
			
			break;
		case UIInterfaceOrientationLandscapeRight:
			NSLog(@"utc will animate rotation to interface orientation landscape right duration: %f sec", duration);

			gt = [[graphTrackerVC alloc] init];
			gt.tracker = self.tracker;
			[self presentModalViewController:gt animated:YES];
			[gt release];
			
			break;
		default:
			NSLog(@"utc will animate rotation but can't tell to where. duration: %f sec", duration);
			break;			
	}
}
#else 
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	NSLog(@"utc will animate first half rotation to interface orientation duration: %@",duration);
}
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	NSLog(@"utc will animate second half rotation to interface orientation duration: %@",duration);
}
#endif

#pragma mark -
#pragma mark datepicker support

- (void) updateTrackerTableView {
	NSLog(@"utc: updateTrackerTableView");
	
	for (valueObj *vo in self.tracker.valObjTable) {
		vo.display = nil;
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

	NSLog(@"prevD = %d",prevD);
	NSLog(@"currD = %d",currD);
	NSLog(@"postD = %d",postD);
	NSLog(@"lastD = %d",lastD);
	
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

	/*
	if ((prevD==0) && (postD==0) && (lastD==0)) {  // no stored entries
		self.postDateBtn = nil;
		self.prevDateBtn = nil;
		tbi = [NSArray arrayWithObjects: 
				   self.fixed1SpaceButtonItem, 
				   self.currDateBtn,
				   nil];
	} else if ((prevD != 0) && (postD==0)) {
		self.postDateBtn = nil;
		tbi = [NSArray arrayWithObjects: 
			   self.prevDateBtn, self.currDateBtn,
			   nil];
	} else if ((prevD==0) && (postD != 0)) {
		self.prevDateBtn = nil;
		tbi = [NSArray arrayWithObjects: 
			   self.fixed1SpaceButtonItem, 
			   self.currDateBtn, self.postDateBtn, 
			   self.flexibleSpaceButtonItem, 
			   self.delBtn, 
			   nil];
	} else {
		tbi = [NSArray arrayWithObjects: 
			   self.fixed1SpaceButtonItem, 
			   self.currDateBtn, self.postDateBtn, 
			   self.flexibleSpaceButtonItem, 
			   self.delBtn, 
			   nil];
	}
*/
	
	[self setToolbarItems:tbi animated:YES];
}

- (void) setTrackerDate:(int) targD {
	
	if (targD == 0) {
		NSLog(@" setTrackerDate: %d = reset to now",targD);
		[self.tracker resetData];
	} else if (targD < 0) {
		NSLog(@"setTrackerDate: %d = no earlier date", targD);
	} else {
		NSLog(@" setTrackerDate: %d = %@",targD, [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)targD]);
		[self.tracker loadData:targD];
	}
	
	[self updateToolBar];
	[self updateTrackerTableView];
}

#pragma mark -
#pragma mark button press action methods

- (IBAction)btnCancel {
	NSLog(@"btnCancel was pressed!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSave {
	NSLog(@"btnSave was pressed! tracker name= %@ toid= %d",self.tracker.trackerName, self.tracker.toid);
	[self.tracker saveData];
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
		dpvc = [[datePickerVC alloc] init];;
	}
	return dpvc;
}

- (void) btnCurrDate {
	NSLog(@"pressed date becuz its a button, should pop up a date picker....");
	
	
	self.dpvc.myTitle = [NSString stringWithFormat:@"Date for %@", self.tracker.trackerName];
	self.dpvc.date = self.tracker.trackerDate;
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
	NSLog(@"currDateBtn called");
	NSString *datestr = [NSDateFormatter localizedStringFromDate:tracker.trackerDate 
													   dateStyle:NSDateFormatterShortStyle 
													   timeStyle:NSDateFormatterShortStyle];

	if (currDateBtn == nil) {
		NSLog(@"creating button");
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
	NSLog(@"checkTrackerDelete buttonIndex= %d",buttonIndex);
	
	if (buttonIndex == checkTrackerEntryDelete.destructiveButtonIndex) {
		int targD = [self.tracker prevDate];
		if (!targD) {
			targD = [self.tracker postDate];
		}
		[self.tracker deleteCurrEntry];
		[self setTrackerDate: targD];
	} else {
		NSLog(@"cancelled");
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


#define LMARGIN 60.0f
#define RMARGIN 10.0f
#define BMARGIN  7.0f

#define MARGIN 7.0f

#define CELL_HEIGHT_NORMAL (self.tracker.maxLabel.height + (3.0*MARGIN))
#define CELL_HEIGHT_TALL (2.0 * CELL_HEIGHT_NORMAL)

#define CHECKBOX_WIDTH 40.0f


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	valueObj *vo = (valueObj *) [self.tracker.valObjTable  objectAtIndex:row];
    NSLog(@"uvc table cell at index %d label %@",row,vo.valueName);
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
		// the cell is being recycled, remove old embedded controls
		UIView *viewToRemove = nil;
		while (viewToRemove = [cell.contentView viewWithTag:kViewTag])
			[viewToRemove removeFromSuperview];
	}
	
    
	// Configure the cell.

	CGRect bounds;
	
	if ((vo.vtype == VOT_CHOICE) || (vo.vtype == VOT_SLIDER)) {
		//cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		// checkButton top row left
		
		UIImage *checkImage = [UIImage imageNamed:@"checked.png"];
		
		bounds.origin.x = MARGIN;
		bounds.origin.y = MARGIN;
		bounds.size.width = checkImage.size.width ; //CHECKBOX_WIDTH; // cell.frame.size.width;
		bounds.size.height = checkImage.size.height ; //self.tracker.maxLabel.height + 2*BMARGIN; //CELL_HEIGHT_TALL/2.0; //self.tracker.maxLabel.height + BMARGIN;
		
		vo.checkButtonUseVO.frame = bounds;
		vo.checkButtonUseVO.tag = kViewTag;
		vo.checkButtonUseVO.backgroundColor = cell.backgroundColor;
		if (!postDateBtn) {
			[cell.contentView addSubview:vo.checkButtonUseVO];
		
			UIImage *image = (vo.useVO) ? checkImage : [UIImage imageNamed:@"unchecked.png"];
			UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
			[vo.checkButtonUseVO setBackgroundImage:newImage forState:UIControlStateNormal];
		}
		
		// cell label top row right 
		
		bounds.origin.x += checkImage.size.width + MARGIN;
		bounds.size.width = cell.frame.size.width - checkImage.size.width - (2.0*MARGIN);
		bounds.size.height = self.tracker.maxLabel.height + MARGIN; //CELL_HEIGHT_TALL/2.0; //self.tracker.maxLabel.height + BMARGIN;
		
		UILabel *label = [[UILabel alloc] initWithFrame:bounds];
		label.tag=kViewTag;
		label.font = [UIFont boldSystemFontOfSize:18.0];
		label.textAlignment = UITextAlignmentLeft;
		label.textColor = [UIColor blackColor];
		label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; // | UIViewAutoresizingFlexibleHeight;
		label.contentMode = UIViewContentModeTopLeft;
		label.text = vo.valueName;
		[cell.contentView addSubview:label];
		[label release];
		
		bounds.origin.y = self.tracker.maxLabel.height + (3.0*MARGIN); //CELL_HEIGHT_TALL/2.0 + MARGIN; // 38.0f; //bounds.size.height; // + BMARGIN;
		bounds.size.height = /*CELL_HEIGHT_TALL/2.0 ; // */ self.tracker.maxLabel.height + (1.5*MARGIN);
		
		bounds.size.width = cell.frame.size.width - (2.0f * MARGIN);
		bounds.origin.x = MARGIN; // 0.0f ;  //= bounds.origin.x + RMARGIN;
	} else {
		cell.textLabel.text = vo.valueName;
		bounds.origin.x = cell.frame.origin.x + self.tracker.maxLabel.width + LMARGIN;
		bounds.origin.y = self.tracker.maxLabel.height - (1.5*MARGIN);
		bounds.size.width = cell.frame.size.width - self.tracker.maxLabel.width - LMARGIN - RMARGIN;
		bounds.size.height = self.tracker.maxLabel.height + MARGIN;
	}

	NSLog(@"maxLabel: % f %f",self.tracker.maxLabel.width, self.tracker.maxLabel.height);
	//bounds.origin.y = bounds.size.height;// - BMARGIN;

	NSLog(@"bounds= %f %f %f %f",bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)	;
	[cell.contentView addSubview:[vo display:bounds]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger vt = ((valueObj*) [self.tracker.valObjTable objectAtIndex:[indexPath row]]).vtype;
	if ( (vt == VOT_CHOICE) || (vt == VOT_SLIDER) )
		return CELL_HEIGHT_TALL;
	return CELL_HEIGHT_NORMAL;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
	valueObj *vo = (valueObj *) [self.tracker.valObjTable  objectAtIndex:row];

	NSLog(@"selected row %d : %@", row, vo.valueName);
}




@end
