//
//  gtVONameV.m
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "gtVONameV.h"


@implementation gtVONameV

@synthesize currVO,myFont,voColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// TODO: clean up / eliminate flipCTM calls
- (void) flipCTM:(CGContextRef)context {
    CGAffineTransform tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
    CGContextConcatCTM(context,tm);
} 


- (void) drawCVOnextBtn:(CGContextRef)context {
	CGSize tsize = [@"N" sizeWithFont:self.myFont];  // only need height
    CGPoint tpos = { self.bounds.size.width - tsize.width ,(tsize.height/2.0f) };  // right side
	if (tpos.y > self.bounds.size.height)
		tpos.y = self.bounds.size.height;
    
	[self flipCTM:context];
	[@"N" drawAtPoint:tpos withFont:myFont];
	[self flipCTM:context];
}

- (void) drawCVOrefreshBtn:(CGContextRef)context {
	CGSize tsize = [@"R" sizeWithFont:self.myFont];  // only need height
    CGPoint tpos = { self.bounds.size.width - (2.0f * tsize.width) ,(tsize.height/2.0f) };  // right side, 1 width in
	if (tpos.y > self.bounds.size.height)
		tpos.y = self.bounds.size.height;
    
	[self flipCTM:context];
	[@"R" drawAtPoint:tpos withFont:myFont];
	[self flipCTM:context];
}

- (void) drawCVOName:(CGContextRef)context {
    CGSize tsize = [self.currVO.valueName sizeWithFont:myFont];
    CGPoint tpos = { 0.0f,(self.bounds.size.height - tsize.height)/2.0f }; // left side of view for vo name
    //CGPoint tpos = { ((self.bounds.size.width/2.0f) - tsize.width)/2.0f,((BORDER - tsize.height)/2.0f) };  // center left half
    //if (tpos.x < 0) 
    //	tpos.x=0;
    if (tpos.y > self.bounds.size.height)
        tpos.y = self.bounds.size.height;
    
    [self flipCTM:context];
    [self.currVO.valueName drawAtPoint:tpos withFont:myFont];
    [self flipCTM:context];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	[self.voColor set];
    
    [self drawCVOName:context];
    [self drawCVOnextBtn:context];
}
    

#pragma mark -
#pragma mark touch support

- (NSString*) touchReport:(NSSet*)touches {
    
#if DEBUGLOG
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    return [NSString stringWithFormat:@"touch at %f, %f.  taps= %d  numTouches= %d",
            touchPoint.x, touchPoint.y, [touch tapCount], [touches count]];
#endif
    return @"";
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches began: %@", [self touchReport:touches]);
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches cancelled: %@", [self touchReport:touches]);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches ended: %@", [self touchReport:touches]);
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches moved: %@", [self touchReport:touches]);
}





- (void)dealloc
{
    self.currVO = nil;
    [currVO release];
    self.myFont = nil;
    [myFont release];
    self.voColor = nil;
    [voColor release];
    
    [super dealloc];
}

@end
