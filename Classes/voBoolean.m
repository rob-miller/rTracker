//
//  voBoolean.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voBoolean.h"
#import "dbg-defs.h"

@implementation voBoolean

@synthesize imageButton;

- (void) dealloc {
	DBGLog(@"dealloc voBoolean");
	//self.imageButton = nil;  // convenience constructor
    //[imageButton release];
                         
	[super dealloc];
	
}

- (int) getValCap {  // NSMutableString size for value
    return 1;
}

- (UIImage *) boolBtnImage {
	// default is not checked
	return ( [self.vo.value isEqualToString:@"1"] ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"] );
}

- (void)boolBtnAction:(UIButton *)imageButton
{  // default is unchecked or nil, so only certain is if =1
	if ([self.vo.value isEqualToString:@"1"]) {
		[self.vo.value setString:@""];
		[self.imageButton setImage:[UIImage imageNamed:@"unchecked.png"] forState: UIControlStateNormal];
	} else {  
		[self.vo.value setString:@"1"];
		[self.imageButton setImage:[UIImage imageNamed:@"checked.png"] forState: UIControlStateNormal];		
	}

	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (UIButton*) imageButton {
	if (nil == imageButton) {
        imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = self.vosFrame; //CGRectZero;
        imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
        [imageButton addTarget:self action:@selector(boolBtnAction:) forControlEvents:UIControlEventTouchDown];		
        imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
    return imageButton;
}

- (UIView*) voDisplay:(CGRect)bounds {
    self.vosFrame = bounds;
	[self.imageButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
    
    DBGLog(@"bool voDisplay: %d", ([self.imageButton imageForState:UIControlStateNormal] == [UIImage imageNamed:@"checked.png"] ? 1 : 0) );
	return self.imageButton;
}

- (NSArray*) voGraphSet {
	return [NSArray arrayWithObjects:@"dots", @"bar", nil];
}

#pragma mark -
#pragma mark graph display
/*
- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    
    [self transformVO_bool:xdat ydat:ydat dscale:dscale height:height border:border firstDate:firstDate];
    
}
*/

- (id) newVOGD {
    return [[vogd alloc] initAsBool:self.vo];
}





@end
