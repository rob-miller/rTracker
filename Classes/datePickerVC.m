//
//  datePicker.m
//  rTracker
//
//  Created by Robert Miller on 14/10/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "datePickerVC.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

@implementation datePickerVC

@synthesize myTitle=_myTitle, /*date,action,*/ dpr=_dpr, dateSetBtn=_dateSetBtn,entryNewBtn=_entryNewBtn,dateGotoBtn=_dateGotoBtn,navBar=_navBar,toolBar=_toolBar,datePicker=_datePicker;

- (IBAction) btnCancel:(UIButton*)btn
{
	self.dpr.date = self.datePicker.date;
	self.dpr.action = DPA_CANCEL;
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[self.navBar.items lastObject] setTitle:self.myTitle];
    [super viewDidLoad];

	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								target:self
								action:@selector(btnCancel:)];
	self.toolBar.items = [NSArray arrayWithObjects: cancelBtn, nil];
	
    if (![rTracker_resource getSeparateDateTimePicker]) {
        self.dtSegmentedControl.hidden = YES;
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
	self.datePicker.locale = [NSLocale currentLocale];
	self.datePicker.maximumDate = [NSDate date];
	self.datePicker.date = self.dpr.date;
	self.datePicker.minuteInterval = 2;
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.title = nil;
	self.entryNewBtn = nil;
	self.dateSetBtn = nil;
	self.dateGotoBtn = nil;
	self.datePicker = nil;
	self.navBar = nil;
	self.toolBar = nil;

	// note keep date for parent
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark -
#pragma mark button actions

- (IBAction) entryNewBtnAction
{
	self.dpr.date = self.datePicker.date;
	self.dpr.action = DPA_NEW;
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction) dateSetBtnAction
{
	self.dpr.date = self.datePicker.date;
	self.dpr.action = DPA_SET;
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction) dateGotoBtnAction
{
	self.dpr.date = self.datePicker.date;
	self.dpr.action = DPA_GOTO;
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction) dateModeChoice:(id)sender
{
	self.datePicker.maximumDate = [NSDate date];
	self.datePicker.date = self.dpr.date;
	
	switch ([sender selectedSegmentIndex]) {
		case SEG_DATE :
			self.datePicker.datePickerMode = UIDatePickerModeDate;
			break;
		case SEG_TIME:
			self.datePicker.datePickerMode = UIDatePickerModeTime;
			break;
		default:
			dbgNSAssert(0,@"dateModeChoice: cannot identify seg index");
			break;
	}
}



@end
