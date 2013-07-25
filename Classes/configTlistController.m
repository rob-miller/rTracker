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

@implementation configTlistController

@synthesize tlist;
@synthesize table;

static int selSegNdx=SegmentEdit;

NSIndexPath *deleteIndexPath; // remember row to delete if user confirms in checkTrackerDelete alert
UITableView *deleteTableView;

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	DBGLog(@"configTlistController dealloc");
	self.tlist = nil;
	[tlist release];
	 
	self.table = nil;
	[table release];
	
    [super dealloc];
}


# pragma mark -
# pragma mark view support

- (void) startExport {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self.tlist exportAll];
    
    [rTracker_resource finishProgressBar:self.view navItem:self.navigationItem disable:YES];
    
    [pool drain];
}

- (void) btnExport {
    
    DBGLog(@"export all");
    [rTracker_resource startProgressBar:self.view navItem:self.navigationItem disable:YES];
    
    [NSThread detachNewThreadSelector:@selector(startExport) toTarget:self withObject:nil];
}

#if !RELEASE

- (void) btnWipeOrphans {
    self.tlist.sql = @"select id, name from toplevel order by id";
    NSMutableArray *i1 = [[NSMutableArray alloc]init];
    NSMutableArray *s1 = [[NSMutableArray alloc]init];
    [self.tlist toQry2AryIS:i1 s1:s1];
    NSMutableDictionary *dictTid2Ndx = [[NSMutableDictionary alloc]init];
    NSUInteger c = [i1 count];
    NSUInteger i;
    for (i=0;i<c;i++) {
        [dictTid2Ndx setObject:[NSNumber numberWithUnsignedInt:i] forKey:[i1 objectAtIndex:i]];
    }
    
    NSError *err;
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[rTracker_resource ioFilePath:@"" access:DBACCESS] error:&err];
    NSMutableDictionary *dictTid2Filename = [[NSMutableDictionary alloc]init];
    
    if (nil == fileList) {
        DBGLog(@"error getting file list: %@",err);
    } else {
        NSString *fn;
        for (fn in fileList) {
            int ftid = [[fn substringFromIndex:4] intValue];
            if (ftid) {
                [dictTid2Filename setObject:fn forKey:[NSNumber numberWithInt:ftid]];
                NSNumber *ftidNdx = [dictTid2Ndx objectForKey:[NSNumber numberWithInt:ftid]];
                if (ftidNdx) {
                    DBGLog(@"%@ iv: %d toplevel: %@",fn, ftid, [s1 objectAtIndex:[ftidNdx unsignedIntegerValue]]);
                } else {
                    BOOL doDel=YES;
                    if (doDel) {
                        DBGLog(@"deleting orphan %d file %@",ftid,fn);
                        [rTracker_resource deleteFileAtPath:[rTracker_resource ioFilePath:fn access:DBACCESS]];
                    } else {
                        trackerObj *to = [[trackerObj alloc]init:ftid];
                        DBGLog(@"%@ iv: %d orphan file: %@",fn, ftid, to.trackerName );
                        [to release];
                    }
                }
            
            } else if ([fn hasPrefix:@"stash_trkr"]) {
                DBGLog(@"deleting stashed tracker %@",fn);
                [rTracker_resource deleteFileAtPath:[rTracker_resource ioFilePath:fn access:DBACCESS]];
            }
        }
        NSNumber *tlTid;
        i=0;
        for (tlTid in i1) {
            NSString *tltidFilename = [dictTid2Filename objectForKey:tlTid];
            if (tltidFilename) {
                DBGLog(@"tid %@ name %@ file %@",tlTid,[s1 objectAtIndex:i],tltidFilename);
            } else {
                NSString *tname = [s1 objectAtIndex:i];
                DBGLog(@"tid %@ name %@ no file found",tlTid,tname);
                self.tlist.sql = [NSString stringWithFormat:@"delete from toplevel where id=%@ and name='%@'",tlTid, tname];
                [self.tlist toExecSql];
            }
            i++;
        }
    }
    
    [i1 release];
    [s1 release];
    [dictTid2Ndx release];
    [dictTid2Filename release];
    self.tlist.sql = nil;
}

#endif

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	self.title = @"Edit trackers";
    
#if RELEASE
	UIBarButtonItem *exportBtn = [[UIBarButtonItem alloc]
								  initWithTitle:@"Export all"
								  style:UIBarButtonItemStyleBordered
								  target:self
								  action:@selector(btnExport)];
#else
    // wipe orphans
	UIBarButtonItem *exportBtn = [[UIBarButtonItem alloc]
								  initWithTitle:@"wipe orphans"
								  style:UIBarButtonItemStyleBordered
								  target:self
								  action:@selector(btnWipeOrphans)];

#endif
    
	//NSArray *tbArray = [NSArray arrayWithObjects: exportBtn, nil];
	//self.toolbarItems = tbArray;
    [self.navigationItem setRightBarButtonItem:exportBtn animated:NO];
	[exportBtn release];
	    
	[super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
	DBGLog(@"configTlistController view didunload");
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	self.title = nil;
	self.tlist = nil;
	self.table = nil;
	self.toolbarItems = nil;

	[super viewDidLoad];
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	DBGLog(@"ctlc: viewWillAppear");
	
	[self.table reloadData];
	selSegNdx=SegmentEdit;  // because mode select starts with default 'modify' selected
	
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	DBGLog(@"ctlc: viewWillDisappear");

	//self.tlist = nil;
	
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark button press action methods


- (IBAction) modeChoice:(id)sender {

	switch (selSegNdx = [sender selectedSegmentIndex]) {
		case SegmentEdit :
			//DBGLog(@"ctlc: set edit mode");
			[self.table setEditing:NO animated:YES];
			break;
		case SegmentCopy :
			//DBGLog(@"ctlc: set copy mode");
			[self.table setEditing:NO animated:YES];
			break;
		case SegmentMoveDelete :
			//DBGLog(@"ctlc: set move/delete mode");
			[self.table setEditing:YES animated:YES];
			break;
		default:
			dbgNSAssert(0,@"ctlc: segment index not handled");
			break;
	}
			
			
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void) delTracker
{
	NSUInteger row = [deleteIndexPath row];
	DBGLog(@"checkTrackerDelete: will delete row %d ",row);
	[self.tlist deleteTrackerAllRow:row];
	[deleteTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deleteIndexPath] 
						   withRowAnimation:UITableViewRowAnimationFade];		
	[self.tlist reloadFromTLT];	
}

- (void) delTrackerRecords {
	NSUInteger row = [deleteIndexPath row];
	DBGLog(@"checkTrackerDelete: will delete records only for row %d ",row);
	[self.tlist deleteTrackerRecordsRow:row];
	[self.tlist reloadFromTLT];	
}

- (void)actionSheet:(UIActionSheet *)checkTrackerDelete clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	//DBGLog(@"checkTrackerDelete buttonIndex= %d",buttonIndex);
	
	if (buttonIndex == checkTrackerDelete.destructiveButtonIndex) {
		[self delTracker];
	} else if (buttonIndex == checkTrackerDelete.cancelButtonIndex) {
		DBGLog(@"cancelled tracker delete");
	} else {
        [self delTrackerRecords];
    }

    [deleteIndexPath release];
    [deleteTableView release];
	
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [self.tlist.topLayoutNames objectAtIndex:row];
	
    return cell;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *) fromIndexPath 
	  toIndexPath:(NSIndexPath *) toIndexPath {
    
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];
	
	DBGLog(@"ctlc: move row from %d to %d",fromRow, toRow);
	[self.tlist reorderTLT :fromRow toRow:toRow];
	[self.tlist reorderFromTLT];
	
}
					 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
	deleteIndexPath = [indexPath retain];
    deleteTableView = [tableView retain];
	
    NSString *acTitle;
    NSString *tname = [self.tlist.topLayoutNames objectAtIndex:[indexPath row]];
    
	int toid = [self.tlist getTIDfromIndex:[indexPath row]];
	trackerObj *to = [[trackerObj alloc] init:toid];
	int entries = [to countEntries];
    [to release];
    NSString *delRecTitle;
    if (entries==0) {
        acTitle = [NSString stringWithFormat:@"Tracker %@ has no records.",tname];
        delRecTitle=nil;
    } else {
        delRecTitle = @"Remove records only";
        if (entries==1) 
            acTitle = [NSString stringWithFormat:@"Tracker %@ has 1 record.",tname];
        else 
            acTitle = [NSString stringWithFormat:@"Tracker %@ has %d records.",tname,entries];
	}
    
    UIActionSheet *checkTrackerDelete = [[UIActionSheet alloc] 
                                         initWithTitle:acTitle
                                         delegate:self 
                                         cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Delete tracker"
                                         otherButtonTitles:delRecTitle,nil];
		[checkTrackerDelete showFromToolbar:self.navigationController.toolbar ];
		[checkTrackerDelete release];
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
		int toid = [self.tlist getTIDfromIndex:row];
		DBGLog(@"will config toid %d",toid);
		
		addTrackerController *atc = [[addTrackerController alloc] initWithNibName:@"addTrackerController" bundle:nil ];
		atc.tlist = self.tlist;
        trackerObj *tto = [[trackerObj alloc] init:toid];
		atc.tempTrackerObj = tto;
        [tto release];
	
		[self.navigationController pushViewController:atc animated:YES];
        //[atc.tempTrackerObj release]; // rtm 05 feb 2012 +1 alloc/init, +1 atc.temptto retain 
		[atc release];
	} else if (selSegNdx == SegmentCopy) {
		int toid = [self.tlist getTIDfromIndex:row];
		DBGLog(@"will copy toid %d",toid);

		trackerObj *oTO = [[trackerObj alloc] init:toid];
		trackerObj *nTO = [self.tlist copyToConfig:oTO];
		[self.tlist addToTopLayoutTable:nTO];
        //[self.tlist confirmTopLayoutEntry:nTO];
		[oTO release];
		[nTO release];
		//[self.tlist loadTopLayoutTable];
		[self.table reloadData];

	} else if (selSegNdx == SegmentMoveDelete) {
		DBGWarn(@"selected for move/delete?");
	}
}
@end
