//
//  addTrackerController.m
//  rTracker
//
//  Created by Robert Miller on 15/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "addTrackerController.h"
#import "valueObj.h"
#import "addValObjController.h"
#import "configTVObjVC.h"
#import "rTracker-constants.h"

#import "dbg-defs.h"

@implementation addTrackerController 

@synthesize tlist;
@synthesize tempTrackerObj;
@synthesize table;
@synthesize nameField;

NSIndexPath *deleteIndexPath; // remember row to delete if user confirms in checkTrackerDelete alert
UITableView *deleteTableView;
NSMutableArray *deleteVOs=nil;

#pragma mark -
#pragma mark core object methods and support

- (void) dealloc {
	DBGLog(@"atc: dealloc");
	self.nameField = nil;
	[nameField release];
	self.tempTrackerObj = nil;
	[tempTrackerObj release];
	self.tlist = nil;
	[tlist release];
	self.table = nil;
	[table release];

	if (deleteVOs != nil) {
		[deleteVOs release];
		deleteVOs = nil;
	}
	
	[super dealloc];
}

# pragma mark -
# pragma mark view support


- (void) viewDidLoad {

	DBGLog1(@"atc: vdl tlist dbname= %@",tlist.dbName);
	
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

	// list manage / configure segmented control on bottom toolbar
	[self configureToolbarItems];
	
	if (! self.tempTrackerObj) {
		// the temporary tracker obj we work with
		self.tempTrackerObj = [trackerObj alloc];
		//tempTrackerObj.trackerName = @"";
		[self.tempTrackerObj init];
		self.tempTrackerObj.toid = [tlist getUnique];
		[tempTrackerObj release];
		self.title = @"add tracker";
	} else {
			self.title = @"modify tracker";
	}
	
	[self.table setEditing:YES animated:YES];
	self.table.allowsSelection = NO;  
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	
	DBGLog1(@"atc: viewWillAppear, valObjTable count= %d", [tempTrackerObj.valObjTable count]);
	
	[self.table reloadData];
	if (self.navigationController.toolbarHidden)
		[self.navigationController setToolbarHidden:NO animated:YES];
	
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	
	tempTrackerObj.colorSet = nil;
	tempTrackerObj.votArray = nil;
	
}

- (void)viewWillDisappear:(BOOL)animated {
	DBGLog1(@"atc: viewWillDisappear, tracker name = %@",self.tempTrackerObj.trackerName);
	
	[super viewWillDisappear:animated];
}



- (void) viewDidUnload {
	DBGLog(@"atc: viewdidunload");
	self.nameField = nil;
	self.tlist = nil;
	self.tempTrackerObj = nil;
	self.table = nil;
	
	self.title = nil;
	
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[self setToolbarItems:nil
				 animated:NO];
	
	if (deleteVOs != nil) {
		[deleteVOs release];
		deleteVOs = nil;
	}
	
	[super viewDidUnload];
}

# pragma mark -
# pragma mark toolbar support

- (void) btnSetup {
	configTVObjVC *ctvovc = [[configTVObjVC alloc] init];
	ctvovc.to = self.tempTrackerObj;
	ctvovc.vo = nil;
	ctvovc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:ctvovc animated:YES];
	//[ctvovc release];
}

static int editMode;

- (void)configureToolbarItems {
	UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
												initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
												target:nil action:nil];
	
	// Create and configure the segmented control
	UISegmentedControl *editToggle = [[UISegmentedControl alloc]
									  initWithItems:[NSArray arrayWithObjects:@"Tracker",
													 @"Values", nil]];
	editToggle.segmentedControlStyle = UISegmentedControlStyleBar;
	editToggle.selectedSegmentIndex = 0;
	editMode = 0;
	[editToggle addTarget:self action:@selector(toggleEdit:)
		 forControlEvents:UIControlEventValueChanged];
	
	// Create the bar button item for the segmented control
	UIBarButtonItem *editToggleButtonItem = [[UIBarButtonItem alloc]
											 initWithCustomView:editToggle];
	[editToggle release];

	UIBarButtonItem *setupBtnItem = [[UIBarButtonItem alloc]
								 initWithTitle:@"Setup"
								 style:UIBarButtonItemStyleBordered
								 target:self
								 action:@selector(btnSetup)];
	
	
	// Set our toolbar items
	self.toolbarItems = [NSArray arrayWithObjects:
                         //flexibleSpaceButtonItem,
						 setupBtnItem,
                         flexibleSpaceButtonItem,
                         editToggleButtonItem,
                         flexibleSpaceButtonItem,
                         nil];
	[setupBtnItem release];
	[flexibleSpaceButtonItem release];
	[editToggleButtonItem release];
}

- (void) toggleEdit:(id) sender {
	editMode = [sender selectedSegmentIndex];
	//[table reloadData];
	if (editMode == 0) {
		[self.table setEditing:YES animated:YES];
	} else {
		[self.table setEditing:NO animated:YES];
	}
	
	//[table reloadRowsAtIndexPaths:[table indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
	
	[self.table reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	
}


# pragma mark -
# pragma mark button press handlers
/*
- (IBAction)btnAddValue {
DBGLog(@"btnAddValue was pressed!");
}
*/
- (IBAction)btnCancel {
	if (deleteVOs != nil) {
		[deleteVOs release];
		deleteVOs = nil;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) delVOdb:(NSInteger)vid 
{
	self.tempTrackerObj.sql = [NSString stringWithFormat:@"delete from voData where id=%d;",vid];
	[self.tempTrackerObj toExecSql];
	self.tempTrackerObj.sql = [NSString stringWithFormat:@"delete from voConfig where id=%d;",vid];
	[self.tempTrackerObj toExecSql];
}


- (IBAction)btnSave {
	DBGLog3(@"btnSave was pressed! tempTrackerObj name= %@ toid= %d tlist= %x",tempTrackerObj.trackerName, tempTrackerObj.toid, (unsigned int) tlist);

	if (deleteVOs != nil) {
		for (valueObj *vo in deleteVOs) {
			[self delVOdb:vo.vid];
		}
		[deleteVOs release];
		deleteVOs = nil;
	}
	
	if ([self.nameField.text length] > 0) {
		self.tempTrackerObj.trackerName = self.nameField.text;
		if (! self.tempTrackerObj.toid) {
			self.tempTrackerObj.toid = [self.tlist getUnique];
		}
		[self.tempTrackerObj saveConfig];
		[self.tlist confirmTopLayoutEntry:tempTrackerObj];
		[self.tlist loadTopLayoutTable];
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"save Tracker" message:@"Please set a name for this tracker to save"
							  delegate:nil 
							  cancelButtonTitle:@"Ok"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

# pragma mark -
# pragma mark nameField, privField support Methods

- (IBAction) nameFieldDone:(id)sender {
	[sender resignFirstResponder];
	if (nameField.text) {
		self.tempTrackerObj.trackerName = nameField.text;
		[self.tempTrackerObj.optDict setObject:nameField.text forKey:@"name"];
	}
}

/*
- (IBAction) privFieldDone:(id)sender {
	[sender resignFirstResponder];
	self.tempTrackerObj.privacy = [nameField.text integerValue];
}
*/

#pragma mark -
#pragma mark UIActionSheet methods

- (void) delVOlocal:(NSUInteger) row
{
	[self.tempTrackerObj.valObjTable removeObjectAtIndex:row];
	[deleteTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deleteIndexPath] 
						   withRowAnimation:UITableViewRowAnimationFade];		
}

- (void) addDelVO:(valueObj*)vo {
		if (deleteVOs == nil) {
			deleteVOs = [[NSMutableArray alloc] init];
		}
		[deleteVOs addObject:vo];
}

- (void)actionSheet:(UIActionSheet *)checkValObjDelete clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	//DBGLog1(@"checkValObjDelete buttonIndex= %d",buttonIndex);
	
	if (buttonIndex == checkValObjDelete.destructiveButtonIndex) {
		NSUInteger row = [deleteIndexPath row];
		valueObj *vo = [self.tempTrackerObj.valObjTable objectAtIndex:row];
		DBGLog3(@"checkValObjDelete: will delete row %d name %@ id %d",row, vo.valueName,vo.vid);
		//[self delVOdb:vo.vid];
        [self addDelVO:vo];
		[self delVOlocal:row];
	} else {
		//DBGLog(@"check valobjdelete cancelled");
	}
	
}


# pragma mark -
# pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return (NSInteger) 1;
	} else {
		int rval = [self.tempTrackerObj.valObjTable count];
		if (editMode == 0) {
			rval++;
		}
		return rval;
	}

}

//- (NSInteger)tableView:(UITableView *)tableView numberOfSections: (UITableView *) tableView {
- (NSInteger)numberOfSectionsInTableView: (UITableView *) tableView {
		return (NSInteger) 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	UITableViewCell *cell;
	
	NSUInteger section = [indexPath section];
	
	if (section == 0) {
		static NSString *nameCellID = @"nameCellID";
		cell = [tableView dequeueReusableCellWithIdentifier: nameCellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc]
					 initWithStyle:UITableViewCellStyleDefault
					 reuseIdentifier: nameCellID] 
					autorelease];
		} else {
			// the cell is being recycled, remove old embedded controls
			UIView *viewToRemove = nil;
			while ((viewToRemove = [cell.contentView viewWithTag:kViewTag]))
				[viewToRemove removeFromSuperview];
		}
		
		//NSInteger row = [indexPath row];
		//if (row == 0) {

			self.nameField = nil;
			nameField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,175,25) ];
			self.nameField.clearsOnBeginEditing = NO;
			[self.nameField setDelegate:self];
			self.nameField.returnKeyType = UIReturnKeyDone;
			[self.nameField addTarget:self
						  action:@selector(nameFieldDone:)
				forControlEvents:UIControlEventEditingDidEndOnExit];
			self.nameField.tag = kViewTag;
			[cell.contentView addSubview:nameField];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
			self.nameField.text = self.tempTrackerObj.trackerName;
			self.nameField.placeholder = @"Tracker Name";

//		} else {   // row = 1
//			cell.textLabel.text = @"privacy level:";
//			self.privField = nil;
//			privField = [[UITextField alloc] initWithFrame:CGRectMake(180,10,60,25) ];
//			self.privField.borderStyle = UITextBorderStyleRoundedRect;
//			self.privField.clearsOnBeginEditing = NO;
//			[self.privField setDelegate:self];
//			self.privField.returnKeyType = UIReturnKeyDone;
//			[self.privField addTarget:self
//						  action:@selector(privFieldDone:)
//				forControlEvents:UIControlEventEditingDidEndOnExit];
//			self.privField.tag = kViewTag;
//			[cell.contentView addSubview:privField];
//			
//			cell.selectionStyle = UITableViewCellSelectionStyleNone;
//		
//			self.privField.text = self.tempTrackerObj.trackerName;
//
//			self.privField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
//			self.privField.text = [NSString stringWithFormat:@"%d",self.tempTrackerObj.privacy];
//			self.privField.placeholder = @"num";
//			self.privField.textAlignment = UITextAlignmentRight;
//		}
		
	} else {
		static NSString *valCellID = @"valCellID";
		cell = [tableView dequeueReusableCellWithIdentifier: valCellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc]
					 initWithStyle:UITableViewCellStyleSubtitle
					 reuseIdentifier: valCellID] 
					autorelease];
		}
		NSInteger row = [indexPath row];
		if (row == [self.tempTrackerObj.valObjTable count] ) {
			cell.detailTextLabel.text = @"add value";
			cell.textLabel.text = @"";
		} else {
			valueObj *vo = [self.tempTrackerObj.valObjTable objectAtIndex:row];
			cell.textLabel.text = vo.valueName;
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.detailTextLabel.text = [self.tempTrackerObj.votArray objectAtIndex:vo.vtype];
		}
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [indexPath section];
	if (section == 0) {
		return NO;
	} 
	NSInteger row = [indexPath row];
	if (row >= [self.tempTrackerObj.valObjTable count]) {
		return NO;
	}
	
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *) fromIndexPath 
	  toIndexPath:(NSIndexPath *) toIndexPath {
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];

#if DEBUGLOG	
	NSUInteger fromSection = [fromIndexPath section];
	NSUInteger toSection = [toIndexPath section];
	DBGLog4(@"atc: move row from %d:%d to %d:%d",fromSection, fromRow, toSection, toRow);
#endif
    
	valueObj *vo = [self.tempTrackerObj.valObjTable objectAtIndex:fromRow];
	[vo retain];
	[self.tempTrackerObj.valObjTable removeObjectAtIndex:fromRow];
	if (toRow > [self.tempTrackerObj.valObjTable count])
		toRow = [self.tempTrackerObj.valObjTable count];
	[self.tempTrackerObj.valObjTable insertObject:vo atIndex:toRow];
	[vo release];
	
	// fail [table reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableview editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [indexPath section];
	if (section == 0) {
		return UITableViewCellEditingStyleNone;
	} else {
		NSInteger row = [indexPath row];
		if (row >= [self.tempTrackerObj.valObjTable count]) {
			return UITableViewCellEditingStyleInsert;
		} else {
			return UITableViewCellEditingStyleDelete;
		}
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	// NSUInteger section = [indexPath section];  // in theory this only called on vals section
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		DBGLog1(@"atc: delete row %d ",row);
		deleteIndexPath = indexPath;
		deleteTableView = tableView;
		
		valueObj *vo = [self.tempTrackerObj.valObjTable objectAtIndex:row];
		if ((! self.tempTrackerObj.tDb) // no db created yet for this tempTrackerObj
            || (! self.tempTrackerObj.toid))   // this tempTrackerObj not written to db yet at all
		{ 
            [self delVOlocal:row];
        } else if (! [self.tempTrackerObj voHasData:vo.vid]) {  // no actual values stored in db for this valObj
            [self addDelVO:vo];
            [self delVOlocal:row];
		} else {
			UIActionSheet *checkValObjDelete = [[UIActionSheet alloc] 
												initWithTitle:[NSString stringWithFormat:
															   @"Value %@ has stored data, which will be removed when you 'Save' this page.",
															   vo.valueName]
												delegate:self 
												cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:@"Yes, delete"
												otherButtonTitles:nil];
			//[checkTrackerDelete showInView:self.view];
			[checkValObjDelete showFromToolbar:self.navigationController.toolbar ];
			[checkValObjDelete release];
		}
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		DBGLog1(@"atc: insert row %d ",row);

		addValObjController *avc = [[addValObjController alloc] initWithNibName:@"addValObjController" bundle:nil ];
		avc.parentTrackerObj = self.tempTrackerObj;
		[self.navigationController pushViewController:avc animated:YES];
		[avc release];
		
		
	} // else ??
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	

	//NSUInteger row = [indexPath row];
	//NSUInteger section = [indexPath section];
	
	//DBGLog2(@"selected section %d row %d ", section, row);

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {


	NSUInteger row = [indexPath row];
	//NSUInteger section = [indexPath section];
	
	//DBGLog2(@"accessory button tapped for section %d row %d ", section, row);

	addValObjController *avc = [[addValObjController alloc] initWithNibName:@"addValObjController" bundle:nil ];
	avc.parentTrackerObj = self.tempTrackerObj;
	avc.tempValObj = [self.tempTrackerObj.valObjTable objectAtIndex:row];
	
	[self.navigationController pushViewController:avc animated:YES];
	[avc release];
	
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		return NO;
	}
	
    // Return NO if you do not want the specified item to be editable.
    if (editMode == 0) {
		return YES;
	} else {
		return NO;
	}
}

@end
