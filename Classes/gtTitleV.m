//
//  gtTitleV.m
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "gtTitleV.h"


@implementation gtTitleV

@synthesize tracker=_tracker,myFont=_myFont;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // rtm debug
        //[self setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor whiteColor] set];
    
    CGSize tsize = [self.tracker.trackerName sizeWithAttributes:@{NSFontAttributeName:self.myFont}];
    CGPoint tpos = { (self.bounds.size.width - tsize.width)/2.0f,(self.bounds.size.height - tsize.height)/2.0f };  
	if (tpos.x < 0) 
		tpos.x=0;
	if (tpos.y > self.bounds.size.height)
		tpos.y = self.bounds.size.height;
    
	//[self flipCTM];
	//CGAffineTransform tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
	//CGContextConcatCTM(context,tm);
    
	//[self.tracker.trackerName NSFontAttributeName:self.myFont];
    [self.tracker.trackerName drawAtPoint:tpos withAttributes:@{NSFontAttributeName:self.myFont,NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //[self flipCTM];
	//tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
	////CGContextConcatCTM(context,tm);
    
}




#pragma mark -
#pragma mark private methods

- (void) flipCTM 
{
}

- (void) drawTitle {
    
}

@end
