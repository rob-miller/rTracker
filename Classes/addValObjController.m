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

@synthesize tempValObj;
@synthesize parentTrackerObj;

@synthesize toolbar;

@synthesize graphTypes;

CGSize sizeVOTLabel;
CGSize sizeGTLabel;

+(CGSize) maxLabelFromArray:(const NSArray *)arr 
{
	CGSize rsize = {0.0f, 0.0f};
	NSEnumerator *e = [arr objectEnumerator];
	NSString *s;
	while ( s = (NSString *) [e nextObject]) {
		CGSize tsize = [s sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
		if (tsize.width > rsize.width) {
			rsize = tsize;
		}
	}
	
	return rsize;
}
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

	
	UIBarButtonItem *configBtn = [[UIBarButtonItem alloc]
								initWithTitle:@"Configure"
								style:UIBarButtonItemStyleBordered
								target:self
								action:@selector(btnConfigure)];
	//self.toolbarItem.leftBarButtonItem = configBtn;

	self.toolbarItems = [NSArray arrayWithObjects: configBtn, nil];
	[configBtn release];
		
	
	if (tempValObj == nil) {
		tempValObj = [[valueObj alloc] init];
		graphTypes = [valueObj graphsForVOTCopy:VOT_NUMBER];
		//[graphTypes retain];
	} else {
		self.labelField.text = self.tempValObj.valueName;
		[self.votPicker selectRow:self.tempValObj.vtype inComponent:0 animated:NO];
		[self.votPicker selectRow:self.tempValObj.vcolor inComponent:1 animated:NO];
		
		[graphTypes release];
		graphTypes = [valueObj graphsForVOTCopy:-1];
		NSString *g = [graphTypes objectAtIndex:self.tempValObj.vGraphType];
		//[g retain];
		[graphTypes release];
		graphTypes = [valueObj graphsForVOTCopy:tempValObj.vtype];
		//[graphTypes retain];
		
		NSEnumerator *e = [graphTypes objectEnumerator];
		NSString *s;
		NSInteger row=0;
		while ( s = (NSString *) [e nextObject]) {
			if ([g isEqual:s])
				break;
			row++;
		}
		//[g release];
		[self.votPicker reloadComponent:2];
		
		[self.votPicker selectRow:row inComponent:2 animated:NO];
		
		
	}

	
	sizeVOTLabel = [addValObjController maxLabelFromArray:parentTrackerObj.votArray];
	NSArray *allGraphs = [valueObj graphsForVOTCopy:-1];
	sizeGTLabel = [addValObjController maxLabelFromArray:allGraphs];
	[allGraphs release];
	
	
	self.title = @"value";
	

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
	self.labelField = nil;
	self.tempValObj = nil;
	
	[super viewDidUnload];
}


- (void)dealloc {
	NSLog(@"avoc dealloc");
	[votPicker release];
	[labelField release];
	[tempValObj release];
	[graphTypes release];
    [super dealloc];
}



- (IBAction)btnCancel {
	NSLog(@"addVObjC: btnCancel was pressed!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSave {
	NSLog(@"addVObjC: btnSave was pressed!");
	tempValObj.valueName = labelField.text;  // in case neglected to 'done' keyboard
	
	NSUInteger row = [votPicker selectedRowInComponent:0];
	tempValObj.vtype = row;  // works because vtype defs are same order as rt-types.plist entries
	row = [votPicker selectedRowInComponent:1];
	tempValObj.vcolor = row; // works because vColor defs are same order as trackerObj.colorSet creator 
	row = [votPicker selectedRowInComponent:2];
	tempValObj.vGraphType = [valueObj mapGraphType:[graphTypes objectAtIndex:row]];
	
	if (tempValObj.vid == 0) {
		tempValObj.vid = [parentTrackerObj getUnique];
	}
	
	NSString *selected = [parentTrackerObj.votArray objectAtIndex:row];
	NSLog(@"label: %@ id: %d row: %d = %@",tempValObj.valueName,tempValObj.vid, row,selected);
	
	[parentTrackerObj addValObj:tempValObj];
	
	[self.navigationController popViewControllerAnimated:YES];
	//[parent.tableView reloadData];
}

- (IBAction)btnConfigure {
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
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
	switch (component) {
		case 0:
			return [parentTrackerObj.votArray count];
			break;
		case 1:
			return [parentTrackerObj.colorSet count];
			break;
		case 2:
			return [graphTypes count];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return 0;
			break;
	}
}

#pragma mark Picker Delegate Methods
/*
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component {
	switch (component) {
		case 0:
			return [parentTrackerObj.votArray objectAtIndex:row];
			break;
		case 1:
			//return [paretntTrackerObj.colorSet objectAtIndex:row];
			return @"color";
			break;
		case 2:
			return [graphTypes objectAtIndex:row];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return @"boo.";
			break;
	}
}
*/
#define COLORSIDE 18.0f
///*

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel *label;
	CGRect frame;
	
	
	switch (component) {
		case 0:
			frame.size = sizeVOTLabel;
			frame.size.width += 2*[UIFont systemFontSize];
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
			label.backgroundColor = [UIColor clearColor];
			label.text = [parentTrackerObj.votArray objectAtIndex:row];
			label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
			break;
		case 1:
			frame.size.height = COLORSIDE;
			frame.size.width = COLORSIDE;
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UIView alloc] initWithFrame:frame];
			label.backgroundColor = [parentTrackerObj.colorSet objectAtIndex:row];
			break;
		case 2:
			frame.size = sizeGTLabel;
			frame.size.width += 2*[UIFont systemFontSize];
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
			label.backgroundColor = [UIColor clearColor];
			label.text = [graphTypes objectAtIndex:row];
			label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			label.text = @"boo!";
			break;
	}
	[label autorelease];
	return label;
	
}
//*/

/*
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return COLORSIDE;
}
 */


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	//CGSize siz;
	switch (component) {
		case 0:
			return sizeVOTLabel.width + (4.0f * [UIFont systemFontSize]);
			break;
		case 1:
			return 2.0f * COLORSIDE;
			break;
		case 2:
			return sizeGTLabel.width + (4.0f * [UIFont systemFontSize]);
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return 0.0f;
			break;
	}
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		[graphTypes release];
		//graphTypes = nil;
		graphTypes = [valueObj graphsForVOTCopy:row];
		//[graphTypes retain];
		[self.votPicker reloadComponent:2];
	}
}


@end
