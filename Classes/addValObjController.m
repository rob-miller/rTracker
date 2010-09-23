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

#define FONTSIZE 20.0f
//#define FONTSIZE [UIFont labelFontSize]

+(CGSize) maxLabelFromArray:(const NSArray *)arr 
{
	CGSize rsize = {0.0f, 0.0f};
	NSEnumerator *e = [arr objectEnumerator];
	NSString *s;
	while ( s = (NSString *) [e nextObject]) {
		CGSize tsize = [s sizeWithFont:[UIFont systemFontOfSize:FONTSIZE]];
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

	self.toolbarItems = [NSArray arrayWithObjects: configBtn, nil];
	[configBtn release];
		
	sizeVOTLabel = [addValObjController maxLabelFromArray:parentTrackerObj.votArray];
	NSArray *allGraphs = [valueObj graphsForVOTCopy:-1];
	sizeGTLabel = [addValObjController maxLabelFromArray:allGraphs];
	[allGraphs release];
	
	
	if (tempValObj == nil) {
		tempValObj = [[valueObj alloc] init];
		graphTypes = [valueObj graphsForVOTCopy:VOT_NUMBER];
	} else {
		self.labelField.text = self.tempValObj.valueName;
		[self.votPicker selectRow:self.tempValObj.vtype inComponent:0 animated:NO];
		[self.votPicker selectRow:self.tempValObj.vcolor inComponent:1 animated:NO];
		
		[graphTypes release];
		graphTypes = [valueObj graphsForVOTCopy:-1];
		NSString *g = [graphTypes objectAtIndex:self.tempValObj.vGraphType];
		[graphTypes release];
		graphTypes = [valueObj graphsForVOTCopy:tempValObj.vtype];
		
		NSEnumerator *e = [graphTypes objectEnumerator];
		NSString *s;
		NSInteger row=0;
		while ( s = (NSString *) [e nextObject]) {
			if ([g isEqual:s])
				break;
			row++;
		}

		[self.votPicker reloadComponent:2];
		
		[self.votPicker selectRow:row inComponent:2 animated:NO];
		
		
	}

	
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

#define TEXTPICKER 0
#if TEXTPICKER

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
			label.text = [parentTrackerObj.votArray objectAtIndex:row];
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
			label.backgroundColor = [parentTrackerObj.colorSet objectAtIndex:row];
			break;
		case 2:
			frame.size = sizeGTLabel;
			frame.size.width += FONTSIZE;
			frame.origin.x = 0.0f;
			frame.origin.y = 0.0f;
			label = [[UILabel alloc] initWithFrame:frame];
									  label.backgroundColor = [UIColor clearColor]; //greenColor];
			label.text = [graphTypes objectAtIndex:row];
			label.font = [UIFont boldSystemFontOfSize:FONTSIZE];
			break;
		default:
			NSAssert(0,@"bad component for avo picker");
			label.text = @"boo!";
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
		[graphTypes release];
		//graphTypes = nil;
		graphTypes = [valueObj graphsForVOTCopy:row];
		//[graphTypes retain];
		[self.votPicker reloadComponent:2];
	}
}


@end
