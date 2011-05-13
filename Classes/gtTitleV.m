//
//  gtTitleV.m
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "gtTitleV.h"


@implementation gtTitleV

@synthesize tracker,myFont;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor whiteColor] set];
    
	CGSize tsize = [self.tracker.trackerName sizeWithFont:myFont];
    CGPoint tpos = { (self.bounds.size.width - tsize.width)/2.0f,(self.bounds.size.height - tsize.height)/2.0f };  
	if (tpos.x < 0) 
		tpos.x=0;
	if (tpos.y > self.bounds.size.height)
		tpos.y = self.bounds.size.height;
    
	//[self flipCTM];
	//CGAffineTransform tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
	//CGContextConcatCTM(context,tm);
    
	[self.tracker.trackerName drawAtPoint:tpos withFont:myFont];
	//[self flipCTM];
	//tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
	////CGContextConcatCTM(context,tm);
    
}


- (void)dealloc
{
    self.tracker = nil;
    [tracker release];
    [super dealloc];
}


#pragma mark -
#pragma mark private methods

- (void) flipCTM 
{
}

- (void) drawTitle {
    
}

@end
