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

//@synthesize toolbar;

@synthesize graphTypes;

CGSize sizeVOTLabel;
CGSize sizeGTLabel;

#define FONTSIZE 20.0f
//#define FONTSIZE [UIFont labelFontSize]


#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	NSLog(@"avoc dealloc");
	self.votPicker = nil;
	[votPicker release];
	self.labelField = nil;
	[labelField release];
	self.tempValObj = nil;
	[tempValObj release];
	self.graphTypes = nil;
	[graphTypes release];
	self.parentTrackerObj = nil;
	[parentTrackerObj release];
	
    [super dealloc];
}


# pragma mark -
# pragma mark utility routines

+(CGSize) maxLabelFromArray:(const NSArray *)arr 
{
	CGSize rsize = {0.0f, 0.0f};
	//NSEnumerator *e = [arr objectEnumerator];
	//NSString *s;
	//while ( s = (NSString *) [e nextObject]) {
	for (NSString *s in arr) {
		CGSize tsize = [s sizeWithFont:[UIFont systemFontOfSize:FONTSIZE]];
		if (tsize.width > rsize.width) {
			rsize = tsize;
		}
	}
	
	return rsize;
}

# pragma mark -
# pragma mark view support

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

	self.toolbarItems = [NSArray arrayWithObjects: configBtn, nil];
	[configBtn release];
		
	sizeVOTLabel = [addValObjController maxLabelFromArray:parentTrackerObj.votArray];
	NSArray *allGraphs = [valueObj graphsForVOTCopy:-1];
	sizeGTLabel = [addValObjController maxLabelFromArray:allGraphs];
	
	
	if (self.tempValObj == nil) {
		tempValObj = [[valueObj alloc] init];
		//self.tempValObj = [[valueObj alloc] init];
		self.graphTypes = nil;
		graphTypes = [valueObj graphsForVOTCopy:VOT_NUMBER];
		//self.graphTypes = [valueObj graphsForVOTCopy:VOT_NUMBER];
		//[tempValObj release];
		//[graphTypes release];
	} else {
		self.labelField.text = self.tempValObj.valueName;
		[self.votPicker selectRow:self.tempValObj.vtype inComponent:0 animated:NO];
		[self.votPicker selectRow:self.tempValObj.vcolor inComponent:1 animated:NO];
		
		NSString *g = [allGraphs objectAtIndex:self.tempValObj.vGraphType];
		self.graphTypes = nil;
		graphTypes = [valueObj graphsForVOTCopy:tempValObj.vtype];
		//self.graphTypes = [valueObj graphsForVOTCopy:tempValObj.vtype];
		//[graphTypes release];
		
		//NSEnumerator *e = [self.graphTypes objectEnumerator];
		//NSString *s;
		NSInteger row=0;
		//while ( s = (NSString *) [e nextObject]) {
		for (NSString *s in self.graphTypes) {
			if ([g isEqual:s])
				break;
			row++;
		}

		[self.votPicker reloadComponent:2];
		[self.votPicker selectRow:row inComponent:2 animated:NO];
	}

	[allGraphs release];
	
	
	self.title = @"value";
	
	self.labelField.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
	self.labelField.clearsOnBeginEditing = NO;
	[self.labelField setDelegate:self];
	self.labelField.returnKeyType = UIReturnKeyDone;
	[self.labelField addTarget:self
				  action:@selector(labelFieldDone:)
		forControlEvents:UIControlEventEditingDidEndOnExit];
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.

	parentTrackerObj.colorSet = nil;
	parentTrackerObj.votArray = nil;
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	NSLog(@"avoc didUnload");
	
	self.votPicker = nil;
	self.labelField = nil;
	self.tempValObj = nil;
	self.graphTypes = nil;
	self.parentTrackerObj = nil;

	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[self setToolbarItems:nil
				 animated:NO];
	self.title = nil;
	
	[super viewDidUnload];
}


#pragma mark -
#pragma mark button press action methods

- (IBAction)btnCancel {
	NSLog(@"addVObjC: btnCancel was pressed!");
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSave {
	NSLog(@"addVObjC: btnSave was pressed!");
	self.tempValObj.valueName = self.labelField.text;  // in case neglected to 'done' keyboard
	
	NSUInteger row = [self.votPicker selectedRowInComponent:0];
	self.tempValObj.vtype = row;  // works because vtype defs are same order as rt-types.plist entries
	row = [self.votPicker selectedRowInComponent:1];
	self.tempValObj.vcolor = row; // works because vColor defs are same order as trackerObj.colorSet creator 
	row = [self.votPicker selectedRowInComponent:2];
	self.tempValObj.vGraphType = [valueObj mapGraphType:[self.graphTypes objectAtIndex:row]];
	
	if (self.tempValObj.vid == 0) {
		self.tempValObj.vid = [self.parentTrackerObj getUnique];
	}
	
	NSString *selected = [self.parentTrackerObj.votArray objectAtIndex:row];
	NSLog(@"label: %@ id: %d row: %d = %@",self.tempValObj.valueName,self.tempValObj.vid, row,selected);
	
	[self.parentTrackerObj addValObj:tempValObj];
	
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
	self.tempValObj.valueName = self.labelField.text;
}


#pragma mark -
#pragma mark Picker Data Source Methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
	switch (component) {
		case 0:
			return [self.parentTrackerObj.votArray count];
			break;
		case 1:
			return [self.parentTrackerObj.colorSet count];
			break;
		case 2:
			return [self.graphTypes count];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return 0;
			break;
	}
}

#pragma mark Picker Delegate Methods

#define TEXTPICKER 0
#if TEXTPICKER

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component {
	switch (component) {
		case 0:
			return [self.parentTrackerObj.votArray objectAtIndex:row];
			break;
		case 1:
			//return [self.paretntTrackerObj.colorSet objectAtIndex:row];
			return @"color";
			break;
		case 2:
			return [self.graphTypes objectAtIndex:row];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return @"boo.";
			break;
	}
}

#else 

#define COLORSIDE FONTSIZE

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel *label;
	CGRect frame;
	
	
	switch (component) {
		case 0:
			frame.size = sizeVOTLabel;
			frame.size.width += FONTSIZE;
			//CGFloat lfs = [UIFont labelFontSize]; // 17
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
			label.backgroundColor = [UIColor clearColor] ; //]greenColor];
			label.text = [self.parentTrackerObj.votArray objectAtIndex:row];
			label.font = [UIFont boldSystemFontOfSize:FONTSIZE];
			break;
		case 1:
			frame.size.height = 1.2*COLORSIDE;
			frame.size.width = 2.0*COLORSIDE;
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
			//label = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			//[label retain];
			//label.frame = frame;
			label.backgroundColor = [self.parentTrackerObj.colorSet objectAtIndex:row];
			break;
		case 2:
			frame.size = sizeGTLabel;
			frame.size.width += FONTSIZE;
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
									  label.backgroundColor = [UIColor clearColor]; //greenColor];
			label.text = [self.graphTypes objectAtIndex:row];
			label.font = [UIFont boldSystemFontOfSize:FONTSIZE];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			break;
	}
	[label autorelease];
	return label;
	
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	//CGSize siz;
	switch (component) {
		case 0:
			return sizeVOTLabel.width + (2.0f * FONTSIZE);
			break;
		case 1:
			return 3.0f * COLORSIDE;
			break;
		case 2:
			return sizeGTLabel.width + (2.0f * FONTSIZE);
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			return 0.0f;
			break;
	}
}

#endif

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		self.graphTypes = nil;
		graphTypes = [valueObj graphsForVOTCopy:row];
		//self.graphTypes = [valueObj graphsForVOTCopy:row];
		//[graphTypes release];
		
		[self.votPicker reloadComponent:2];
	}
}


@end
