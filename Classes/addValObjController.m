//
//  addValObjController.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "addValObjController.h"
#import "configTVObjVC.h"
#import "voState.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

@interface addValObjController() 
@property (nonatomic) NSInteger tmpVtype;
@property (nonatomic) NSInteger tmpVcolor;
@property (nonatomic) NSInteger tmpVGraphType;
@end

@implementation addValObjController

@synthesize tempValObj; // =_tempValObj;
@synthesize parentTrackerObj; // = _parentTrackerObj;
@synthesize graphTypes; // = _graphTypes;

// setting to _foo breaks size calc for picker, think because is iboutlet?
@synthesize labelField;  // = _labelField; 
@synthesize votPicker;  // = _votPicker;

@synthesize tmpVtype = _tmpVtype;
@synthesize tmpVcolor = _tmpVcolor;
@synthesize tmpVGraphType = _tmpVGraphType;

CGSize sizeVOTLabel;
CGSize sizeGTLabel;

NSInteger colorCount;  // count of entries to show in center color picker spinner.


#define FONTSIZE 20.0f
//#define FONTSIZE [UIFont labelFontSize]


#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	DBGLog(@"avoc dealloc");
	
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
# pragma mark view support

//#define SCROLLVIEW_HEIGHT 100
//#define SCROLLVIEW_WIDTH  320

//#define SCROLLVIEW_CONTENT_HEIGHT 720
//#define SCROLLVIEW_CONTENT_WIDTH  320



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


	//[self.navigationController setToolbarHidden:YES animated:YES];
	
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoBtn addTarget:self action:@selector(btnSetup) forControlEvents:UIControlEventTouchUpInside];
    infoBtn.frame = CGRectMake(0, 0, 44, 44);
    UIBarButtonItem *setupBtn = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];

	/*
     UIBarButtonItem *setupBtn = [[UIBarButtonItem alloc]
								initWithTitle:@"Setup"
								style:UIBarButtonItemStyleBordered
								target:self
								action:@selector(btnSetup)];
    */
    
	self.toolbarItems = [NSArray arrayWithObjects: setupBtn, nil];
	[setupBtn release];
	
	
	sizeVOTLabel = [addValObjController maxLabelFromArray:parentTrackerObj.votArray];
	NSArray *allGraphs = [valueObj allGraphs];
	sizeGTLabel = [addValObjController maxLabelFromArray:allGraphs];
	
	colorCount = [[rTracker_resource colorSet] count];

	if (self.tempValObj == nil) {
		tempValObj = [[valueObj alloc] init];
		tempValObj.parentTracker = (id) self.parentTrackerObj;
		self.graphTypes = nil;
		self.graphTypes = [voState voGraphSetNum];  //[valueObj graphsForVOT:VOT_NUMBER];
		//[self updateScrollView:(NSInteger)VOT_NUMBER];
		[self.votPicker selectRow:self.parentTrackerObj.nextColor inComponent:1 animated:NO];
	} else {
		self.labelField.text = self.tempValObj.valueName;
		[self.votPicker selectRow:self.tempValObj.vcolor inComponent:1 animated:NO]; // first as no picker update effects
		[self.votPicker selectRow:self.tempValObj.vtype inComponent:0 animated:NO];
		[self updateForPickerRowSelect:self.tempValObj.vtype inComponent:0];
		[self.votPicker selectRow:self.tempValObj.vGraphType inComponent:2 animated:NO];
		[self updateForPickerRowSelect:self.tempValObj.vGraphType inComponent:2];
		 
		NSString *g = [allGraphs objectAtIndex:self.tempValObj.vGraphType];
		self.graphTypes = [self.tempValObj.vos voGraphSet];

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

	self.title = @"Item";
	
	self.labelField.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
	self.labelField.clearsOnBeginEditing = NO;
	[self.labelField setDelegate:self];
	self.labelField.returnKeyType = UIReturnKeyDone;
	[self.labelField addTarget:self
				  action:@selector(labelFieldDone:)
		forControlEvents:UIControlEventEditingDidEndOnExit];
//	DBGLog(@"frame: %f %f %f %f",self.labelField.frame.origin.x, self.labelField.frame.origin.y, self.labelField.frame.size.width, self.labelField.frame.size.height);
	
	[super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.

	//parentTrackerObj.colorSet = nil;
	parentTrackerObj.votArray = nil;
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	DBGLog(@"avoc didUnload");
	
	self.votPicker = nil;
	self.labelField = nil;
	self.tempValObj = nil;
	self.graphTypes = nil;
	self.parentTrackerObj = nil;

	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	//[self setToolbarItems:nil
	//			 animated:NO];
	self.title = nil;
	
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	
    DBGLog(@"avoc: viewWillAppear");
	
	if (self.tempValObj) {
		self.graphTypes = nil;
		self.graphTypes = [self.tempValObj.vos voGraphSet];
		[self.votPicker reloadComponent:2]; // in case added more graphtypes (eg tb count lines)
	}
	
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark button press action methods

- (void) leave
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) stashVals {
    self.tmpVtype = self.tempValObj.vtype;
    self.tmpVcolor = self.tempValObj.vcolor;
    self.tmpVGraphType = self.tempValObj.vGraphType;
}

- (void) retrieveVals {
    self.tempValObj.vtype = self.tmpVtype;
    self.tempValObj.vcolor = self.tmpVcolor;
    self.tempValObj.vGraphType = self.tmpVGraphType;
}

- (IBAction)btnCancel {
	//DBGLog(@"addVObjC: btnCancel was pressed!");
    [self retrieveVals];
	[self leave];
}

- (IBAction)btnSave {
	//DBGLog(@"addVObjC: btnSave was pressed!");
    
    if ([self.labelField.text length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"save Item" message:@"Please set a name for this item to save"
							  delegate:nil 
							  cancelButtonTitle:@"Ok"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
        return;
    
    }
    
	self.tempValObj.valueName = self.labelField.text;  // in case neglected to 'done' keyboard
	[self.labelField resignFirstResponder];
    
	NSUInteger row = [self.votPicker selectedRowInComponent:0];
	self.tempValObj.vtype = row;  // works because vtype defs are same order as rt-types.plist entries
	row = [self.votPicker selectedRowInComponent:1];
    if (VOT_CHOICE == self.tempValObj.vtype) {
        self.tempValObj.vcolor = -1;   // choice color set in optDict per choice
    } else {
        self.tempValObj.vcolor = row; // works because vColor defs are same order as trackerObj.colorSet creator 
    }
    
    if (VOT_FUNC == self.tempValObj.vtype) {
        [self.parentTrackerObj.optDict setObject:@"1" forKey:@"dirtyFns"];
    }
    
	row = [self.votPicker selectedRowInComponent:2];
	self.tempValObj.vGraphType = [valueObj mapGraphType:[self.graphTypes objectAtIndex:row]];
	
	if (self.tempValObj.vid == 0) {
		self.tempValObj.vid = [self.parentTrackerObj getUnique];
	}
	
	// clear extraneous frv entries to keep db clean
    
    // no default fdlc so if set stays set - delete on del cons from fn
    
	NSInteger v = [[self.tempValObj.optDict objectForKey:@"frep0"] integerValue] ;
	if (v >= FREPDFLT) 
		[self.tempValObj.optDict removeObjectForKey:@"frv0"];
    
	v = [[self.tempValObj.optDict objectForKey:@"frep1"] integerValue] ;
	if (v >= FREPDFLT) 
		[self.tempValObj.optDict removeObjectForKey:@"frv1"];
	
    if ([(NSString*) [self.tempValObj.optDict objectForKey:@"autoscale"] isEqualToString:@"0"]) {
        
        // override no autoscale if gmin, gmax both set and equal
        double gmn, gmx;
        
        if ( ([[NSScanner localizedScannerWithString:[self.tempValObj.optDict objectForKey:@"gmin"]] scanDouble:&gmn])
            &&
             ([[NSScanner localizedScannerWithString:[self.tempValObj.optDict objectForKey:@"gmax"]] scanDouble:&gmx])
            ){
            if (gmn == gmx) {
                [self.tempValObj.optDict setObject:@"1" forKey:@"autoscale"];
            }
        }
    }
    
#if DEBUGLOG	
	NSString *selected = [self.parentTrackerObj.votArray objectAtIndex:row];
	DBGLog(@"save label: %@ id: %d row: %d = %@",self.tempValObj.valueName,self.tempValObj.vid, row,selected);
#endif
	
	[self.parentTrackerObj addValObj:tempValObj];
	
	[self leave];
	//[self.navigationController popViewControllerAnimated:YES];
	//[parent.tableView reloadData];
}

- (void) btnSetup {
	//DBGLog(@"addVObjC: config was pressed!");
	
	configTVObjVC *ctvovc = [[configTVObjVC alloc] init];
	ctvovc.to = self.parentTrackerObj;
	//[parentTrackerObj retain];
	ctvovc.vo = self.tempValObj;
	//[tempValObj retain];
	ctvovc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	//[self presentModalViewController:ctvovc animated:YES];
    [self presentViewController:ctvovc animated:YES completion:NULL];
	[ctvovc release];
}


# pragma mark -
# pragma mark textField support Methods

- (IBAction) labelFieldDone:(id)sender {
	[sender resignFirstResponder];
	self.tempValObj.valueName = self.labelField.text;
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
			//return [self.parentTrackerObj.colorSet count];
			return colorCount;
			break;
		case 2:
			return [self.graphTypes count];
			break;
		default:
			dbgNSAssert(0,@"bad component for avo picker");
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
			dbgNSAssert(0,@"bad component for avo picker");
			return @"boo.";
			break;
	}
}

#else 

#define COLORSIDE FONTSIZE

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel *label=0;
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
			label.backgroundColor = [[rTracker_resource colorSet] objectAtIndex:row];
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
			dbgNSAssert(0,@"bad component for avo picker");
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
			dbgNSAssert(0,@"bad component for avo picker");
			return 0.0f;
			break;
	}
}

#endif

- (void) updateColorCount {
	NSInteger oldcc = colorCount;
	
	if (self.tempValObj.vtype == VOT_CHOICE) {
		colorCount = 0;
	} else if (self.tempValObj.vGraphType == VOG_NONE) {
		colorCount = 0;
	} else if (colorCount == 0) {
		colorCount = [[rTracker_resource colorSet] count];
	}
	
	if (oldcc != colorCount) 
		[self.votPicker reloadComponent:1];
}

- (void) updateForPickerRowSelect:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		self.graphTypes = [self.tempValObj.vos voGraphSet];
		[self.votPicker reloadComponent:2];
		[self updateColorCount];
		//[self updateScrollView:row];
	} else if (component == 1) {
	} else if (component == 2) {
		[self updateColorCount];
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.labelField isFirstResponder]) {
        [self.labelField resignFirstResponder];
    }
	if (component == 0) {
		self.tempValObj.vtype = row;
	} else if (component == 1) {
		self.tempValObj.vcolor = row;
	} else if (component == 2) {
		self.tempValObj.vGraphType = [valueObj mapGraphType:[self.graphTypes objectAtIndex:row]];
	}
	
	[self updateForPickerRowSelect:row inComponent:component];
}



@end
