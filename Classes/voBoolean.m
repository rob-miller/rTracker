//
//  voBoolean.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voBoolean.h"


@implementation voBoolean




- (UIImage *) boolBtnImage {
	// default is not checked
	return ( [self.vo.value isEqualToString:@"1"] ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"] );
}

- (void)boolBtnAction:(UIButton *)imageButton
{  // default is unchecked or nil, so only certain is if =1
	if ([self.vo.value isEqualToString:@"1"]) {
		[self.vo.value setString:@"0"];
		[imageButton setImage:[UIImage imageNamed:@"unchecked.png"] forState: UIControlStateNormal];
	} else {  
		[self.vo.value setString:@"1"];
		[imageButton setImage:[UIImage imageNamed:@"checked.png"] forState: UIControlStateNormal];		
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}


- (UIView*) voDisplay:(CGRect)bounds {
	
	UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	imageButton.frame = bounds; //CGRectZero;
	imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
	[imageButton addTarget:self action:@selector(boolBtnAction:) forControlEvents:UIControlEventTouchDown];		
	[imageButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
	
	imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	
	return imageButton;
}

- (NSArray*) voGraphSet {
	return [NSArray arrayWithObjects:@"dots", @"bar", nil];
}

@end
