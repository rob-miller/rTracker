/***************
 configTlistController.m
 Copyright 2010-2016 Robert T. Miller
 
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
//  configTlistController.m
//  rTracker
//
//  Created by Robert Miller on 06/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "configTlistController.h"
#import "trackerList.h"
#import "addTrackerController.h"
#import "rTracker-resource.h"
#import "dbg-defs.h"

#if ADVERSION
#import "rt_IAPHelper.h"
#endif

@implementation configTlistController

@synthesize tlist=_tlist;
@synthesize tableView=_tableView;
@synthesize deleteIndexPath=_deleteIndexPath;

static int selSegNdx=SegmentEdit;


#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	DBGLog(@"configTlistController dealloc");
}


# pragma mark -
# pragma mark view support

- (void) startExport {
    @autoreleasepool {
        [self.tlist exportAll];
        safeDispatchSync(^{
            [rTracker_resource finishProgressBar:self.view navItem:self.navigationItem disable:YES];
        });
    
    }
}

- (void) btnExport {
    
    DBGLog(@"export all");
    CGRect navframe = [[self.navigationController navigationBar] frame];
    [rTracker_resource alert:@"exporting trackers" msg:@"_out.csv and _out.plist files are being saved to the rTracker Documents directory on this device.  Access them through iTunes on your PC/Mac, or with a program like iExplorer from Macroplant.com.  Import by changing the names to _in.csv and _in.plist, and read about .rtcsv file import capabilities in the help pages." vc:self];
    [rTracker_resource startProgressBar:self.view navItem:self.navigationItem disable:YES yloc:(navframe.size.height + navframe.origin.y)];
    
    [NSThread detachNewThreadSelector:@selector(startExport) toTarget:self withObject:nil];
}
#if ADVERSION
- (void) btnUpgrade {
    //[rTracker_resource buy_rTrackerAlert];
    [rTracker_resource replaceRtrackerA:self];
}
#endif

- (UIBarButtonItem *) getExportBtn {
    UIBarButtonItem *exportBtn;
#if ADVERSION
    if (![rTracker_resource getPurchased]) {
        
        exportBtn = [[UIBarButtonItem alloc]
                     initWithTitle:@"Upgrade"
                     style:UIBarButtonItemStylePlain
                     target:self
                     action:@selector(btnUpgrade)];
    } else {
        exportBtn = [[UIBarButtonItem alloc]
                     initWithTitle:@"Export all"
                     style:UIBarButtonItemStylePlain
                     target:self
                     action:@selector(btnExport)];
        
    }
#else
    exportBtn = [[UIBarButtonItem alloc]
                 initWithTitle:@"Export all"
                 style:UIBarButtonItemStylePlain
                 target:self
                 action:@selector(btnExport)];
#endif
    return exportBtn;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	self.title = @"Edit trackers";

/*
 #else
    // wipe orphans
	UIBarButtonItem *exportBtn = [[UIBarButtonItem alloc]
								  initWithTitle:@"wipe orphans"
								  style:UIBarButtonItemStylePlain
								  target:self
								  action:@selector(btnWipeOrphans)];

#endif
*/
	//NSArray *tbArray = [NSArray arrayWithObjects: exportBtn, nil];
	//self.toolbarItems = tbArray;
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationItem setRightBarButtonItem:[self getExportBtn] animated:NO];

    UIImageView *bg = [[UIImageView alloc] initWithImage:[rTracker_resource get_background_image:self]];
    bg.tag = BGTAG;
    [self.view addSubview:bg];
    [self.view sendSubviewToBack:bg];
    [rTracker_resource setViewMode:self];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewSwipeRight:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];

	[super viewDidLoad];
}

- (void)handleViewSwipeRight:(UISwipeGestureRecognizer *)gesture {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [rTracker_resource setViewMode:self];
    [self.tableView setNeedsDisplay];
    [self.view setNeedsDisplay];
}


/*
- (void)viewDidUnload {
	
	DBGLog(@"configTlistController view didunload");
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	self.title = nil;
	self.tlist = nil;
	self.tableView = nil;
	self.toolbarItems = nil;

	[super viewDidLoad];
	
}
*/

#if ADVERSION
// handle rtPurchasedNotification
- (void) updatePurchased:(NSNotification*)n {
    [rTracker_resource doQuickAlert:@"Purchase Successful" msg:@"Thank you!" delay:2 vc:self];
    [self.navigationItem setRightBarButtonItem:[self getExportBtn] animated:NO];
}

#endif

- (void)viewWillAppear:(BOOL)animated {
    
    DBGLog(@"ctlc: viewWillAppear");
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [self.tableView reloadData];
    selSegNdx=SegmentEdit;  // because mode select starts with default 'modify' selected
    
#if ADVERSION
    if (![rTracker_resource getPurchased]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatePurchased:)
                                                     name:rtPurchasedNotification
                                                   object:nil];
    }
#endif
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	DBGLog(@"ctlc: viewWillDisappear");
    
    [self.tlist updateShortcutItems];

	//self.tlist = nil;

#if ADVERSION
    //unregister for purchase notices
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:rtPurchasedNotification
                                                    object:nil];
#endif
	
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark button press action methods


- (IBAction) modeChoice:(id)sender {

	switch (selSegNdx = (int) [sender selectedSegmentIndex]) {
		case SegmentEdit :
			//DBGLog(@"ctlc: set edit mode");
			[self.tableView setEditing:NO animated:YES];
			break;
		case SegmentCopy :
			//DBGLog(@"ctlc: set copy mode");
			[self.tableView setEditing:NO animated:YES];
			break;
		case SegmentMoveDelete :
			//DBGLog(@"ctlc: set move/delete mode");
			[self.tableView setEditing:YES animated:YES];
			break;
		default:
			dbgNSAssert(0,@"ctlc: segment index not handled");
			break;
	}
			
			
}

#pragma mark -
#pragma mark delete tracker options methods

- (void) delTracker
{
	NSUInteger row = [self.deleteIndexPath row];
	DBGLog(@"checkTrackerDelete: will delete row %lu ",(unsigned long)row);
	[self.tlist deleteTrackerAllRow:row];
	//[self.deleteTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.deleteIndexPath]
	//					   withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView deleteRowsAtIndexPaths:@[self.deleteIndexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
	[self.tlist reloadFromTLT];
}

- (void) delTrackerRecords {
	NSUInteger row = [self.deleteIndexPath row];
	DBGLog(@"checkTrackerDelete: will delete records only for row %lu ",(unsigned long)row);
	[self.tlist deleteTrackerRecordsRow:row];
	[self.tlist reloadFromTLT];
}

- (void) handleCheckTrackerDelete:(NSInteger)choice {
	//DBGLog(@"checkTrackerDelete buttonIndex= %d",buttonIndex);
	
	if (choice == 0) {
        DBGLog(@"cancelled tracker delete");
        [self.tableView reloadRowsAtIndexPaths:@[self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    } else if (choice == 1) {
		[self delTracker];
	} else {
        [self delTrackerRecords];
        [self.tableView reloadRowsAtIndexPaths:@[self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    }

    self.deleteIndexPath = nil;
	
}
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self handleCheckTrackerDelete:buttonIndex];
}

*/
					 
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
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //DBGLog(@"rvc table cell at index %d label %@",[indexPath row],[self.tlist.topLayoutNames objectAtIndex:[indexPath row]]);
	
    static NSString *CellIdentifier;
	
	if (selSegNdx == SegmentMoveDelete) {
		CellIdentifier = @"DeleteCell";
	} else {
		CellIdentifier = @"Cell";
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
    }
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
	cell.textLabel.text = (self.tlist.topLayoutNames)[row];
    if (@available(iOS 13.0, *)) {
        cell.textLabel.textColor = [UIColor labelColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSString *tn = (self.tlist.topLayoutNames)[row];
    CGSize tns = [tn sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}];
    return tns.height + (2*MARGIN) ;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *) fromIndexPath 
	  toIndexPath:(NSIndexPath *) toIndexPath {
    
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];
	
	DBGLog(@"ctlc: move row from %lu to %lu",(unsigned long)fromRow, (unsigned long)toRow);
	[self.tlist reorderTLT :fromRow toRow:toRow];
	[self.tlist reorderFromTLT];
	
}
					 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	self.deleteIndexPath = indexPath;;
	
    NSString *tname = (self.tlist.topLayoutNames)[[indexPath row]];
    
	NSInteger toid = [self.tlist getTIDfromIndex:[indexPath row]];
	trackerObj *to = [[trackerObj alloc] init:toid];
	int entries = [to countEntries];

    NSString *title = [NSString stringWithFormat:@"Delete tracker %@",tname];
    NSString *msg;
    NSString *btn0 = @"Cancel";
    NSString *btn1 = @"Delete tracker";
    NSString *btn2;

    if (entries==0) {
        msg  = [NSString stringWithFormat:@"Tracker %@ has no records.",tname];
        btn2 = nil;
    } else {
        btn2 = @"Remove records only";
        if (entries==1)
            msg = [NSString stringWithFormat:@"Tracker %@ has 1 record.",tname];
        else
            msg = [NSString stringWithFormat:@"Tracker %@ has %d records.",tname,entries];
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:btn0 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleCheckTrackerDelete:0]; }];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:btn1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleCheckTrackerDelete:1]; }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    
    if (btn2) {
        UIAlertAction* deleteRecordsAction = [UIAlertAction actionWithTitle:btn2 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self handleCheckTrackerDelete:2]; }];
        [alert addAction:deleteRecordsAction];
    }
    
    
    [self presentViewController:alert animated:YES completion:nil];
    

}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
	//DBGLog(@"configTList selected row %d : %@", row, [self.tlist.topLayoutNames objectAtIndex:row]);
	
	if (selSegNdx == SegmentEdit) {
		NSInteger toid = [self.tlist getTIDfromIndex:row];
		DBGLog(@"will config toid %ld",(long)toid);
		
		addTrackerController *atc = [[addTrackerController alloc] initWithNibName:@"addTrackerController" bundle:nil ];
		atc.tlist = self.tlist;
        trackerObj *tto = [[trackerObj alloc] init:toid];
		atc.tempTrackerObj = tto;
        [tto removeTempTrackerData];  // ttd array no longer valid if make any changes, can't be sure from here so wipe it

		[self.navigationController pushViewController:atc animated:YES];
        //[atc.tempTrackerObj release]; // rtm 05 feb 2012 +1 alloc/init, +1 atc.temptto retain 
	} else if (selSegNdx == SegmentCopy) {
		NSInteger toid = [self.tlist getTIDfromIndex:row];
		DBGLog(@"will copy toid %ld",(long)toid);

		trackerObj *oTO = [[trackerObj alloc] init:toid];
		trackerObj *nTO = [self.tlist copyToConfig:oTO];
		[self.tlist addToTopLayoutTable:nTO];
		//[self.tlist loadTopLayoutTable];
         dispatch_async(dispatch_get_main_queue(), ^(void){
             [self.tableView reloadData];
         });

	} else if (selSegNdx == SegmentMoveDelete) {
		DBGWarn(@"selected for move/delete?");
	}
}
@end
