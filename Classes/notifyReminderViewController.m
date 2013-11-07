//
//  notifyReminderViewController.m
//  rTracker
//
//  Created by Rob Miller on 07/08/2013.
//  Copyright (c) 2013 Robert T. Miller. All rights reserved.
//

#import "notifyReminderViewController.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

#define SEGWEEK 0
#define SEGMONTH 1
#define SEGEVERY 2

//@interface notifyReminderViewController ()

//@end

@implementation notifyReminderViewController

@synthesize tracker, chkImg, unchkImg, startHr, startMin, startTimeAmPm, startSlider, finishHr, finishMin, finishTimeAmPm, repeatTimes, finishSlider, intervalButton, toolBar, activeField;

-(void)dealloc {
    self.tracker = nil;
    [tracker release];
    self.chkImg = nil;
    [chkImg release];
    self.unchkImg = nil;
    [unchkImg release];
    
    [super dealloc];
}

- (void)btnDone:(id)sender
{
	//ios6 [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title=@"hello";
        // Custom initialization
       // [self viewDidLoad];
    }
    return self;
}


- (void)viewDidLoad
{
    

    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								target:self
								action:@selector(btnDone:)];
    self.toolbarItems = [NSArray arrayWithObjects: doneBtn, nil];

	[doneBtn release];

    self.chkImg = [UIImage imageNamed:@"checked.png"];
    self.unchkImg = [UIImage imageNamed:@"unchecked.png"];

    [rTracker_resource initHasAmPm];
    if (hasAmPm) {
        self.startTimeAmPm.hidden=NO;
        self.finishTimeAmPm.hidden=NO;
        self.finishTimeAmPm.enabled=NO;
        self.finishHr.text=@"11";
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:self.view.window];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:self.view.window];
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear :(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}


// 3rd 5th 7th 10th day of each month
// every n hrs / days / weeks / months
// n hrs / days / weeks / months from last save

- (IBAction)fromSaveBtn:(id)sender {
    DBGLog(@"fromSaveBtn");
    
    if (self.fromSaveButton.currentImage == self.chkImg) {
        [self.fromSaveButton setImage:self.unchkImg forState:UIControlStateNormal];
        [self enableStartControls:YES];
    } else {
        [self.fromSaveButton setImage:self.chkImg forState:UIControlStateNormal];
        [self enableStartControls:NO];
    }
    
}
- (IBAction)prevBtn:(id)sender {
    DBGLog(@"prevBtn");
}
- (IBAction)nextAddBtn:(id)sender {
    DBGLog(@"nextAddBtn");
}
- (IBAction)everyBtn:(id)sender {
    DBGLog(@"everyBtn %@", [self.everyButton titleForState:UIControlStateNormal]);
    if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Minutes"]) {
        [self.everyButton setTitle:@"Hours" forState:UIControlStateNormal];
    } else if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Hours"]) {
        [self.everyButton setTitle:@"Days" forState:UIControlStateNormal];
    } else if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Days"]) {
        [self.everyButton setTitle:@"Weeks" forState:UIControlStateNormal];
    } else if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Weeks"]) {
        [self.everyButton setTitle:@"Months" forState:UIControlStateNormal];
    } else if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Months"]) {
        [self.everyButton setTitle:@"Minutes" forState:UIControlStateNormal];
    }
    [self everyBtnStateUpdate];
}

-(void)everyBtnStateUpdate {
    if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Minutes"]) {
        [self startLabelFrom:YES];
        [self hideFinishControls:NO];
    } else if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Hours"]) {
        [self startLabelFrom:YES];
        [self hideFinishControls:NO];
    } else if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Days"]) {
        [self startLabelFrom:NO];
        [self hideFinishControls:YES];
    } else if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Weeks"]) {
        [self startLabelFrom:NO];
        [self hideFinishControls:YES];
    } else if ([[self.everyButton titleForState:UIControlStateNormal] isEqualToString:@"Months"]) {
        [self startLabelFrom:NO];
        [self hideFinishControls:YES];
    }
    
}


- (IBAction)btnHelp:(id)sender {
    DBGLog(@"btnHelp");
}

- (IBAction)monthDaysChange:(id)sender {
    DBGLog(@"monthDaysChange ");
}
- (IBAction)everyTFChange:(id)sender {
    DBGLog(@"everyTFChange");
}

- (IBAction)messageTFChange:(id)sender {
    DBGLog(@"messageTFChange");
}

-(void) hideWeekdays:(BOOL)state {
    self.wdButton1.hidden=state;
    self.wdButton2.hidden=state;
    self.wdButton3.hidden=state;
    self.wdButton4.hidden=state;
    self.wdButton5.hidden=state;
    self.wdButton6.hidden=state;
    self.wdButton7.hidden=state;
}

-(void) hideMonthdays:(BOOL)state {
    self.monthDaysLabel.hidden=state;
    self.monthDays.hidden=state;
}

-(void) hideEvery:(BOOL)state {
    self.everyTF.hidden=state;
    self.everyButton.hidden=state;
    self.fromSaveButton.hidden=state;
    self.fromSaveLabel.hidden=state;
}

- (IBAction)weekMonthEveryChange:(id)sender {
    DBGLog(@"weekMonthEveryChange -- %d --",[sender selectedSegmentIndex]);
    switch([sender selectedSegmentIndex]) {
        case SEGWEEK:
            [self hideWeekdays:NO];
            [self hideMonthdays:YES];
            [self hideEvery:YES];
            [self enableStartControls:YES];
            [self hideFinishControls:NO];
            break;
        case SEGMONTH:
            [self hideWeekdays:YES];
            [self hideMonthdays:NO];
            [self hideEvery:YES];
            [self enableStartControls:YES];
            [self hideFinishControls:NO];
        break;
        case SEGEVERY:
            [self hideWeekdays:YES];
            [self hideMonthdays:YES];
            [self hideEvery:NO];
            [self enableStartControls:(self.fromSaveButton.currentImage != self.chkImg)];
            [self everyBtnStateUpdate];
        break;
            
    }
}

-(IBAction) wdBtn:(id)sender {
    DBGLog(@"wdBtn %@",((UIButton*)sender).currentTitle);
    ((UIButton*)sender).selected = ! ((UIButton*)sender).selected;
}

- (void) doEFbtnState {
    
    if (self.enableFinishButton.currentImage == self.chkImg) {
        self.finishSlider.enabled = YES;
        self.finishHr.enabled = YES;
        self.finishMin.enabled = YES;
        if (hasAmPm) self.finishTimeAmPm.enabled = YES;
        self.finishLabel.enabled = YES;
        if (SEGEVERY == self.weekMonthEvery.selectedSegmentIndex) {
            self.intervalButton.hidden = YES;
            self.repeatTimes.hidden = YES;
            self.repeatTimesLabel.hidden = YES;
        } else {
            self.intervalButton.hidden = NO;
            self.repeatTimes.hidden = NO;
            self.repeatTimesLabel.hidden = NO;
        }
    } else {
        self.intervalButton.hidden = YES;
        self.finishSlider.enabled = NO;
        self.finishHr.enabled = NO;
        self.finishMin.enabled = NO;
        if (hasAmPm) self.finishTimeAmPm.enabled = NO;
        self.finishLabel.enabled = NO;
        self.repeatTimes.hidden = YES;
        self.repeatTimesLabel.hidden = YES;        
    }
}

-(void) startLabelFrom:(BOOL)from {
    if (from) {
        self.startLabel.text = @"From";
    } else {
        self.startLabel.text = @"At";
    }
}

-(void) hideFinishControls:(BOOL)hide {
    self.enableFinishButton.hidden = hide;
    self.finishSlider.hidden = hide;
    self.finishHr.hidden = hide;
    self.finishMin.hidden = hide;
    self.finishLabel.hidden = hide;
    self.finishColon.hidden = hide;
    
    if (hasAmPm) self.finishTimeAmPm.hidden = hide;
    
    if (!hide) [self doEFbtnState];
}

-(void) enableStartControls:(BOOL)enable {
    self.startHr.enabled = enable;
    self.startMin.enabled = enable;
    self.startSlider.enabled = enable;
    self.startLabel.enabled = enable;
    
    if (hasAmPm) self.startTimeAmPm.enabled = enable;
    
}

-(IBAction) enableFinishBtn:(id)sender {
    DBGLog(@"enableFinishBtn");
    UIButton *efBtn = (UIButton*)sender;
    
    if (efBtn.currentImage == self.chkImg) {
        [efBtn setImage:self.unchkImg forState: UIControlStateNormal];
    } else { //if (efBtn.currentImage == unchkImg) {
        [efBtn setImage:self.chkImg forState: UIControlStateNormal];
    }
    
    [self doEFbtnState];
    
    //img = (dfltState ? @"unchecked.png" : @"checked.png"); // going to not default state
    //[btn setImage:[UIImage imageNamed:img] forState: UIControlStateNormal];

    //efBtn.
}

-(IBAction) intervalBtn:(id)sender {
    DBGLog(@"intervalBtn %@",((UIButton*)sender).currentTitle);
    DBGLog(@"everyBtn %@", [self.intervalButton titleForState:UIControlStateNormal]);
    if ([[self.intervalButton titleForState:UIControlStateNormal] isEqualToString:@"random"]) {
        [self.intervalButton setTitle:@"interval" forState:UIControlStateNormal];
    } else {
        [self.intervalButton setTitle:@"random" forState:UIControlStateNormal];
    }
    //((UIButton*)sender).selected = ! ((UIButton*)sender).selected;
}

-(void)sliderUpdate:(int)val hrtf:(UITextField*)hrtf mntf:(UITextField*)mntf ampml:(UILabel*)ampml {
    int hrVal = val/60;
    int mnVal = val % 60;
    if (hasAmPm) {
        if (hrVal >= 12) {
            if (hrVal > 12) {
                hrVal -= 12;
            };
            ampml.text=@"pm";
        } else {
            if (0 == hrVal) {
                hrVal = 12;
            }
            ampml.text=@"am";
        }
    }
    //DBGLog(@"val %d hrVal %d mnVal %d",val,hrVal,mnVal);
    hrtf.text = [NSString stringWithFormat:@"%02d",hrVal];
    mntf.text = [NSString stringWithFormat:@"%02d",mnVal];
}

-(IBAction)startSliderAction:(id)sender {
    DBGLog(@"startSlider");
    [self sliderUpdate:(int)((UISlider*)sender).value hrtf:startHr mntf:startMin ampml:startTimeAmPm];
}

-(IBAction)finishSliderAction:(id)sender {
    DBGLog(@"finishSlider %f",((UISlider*)sender).value);
    [self sliderUpdate:(int)((UISlider*)sender).value hrtf:finishHr mntf:finishMin ampml:finishTimeAmPm];
}

- (void)timeTfUpdate:(UISlider*)slider hrtf:(UITextField*)hrtf mntf:(UITextField*)mntf ampml:(UILabel*)ampml {
    int hrVal = [[hrtf text] intValue];
    int mnVal = [[mntf text] intValue];
    if (hasAmPm) {
        if (hrVal >= 12) {
            ampml.text = @"pm";
        } else if ([[ampml text] isEqualToString:@"pm"]) {
            hrVal += 12;
        }
    }
    
    [slider setValue:(float) ((hrVal * 60) + mnVal) animated:YES];
    
}

- (IBAction)startHrChange:(id)sender {
    DBGLog(@"hrChange %@",((UITextField*)sender).text);
    [self timeTfUpdate:startSlider hrtf:startHr mntf:startMin ampml:startTimeAmPm];
}

- (IBAction)startMinChange:(id)sender {
    DBGLog(@"minChange %@",((UITextField*)sender).text);
    [self timeTfUpdate:startSlider hrtf:startHr mntf:startMin ampml:startTimeAmPm];
}

- (IBAction)finishHrChange:(id)sender {
    DBGLog(@"hrChange %@",((UITextField*)sender).text);
    [self timeTfUpdate:finishSlider hrtf:finishHr mntf:finishMin ampml:finishTimeAmPm];
}

- (IBAction)finishMinChange:(id)sender {
    DBGLog(@"minChange %@",((UITextField*)sender).text);
    [self timeTfUpdate:finishSlider hrtf:finishHr mntf:finishMin ampml:finishTimeAmPm];
}

- (IBAction)timesChange:(id)sender {
    DBGLog(@"timesChange %@",((UITextField*)sender).text);
}

#pragma mark -

- (void)TFdidBeginEditing:(UITextField *)textField
{
	DBGLog(@"tf begin editing");
    activeField = textField;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    //DBGLog(@"configTVObjVC keyboardwillshow");
    CGFloat boty = activeField.frame.origin.y + activeField.frame.size.height + MARGIN;
    [rTracker_resource willShowKeyboard:n view:self.view boty:boty];
}

- (void)keyboardWillHide:(NSNotification *)n
{
	//DBGLog(@"handling keyboard will hide");
	[rTracker_resource willHideKeyboard];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#if DEBUGLOG
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	DBGLog(@"I am touched at %f, %f.",touchPoint.x, touchPoint.y);
#endif
    
	[activeField resignFirstResponder];
}

@end
