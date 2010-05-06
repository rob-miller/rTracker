//
//  addTrackerController.m
//  rTracker
//
//  Created by Robert Miller on 15/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "addTrackerController.h"
#import "trackerList.h"

@implementation addTrackerController 

@synthesize nameField;
@synthesize tlist;

- (void) viewDidLoad {
	self.title = @"add tracker";
	// here: alloc trackerobj with name? don't have name yet...
	
	UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]
							   initWithTitle:@"+"
							   style:UIBarButtonItemStyleBordered
							   target:self
							   action:@selector(btnAddValue)];
	self.navigationItem.rightBarButtonItem = addBtn;
	[addBtn release];

	[super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"atc: viewWillDisappear, namefield= %@",nameField.text);
	if ([nameField.text length] > 0) {
		[self.tlist addTopLayoutEntry:10000 name:nameField.text];
	}
	self.tlist = nil;
	
	[super viewWillDisappear:animated];
}



- (void) viewDidUnload {
	NSLog(@"atc: viewdidunload");
	self.nameField = nil;
	self.tlist = nil;
	[super viewDidUnload];
}

- (void) dealloc {
	NSLog(@"atc: dealloc");
	self.nameField = nil;
	self.tlist = nil;
	[nameField release];
	[super dealloc];
}

- (IBAction) textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

//- (IBAction) backgroundTap:(id)sender {
//	[nameField resignFirstResponder];
//}

- (IBAction)btnAddValue {
NSLog(@"btnAddValue was pressed!");
}

# pragma mark -
# pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (NSInteger) 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	static NSString *SimpleTableID = @"SimpleTableID";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableID];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier: SimpleTableID] 
				autorelease];
	}
	
	cell.textLabel.text = @"cell label text"; // yes working here...
	
	return cell;
}

@end
