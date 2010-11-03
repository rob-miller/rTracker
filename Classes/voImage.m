//
//  voImage.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voImage.h"


@implementation voImage

- (UIView*) voDisplay:(CGRect)bounds {
	NSLog(@"image not implemented");
	return nil;
}


- (void) voDrawOptions:(configTVObjVC*)ctvovc {

	CGRect labframe = [ctvovc configLabel:@"need Image Location -- Options:" 
								  frame:(CGRect) {MARGIN,ctvovc.lasty,0.0,0.0}
									key:@"ioLab" 
								  addsv:YES ];
	
	ctvovc.lasty += labframe.size.height + MARGIN;
	[super voDrawOptions:ctvovc];
}


@end
