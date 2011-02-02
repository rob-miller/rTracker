//
//  tictacV.m
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "tictacV.h"
#import "gfx.h"

@implementation tictacV

@synthesize context;

//- (id)initWithFrame:(CGRect)frame {
//    if ((self = [super initWithFrame:frame])) {
//        // Initialization code
//    }
//    return self;
//}

- (id)initWithPFrame:(CGRect)ttf {
	ttf.origin.x = 0.2f * ttf.size.width;
	ttf.origin.y = 0.2f * ttf.size.height;
	ttf.size.height *= 0.6f;
	ttf.size.width *= 0.6f;
	NSLog(@"ttv: x=%f y=%f w=%f h=%f",ttf.origin.x,ttf.origin.y,ttf.size.width, ttf.size.height);
	if ((self = [super initWithFrame:ttf])) {
		self.backgroundColor = [UIColor whiteColor];
    }
    return self;
	
}

#define TTBF 0.1f
#define TTSF 0.2667f

- (void) drawTicTac {
	int i;
	CGFloat vborder = TTBF * self.frame.size.height;
	CGFloat hborder = TTBF * self.frame.size.width;
	CGFloat vlen = self.bounds.size.height - (CGFloat) (2*vborder);
	CGFloat hlen = self.bounds.size.width - (CGFloat) (2*hborder);
	CGFloat vstep = self.bounds.size.height * TTSF;
	CGFloat hstep = self.bounds.size.width * TTSF;
	
	[[UIColor greenColor] set];
	MoveTo(hborder,vborder);
	AddLineTo(hborder+hlen,vborder);
	AddLineTo(hborder+hlen,vborder+vlen);
	AddLineTo(hborder,vborder+vlen);
	AddLineTo(hborder,vborder);
	Stroke;
	
	[[UIColor blackColor] set];
	
	for (i=1;i<=2;i++) {
		MoveTo(hborder,vborder+(i*vstep));
		AddLineTo(hborder+hlen,vborder+(i*vstep));
	}
	
	for (i=1;i<=2;i++) {
		MoveTo(hborder+(i*hstep),vborder);
		AddLineTo(hborder+(i*hstep),vborder+vlen);
	}
	Stroke;
}		
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect {
    // Drawing code
	self.context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(self.context, 1.0f);
	CGContextSetAlpha(self.context, 1.0f);
	[self drawTicTac];
}


- (void)dealloc {
    [super dealloc];
}


@end
