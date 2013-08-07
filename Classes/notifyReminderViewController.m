//
//  notifyReminderViewController.m
//  rTracker
//
//  Created by Rob Miller on 07/08/2013.
//  Copyright (c) 2013 Robert T. Miller. All rights reserved.
//

#import "notifyReminderViewController.h"
#import "dbg-defs.h"

//@interface notifyReminderViewController ()

//@end

@implementation notifyReminderViewController

@synthesize tracker, startHr, startMin, finishHr, finishMin, repeatTimes, finishSlider, intervalButton;

- (void)btnDone:(UIButton *)btn
{
	//ios6 [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title=@"hello";
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
    self.toolBar.items = [NSArray arrayWithObjects: doneBtn, nil];

	[doneBtn release];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) wdBtn:(id)sender {
    DBGLog(@"wdBtn %@",((UIButton*)sender).currentTitle);
}

-(IBAction) enableFinishBtn:(id)sender {
    DBGLog(@"enableFinishBtn");
    UIButton *efBtn = (UIButton*)sender;
    
    UIImage *chkImg = [UIImage imageNamed:@"checked.png"];
    UIImage *unchkImg = [UIImage imageNamed:@"unchecked.png"];
    
    if (efBtn.currentImage == chkImg) {
        [efBtn setImage:unchkImg forState: UIControlStateNormal];
        self.intervalButton.enabled = NO;
        self.finishSlider.enabled = NO;
        self.finishHr.enabled = NO;
        self.finishMin.enabled = NO;
        self.repeatTimes.enabled = NO;
    } else if (efBtn.currentImage == unchkImg) {
        [efBtn setImage:chkImg forState: UIControlStateNormal];
        self.intervalButton.enabled = YES;
        self.finishSlider.enabled = YES;
        self.finishHr.enabled = YES;
        self.finishMin.enabled = YES;
        self.repeatTimes.enabled = YES;
    } else {
        DBGLog(@"no image for efbtn");
    }
    
    //img = (dfltState ? @"unchecked.png" : @"checked.png"); // going to not default state
    //[btn setImage:[UIImage imageNamed:img] forState: UIControlStateNormal];

    //efBtn.
}

-(IBAction) intervalBtn:(id)sender {
    DBGLog(@"intervalBtn %@",((UIButton*)sender).currentTitle);
}

-(IBAction)startSliderAction:(id)sender {
    DBGLog(@"startSlider %f",((UISlider*)sender).value);
}

-(IBAction)finishSliderAction:(id)sender {
    DBGLog(@"finishSlider %f",((UISlider*)sender).value);
}

- (IBAction)hrChange:(id)sender {
    DBGLog(@"hrChange %@",((UITextField*)sender).text);
}

- (IBAction)minChange:(id)sender {
    DBGLog(@"minChange %@",((UITextField*)sender).text);
}

- (IBAction)timesChange:(id)sender {
    DBGLog(@"timesChange %@",((UITextField*)sender).text);
}



@end
