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

const NSInteger kViewTag = 1;

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
	
	self.tracker = nil;
	[tracker release];
	[super dealloc];
}


# pragma mark -
# pragma mark view support

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = tracker.trackerName;
	
	//NSEnumerator *enumer = [tracker.valObjTable objectEnumerator];
	//valueObj *vo;
	//while ( vo = (valueObj *) [enumer nextObject]) {
	
	for (valueObj *vo in self.tracker.valObjTable) {
	
	
		[vo display];
	}
	
	// cancel / save buttons on top nav bar
	/*
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								  target:self
								  action:@selector(btnCancel)];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	[cancelBtn release];
	*/
	
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
							   //self.flexibleSpaceButtonItem,
							   self.fixed1SpaceButtonItem, self.currDateBtn, 
							   //self.flexibleSpaceButtonItem, 
							   nil] 
					 animated:NO];
	} else { 
		[self setToolbarItems:[NSArray arrayWithObjects: 
							   //self.flexibleSpaceButtonItem,
							   self.prevDateBtn, self.currDateBtn, 
							   //self.flexibleSpaceButtonItem, 
							   nil] 
					 animated:NO];
	} 
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
	
	[super viewDidLoad];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
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
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
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
			NSLog(@"utc will animate rotation but can't tell to where duration: %f sec", duration);
			break;			
	}
}

#else 

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	NSLog(@"utc will animate first half rotation to interface orientation duration: %@",duration);
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
	NSLog(@"utc will animate second half rotation to interface orientation duration: %@",duration);
}
#endif


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

- (void) updateTrackerTableView {
	NSLog(@"utc: updateTrackerTableView");
	//NSEnumerator *enumer = [self.tracker.valObjTable objectEnumerator];
	//valueObj *vo;
	//while ( vo = (valueObj *) [enumer nextObject]) {
	for (valueObj *vo in self.tracker.valObjTable) {
		//[vo.display release];
		vo.display = nil;
		//[vo display]; // happens with table reloadData
	}
	
//	[self.table reloadData];
	[(UITableView *) self.view reloadData];
//	[self.tableView reloadData];  // if we were a uitableviewcontroller not uiviewcontroller
}

- (void) setTrackerDate:(int) targD {
	NSArray *tbi=nil;
	self.currDateBtn = nil;
	
	if (targD == 0) {
		NSLog(@" setTrackerDate: %d = reset to today",targD);
		[self.tracker resetData];
		int pDate = [self.tracker prevDate];
		[self updateTrackerTableView];
		if (pDate != 0) {
			tbi = [NSArray arrayWithObjects: 
				   //self.flexibleSpaceButtonItem, 
				   self.prevDateBtn, self.currDateBtn,
				   //self.flexibleSpaceButtonItem, 
				   nil];
		} else {
			tbi = [NSArray arrayWithObjects: 
				   //self.flexibleSpaceButtonItem, 
				   self.fixed1SpaceButtonItem, 
				   self.currDateBtn,
				   //self.flexibleSpaceButtonItem, 
				   nil];
		}
	} else if (targD < 0) {
		NSLog(@"setTrackerDate: %d = no earlier date", targD);
		tbi = [NSArray arrayWithObjects: 
			   //self.flexibleSpaceButtonItem,
			   self.fixed1SpaceButtonItem, 
			   self.currDateBtn, self.postDateBtn, 
			   self.flexibleSpaceButtonItem, 
			   self.delBtn, 
			   //self.flexibleSpaceButtonItem, 
			   nil];
	} else {
		NSLog(@" setTrackerDate: %d = %@",targD, [NSDate dateWithTimeIntervalSince1970:targD]);
		[self.tracker loadData:targD];
		int pDate = [self.tracker prevDate];
		[self updateTrackerTableView];
		if (pDate != 0) {
			tbi = [NSArray arrayWithObjects: 
				   //self.flexibleSpaceButtonItem,
				   self.prevDateBtn, self.currDateBtn, self.postDateBtn, 
				   self.flexibleSpaceButtonItem, 
				   self.delBtn, 
				   //self.flexibleSpaceButtonItem, 
				   nil];
		} else {
			tbi = [NSArray arrayWithObjects: 
				   //self.flexibleSpaceButtonItem,
				   self.fixed1SpaceButtonItem, 
				   self.currDateBtn, self.postDateBtn, 
				   self.flexibleSpaceButtonItem, 
				   self.delBtn, 
				   //self.flexibleSpaceButtonItem, 
				   nil];
		}
	}
	
	[self setToolbarItems:tbi animated:YES];
}

- (void) btnPrevDate {
	int targD = [tracker prevDate];
	if (targD == 0) {
		targD = -1;
	} 
	[self setTrackerDate: targD];
}

- (void) btnPostDate {
	[self setTrackerDate:[self.tracker postDate]];
}

- (void) btnCurrDate {
	NSLog(@"pressed date becuz its a button, should pop up a date picker....");
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
#pragma mark button accessor getters

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
		viewToRemove = [cell.contentView viewWithTag:kViewTag];
		if (viewToRemove)
			[viewToRemove removeFromSuperview];
	}
	
    
	// Configure the cell.

	cell.textLabel.text = vo.valueName;
	
	CGRect bounds = cell.frame;
	NSLog(@"maxLabel: % f %f",self.tracker.maxLabel.width, self.tracker.maxLabel.height);
	//bounds.origin.y = bounds.size.height;// - BMARGIN;
	bounds.origin.y = self.tracker.maxLabel.height - BMARGIN;
	bounds.size.height = self.tracker.maxLabel.height + BMARGIN;
	bounds.size.width = bounds.size.width - self.tracker.maxLabel.width - LMARGIN - RMARGIN;
	bounds.origin.x = bounds.origin.x + self.tracker.maxLabel.width + LMARGIN;

	NSLog(@"bounds= %f %f %f %f",bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)	;
	[cell.contentView addSubview:[vo display:bounds]];
    return cell;
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
