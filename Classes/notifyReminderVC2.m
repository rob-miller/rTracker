/***************
 notifyReminderVC2.m
 Copyright 2014-2021 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

//
//  notifyReminderVC2.m
//  rTracker
//
//  Created by Rob Miller on 19/04/2014.
//  Copyright (c) 2014 Robert T. Miller. All rights reserved.
//

#import "notifyReminderVC2.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"
#import "notifyReminder.h"

//@interface notifyReminderVC2 ()
//@end

@implementation notifyReminderVC2

@synthesize parentNRVC=_parentNRVC, soundFiles=_soundFiles;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSMutableArray *sfa = [[NSMutableArray alloc]init];
        self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)self.parentNRVC.nr.saveDate];
        
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:NULL];
        for (NSString *fileName in files) {
            if ([fileName hasSuffix:@".caf"]) {
                [sfa addObject:fileName];
            }
        }
        self.soundFiles = [NSArray arrayWithArray:sfa];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)self.parentNRVC.nr.saveDate];
    [self.btnHelpOutlet setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont systemFontOfSize:28.0]
                                              //,NSForegroundColorAttributeName: [UIColor greenColor]
                                              } forState:UIControlStateNormal];

    self.btnDoneOutlet.title = @"\u2611";
    [self.btnDoneOutlet setTitleTextAttributes:@{
                                                 NSFontAttributeName: [UIFont systemFontOfSize:28.0]
                                                 //,NSForegroundColorAttributeName: [UIColor greenColor]
                                                 } forState:UIControlStateNormal];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewSwipeRight:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];


    // Do any additional setup after loading the view.
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self.view setNeedsDisplay];
}

- (void)handleViewSwipeRight:(UISwipeGestureRecognizer *)gesture {
    [self btnDone:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)self.parentNRVC.nr.saveDate];
    unsigned long ndx = [self.soundFiles indexOfObject:self.parentNRVC.nr.soundFileName];
    if ((nil == self.parentNRVC.nr.soundFileName) || (NSNotFound == ndx)) {
        [self.soundPicker selectRow:[self.soundFiles count] inComponent:0 animated:false];
        self.btnTestOutlet.enabled=false;
    } else {
        [self.soundPicker selectRow:ndx inComponent:0 animated:false];
        self.btnTestOutlet.enabled=true;
    }
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnHelp:(id)sender {
    DBGLog(@"btnHelp");
    [rTracker_resource alert:@"Reminder details" msg:@"Set the start date and time for the reminder delay here if not based on the last tracker save.\nSet the sound to be played when the reminder is triggered.  The default sound cannot be played while rTracker is the active application." vc:self];
}

- (IBAction)btnTest:(id)sender {
    DBGLog(@"btnTest");
    //[self.parentNRVC.nr present];
    //[self.parentNRVC.nr schedule:[NSDate dateWithTimeIntervalSinceNow:1]];
    [self.parentNRVC.nr playSound];
    
}

- (IBAction)btnDone:(id)sender
{
	//ios6 [self dismissModalViewControllerAnimated:YES];
    DBGLog(@"leaving - datepicker says %@",self.datePicker.date);
    self.parentNRVC.nr.saveDate = (int)[self.datePicker.date timeIntervalSince1970];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
- (void)viewDidUnload {
    [self setDatePicker:nil];
    [self setSoundPicker:nil];
    [self setBtnTestOutlet:nil];
    [super viewDidUnload];
}
*/

#pragma mark -
#pragma mark Picker Data Source Methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
    return [self.soundFiles count]+2;
}

#pragma mark Picker Delegate Methods

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component {
    NSUInteger c = [self.soundFiles count];
    if (row < c) {
        return [[(self.soundFiles)[row]
                 stringByReplacingOccurrencesOfString:@"_" withString:@" "]
                stringByReplacingOccurrencesOfString:@".caf" withString:@""];
    } else if (row == c) {
        return @"Default";
    } else {
        return @"Silent";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSUInteger c = [self.soundFiles count];
    if (row < c) {
        self.parentNRVC.nr.soundFileName = (self.soundFiles)[row];
        self.btnTestOutlet.enabled=true;
    } else {
        self.btnTestOutlet.enabled=false;
        if (row == c) {
            self.parentNRVC.nr.soundFileName = nil;
        } else {
            self.parentNRVC.nr.soundFileName = @"Silent";
        }
    }
}



@end
