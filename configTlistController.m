//
//  configTlistController.m
//  rTracker
//
//  Created by Robert Miller on 06/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "configTlistController.h"
#import "trackerList.h"


@implementation configTlistController

@synthesize tlist;
@synthesize table;

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
	
	self.title = @"configure trackers";

	UIBarButtonItem *exportBtn = [[UIBarButtonItem alloc]
								  initWithTitle:@"export"
								  style:UIBarButtonItemStyleBordered
								  target:self
								  action:@selector(btnExport)];
	
	NSArray *tbArray = [NSArray arrayWithObjects: exportBtn, nil];
	
	self.toolbarItems = tbArray;
	[exportBtn release];
	
	
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
	
	NSLog(@"configTlistController view didunload");
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	self.tlist = nil;
	self.toolbarItems = nil;

}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"ctlc: viewWillDisappear");

	self.tlist = nil;
	
	[super viewWillDisappear:animated];
}


- (void)dealloc {
	NSLog(@"configTlistController dealloc");

	self.tlist = nil;
	self.toolbarItems = nil;

    [super dealloc];
}


#pragma mark button support

- (IBAction)btnExport {
	NSLog(@"btnExport was pressed!");
}

- (IBAction) modeChoice:(id)sender {

	switch ([sender selectedSegmentIndex]) {
		case SegmentEdit :
			NSLog(@"ctlc: set edit mode");
			[table setEditing:NO animated:YES];
			break;
		case SegmentCopy :
			NSLog(@"ctlc: set copy mode");
			[table setEditing:NO animated:YES];
			break;
		case SegmentMoveDelete :
			NSLog(@"ctlc: set move/delete mode");
			[table setEditing:YES animated:YES];
			break;
		default:
			NSAssert(0,@"ctlc: segment index not handled");
			break;
	}
			
			
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//return 0;  //[rTrackerAppDelegate.topLayoutTable count];
	return [tlist.topLayoutTable count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"rvc table cell at index %d label %@",[indexPath row],[tlist.topLayoutTable objectAtIndex:[indexPath row]]);
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [tlist.topLayoutTable objectAtIndex:row];
	
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableview 
		   editingStyleForRowAtIndexPath:(NSIndexPath *) indexpath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *) fromIndexPath 
	  toIndexPath:(NSIndexPath *) toIndexPath {
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];
	
	id object = [[self.tlist.topLayoutTable objectAtIndex:fromRow] retain];
	[self.tlist.topLayoutTable removeObjectAtIndex:fromRow];
	[self.tlist.topLayoutTable insertObject:object atIndex:toRow];
	[object release];
	
	[self.tlist reorderFromTLT];
	
}

@end
