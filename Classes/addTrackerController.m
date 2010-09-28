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

@implementation addTrackerController 

@synthesize nameField;
@synthesize tlist;
@synthesize tempTrackerObj;
@synthesize table;

#pragma mark -
#pragma mark core object methods and support

- (void) dealloc {
	NSLog(@"atc: dealloc");
	self.nameField = nil;
	[nameField release];
	self.tempTrackerObj = nil;
	[tempTrackerObj release];
	self.tlist = nil;
	[tlist release];
	self.table = nil;
	[table release];
	
	[super dealloc];
}

# pragma mark -
# pragma mark view support


- (void) viewDidLoad {

	NSLog(@"atc: vdl tlist dbname= %@",tlist.dbName);
	
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
	
	NSLog(@"atc: viewWillAppear, valObjTable count= %d", [tempTrackerObj.valObjTable count]);
	
	[self.table reloadData];
	
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	//NSLog(@"atc: viewWillDisappear, namefield= %@",nameField.text);
	NSLog(@"atc: viewWillDisappear, tracker name = %@",self.tempTrackerObj.trackerName);
	
	[super viewWillDisappear:animated];
}



- (void) viewDidUnload {
	NSLog(@"atc: viewdidunload");
	self.nameField = nil;
	self.tlist = nil;
	self.tempTrackerObj = nil;
	self.table = nil;
	
	self.title = nil;
	
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[self setToolbarItems:nil
				 animated:NO];
		
	[super viewDidUnload];
}

# pragma mark -
# pragma mark toolbar support

static int editMode;

- (void)configureToolbarItems {
	UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
												initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
												target:nil action:nil];
	
	// Create and configure the segmented control
	UISegmentedControl *editToggle = [[UISegmentedControl alloc]
									  initWithItems:[NSArray arrayWithObjects:@"Manage Tracker",
													 @"Configure Values", nil]];
	editToggle.segmentedControlStyle = UISegmentedControlStyleBar;
	editToggle.selectedSegmentIndex = 0;
	editMode = 0;
	[editToggle addTarget:self action:@selector(toggleEdit:)
		 forControlEvents:UIControlEventValueChanged];
	
	// Create the bar button item for the segmented control
	UIBarButtonItem *editToggleButtonItem = [[UIBarButtonItem alloc]
											 initWithCustomView:editToggle];
	[editToggle release];
	
	// Set our toolbar items
	self.toolbarItems = [NSArray arrayWithObjects:
                         flexibleSpaceButtonItem,
                         editToggleButtonItem,
                         flexibleSpaceButtonItem,
                         nil];
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

- (IBAction)btnAddValue {
NSLog(@"btnAddValue was pressed!");
}

- (IBAction)btnCancel {
	NSLog(@"btnCancel was pressed!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSave {
	NSLog(@"btnSave was pressed! tempTrackerObj name= %@ toid= %d tlist= %x",tempTrackerObj.trackerName, tempTrackerObj.toid, tlist);

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
# pragma mark nameField support Methods

- (IBAction) nameFieldDone:(id)sender {
	[sender resignFirstResponder];
	self.tempTrackerObj.trackerName = nameField.text;
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

			self.nameField = nil;
			nameField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,175,25) ];
			//self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,175,25) ];
			//[self.nameField release];
			self.nameField.clearsOnBeginEditing = NO;
			[self.nameField setDelegate:self];
			self.nameField.returnKeyType = UIReturnKeyDone;
			[self.nameField addTarget:self
						  action:@selector(nameFieldDone:)
				forControlEvents:UIControlEventEditingDidEndOnExit];
			[cell.contentView addSubview:nameField];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		self.nameField.text = self.tempTrackerObj.trackerName;

		self.nameField.placeholder = @"Tracker Name";
		
		/*
		if (tempTrackerObj.trackerName == @"") {
		} else {
		}
		*/
		
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
	
	NSUInteger fromSection = [fromIndexPath section];
	NSUInteger toSection = [toIndexPath section];
	
	NSLog(@"atc: move row from %d:%d to %d:%d",fromSection, fromRow, toSection, toRow);
	
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
		NSLog(@"atc: delete row %d ",row);
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		NSLog(@"atc: insert row %d ",row);

		addValObjController *avc = [[addValObjController alloc] initWithNibName:@"addValObjController" bundle:nil ];
		avc.parentTrackerObj = self.tempTrackerObj;
		[self.navigationController pushViewController:avc animated:YES];
		[avc release];
		
		
	} // else ??
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	

	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	
	NSLog(@"selected section %d row %d ", section, row);

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {


	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	
	NSLog(@"accessory button tapped for section %d row %d ", section, row);

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
