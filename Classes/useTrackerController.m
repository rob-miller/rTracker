//
//  useTrackerController.m
//  rTracker
//
//  Created by Robert Miller on 03/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "useTrackerController.h"


@implementation useTrackerController

@synthesize tracker, table;

@synthesize prevDateBtn, postDateBtn, currDateBtn, delBtn, flexibleSpaceButtonItem, fixed1SpaceButtonItem;

const NSInteger kViewTag = 1;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = tracker.trackerName;
	
	NSEnumerator *enumer = [tracker.valObjTable objectEnumerator];
	valueObj *vo;
	while ( vo = (valueObj *) [enumer nextObject]) {
		[vo display];
	}
	
	// cancel / save buttons on top nav bar
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								  target:self
								  action:@selector(btnCancel)];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	[cancelBtn release];
	
	UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemSave
								target:self
								action:@selector(btnSave)];
	self.navigationItem.rightBarButtonItem = saveBtn;
	[saveBtn release];
			
	//self.toolbarItems = [NSArray arrayWithObjects: self.prevDateBtn, self.currDateBtn,nil];

	[self setToolbarItems:[NSArray arrayWithObjects: 
						   //self.flexibleSpaceButtonItem,
						   self.prevDateBtn, self.currDateBtn, 
						   //self.flexibleSpaceButtonItem, 
						   nil] 
				 animated:NO];
	
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	[self.prevDateBtn release];
	[self.currDateBtn release];
	[self.postDateBtn release];
	[self.delBtn release];
	
	[self.fixed1SpaceButtonItem release];
	[self.flexibleSpaceButtonItem release];
}

- (void)dealloc {

	[super dealloc];
}


#pragma mark buttons

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
	if (currDateBtn == nil) {
		NSLog(@"creating button");
		currDateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:[tracker.trackerDate description]
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



#pragma mark button methods

- (IBAction)btnCancel {
	NSLog(@"btnCancel was pressed!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSave {
	NSLog(@"btnSave was pressed! tracker name= %@ toid= %d",tracker.trackerName, tracker.toid);
	[tracker saveData];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) updateTrackerTableView {
	NSEnumerator *enumer = [tracker.valObjTable objectEnumerator];
	valueObj *vo;
	while ( vo = (valueObj *) [enumer nextObject]) {
		//[vo.display release];
		vo.display = nil;
		[vo display];
	}
	[table reloadData];
}

- (void) setTrackerDate:(int) targD {
	NSArray *tbi=nil;
	
	if (targD == 0) {
		NSLog(@" setTrackerDate: %d = reset to today",targD);
		[tracker resetData];
		int pDate = [tracker prevDate];
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
		[tracker loadData:targD];
		int pDate = [tracker prevDate];
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
	
	//[self.currDateBtn release];
	self.currDateBtn = nil;
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
	[self setTrackerDate:[tracker postDate]];
}

- (void) btnCurrDate {
	NSLog(@"pressed date becuz its a button, should pop up a date picker....");
}

- (void) btnNull {
}

- (void) btnDel {
	UIActionSheet *checkTrackerEntryDelete = [[UIActionSheet alloc] 
										 initWithTitle:[NSString stringWithFormat:
														@"Really delete %@ entry %@?", 
														tracker.trackerName, tracker.trackerDate]
										 delegate:self 
										 cancelButtonTitle:@"Cancel"
										 destructiveButtonTitle:@"Yes, delete"
										 otherButtonTitles:nil];
	[checkTrackerEntryDelete showInView:self.view];
	[checkTrackerEntryDelete release];
}

#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)checkTrackerEntryDelete clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSLog(@"checkTrackerDelete buttonIndex= %d",buttonIndex);
	
	if (buttonIndex == checkTrackerEntryDelete.destructiveButtonIndex) {
		int targD = [tracker prevDate];
		if (!targD) {
			targD = [tracker postDate];
		}
		[tracker deleteCurrEntry];
		[self setTrackerDate: targD];
	} else {
		NSLog(@"cancelled");
	}
	
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//return 0;  //[rTrackerAppDelegate.topLayoutTable count];
	return [tracker.valObjTable count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	valueObj *vo = (valueObj *) [tracker.valObjTable  objectAtIndex:row];
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
	[cell.contentView addSubview:[vo display]];
    return cell;
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
	valueObj *vo = (valueObj *) [tracker.valObjTable  objectAtIndex:row];

	NSLog(@"selected row %d : %@", row, vo.valueName);
	
	
}




@end
