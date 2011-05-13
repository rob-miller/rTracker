//
//  gtYAxV.m
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "gtYAxV.h"
#import "vogd.h"

#import "graphTracker-constants.h"
#import "gfx.h"

#import "rTracker-constants.h"
@implementation gtYAxV
@synthesize vogd,myFont,scaleOriginY,scaleHeightY;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) drawYAxis:(CGContextRef)context 
{
	int i;
	//CGFloat len = self.bounds.size.height - (CGFloat) (2*BORDER);
	CGFloat step = self.scaleHeightY / YTICKS;
	CGFloat x0 = self.bounds.size.width;
    CGFloat x1 = x0-TICKLEN;
    
	for (i=0; i<=YTICKS; i++) {
		CGFloat y = f(i) * step;
		MoveTo(x0,y);
		AddLineTo(x1,y);
	}
	Stroke;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
 CGContextRef context = UIGraphicsGetCurrentContext();
 [[UIColor whiteColor] set];
 
 MoveTo(self.bounds.size.width,self.scaleOriginY);
 AddLineTo(self.bounds.size.width,self.scaleHeightY);
 
    [self drawYAxis:context];
 
}




- (void)dealloc
{
    [super dealloc];
}

@end
