//
//  graphTracker.m
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "graphTrackerVC.h"
#import "graphTrackerV.h"
#import "dbg-defs.h"

@implementation graphTrackerVC

@synthesize tracker;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	graphTrackerV *gtv = [[[graphTrackerV alloc]initWithFrame:CGRectZero] autorelease];
	gtv.tracker = self.tracker;
	self.view = gtv;

    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.tracker = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.tracker = nil;
	[tracker release];
	
    [super dealloc];
}

#pragma mark -
# pragma mark view rotation methods

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt should rotate to interface orientation portrait?");
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"gt should rotate to interface orientation portrait upside down?");
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"gt should rotate to interface orientation landscape left?");
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt should rotate to interface orientation landscape right?");
			break;
		default:
			DBGLog(@"gt rotation query but can't tell to where?");
			break;			
	}
	
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown );
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	switch (fromInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt did rotate from interface orientation portrait");
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"gt did rotate from interface orientation portrait upside down");
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"gt did rotate from interface orientation landscape left");
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt did rotate from interface orientation landscape right");
			break;
		default:
			DBGLog(@"gt did rotate but can't tell from where");
			break;			
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog1(@"gt will rotate to interface orientation portrait duration: %f sec",duration);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog1(@"gt will rotate to interface orientation portrait upside down duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog1(@"gt will rotate to interface orientation landscape left duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog1(@"gt will rotate to interface orientation landscape right duration: %f sec", duration);
			break;
		default:
			DBGErr1(@"gt will rotate but can't tell to where duration: %f sec", duration);
			break;			
	}
}

#if (1) 
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog1(@"gt will animate rotation to interface orientation portrait duration: %f sec",duration);
			[self dismissModalViewControllerAnimated:YES];
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog1(@"gt will animate rotation to interface orientation portrait upside down duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog1(@"gt will animate rotation to interface orientation landscape left duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog1(@"gt will animate rotation to interface orientation landscape right duration: %f sec", duration);
			break;
		default:
			DBGErr1(@"gt will animate rotation but can't tell to where duration: %f sec", duration);
			break;			
	}
}

#else 

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	DBGLog1(@"gt will animate first half rotation to interface orientation duration: %@",duration);
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
	DBGLog1(@"gt will animate second half rotation to interface orientation duration: %@",duration);
}
#endif



@end
