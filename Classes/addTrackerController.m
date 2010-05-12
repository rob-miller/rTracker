//
//  addTrackerController.m
//  rTracker
//
//  Created by Robert Miller on 15/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "addTrackerController.h"
#import "valueObj.h"

@implementation addTrackerController 

@synthesize nameField;
@synthesize tlist;
@synthesize tempTrackerObj;
@synthesize table;


- (void) viewDidLoad {
	self.title = @"add tracker";
	// here: alloc trackerobj with name? don't have name yet...
	
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

	tempTrackerObj = [trackerObj alloc];
	tempTrackerObj.trackerName = @"";
	[tempTrackerObj init];
	
	[table setEditing:YES animated:YES];
	//[table allowsSelectionDuringEditing:YES];  // not there hmmmmmm
	
	[super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated {
	//NSLog(@"atc: viewWillDisappear, namefield= %@",nameField.text);
	NSLog(@"atc: viewWillDisappear, tracker name = %@",tempTrackerObj.trackerName);
	tlist = nil;
	
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

//- (IBAction) backgroundTap:(id)sender {
//	[nameField resignFirstResponder];
//}

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
	NSLog(@"btnSave was pressed! temp= %@",tempTrackerObj.trackerName);

	/*
	if ([nameField.text length] > 0) {
		[tlist addTopLayoutEntry:10000 name:tlist.tObj.trackerName];
	}
	*/
	
	
	[self.navigationController popViewControllerAnimated:YES];
	//[parent.tableView reloadData];
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
	if (section == 1) {
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

			nameField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,75,25) ];
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
		nameField.placeholder = @"Name";
		
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
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		return NO;
	}
	
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

@end
