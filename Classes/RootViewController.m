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

- (void)viewDidLoad {

    self.title = @"rTracker";


    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;

	UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								  target:self
								  action:@selector(btnEdit)];
	self.navigationItem.leftBarButtonItem = editBtn;
	[editBtn release];
	
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
	
	NSLog(@"rvc viewDidLoad");
	
	tlist = [[trackerList alloc] init];
	//[tlist loadTopLayoutTable];

	UIApplication *app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillTerminate:) 
												 name:UIApplicationWillTerminateNotification
											   object:app];
	

	[super viewDidLoad];
											
}



- (void)viewWillAppear:(BOOL)animated {

	NSLog(@"rvc: viewWillAppear");	
	
	[tlist loadTopLayoutTable];
	[self.tableView reloadData];
	
	//NSString *foo = [[NSString alloc] initWithFormat:@"I am a wasteful string"];
	//NSLog(@"foo is %@",foo);
	
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

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

	//[self.tlist release];
	//self.tlist = nil;

}


- (void)dealloc {
	
	NSLog(@"rvc dealloc");
	[tlist release];
	
    [super dealloc];
}

#pragma mark buttons

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




#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [tlist.topLayoutNames count];
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
	cell.textLabel.text = [tlist.topLayoutNames objectAtIndex:row];

    return cell;
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];

	NSUInteger row = [indexPath row];
	NSLog(@"selected row %d : %@", row, [tlist.topLayoutNames objectAtIndex:row]);
	
	trackerObj *to = [[trackerObj alloc] init:[tlist getTIDfromIndex:row]];
	[to describe];

	useTrackerController *utc = [[useTrackerController alloc] initWithNibName:@"useTrackerController" bundle:nil ];
	utc.tracker = to;
	[self.navigationController pushViewController:utc animated:YES];
	[utc release];
	
	[to release];
	
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


 - (void)applicationWillTerminate:(NSNotification *)notification {
	 NSLog(@"rvc: app will terminate");
	// close trackerList
	 // TODO: close all tracker Dbs -- or sooner?
	 [self.tlist release];
	 //self.tlist = nil;

}


@end

