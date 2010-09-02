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
		[table setEditing:YES animated:YES];
	} else {
		[table setEditing:NO animated:YES];
	}
}

# pragma mark -
# pragma mark view support


- (void) viewDidLoad {
	self.title = @"add tracker";

	NSLog(@"atc: vdl tlist dbname= %@",tlist.dbName);
	
	// cancel / save buttons on top nav bar
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
							   initWithTitle:@"Cancel"
							   style:UIBarButtonItemStyleBordered
							   target:self
							   action:@selector(btnCancel)];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	[cancelBtn release];
	
	UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]
							   initWithTitle:@"Save"
							   style:UIBarButtonItemStyleBordered
							   target:self
							   action:@selector(btnSave)];
	self.navigationItem.rightBarButtonItem = saveBtn;
	[saveBtn release];

	// list manage / configure segmented control on bottom toolbar
	[self configureToolbarItems];
	
	if (! tempTrackerObj) {
		// the temporary tracker obj we work with
		tempTrackerObj = [trackerObj alloc];
		//tempTrackerObj.trackerName = @"";
		[tempTrackerObj init];
		tempTrackerObj.toid = [tlist getUnique];
	}
	[table setEditing:YES animated:YES];
	//[table allowsSelectionDuringEditing:YES];  // not there hmmmmmm
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	
	NSLog(@"atc: viewWillAppear, valObjTable count= %d", [tempTrackerObj.valObjTable count]);
	
	[table reloadData];
	
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	//NSLog(@"atc: viewWillDisappear, namefield= %@",nameField.text);
	NSLog(@"atc: viewWillDisappear, tracker name = %@",tempTrackerObj.trackerName);
	
	[super viewWillDisappear:animated];
}



- (void) viewDidUnload {
	NSLog(@"atc: viewdidunload");
	nameField = nil;
	tlist = nil;
	[super viewDidUnload];
}

- (void) dealloc {
	NSLog(@"atc: dealloc");
	[tempTrackerObj release];
	[tlist release];
	
	//tlist = nil;

	[super dealloc];
}

/*
- (IBAction) textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
	tlist.tObj = [trackerObj alloc];
	tlist.tObj.trackerName = nameField.text;
	[tlist.tObj init];
}
*/

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

	if ([nameField.text length] > 0) {
		tempTrackerObj.trackerName = nameField.text;
		if (! tempTrackerObj.toid) {
			tempTrackerObj.toid = [tlist getUnique];
		}
		[tempTrackerObj saveConfig];
		[tlist confirmTopLayoutEntry:tempTrackerObj];
		[tlist loadTopLayoutTable];
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
	tempTrackerObj.trackerName = nameField.text;
}

# pragma mark -
# pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return (NSInteger) 1;
	} else {
		return [tempTrackerObj.valObjTable count] +1;
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

			nameField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,175,25) ];
			//nameField = [[[UITextField alloc] init ];
			nameField.clearsOnBeginEditing = NO;
			[nameField setDelegate:self];
			nameField.returnKeyType = UIReturnKeyDone;
			[nameField addTarget:self
						  action:@selector(nameFieldDone:)
				forControlEvents:UIControlEventEditingDidEndOnExit];
			[cell.contentView addSubview:nameField];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		nameField.text = tempTrackerObj.trackerName;
		nameField.placeholder = @"Tracker Name";
		
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
		if (row == [tempTrackerObj.valObjTable count] ) {
			cell.detailTextLabel.text = @"add value";
		} else {
			valueObj *vo = [tempTrackerObj.valObjTable objectAtIndex:row];
			cell.textLabel.text = vo.valueName;
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.detailTextLabel.text = [vo.votArray objectAtIndex:vo.vtype];
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
	if (row >= [tempTrackerObj.valObjTable count]) {
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
		if (row >= [tempTrackerObj.valObjTable count]) {
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
		avc.parentTrackerObj = tempTrackerObj;
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
	avc.parentTrackerObj = tempTrackerObj;
	avc.tempValObj = [tempTrackerObj.valObjTable objectAtIndex:row];
	
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
