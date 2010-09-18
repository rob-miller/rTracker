//
//  configTlistController.m
//  rTracker
//
//  Created by Robert Miller on 06/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "configTlistController.h"
#import "trackerList.h"
#import "addTrackerController.h"


@implementation configTlistController

@synthesize tlist;
@synthesize table;

static int selSegNdx=SegmentEdit;

NSIndexPath *deleteIndexPath; // remember row to delete if user confirms in checkTrackerDelete alert
UITableView *deleteTableView;

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

- (void)viewWillAppear:(BOOL)animated {
	
	NSLog(@"ctlc: viewWillAppear");
	
	[table reloadData];
	
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"ctlc: viewWillDisappear");

	//self.tlist = nil;
	
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

	switch (selSegNdx = [sender selectedSegmentIndex]) {
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

#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)checkTrackerDelete clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSLog(@"checkTrackerDelete buttonIndex= %d",buttonIndex);
	
	if (buttonIndex == checkTrackerDelete.destructiveButtonIndex) {
		NSUInteger row = [deleteIndexPath row];
		NSLog(@"checkTrackerDelete: will delete row %d ",row);
		int toid = [self.tlist getTIDfromIndex:row];
		[tlist.topLayoutTable removeObjectAtIndex:row];
		[deleteTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deleteIndexPath] 
						 withRowAnimation:UITableViewRowAnimationFade];		
		trackerObj *to = [[trackerObj alloc] init:toid];
		[to deleteAllData];
		[to release];
		[tlist reloadFromTLT];
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
	return [tlist.topLayoutTable count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"rvc table cell at index %d label %@",[indexPath row],[tlist.topLayoutTable objectAtIndex:[indexPath row]]);
	
    static NSString *CellIdentifier;
	
	if (selSegNdx == SegmentMoveDelete) {
		CellIdentifier = @"DeleteCell";
	} else {
		CellIdentifier = @"Cell";
	}
		
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [tlist.topLayoutTable objectAtIndex:row];
	
    return cell;
}

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableview 
		   editingStyleForRowAtIndexPath:(NSIndexPath *) indexpath {
	return UITableViewCellEditingStyleNone;
}
*/

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *) fromIndexPath 
	  toIndexPath:(NSIndexPath *) toIndexPath {
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];
	
	NSLog(@"ctlc: move row from %d to %d",fromRow, toRow);
	
	id object = [[tlist.topLayoutTable objectAtIndex:fromRow] retain];
	[tlist.topLayoutTable removeObjectAtIndex:fromRow];
	[tlist.topLayoutTable insertObject:object atIndex:toRow];
	[object release];
	
	[tlist reorderFromTLT];
	
}
					 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
	deleteIndexPath = indexPath;
	deleteTableView = tableView;
	

	UIActionSheet *checkTrackerDelete = [[UIActionSheet alloc] 
										 initWithTitle:[NSString stringWithFormat:
														@"Really delete all data for %@?",
														[tlist.topLayoutTable objectAtIndex:[indexPath row]]]
							delegate:self 
							cancelButtonTitle:@"Cancel"
							destructiveButtonTitle:@"Yes, delete"
							otherButtonTitles:nil];
	[checkTrackerDelete showInView:self.view];
	[checkTrackerDelete release];
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
	NSLog(@"configTList selected row %d : %@", row, [tlist.topLayoutTable objectAtIndex:row]);
	
	if (selSegNdx == SegmentEdit) {
		int toid = [self.tlist getTIDfromIndex:row];
		NSLog(@"will config toid %d",toid);
		
		addTrackerController *atc = [[addTrackerController alloc] initWithNibName:@"addTrackerController" bundle:nil ];
		atc.tlist = self.tlist;
		atc.tempTrackerObj = [[trackerObj alloc] init:toid];
	
		[self.navigationController pushViewController:atc animated:YES];
		[atc release];
	} else if (selSegNdx == SegmentCopy) {
		int toid = [self.tlist getTIDfromIndex:row];
		NSLog(@"will copy toid %d",toid);

		trackerObj *oTO = [[trackerObj alloc] init:toid];
		//oTO.toid = toid;
		//oTO = [oTO init:toid];
		
		trackerObj *nTO = [self.tlist toDeepCopy:oTO];
		[oTO release];
		[self.tlist confirmTopLayoutEntry:nTO];
		[nTO release];
		//[self.tlist confirmTopLayoutEntry:[self.tlist toDeepCopy:[self.tlist.topLayoutTable objectAtIndex:row]]];
		[tlist loadTopLayoutTable];
		[table reloadData];
		//[self.navigationController popViewControllerAnimated:YES];
	} else if (selSegNdx == SegmentMoveDelete) {
		NSLog(@"selected for move/delete?");
	}
}
@end
