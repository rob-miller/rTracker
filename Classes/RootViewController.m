//
//  RootViewController.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import "RootViewController.h"
#import "rTrackerAppDelegate.h"
#import "addTrackerController.h"
#import "configTlistController.h"
#import "useTrackerController.h"

@implementation RootViewController

@synthesize tlist;
@synthesize privateBtn, multiGraphBtn;

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	
	NSLog(@"rvc dealloc");
	self.tlist = nil;
	[tlist release];
	
    [super dealloc];
}

/*
- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"rvc: app will terminate");
	// close trackerList
	
}
*/

#pragma mark -
#pragma mark view support

- (void)viewDidLoad {
	NSLog(@"rvc: viewDidLoad");
    self.title = @"rTracker";

	UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								target:self
								action:@selector(btnAddTracker)];
	self.navigationItem.rightBarButtonItem = addBtn;
	[addBtn release];
	
	[self setToolbarItems:[NSArray arrayWithObjects: 
						   //self.flexibleSpaceButtonItem,
						   self.privateBtn, self.multiGraphBtn, 
						   //self.flexibleSpaceButtonItem, 
						   nil] 
				 animated:NO];
	
	[privateBtn release];
	[multiGraphBtn release];

	self.tlist = [[trackerList alloc] init];
	//[tlist loadTopLayoutTable];

	/*
	UIApplication *app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillTerminate:) 
												 name:UIApplicationWillTerminateNotification
											   object:app];
	
	 */
	
	[super viewDidLoad];
	
}

- (void)viewWillAppear:(BOOL)animated {

	NSLog(@"rvc: viewWillAppear");	
	
	[self.tlist loadTopLayoutTable];
	[self.tableView reloadData];

	if ([self.tlist.topLayoutNames count] == 0) {
		if (self.navigationItem.leftBarButtonItem != nil) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	} else {
		if (self.navigationItem.leftBarButtonItem == nil) {
			
			UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]
										initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
										target:self
										action:@selector(btnEdit)];
			self.navigationItem.leftBarButtonItem = editBtn;
			[editBtn release];
		}
	}
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	
	NSLog(@"rvc didReceiveMemoryWarning");
	// Release any cached data, images, etc that aren't in use.

    [super didReceiveMemoryWarning];


}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
	
	NSLog(@"rvc viewDidUnload");

	self.title = nil;
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[self setToolbarItems:nil
				 animated:NO];
	
	self.tlist = nil;
	
	//NSLog(@"pb rc= %d  mgb rc= %d", [self.privateBtn retainCount], [self.multiGraphBtn retainCount]);
	
}


#pragma mark -
#pragma mark button accessor getters

- (UIBarButtonItem *) privateBtn {
	if (privateBtn == nil) {
		privateBtn = [[UIBarButtonItem alloc]
					   initWithTitle:@"private"
					   style:UIBarButtonItemStyleBordered
					   target:self
					   action:@selector(btnPrivate)];
	}
	return privateBtn;
}

- (UIBarButtonItem *) multiGraphBtn {
	if (multiGraphBtn == nil) {
		multiGraphBtn = [[UIBarButtonItem alloc]
					  initWithTitle:@"Multi-Graph"
					  style:UIBarButtonItemStyleBordered
					  target:self
					  action:@selector(btnMultiGraph)];
	}
	return multiGraphBtn;
}

#pragma mark -
#pragma mark button action methods

- (void) btnAddTracker {
	//NSLog(@"btnAddTracker was pressed!");
	
	addTrackerController *atc = [[addTrackerController alloc] initWithNibName:@"addTrackerController" bundle:nil ];
	atc.tlist = self.tlist;
	[self.navigationController pushViewController:atc animated:YES];
	[atc release];
	
}

- (IBAction)btnEdit {
	//NSLog(@"btnConfig was pressed!");
	
	configTlistController *ctlc = [[configTlistController alloc] initWithNibName:@"configTlistController" bundle:nil ];
	ctlc.tlist = self.tlist;
	[self.navigationController pushViewController:ctlc animated:YES];
	[ctlc release];
	
}
	
- (void)btnMultiGraph {
	NSLog(@"btnMultiGraph was pressed!");
}

- (void)btnPrivate {
	NSLog(@"btnPrivate was pressed!");
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tlist.topLayoutNames count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"rvc table cell at index %d label %@",[indexPath row],[tlist.topLayoutNames objectAtIndex:[indexPath row]]);
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [self.tlist.topLayoutNames objectAtIndex:row];

    return cell;
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger row = [indexPath row];
	NSLog(@"selected row %d : %@", row, [self.tlist.topLayoutNames objectAtIndex:row]);
	
	trackerObj *to = [[trackerObj alloc] init:[self.tlist getTIDfromIndex:row]];
	[to describe];

	useTrackerController *utc = [[useTrackerController alloc] initWithNibName:@"useTrackerController" bundle:nil ];
	utc.tracker = to;
	[self.navigationController pushViewController:utc animated:YES];
	[utc release];
	
	[to release];
	
}

@end

