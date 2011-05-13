//
//  graphTrackerV.m
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "graphTrackerV.h"
#import "gfx.h"
#import "vogd.h"

#import "graphTracker-constants.h"

#import "dbg-defs.h"

//#define DEBUGLOG 1



@implementation graphTrackerV

@synthesize tracker,doDrawGraph;

/*
-(id)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];
    if(self) {
        CATiledLayer *tempTiledLayer = (CATiledLayer*)self.layer;
        tempTiledLayer.levelsOfDetail = 5;
        tempTiledLayer.levelsOfDetailBias = 2;
        self.opaque=YES;
    }
    return self;
}
*/

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        //from scrollview programming guide listing 3-3
        
        CATiledLayer *tempTiledLayer = (CATiledLayer*)self.layer;
        tempTiledLayer.levelsOfDetail = 5;
        tempTiledLayer.levelsOfDetailBias = 2;
        self.opaque=NO;
        
    }
    return self;
}
/*
- (void)setTransform:(CGAffineTransform)newValue;
{
    CGAffineTransform constrainedTransform = CGAffineTransformIdentity;
    constrainedTransform.a = newValue.a;
    [super setTransform:constrainedTransform];
}
*/

- (void)dealloc {
	self.tracker = nil;
    [tracker release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark drawing routines

- (void) drawBackground:(CGContextRef)context
{
	[[UIColor purpleColor] set];
	CGContextFillRect(context,self.bounds);
	
}






- (void) plotVO_lines:(vogd *)vogd context:(CGContextRef)context
{
    
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	
	BOOL going=NO;
	for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];
		if (going) {
			//DBGLog(@"addline %f %f",x,y);
			AddLineTo(x,y);
		} else {
			//DBGLog(@"moveto %f %f",x,y);
			MoveTo(x,y);
			going=1;
		}
	}
	
	Stroke;
}


- (void) plotVO_dotsline:(vogd*)vogd context:(CGContextRef)context
{
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	
	BOOL going=NO;
	for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];
		if (going) {
			//DBGLog(@"addline %f %f",x,y);
			AddLineTo(x,y);
			AddCircle(x,y);
		} else {
			//DBGLog(@"moveto %f %f",x,y);
			MoveTo(x,y);
			AddCircle(x,y);
			going=1;
		}
	}
	
	Stroke;
}

- (void) plotVO_dots:(vogd *)vogd context:(CGContextRef)context
{
    NSArray *lydat = [[NSArray alloc] initWithArray:vogd.ydat];
	NSEnumerator *e = [lydat objectEnumerator];
	NSArray *lxdat = [[NSArray alloc] initWithArray:vogd.xdat];
    
	for (NSNumber *nx in lxdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];

		//DBGLog(@"moveto %f %f",x,y);
		MoveTo(x,y);
		AddCircle(x,y);
	}
	
	Stroke;
}

- (void) plotVO_bar:(vogd *)vogd context:(CGContextRef)context
{
	CGContextSetAlpha(context, BAR_ALPHA);
	
	CGContextSetLineWidth(context, BAR_LINE_WIDTH);
	
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	
	for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];

		DBGLog(@"bar to %f %f",x,y);
		MoveTo(x,BORDER);
		AddLineTo(x,y);
		AddCircle(x,y);
	}
	
	Stroke;
	
	CGContextSetAlpha(context, STD_ALPHA);
	CGContextSetLineWidth(context, STD_LINE_WIDTH);
	
}


- (void) plotVO:(valueObj *)vo context:(CGContextRef)context
{
	//[(UIColor *) [self.tracker.colorSet objectAtIndex:vo.vcolor] set];
    CGContextSetFillColorWithColor(context,((UIColor *) [self.tracker.colorSet objectAtIndex:vo.vcolor]).CGColor);
    CGContextSetStrokeColorWithColor(context,((UIColor *) [self.tracker.colorSet objectAtIndex:vo.vcolor]).CGColor);
	switch (vo.vGraphType) {
		case VOG_DOTS:
			[self plotVO_dots:(vogd*)vo.vogd context:context];
			break;
		case VOG_BAR:
			[self plotVO_bar:(vogd*)vo.vogd context:context];
			break;
		case VOG_LINE:
			[self plotVO_lines:(vogd*)vo.vogd context:context];
			break;
		case VOG_DOTSLINE:
			[self plotVO_dotsline:(vogd*)vo.vogd context:context];
			break;
		case VOG_PIE:
			DBGErr(@"pie chart not yet supported");
			break;
		case VOG_NONE:  // nothing to do!
			break;
		default:
			DBGErr(@"plotVO: vGraphType %d not recognised",vo.vGraphType);
			break;
	}
}

- (void) drawGraph:(CGContextRef)context
{
	for (valueObj *vo in self.tracker.valObjTable) {
		if (![[vo.optDict objectForKey:@"graph"] isEqualToString:@"0"]) {
			[self plotVO:vo context:context];
        }
	}
		
}

#pragma mark -
#pragma mark drawRect

+(Class)layerClass {
    return [CATiledLayer class];
}

// Implement -drawRect: so that the UIView class works correctly
// Real drawing work is done in -drawLayer:inContext
-(void)drawRect:(CGRect)r
{
//    self.context = UIGraphicsGetCurrentContext();
//    [self drawLayer:self.layer inContext:self.context];
}

/// multi-threaded !!!!
-(void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    //NSLog(@"drawLayer here...");
    
//- (void)drawRect:(CGRect)rect {
    
    if (self.doDrawGraph) {
        /*
        if ((CGContextRef)0 == inContext) {
            self.context = UIGraphicsGetCurrentContext();
        } else {
            self.context = inContext;
        }
         */
        CGContextSetLineWidth(context, STD_LINE_WIDTH);
        CGContextSetAlpha(context, STD_ALPHA);
        
        
        // transform y to origin at lower left ( -y + height )
        CGAffineTransform tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
        // scale x to date range -- unfortunately buggered because line width is in user coords applied to both x and y
        //CGAffineTransform tm = { ((self.bounds.size.width - 2.0f*BORDER) / (lastDate - firstDate)) , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
        CGContextConcatCTM(context,tm);
        // put the text back to normal ... why do they do this?
        //CGAffineTransform tm2 = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, 0.0f };
        //CGContextSetTextMatrix(self.context, tm2);
        /*
         CGContextSelectFont (self.context, 
         "Helvetica-Bold",
         FONTSIZE,
         kCGEncodingMacRoman);
         CGContextSetCharacterSpacing (self.context, 1); 
         CGContextSetTextDrawingMode (self.context, kCGTextFill); 
         */
        //self.myFont = [UIFont fontWithName:[NSString stringWithUTF8String:FONTNAME] size:FONTSIZE];
        //self.myFont = [UIFont systemFontOfSize:FONTSIZE];
        
        //[self drawBackground];
        [self drawGraph:context];
    }
    
}


#pragma mark -
#pragma mark touch support
/*
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
    DBGLog(@"touches began: %@", [self touchReport:touches]);
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"touches cancelled: %@", [self touchReport:touches]);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"touches ended: %@", [self touchReport:touches]);
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"touches moved: %@", [self touchReport:touches]);
}
*/



@end
