//
//  addValObjController.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "addValObjController.h"

@implementation addValObjController

@synthesize labelField;
@synthesize votPicker;
@synthesize votPickerData;
@synthesize tempValObj;
@synthesize parentTrackerObj;

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
	
	self.tempValObj = [[valueObj alloc] init];
	
	self.votPickerData = [valueObj votArray];

	self.labelField.clearsOnBeginEditing = NO;
	[self.labelField setDelegate:self];
	self.labelField.returnKeyType = UIReturnKeyDone;
	[self.labelField addTarget:self
				  action:@selector(labelFieldDone:)
		forControlEvents:UIControlEventEditingDidEndOnExit];
	
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	NSLog(@"avoc didUnload");
	
	self.votPicker = nil;
	self.votPickerData = nil;
	self.labelField = nil;
	self.tempValObj = nil;
	
	[super viewDidUnload];
}


- (void)dealloc {
	NSLog(@"avoc dealloc");
	[votPicker release];
	[votPickerData release];
	[labelField release];
	[tempValObj release];
	
    [super dealloc];
}



- (IBAction)btnCancel {
	NSLog(@"addVObjC: btnCancel was pressed!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSave {
	NSLog(@"addVObjC: btnSave was pressed!");
	
	NSInteger row = [votPicker selectedRowInComponent:0];
	tempValObj.valueType = row;
	
	NSString *selected = [votPickerData objectAtIndex:row];
	NSLog(@"label: %@  row: %d = %@",tempValObj.valueName,row,selected);
	
	[parentTrackerObj addValObj:tempValObj];
	
	[self.navigationController popViewControllerAnimated:YES];
	//[parent.tableView reloadData];
}

- (IBAction)configVOPressed {
	NSLog(@"addVObjC: config was pressed!");
}

# pragma mark -
# pragma mark nameField support Methods

- (IBAction) labelFieldDone:(id)sender {
	[sender resignFirstResponder];
	tempValObj.valueName = labelField.text;
}


#pragma mark -
#pragma mark Picker Data Source Methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
	return [votPickerData count];
}

#pragma mark Picker Delegate Methods

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component {
	return [votPickerData objectAtIndex:row];
}

@end
