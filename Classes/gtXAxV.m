//
//  gtXAxV.m
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "gtXAxV.h"
#import "graphTracker-constants.h"
#import "gfx.h"

#import "rTracker-constants.h"


@implementation gtXAxV
@synthesize togd, myFont, scaleOriginX, scaleWidthX;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    
    MoveTo(self.scaleOriginX,0.0f);
    AddLineTo(self.scaleWidthX, 0.0f);
    Stroke;
    
    [self drawXAxis:context];
}


// TODO: clean up / eliminate flipCTM calls
- (void) flipCTM:(CGContextRef)context {
    CGAffineTransform tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
    CGContextConcatCTM(context,tm);
}

#define DOFFST 10.0f

- (void) drawXAxis:(CGContextRef)context {
	int i;
	CGFloat dateStep = f(self.togd.lastDate - self.togd.firstDate) / XTICKS;  // togd.dateScale is based on togd.rect
	
	//CGFloat len = self.bounds.size.width - (CGFloat) (2*BORDER);
	CGFloat step = (self.scaleWidthX - (2*BORDER)) / XTICKS;
    
	//[self flipCTM:context];
	
    CGFloat nextXt= -2* DOFFST ;
    CGFloat nextXd= -2* DOFFST ;
    
	for (i=0; i<= XTICKS; i++) {
		CGFloat x = BORDER + (f(i) * step);
		CGFloat y = 0.0f; // self.bounds.size.height - BORDER;
		MoveTo(x,y);
		y += TICKLEN;
		//if (i>0)  // from when 1st tick at origin
			AddLineTo(x,y);
		y += 1.0f;
		int date = self.togd.firstDate + (int) ((f(i) * dateStep) +0.5f);
        
		NSDate *sd = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) date];
		NSString *datestr = [NSDateFormatter localizedStringFromDate:sd 
														   dateStyle:(NSDateFormatterStyle)NSDateFormatterShortStyle 
														   timeStyle:(NSDateFormatterStyle)NSDateFormatterShortStyle];
		NSArray *dta = [datestr componentsSeparatedByString:@" "];
        
		NSString *ds = (NSString *) [dta objectAtIndex:0];
		NSString *ts = (NSString *) [dta objectAtIndex:1];
        
		CGSize dsize = [ds sizeWithFont:myFont];
		CGSize tsize = [ts sizeWithFont:myFont];
        
		x-= DOFFST;
		if ((i == 0
			||
			dateStep < 24*60*60
			||
             i == XTICKS) && x>nextXt) {
			[ts drawAtPoint:(CGPoint) {x,y} withFont:self.myFont];
            nextXt = x+tsize.width;
        }
		
		y += tsize.height; // + 1.0f;
		if ((i == 0
			||
			dateStep >= 24*60*60
			||
             i == XTICKS) && x>nextXd) {
            [ds drawAtPoint:(CGPoint) {x,y} withFont:self.myFont];
            nextXd = x+dsize.width;
        }
		
	}
    
	Stroke;
	
	/*
     const char *ds = [(NSString *) [dta objectAtIndex:0] UTF8String];
     const char *ts = [(NSString *) [dta objectAtIndex:1] UTF8String];
     
     CGContextShowTextAtPoint (self.context, BORDER, 0, ds, strlen(ds));
     CGContextShowTextAtPoint (self.context, BORDER, BORDER/2.0f, ts, strlen(ts));
	 * /
     
     
     CGPoint tpos1,tpos2;
     tpos1.x = BORDER;
     tpos2.x = BORDER;
     tpos1.y = self.bounds.size.height - BORDER + (BORDER - (2*tsize.height));
     tpos2.y = self.bounds.size.height - BORDER + (BORDER - tsize.height);
     
     tsize = [ts sizeWithFont:myFont];
     [ts drawAtPoint:tpos2 withFont:myFont];
     
     sd = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)self.lastDate];
     datestr = [NSDateFormatter localizedStringFromDate:sd dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
     dta = [datestr componentsSeparatedByString:@" "];
     / *
     ds = [(NSString *) [dta objectAtIndex:0] UTF8String];
     ts = [(NSString *) [dta objectAtIndex:1] UTF8String];
     
     CGContextShowTextAtPoint (self.context, self.bounds.size.width-(2.0f*BORDER), 0, ds, strlen(ds));
     CGContextShowTextAtPoint (self.context, self.bounds.size.width-(2.0f*BORDER), BORDER/2.0f, ts, strlen(ts));
	 * /
     
     ds = (NSString *) [dta objectAtIndex:0];
     ts = (NSString *) [dta objectAtIndex:1];
     
     tpos1.x = self.bounds.size.width-(2.0f*BORDER);
     tpos2.x = self.bounds.size.width-(2.0f*BORDER);
     
     [ds drawAtPoint:tpos1 withFont:myFont];
     [ts drawAtPoint:tpos2 withFont:myFont];
     
	 */
	
	//[self flipCTM:context];
	
}

- (void)dealloc
{
    self.myFont = nil;
    [myFont release];
    self.togd = nil;
    [togd release];
    
    [super dealloc];
}

@end
