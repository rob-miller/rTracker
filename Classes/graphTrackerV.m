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
//#import "togd.h"
#import "graphTrackerVC.h"

#import "graphTracker-constants.h"

#import "dbg-defs.h"

//#define DEBUGLOG 1


// use layers to get satisfactory resolution for CGContext drawing after zooming
#define USELAYER 1

@implementation graphTrackerV

@synthesize tracker,currVO,doDrawGraph,xMark,parentGTVC;

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
        
#if USELAYER        
        //from scrollview programming guide listing 3-3
        CATiledLayer *tempTiledLayer = (CATiledLayer*)self.layer;
        tempTiledLayer.levelsOfDetail = 5;
        tempTiledLayer.levelsOfDetailBias = 2;
#endif
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
    self.parentGTVC = nil;
    [parentGTVC release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark drawing routines

- (void) drawBackground:(CGContextRef)context
{
	[[UIColor purpleColor] set];
	CGContextFillRect(context,self.bounds);
	
}



- (void) vtChoiceSetColor:(vogd*)vogd context:(CGContextRef)context val:(CGFloat)val{
    NSString *cc = [NSString stringWithFormat:@"cc%d",(int)((val-1.0f) / vogd.vScale)];
    NSInteger col = [[vogd.vo.optDict objectForKey:cc] integerValue];
    CGContextSetFillColorWithColor(context,((UIColor *) [self.tracker.colorSet objectAtIndex:col]).CGColor);
    CGContextSetStrokeColorWithColor(context,((UIColor *) [self.tracker.colorSet objectAtIndex:col]).CGColor);
}

#define LXNOTSTARTED -1.0f

- (void) plotVO_lines:(vogd *)vogd context:(CGContextRef)context
{
    
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width;
    
	BOOL going=NO;
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    
	for (NSNumber *nx in vogd.xdat) {
        CGFloat x = [nx floatValue];
        CGFloat y = [[e nextObject] floatValue];
        if (going) {
            //DBGLog(@"addline %f %f",x,y);
            AddLineTo(x,y);
            if (x > maxX)
                break; //going=NO;                
        } else {  // not started yet
            if (x<minX) {      // not started, save current for next time
                lastX = x;
                lastY = y;
            } else {           // start drawing
                if (lastX == LXNOTSTARTED) { // 1st time through, 1st point needs showing
                    //DBGLog(@"moveto %f %f",x,y);
                    MoveTo(x,y);
                } else { // process starting, need to show lastX plus current
                    MoveTo(lastX, lastY);
                    AddLineTo(x,y);
                }  
                going=YES;
            } 
        }
    }
	
	Stroke;
}


- (void) plotVO_dotsline:(vogd*)vogd context:(CGContextRef)context
{
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width;
    
	BOOL going=NO;
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
	for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];
        if (going) {
            //DBGLog(@"addline %f %f",x,y);
            AddLineTo(x,y);
            AddCircle(x,y);
            if (x > maxX)
                break; //going=NO;   // done
        } else {  // not started yet
            if (x < minX) {  // keep processing until start drawing
                lastX = x;
                lastY = y;
            } else { // start drawing
                if (lastX == LXNOTSTARTED) { // 1st time through, 1st point needs showing
                    //DBGLog(@"moveto %f %f",x,y);
                    MoveTo(x,y);
                    AddCircle(x,y);
                } else { // past 1st data point, need to show lastX plus current
                    MoveTo(lastX, lastY);
                    AddCircle(lastX,lastY);
                    AddLineTo(x,y);
                    AddCircle(x,y);
                }
                going=YES;
            } 
        }
	}
	
	Stroke;
}

- (void) plotVO_dots:(vogd *)vogd context:(CGContextRef)context {
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width;
    
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    BOOL going=NO;
    
	for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];
        if (vogd.vo.vtype == VOT_CHOICE)
            [self vtChoiceSetColor:vogd context:context val:y];
        if (going) {
            //DBGLog(@"moveto %f %f",x,y);
            MoveTo(x,y);
            AddCircle(x,y);
            if (vogd.vo.vtype == VOT_CHOICE)
                Stroke;
            if (x > maxX)
                break; 
        } else if (x < minX) { // not started yet and keep skipping -- save current for next time
            lastX = x;
            lastY = y;
        } else {              // not started yet, start now
            if (lastX != LXNOTSTARTED) {  // past 1st data point, need to show lastX 
                MoveTo(lastX,lastY);
                AddCircle(lastX,lastY);
                if (vogd.vo.vtype == VOT_CHOICE)
                    Stroke;
            }
            going=YES;    // going, show current
            MoveTo(x,y);
            AddCircle(x,y);
            if (vogd.vo.vtype == VOT_CHOICE)
                Stroke;
        }  
    }
    
	Stroke;
}
// TODO: enable putting text on graph
/*
 - complicated by layers and multi-threading
 - works with USELAYERS=0
 
- (void) addText:(vogd*)vogd context:(CGContextRef)context x:(CGFloat)x y:(CGFloat)y e:(NSEnumerator*)e {

    x+= 3.0f;
    y+= 3.0f;
    AddLineTo(x,y);
    x+= 3.0f;
    AddLineTo(x, y);
    NSString *str = [e nextObject];
    CGContextShowTextAtPoint(context, x, y, [str UTF8String], [str length]);
    //[str drawAtPoint:(CGPoint) {x,y} withFont:((graphTrackerVC*)self.parentGTVC).myFont];
    //Stroke;
}
*/

- (void) plotVO_dotsNoY:(vogd *)vogd context:(CGContextRef)context
{
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width;
    
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    BOOL going=NO;
        
    /*
	NSEnumerator *e = [vogd.ydat objectEnumerator];
    BOOL doText=NO;
    if ((VOT_TEXT == vogd.vo.vtype) && (vogd.vo == self.currVO)) {
        doText = YES;
        CGContextSelectFont(context, FONTNAME, FONTSIZE, kCGEncodingMacRoman);
        CGContextSetTextDrawingMode(context, kCGTextFill);
    }
    */
    
	for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = 2.0f; //[[e nextObject] floatValue];
        if (going) {
            //DBGLog(@"moveto %f %f",x,y);
            MoveTo(x,y);
            AddCircle(x,y);
            //if (doText) [self addText:vogd context:context x:x y:y e:e];
            if (x > maxX)
                break; 
        } else if (x < minX) { // not started yet and keep skipping -- save current for next time
            lastX = x;
            lastY = y;
        } else {              // not started yet, start now
            if (lastX != LXNOTSTARTED) {  // past 1st data point, need to show lastX 
                MoveTo(lastX,lastY);
                AddCircle(lastX,lastY);
                //if (doText) [self addText:vogd context:context x:x y:y e:e];
            }
            going=YES;    // going, show current
            MoveTo(x,y);
            AddCircle(x,y);
            //if (doText) [self addText:vogd context:context x:x y:y e:e];
        }  
    }
    
	Stroke;
}

- (void) plotVO_bar:(vogd *)vogd context:(CGContextRef)context
{
	CGContextSetAlpha(context, BAR_ALPHA);
	CGContextSetLineWidth(context, BAR_LINE_WIDTH);
	
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width + BAR_LINE_WIDTH;
    
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    BOOL going=NO;
    
    for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];
        if (vogd.vo.vtype == VOT_CHOICE)
            [self vtChoiceSetColor:vogd context:context val:y];
        
        if (going) {
            //DBGLog(@"moveto %f %f",x,y);
            MoveTo(x,0.0f);
            AddLineTo(x,y);
            AddCircle(x,y);
            if (vogd.vo.vtype == VOT_CHOICE)
                Stroke;
            if (x > maxX)
                break; 
        } else if (x < minX) { // not started yet and keep skipping -- save current for next time
            lastX = x;
            lastY = y;
        } else {              // not started yet, start now
            if (lastX != LXNOTSTARTED) {  // past 1st data point, need to show lastX 
                MoveTo(lastX,0.0f);
                AddLineTo(lastX,lastY);
                AddCircle(lastX,lastY);
                if (vogd.vo.vtype == VOT_CHOICE)
                    Stroke;
            }
            going=YES;    // going, show current
            MoveTo(x,0.0f);
            AddLineTo(x,y);
            AddCircle(x,y);
            if (vogd.vo.vtype == VOT_CHOICE)
                Stroke;
        }  
    }
    
    if (vogd.vo.vtype != VOT_CHOICE)
        Stroke;
	//Stroke;
	
	CGContextSetAlpha(context, STD_ALPHA);
	CGContextSetLineWidth(context, STD_LINE_WIDTH);
	
}


- (void) plotVO:(valueObj *)vo context:(CGContextRef)context
{
	//[(UIColor *) [self.tracker.colorSet objectAtIndex:vo.vcolor] set];
    if (vo.vtype != VOT_CHOICE) {
        CGContextSetFillColorWithColor(context,((UIColor *) [self.tracker.colorSet objectAtIndex:vo.vcolor]).CGColor);
        CGContextSetStrokeColorWithColor(context,((UIColor *) [self.tracker.colorSet objectAtIndex:vo.vcolor]).CGColor);
    }
    if (vo == self.currVO) {
        CGContextSetLineWidth(context, DBL_LINE_WIDTH);
    } else {
        CGContextSetLineWidth(context, STD_LINE_WIDTH);
    }
	switch (vo.vGraphType) {
		case VOG_DOTS:
            switch (vo.vtype) {
                case VOT_NUMBER:
                case VOT_SLIDER:
                case VOT_CHOICE:
                case VOT_FUNC:
                    [self plotVO_dots:(vogd*)vo.vogd context:context];
                    break;
                case VOT_TEXT:
                case VOT_BOOLEAN:
                case VOT_IMAGE:
                    [self plotVO_dotsNoY:(vogd*)vo.vogd context:context];
                    break;
                default:   // VOT_TEXTB
                    if ([(NSString*) [vo.optDict objectForKey:@"tbnl"] isEqualToString:@"1"]) { // linecount is a num for graph
                        [self plotVO_dots:(vogd*)vo.vogd context:context];
                    } else {
                        [self plotVO_dotsNoY:(vogd*)vo.vogd context:context];
                    }
                    break;
            }
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
		
    if (self.xMark != NOXMARK) {
        CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
        CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
        MoveTo(self.xMark, 0.0f);
        AddLineTo(self.xMark,self.frame.size.height);
        Stroke;
    }
     
}

#pragma mark -
#pragma mark drawRect


#if USELAYER

+(Class)layerClass {
    return [CATiledLayer class];
}

// Implement -drawRect: so that the UIView class works correctly
// Real drawing work is done in -drawLayer:inContext
-(void)drawRect:(CGRect)r {
//    self.context = UIGraphicsGetCurrentContext();
//    [self drawLayer:self.layer inContext:self.context];
}

/// multi-threaded !!!!
-(void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context {
    //NSLog(@"drawLayer here...");
    
//- (void)drawRect:(CGRect)rect {
    //((togd*)self.tracker.togd).bbox = CGContextGetClipBoundingBox(context);
#else
-(void)drawRect:(CGRect)r {
    CGContextRef context = UIGraphicsGetCurrentContext();
#endif
    if (self.doDrawGraph) {
        /*
        if ((CGContextRef)0 == inContext) {
            self.context = UIGraphicsGetCurrentContext();
        } else {
            self.context = inContext;
        }
         */
        //CGContextSetLineWidth(context, STD_LINE_WIDTH);
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

- (NSString*) touchReport:(NSSet*)touches {
    
#if DEBUGLOG
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	return [NSString stringWithFormat:@"touch at %f, %f.  taps= %d  numTouches= %d",
            touchPoint.x, touchPoint.y, [touch tapCount], [touches count]];
#endif
    return @"";

}
/*
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"touches began: %@", [self touchReport:touches]);
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"touches cancelled: %@", [self touchReport:touches]);
}
*/
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //DBGLog(@"touches ended: %@", [self touchReport:touches]);
    
    [(graphTrackerVC*) self.parentGTVC gtvTap:touches];
    
}
/*
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"touches moved: %@", [self touchReport:touches]);
}
*/



@end
