//
//  voDataEdit.m
//  rTracker
//
//  Created by Robert Miller on 10/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

// implements textbox editor

#import "voDataEdit.h"
#import "dbg-defs.h"

@implementation voDataEdit

@synthesize vo;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	DBGLog(@"vde view did load");
	self.title = self.vo.valueName;
	[self.vo.vos dataEditVDidLoad:self];
	
}

- (void) viewWillAppear:(BOOL)animated {
	[self.vo.vos dataEditVWAppear:self];
    [super viewWillAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
	[self.vo.vos dataEditVWDisappear:self];
    [super viewWillDisappear:animated];
}

/*
 // needs more work to adjust text box size / display point as rotated view is very short
 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	DBGLog(@"vde view did unload");
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self.vo.vos dataEditVDidUnload];
	self.vo = nil;
}


- (void)dealloc {
	
	DBGLog(@"vde dealloc");
	self.vo = nil;
	//[vo release];

    [super dealloc];
}


@end
