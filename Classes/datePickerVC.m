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
#import "rTracker-constants.h"

@implementation datePickerVC

@synthesize myTitle=_myTitle, /*date,action,*/ dpr=_dpr, dateSetBtn=_dateSetBtn,entryNewBtn=_entryNewBtn,dateGotoBtn=_dateGotoBtn,navBar=_navBar,
//toolBar=_toolBar,
datePicker=_datePicker;

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
    //CGRect f = self.view.frame;
    //f.size.width = [rTracker_resource getKeyWindowWidth];
    //self.view.frame = f;
    
    /*
     // does not resize well -- need more work on xib
    self.dateSetBtn.titleLabel.font = PrefBodyFont;
    self.entryNewBtn.titleLabel.font = PrefBodyFont;
    self.dateGotoBtn.titleLabel.font = PrefBodyFont;
    */
    [super viewDidLoad];
    /*f.origin.y= 416;
    f.size.height = 44;
    UIToolbar *tb = [ [UIToolbar alloc]initWithFrame:f ];
    self.toolBar = tb;
     */
    /*
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								target:self
								action:@selector(btnCancel:)];
    //[self setToolbarItems:@[cancelBtn]];
	self.toolBar.items = @[cancelBtn];
    */
    
	//self.datePicker.locale = [NSLocale currentLocale];
	self.datePicker.maximumDate = [NSDate date];
	self.datePicker.date = self.dpr.date;
	//self.datePicker.minuteInterval = 2;
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/*
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
*/



#pragma mark -
#pragma mark button actions

- (IBAction)cancelEvent:(id)sender {
}

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

/*
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
*/


@end
