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
#import "valueObj.h"
#import "trackerObj.h"
#import "notifyReminder.h"

#define SEGWEEK 0
#define SEGMONTH 1
#define SEGEVERY 2

//@interface notifyReminderViewController ()

//@end

@implementation notifyReminderViewController

@synthesize tracker, nr, chkImg, weekdayBtns, everyTrackerNames, unchkImg, firstWeekDay, everyTrackerNdx, everyMode, lastDefaultMsg, startHr, startMin, startTimeAmPm, startSlider, finishHr, finishMin, finishTimeAmPm, repeatTimes, finishSlider, intervalButton, toolBar, activeField, msgTF,enableButton;

-(void)dealloc {
    self.tracker = nil;
    [tracker release];
    self.nr = nil;
    [nr release];
    self.weekdayBtns = nil;
    [weekdayBtns release];
    self.everyTrackerNames = nil;
    [everyTrackerNames release];
    self.chkImg = nil;
    [chkImg release];
    self.unchkImg = nil;
    [unchkImg release];
    self.msgTF = nil;
    [msgTF release];
    self.enableButton = nil;
    [enableButton release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.tmpReminder=TRUE;
        
        //self.title=@"hello";
        // Custom initialization
       // [self viewDidLoad];
    }
    return self;
}

#pragma mark -

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
    // set weekday buttons to reflect users calendar settings
    
    self.firstWeekDay = [[NSCalendar currentCalendar] firstWeekday];
    //DBGLog(@"firstweekday= %d",self.firstWeekDay);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    int i;
    for (i=0;i<7;i++) {
        NSUInteger wd = self.firstWeekDay +i;
        if (wd > 7) {
            wd -= 7;
        }
        self->weekdays[i] = wd-1;  // firstWeekDay is 1-indexed, switch to 0-indexed
        
        [(UIButton*)[self.weekdayBtns objectAtIndex:i] setTitle:[[dateFormatter shortWeekdaySymbols] objectAtIndex:(self->weekdays[i])] forState:UIControlStateNormal];
        //DBGLog(@"i=%d wd=%d sdayName= %@",i,wd,[[dateFormatter shortWeekdaySymbols] objectAtIndex:(self->weekdays[i])]);
    }
    [dateFormatter release];
    
    self.everyMode = EV_HOURS;
    [self setEveryTrackerBtnName];
    
    self.lastDefaultMsg = self.msgTF.text = self.tracker.trackerName;
    
    if (0 < [self.tracker.reminders count]) {
        self.nr = [self.tracker currReminder];
    } else {
        self.nr = [self.tracker loadReminders];
    }
    
    [self guiFromNr];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



- (BOOL)leaveNR {
    if ([self nullNRguiState]) {
        if (self.nr.rid) {
            [self.tracker deleteReminder];
            return TRUE;
        }
    } else {
        [self nrFromGui];
        [self.tracker saveReminder:self.nr];
    }
    return FALSE;
}

- (void)btnDone:(id)sender
{
    [self leaveNR];
	//ios6 [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)prevBtn:(id)sender {
    DBGLog(@"prevBtn");
    [self leaveNR];
    self.nr = ( 0 == self.nr.rid ? [self.tracker currReminder] : [self.tracker prevReminder] );
    [self guiFromNr];
}

- (IBAction)nextAddBtn:(id)sender {
    DBGLog(@"nextAddBtn");
    if ([self leaveNR]) {
        self.nr = [self.tracker currReminder];
    } else {
        self.nr = [self.tracker nextReminder];
    }
    [self guiFromNr];
}


#pragma mark -


- (NSArray*) weekdayBtns {
    if (nil == weekdayBtns) {
        weekdayBtns = [[NSArray alloc] initWithObjects:self.wdButton1, self.wdButton2, self.wdButton3, self.wdButton4, self.wdButton5, self.wdButton6, self.wdButton7, nil];
    }
    return weekdayBtns;
}

- (NSArray*) everyTrackerNames {
    if (nil == everyTrackerNames) {
        NSMutableArray *mtnames = [[NSMutableArray alloc] initWithCapacity:( [self.tracker.valObjTable count] + 1)];
        [mtnames addObject:self.tracker.trackerName];
        for (valueObj *vo in self.tracker.valObjTable) {
            [mtnames addObject:vo.valueName];
        }
        everyTrackerNames = [[NSArray alloc] initWithArray:mtnames];
        [mtnames release];
    }
    return everyTrackerNames;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    /*
    if (0 < [self.tracker.reminders count]) {
        //self.nextAddBarButton.title = @">";
        self.nr = [self.tracker.reminders objectAtIndex:0];
    } else {
        self.nr = [[notifyReminder alloc] init:self.tracker];
    }
    */
    
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


#pragma mark -

- (void) guiFromNr {
    // if rid == 0 return   
    int i;

    if (nil == self.nr) {
        self.nr = [[notifyReminder alloc] init];
        self.nr.msg = self.tracker.trackerName;
        self.nr.tid = self.tracker.toid;
        //self.tmpReminder=TRUE;
    } else {
        //self.tmpReminder=FALSE;
    }
    DBGLog(@"rid= %d",self.nr.rid);
    self.enableButton.selected = self.nr.reminderEnabled;
    [self updateCheckBtn:self.enableButton];
    self.msgTF.text = self.nr.msg;

    if (self.nr.start > -1) {
        [self enableStartControls:YES];
        self.startSlider.value = self.nr.start;
        [self sliderUpdate:(int)self.startSlider.value hrtf:self.startHr mntf:self.startMin ampml:self.startTimeAmPm];
    } else {
        [self enableStartControls:NO];
    }

    if (self.nr.untilEnabled) {
        self.enableFinishButton.selected = YES;
        [self updateCheckBtn:self.enableFinishButton];
        self.finishSlider.value = self.nr.until;
        self.repeatTimes.text = [NSString stringWithFormat:@"%d",self.nr.times];
        [self.intervalButton setTitle:(self.nr.timesRandom ? @"random" : @"interval") forState:UIControlStateNormal];
        [self sliderUpdate:(int)self.finishSlider.value hrtf:self.finishHr mntf:self.finishMin ampml:self.finishTimeAmPm];
    } else {
        self.enableFinishButton.selected = NO;
    }

    [self doEFbtnState];
    
    if (self.nr.monthDays) {
        self.weekMonthEvery.selectedSegmentIndex=SEGMONTH;
        NSMutableArray *nma = [[NSMutableArray alloc] initWithCapacity:32];
        for (i=0;i<32;i++) {
            if (self.nr.monthDays & (0x01 << i)) {
                [nma addObject:[NSString stringWithFormat:@"%d",i+1]];
            }
        }
        self.monthDays.text = [nma componentsJoinedByString:@","];
        [nma release];
        [self clearWeekDays];
        [self clearEvery];
    } else if (self.nr.everyVal) {
        self.weekMonthEvery.selectedSegmentIndex=SEGEVERY;
        self.everyTF.text = [NSString stringWithFormat:@"%d",self.nr.everyVal];
        self.everyMode = self.nr.everyMode;
        [self everyBtnStateUpdate];
        if (self.nr.fromLast) {
            self.fromLastButton.selected = YES;
            [self updateCheckBtn:self.fromLastButton];
            if (self.nr.vid) {
                int c = [self.tracker.valObjTable count];
                for (i=0; i< c; i++) {
                    if (self.nr.vid == ((valueObj*)[self.tracker.valObjTable objectAtIndex:i]).vid) {
                        self.everyTrackerNdx = i+1;
                    }
                }
            } else {
                self.everyTrackerNdx = 0;
            }
        }
        [self setEveryTrackerBtnName];
        [self clearWeekDays];
        [self clearMonthDays];
    } else {   // if (self.nr.weekDays)  = default if nothing set
        self.weekMonthEvery.selectedSegmentIndex=SEGWEEK;
        for (i=0;i<7;i++) {
            ((UIButton*)[self.weekdayBtns objectAtIndex:i]).selected = (BOOL) (0 != (self.nr.weekDays & (0x01 << self->weekdays[i])));
/*
#if DEBUGLOG
            if (((UIButton*)[self.weekdayBtns objectAtIndex:i]).selected) {
                DBGLog(@"weekday btn %d is selected",i);
            } else {
                DBGLog(@"i=%d s->w[i] = %d  nrwd= %d  shift = %0x &= %d",i,self->weekdays[i], self.nr.weekDays, (0x01 << self->weekdays[i]), (self.nr.weekDays & (0x01 << self->weekdays[i])) );
            }
#endif
*/

        }
        [self clearMonthDays];
        [self clearEvery];
    }
    
    [self weekMonthEveryChange:self.weekMonthEvery];
    [self updateEnabledButton];
}

-(void) clearMonthDays {
    self.monthDays.text = @"";
}

-(void) clearWeekDays {
    int i;
    for (i=0;i<7;i++) {
        ((UIButton*)[self.weekdayBtns objectAtIndex:i]).selected = NO;
    }
    
}

-(void) clearEvery {
    self.everyTF.text = @"";
    self.everyMode = 0;
    [self everyBtnStateUpdate];
    self.everyTrackerNdx=0;
    self.fromLastButton.selected=NO;
    [self updateCheckBtn:self.fromLastButton];
}

- (void) nrFromGui {
    [self.nr clearNR];  // does not wipe rid
    if (self.enableButton.hidden) return;
    
    self.nr.reminderEnabled = self.enableButton.selected;
    self.nr.msg = self.msgTF.text;
    self.nr.tid = self.tracker.toid;
    
    self.nr.start = (self.startSlider.enabled ? self.startSlider.value : -1);

    if (self.enableFinishButton.selected) {
        self.nr.until = self.finishSlider.value;
        self.nr.times = [self.repeatTimes.text intValue];
        if (1 < self.nr.times) self.nr.timesRandom = [[self.intervalButton titleForState:UIControlStateNormal] isEqualToString:@"random"];
    } else {
        self.nr.until = -1;
    }
    self.nr.until = (self.finishSlider.enabled ? self.finishSlider.value : -1);
    self.nr.times = [self.repeatTimes.text intValue];
    
    int wme = self.weekMonthEvery.selectedSegmentIndex;
    switch (wme) {
        case SEGWEEK: {
            int i;
            for (i=0; i<7; i++) {
                if ([(UIButton*)[self.weekdayBtns objectAtIndex:i] isSelected]) {
                    self.nr.weekDays |= (0x01 << (self->weekdays[i]));
                }
            }
            break;
        }
        case SEGMONTH: {
            NSArray *monthDayComponents = [[self.monthDays text] componentsSeparatedByString:@","];
            for (NSString *mdComp in monthDayComponents) {
                self.nr.monthDays |= (0x01 << ([mdComp intValue] -1));
            }
            break;
        }
        case SEGEVERY: {
            self.nr.everyVal = [[self.everyTF text] intValue];
            self.nr.everyMode = self.everyMode;
            self.nr.fromLast = self.fromLastButton.selected;
            if (NO == self.everyTrackerButton.hidden) {
                self.nr.vid = ( self.everyTrackerNdx ? ((valueObj*)[self.tracker.valObjTable objectAtIndex:(self.everyTrackerNdx-1)]).vid : 0 );
            }
            break;
        }
        default:
            break;
    }
    
}

- (BOOL) nullNRguiState {
    int wme = self.weekMonthEvery.selectedSegmentIndex;
    
    if (self.startSlider.enabled && self.finishSlider.enabled && (self.startSlider.value > self.finishSlider.value)) return YES;
    
    switch (wme) {
        case SEGWEEK: {
            int i;
            for (i=0; i<7; i++) {
                if ([(UIButton*)[self.weekdayBtns objectAtIndex:i] isSelected]) {
                    return NO;
                }
            }
            break;
        }
        case SEGMONTH: {
            NSArray *monthDayComponents = [[self.monthDays text] componentsSeparatedByString:@","];
            for (NSString *mdComp in monthDayComponents) {
                if (0 < [mdComp intValue]) return NO;
            }
            break;
        }
        case SEGEVERY: {
            if (0 < [[self.everyTF text] intValue]) return NO;
            break;
        }
        default:
            break;
    }
    
    return YES;
}

/*
- (void) saveNR {
    [compute nr data from gui]
    if computed_nr is null_event
     if 0 != rid : delete rid from db and array
    else (non-null setting)
     if (0 == rid)
        set computed_nr as new nr in db
     else
        update <rid> nr in db
}
*/

#pragma mark -
- (void) updateEnabledButton {
    BOOL guiStateIsNull = [self nullNRguiState];
    self.enableButton.hidden = guiStateIsNull;
    self.enableButton.selected = !guiStateIsNull;  // enable by default if reminder is valid
    [self updateCheckBtn:self.enableButton];
    
    self.nextAddBarButton.enabled = (!guiStateIsNull || [self.tracker haveNextReminder]);
    self.prevBarButton.enabled = ([self.tracker havePrevReminder] || ((0 == self.nr.rid) && [self.tracker haveCurrReminder]));
}


-(void) updateCheckBtn:(UIButton*)btn {
    if (btn.selected) {
        [btn setImage:self.chkImg forState:UIControlStateNormal];
    } else {
        [btn setImage:self.unchkImg forState:UIControlStateNormal];
    }
}
- (void)toggleCheckBtn:(UIButton*)btn {
    btn.selected = ! btn.selected;
    [self updateCheckBtn:btn];
}

// 3rd 5th 7th 10th day of each month
// every n hrs / days / weeks / months
// n mins / hrs / days / weeks / months from last save
//  if days / weeks / months can set at time

-(void)fromLastBtnStateUpdate {
    if (self.fromLastButton.selected) {
        //if ((self.everyMode == EV_HOURS) || (self.everyMode == EV_MINUTES) ) {
        //    [self enableStartControls:NO];
        //} else {
            [self enableStartControls:YES];
        //}
        self.everyTrackerButton.hidden = NO;
    } else {
        [self enableStartControls:YES];
        self.everyTrackerButton.hidden = YES;
    }
    [self updateMessage];
}
- (IBAction)fromLastBtn:(id)sender {
    DBGLog(@"fromLastBtn");
    [self toggleCheckBtn:self.fromLastButton];
    [self fromLastBtnStateUpdate];
}

- (IBAction)everyBtn:(id)sender {
    DBGLog(@"everyBtn %@", [self.everyButton titleForState:UIControlStateNormal]);
    self.everyMode = (self.everyMode ? (self.everyMode << 1) & EV_MASK : EV_HOURS);
    [self everyBtnStateUpdate];
}

-(void)everyBtnStateUpdate {
    switch (self.everyMode) {
        case EV_HOURS:
            [self.everyButton setTitle:@"Hours" forState:UIControlStateNormal];
            [self hideFinishControls:NO];
            if (self.fromLastButton.selected) {
                [self enableStartControls:YES];
            }
            [self startLabelFrom:YES];
            break;
        case EV_DAYS:
            [self.everyButton setTitle:@"Days" forState:UIControlStateNormal];
            [self hideFinishControls:YES];
            if (self.fromLastButton.selected) {
                [self enableStartControls:YES];
            }
            [self startLabelFrom:NO];
            break;
        case EV_WEEKS:
            [self.everyButton setTitle:@"Weeks" forState:UIControlStateNormal];
            [self hideFinishControls:YES];
            if (self.fromLastButton.selected) {
                [self enableStartControls:YES];
            }
            [self startLabelFrom:NO];
            break;
        case EV_MONTHS:
            [self.everyButton setTitle:@"Months" forState:UIControlStateNormal];
            [self hideFinishControls:YES];
            if (self.fromLastButton.selected) {
                [self enableStartControls:YES];
            }
            [self startLabelFrom:NO];
            break;
        default:   // EV_MINUTES
            self.everyMode = 0;  // safety net
            [self.everyButton setTitle:@"Minutes" forState:UIControlStateNormal];
            [self hideFinishControls:NO];
            if (self.fromLastButton.selected) {
                [self enableStartControls:YES];
            }
            [self startLabelFrom:YES];
            break;
    }
    
    //[self updateEnabledButton];
}


- (IBAction)btnHelp:(id)sender {
    DBGLog(@"btnHelp");
}

- (IBAction)monthDaysChange:(id)sender {
    DBGLog(@"monthDaysChange ");
    [self updateEnabledButton];
}

- (void) updateMessage {
    if ([self.lastDefaultMsg isEqualToString:self.msgTF.text]) {
        if ((NO == self.fromLastButton.hidden) && (self.fromLastButton.selected)) {
            if (self.everyTrackerNdx) {
                self.msgTF.text = [NSString stringWithFormat:@"%@ : %@",self.tracker.trackerName,
                                   ((valueObj*)[self.tracker.valObjTable objectAtIndex:(self.everyTrackerNdx-1)]).valueName];
                self.lastDefaultMsg = self.msgTF.text;
                return;
            }
        }
        self.lastDefaultMsg = self.msgTF.text = self.tracker.trackerName;
    }
}
- (void) setEveryTrackerBtnName {
    [self.everyTrackerButton setTitle:[self.everyTrackerNames objectAtIndex:self.everyTrackerNdx] forState:UIControlStateNormal];
    [self.everyTrackerButton setTitleColor:(self.everyTrackerNdx ? [UIColor blueColor] : [UIColor brownColor]) forState:UIControlStateNormal];
    [self updateMessage];
}

- (IBAction)everyTrackerBtn:(id)sender {
    self.everyTrackerNdx = ( self.everyTrackerNdx < [self.everyTrackerNames count]-1 ? self.everyTrackerNdx+1 : 0 );
    [self setEveryTrackerBtnName];
}

- (IBAction)everyTFChange:(UITextField*)sender {
    DBGLog(@"everyTFChange");
    if (0 >= [sender.text intValue]) sender.text=@"";
    [self updateEnabledButton];
}

- (IBAction)messageTFChange:(id)sender {
    DBGLog(@"messageTFChange");
}

-(void) hideWeekdays:(BOOL)state {
    int i;
    for (i=0;i<7;i++) {
        ((UIButton*)[self.weekdayBtns objectAtIndex:i]).hidden=state;
    }
}

-(void) hideMonthdays:(BOOL)state {
    self.monthDaysLabel.hidden=state;
    self.monthDays.hidden=state;
}

-(void) hideEvery:(BOOL)state {
    self.everyTF.hidden=state;
    self.everyButton.hidden=state;
    self.fromLastButton.hidden=state;
    self.fromLastLabel.hidden=state;
    self.everyTrackerButton.hidden=state;
}

- (IBAction)weekMonthEveryChange:(id)sender {
    DBGLog(@"weekMonthEveryChange -- %d --",[sender selectedSegmentIndex]);
    [activeField resignFirstResponder];

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
            [self enableStartControls:(! self.fromLastButton.selected)];
            [self everyBtnStateUpdate];
            [self fromLastBtnStateUpdate];
        break;
            
    }
    [self updateMessage];
    [self updateEnabledButton];
}

-(IBAction) wdBtn:(UIButton*)sender {
    DBGLog(@"wdBtn %@",sender.currentTitle);
    sender.selected = ! sender.selected;
    [self updateEnabledButton];
}

- (void) doEFbtnState {
    
    if (self.enableFinishButton.selected) {
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
        [self startLabelFrom:YES];
    } else {
        self.intervalButton.hidden = YES;
        self.finishSlider.enabled = NO;
        self.finishHr.enabled = NO;
        self.finishMin.enabled = NO;
        if (hasAmPm) self.finishTimeAmPm.enabled = NO;
        self.finishLabel.enabled = NO;
        self.repeatTimes.hidden = YES;
        self.repeatTimesLabel.hidden = YES;
        if ((SEGEVERY == self.weekMonthEvery.selectedSegmentIndex) && ((EV_HOURS == self.everyMode) || (EV_MINUTES == self.everyMode))) {
            [self startLabelFrom:YES];
        } else {
            [self startLabelFrom:NO];
        }
    }
    [self updateEnabledButton];
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

-(IBAction)enableBtn:(UIButton*)sender {
    [self toggleCheckBtn:sender];
    if (! sender.selected) {
        [rTracker_resource alert:@"Reminder disabled" msg:@"This reminder is now disabled.  To delete it, clear the settings and navigate away."];
    }
}

-(IBAction) enableFinishBtn:(UIButton*)sender {
    DBGLog(@"enableFinishBtn");
    [self toggleCheckBtn:sender];
    [self doEFbtnState];
    
    //img = (dfltState ? @"unchecked.png" : @"checked.png"); // going to not default state
    //[btn setImage:[UIImage imageNamed:img] forState: UIControlStateNormal];

    //efBtn.
}

-(IBAction) intervalBtn:(UIButton*)sender {
    DBGLog(@"intervalBtn %@",sender.currentTitle);
    DBGLog(@"everyBtn %@", [self.intervalButton titleForState:UIControlStateNormal]);
    if ([[self.intervalButton titleForState:UIControlStateNormal] isEqualToString:@"random"]) {
        [self.intervalButton setTitle:@"interval" forState:UIControlStateNormal];
    } else {
        [self.intervalButton setTitle:@"random" forState:UIControlStateNormal];
    }
    //((UIButton*)sender).selected = ! ((UIButton*)sender).selected;
}

-(void)sliderUpdate:(int)val hrtf:(UITextField*)hrtf mntf:(UITextField*)mntf ampml:(UILabel*)ampml {
    int hrVal = [self.nr hrVal:val];
    int mnVal = [self.nr mnVal:val];
    
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
    
    [self updateEnabledButton];
}

-(IBAction)startSliderAction:(UISlider*)sender {
    //DBGLog(@"startSlider");
    [self sliderUpdate:(int)sender.value hrtf:self.startHr mntf:self.startMin ampml:self.startTimeAmPm];
}

-(IBAction)finishSliderAction:(UISlider*)sender {
    //DBGLog(@"finishSlider %f",sender.value);
    [self sliderUpdate:(int)sender.value hrtf:self.finishHr mntf:self.finishMin ampml:self.finishTimeAmPm];
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
    [self updateEnabledButton];
}

- (void) limitTimeTF:(UITextField*)tf max:(int)max {
    if (0> [tf.text intValue]) tf.text =@"0";
    if (max< [tf.text intValue]) tf.text =[NSString stringWithFormat:@"%d",max];
}

- (IBAction)startHrChange:(UITextField*)sender {
    DBGLog(@"hrChange %@",sender.text);
    [self limitTimeTF:sender max:23];
    [self timeTfUpdate:startSlider hrtf:self.startHr mntf:self.startMin ampml:self.startTimeAmPm];
}

- (IBAction)startMinChange:(UITextField*)sender {
    DBGLog(@"minChange %@",sender.text);
    [self limitTimeTF:sender max:59];
    [self timeTfUpdate:startSlider hrtf:self.startHr mntf:self.startMin ampml:self.startTimeAmPm];
}

- (IBAction)finishHrChange:(UITextField*)sender {
    DBGLog(@"hrChange %@",sender.text);
    [self limitTimeTF:sender max:23];
    [self timeTfUpdate:finishSlider hrtf:self.finishHr mntf:self.finishMin ampml:self.finishTimeAmPm];
}

- (IBAction)finishMinChange:(UITextField*)sender {
    DBGLog(@"minChange %@",sender.text);
    [self limitTimeTF:sender max:59];
    [self timeTfUpdate:finishSlider hrtf:self.finishHr mntf:self.finishMin ampml:self.finishTimeAmPm];
}

- (IBAction)timesChange:(UITextField*)sender {
    DBGLog(@"timesChange %@",sender.text);
    
    if (2 > [sender.text intValue])  {
        if (self.nr.timesRandom) {
            sender.text = @"1";
        } else {
            sender.text = @"2";
        }
    }
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

- (void)viewDidUnload {
    [self setMsgTF:nil];
    [self setEnableButton:nil];
    [super viewDidUnload];
}

@end
