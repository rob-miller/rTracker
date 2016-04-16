/***************
 graphTrackerV.m
 Copyright 2010-2016 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

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
#import "rTracker-resource.h"

//#define DEBUGLOG 1


// use layers to get satisfactory resolution for CGContext drawing after zooming
#define USELAYER 1

@implementation graphTrackerV

@synthesize tracker=_tracker,gtvCurrVO=_gtvCurrVO,selectedVO=_selectedVO,doDrawGraph=_doDrawGraph,xMark=_xMark,parentGTVC=_parentGTVC;
@synthesize searchXpoints=_searchXpoints;

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
        self.doDrawGraph = TRUE;  // rtm dbg
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


#pragma mark -
#pragma mark drawing routines

- (void) drawBackground:(CGContextRef)context
{
	[[UIColor purpleColor] set];
	CGContextFillRect(context,self.bounds);
	
}


// note same name call in gtYAxV
- (void) vtChoiceSetColor:(vogd*)vogd context:(CGContextRef)context val:(CGFloat)val{
    DBGLog(@"vtChoiceSetColor input %f",val);
    val /= vogd.vScale;
    val += vogd.minVal;
    DBGLog(@"vtChoiceSetColor transformed %f",val);
    int choice = [vogd.vo getChoiceIndexForValue:[NSString stringWithFormat:@"%f",val]];
    NSString *cc = [NSString stringWithFormat:@"cc%d",choice];
    NSInteger col = [(vogd.vo.optDict)[cc] integerValue];
    CGContextSetFillColorWithColor(context,((UIColor *) [rTracker_resource colorSet][col]).CGColor);
    CGContextSetStrokeColorWithColor(context,((UIColor *) [rTracker_resource colorSet][col]).CGColor);
}

#define LXNOTSTARTED -1.0f

- (void) plotVO_lines:(vogd *)vogd context:(CGContextRef)context dots:(BOOL)dots
{
    
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width;
    BOOL bigger = ( [vogd.xdat count] < 2 ? 1 : 0 );

	BOOL going=NO;
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    CGFloat x=1.0f,y=1.0f;
	for (NSNumber *nx in vogd.xdat) {
        x = [nx floatValue];
        y = [[e nextObject] floatValue];
        if (going) {
            //DBGLog(@"addline %f %f",x,y);
            AddLineTo(x,y);
            if (dots) {
                AddCircle(x,y);
                if (self.selectedVO)
                    AddBigCircle(x,y);
            }
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
                    if (dots) {
                        AddCircle(x,y);
                        if (self.selectedVO)
                            AddBigCircle(x,y);
                    }
                } else { // process starting, need to show lastX plus current
                    MoveTo(lastX, lastY);
                    if (dots) {
                        AddCircle(lastX,lastY);
                        if (self.selectedVO)
                            AddBigCircle(lastX,lastY);
                    }
                    AddLineTo(x,y);
                    if (dots) {
                        AddCircle(x,y);
                        if (self.selectedVO)
                            AddBigCircle(x,y);
                    }                    
                }  
                going=YES;
            } 
        }
    }
    if (bigger) {  // only 1 point, have moved there
        AddCircle(x,y);
        AddBigCircle(x,y);
    }
	
	Stroke;
}

/*
- (void) plotVO_dotsline:(vogd*)vogd context:(CGContextRef)context
{
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width;
    BOOL bigger = ( [vogd.xdat count] < 2 ? 1 : 0 );

	BOOL going=NO;
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    CGFloat x=1.0f,y=1.0f;
	for (NSNumber *nx in vogd.xdat) {
		x = [nx floatValue];
		y = [[e nextObject] floatValue];
        if (going) {
            //DBGLog(@"addline %f %f",x,y);
            AddLineTo(x,y);
            //if (self.selectedVO) {
            //    AddFilledCircle(x,y);             // for some reason, filled circle messes up line
            //} else {
                AddCircle(x,y);
                if (self.selectedVO)
                    AddBigCircle(x,y);
            //}
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
                    //if (self.selectedVO) {
                    //    AddFilledCircle(lastX,lastY);
                    //} else {
                        AddCircle(lastX,lastY);
                        if (self.selectedVO)
                            AddBigCircle(lastX,lastY);
                            //AddFilledCircle(lastX,lastY);
                    //}
                } else { // past 1st data point, need to show lastX plus current
                    //if (self.selectedVO) {
                    //    MoveTo(lastX, lastY);
                    //    AddFilledCircle(lastX,lastY);
                    //    AddLineTo(x,y);
                    //    AddFilledCircle(x,y);
                    //} else {
                        MoveTo(lastX, lastY);
                        AddCircle(lastX,lastY);
                        if (self.selectedVO)
                            AddBigCircle(lastX,lastY);
                            //AddFilledCircle(lastX,lastY);
                        AddLineTo(x,y);
                        AddCircle(x,y);
                        if (self.selectedVO)
                            AddBigCircle(x,y);
                            //AddFilledCircle(x,y);
                    //}
                }
                going=YES;
            } 
        }
	}
    if (bigger) // only 1 point, have moved there already
        AddBigCircle(x,y);
	
	Stroke;
}
*/

- (void) plotVO_dots:(vogd *)vogd context:(CGContextRef)context {
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width;
    
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    BOOL going=NO;
    BOOL bigger = ( [vogd.xdat count] < 3 ? 1 : 0 );  // need to emphasize 2 points so can't do outside loop 
    
	for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];
        if (vogd.vo.vtype == VOT_CHOICE)
            [self vtChoiceSetColor:vogd context:context val:y];
        if (going) {
            //DBGLog(@"moveto %f %f",x,y);
            MoveTo(x,y);
            if (self.selectedVO) {
                AddCross(x,y);
                AddFilledCircle(x,y);
            } else {
                AddCircle(x,y);
            }
            if (bigger && !self.selectedVO)
                AddBigCircle(x,y);
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
                if (self.selectedVO) {
                    AddCross(x,y);
                    AddFilledCircle(lastX,lastY);
                } else {
                    AddCircle(lastX,lastY);
                }
                if (vogd.vo.vtype == VOT_CHOICE)
                    Stroke;
            }
            going=YES;    // going, show current
            MoveTo(x,y);
            if (self.selectedVO) {
                AddCross(x,y);
                AddFilledCircle(x,y);
            } else {
                AddCircle(x,y);
            }
            if (bigger && !self.selectedVO)
                AddBigCircle(x,y);
            
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

/* not used
- (void) plotVO_dotsNoY:(vogd *)vogd context:(CGContextRef)context
{
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width;
    
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    BOOL going=NO;
        
    / *
	NSEnumerator *e = [vogd.ydat objectEnumerator];
    BOOL doText=NO;
    if ((VOT_TEXT == vogd.vo.vtype) && (vogd.vo == self.currVO)) {
        doText = YES;
        CGContextSelectFont(context, FONTNAME, FONTSIZE, kCGEncodingMacRoman);
        CGContextSetTextDrawingMode(context, kCGTextFill);
    }
    * /
    
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
*/

- (void) plotVO_bar:(vogd *)vogd context:(CGContextRef)context barCount:(int)barCount
{
    if (vogd.vo == self.gtvCurrVO) {
        CGContextSetAlpha(context, STD_ALPHA);
        CGContextSetLineWidth(context, BAR_LINE_WIDTH_SEL);
    } else {
        CGContextSetAlpha(context, BAR_ALPHA);
        CGContextSetLineWidth(context, BAR_LINE_WIDTH);
    }

	
    CGFloat barStep = BAR_LINE_WIDTH * (CGFloat) barCount;
    
	NSEnumerator *e = [vogd.ydat objectEnumerator];
	CGRect bbox = CGContextGetClipBoundingBox(context);
	CGFloat minX = bbox.origin.x;
    CGFloat maxX = bbox.origin.x + bbox.size.width + BAR_LINE_WIDTH;
    
    CGFloat lastX=LXNOTSTARTED;
    CGFloat lastY=LXNOTSTARTED;
    BOOL going=NO;
    
    for (NSNumber *nx in vogd.xdat) {
		CGFloat x = [nx floatValue] + barStep;
		CGFloat y = [[e nextObject] floatValue];
        if (vogd.vo.vtype == VOT_CHOICE)
            [self vtChoiceSetColor:vogd context:context val:y];
        
        if (going) {
            //DBGLog(@"moveto %f %f",x,y);
            MoveTo(x,0.0f);
            AddLineTo(x,y);
            //AddCircle(x,y);
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
                //AddCircle(lastX,lastY);
                if (vogd.vo.vtype == VOT_CHOICE)
                    Stroke;
            }
            going=YES;    // going, show current
            MoveTo(x,0.0f);
            AddLineTo(x,y);
            //AddCircle(x,y);
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


- (void) plotVO:(valueObj *)vo context:(CGContextRef)context barCount:(int)barCount {
	//[(UIColor *) [self.tracker.colorSet objectAtIndex:vo.vcolor] set];

    vogd *currVogd = (vogd*) vo.vogd;
    
    if (vo == self.gtvCurrVO) {
        if ((currVogd.minVal < 0.0) && (currVogd.maxVal > 0.0)) {   // draw line at 0 if needed
            //CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
            //CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
            //CGContextSetFillColorWithColor(context,[UIColor colorWithWhite:0.75 alpha:0.5].CGColor);
            CGContextSetStrokeColorWithColor(context,[UIColor colorWithWhite:0.75 alpha:0.5].CGColor);
            MoveTo(0.0f, currVogd.yZero);
            AddLineTo(self.frame.size.width,currVogd.yZero);
            Stroke;            
        }
        
        CGContextSetLineWidth(context, DBL_LINE_WIDTH);
        self.selectedVO=YES;
    } else {
        CGContextSetLineWidth(context, STD_LINE_WIDTH);
        self.selectedVO=NO;
    }
    
    if (vo.vtype != VOT_CHOICE) {
        CGContextSetFillColorWithColor(context,((UIColor *) [rTracker_resource colorSet][vo.vcolor]).CGColor);
        CGContextSetStrokeColorWithColor(context,((UIColor *) [rTracker_resource colorSet][vo.vcolor]).CGColor);
    }

	switch (vo.vGraphType) {
		case VOG_DOTS:  // 25.i.14  bool and text/textbox plot as 1 (or boolval) at top of graph
            switch (vo.vtype) {
                case VOT_NUMBER:
                case VOT_SLIDER:
                case VOT_CHOICE:
                case VOT_FUNC:
                case VOT_BOOLEAN:
                    //[self plotVO_dots:currVogd context:context];
                    //break;
                case VOT_TEXT:
                //case VOT_IMAGE:
                    //[self plotVO_dotsNoY:currVogd context:context];
                    //break;
                default:   // VOT_TEXTB
                    //if ([(NSString*) [vo.optDict objectForKey:@"tbnl"] isEqualToString:@"1"]) { // linecount is a num for graph
                        [self plotVO_dots:currVogd context:context];
                    //} else {
                    //    [self plotVO_dotsNoY:currVogd context:context];
                    //}
                    break;
            }
			break;
		case VOG_BAR:
			[self plotVO_bar:currVogd context:context barCount:barCount];
			break;
		case VOG_LINE:
            [self plotVO_lines:currVogd context:context dots:false];
			break;
		case VOG_DOTSLINE:
			//[self plotVO_dotsline:currVogd context:context];
            [self plotVO_lines:currVogd context:context dots:true];
			break;
		case VOG_PIE:
			DBGErr(@"pie chart not yet supported");
			break;
		case VOG_NONE:  // nothing to do!
			break;
		default:
			DBGErr(@"plotVO: vGraphType %ld not recognised",(long)vo.vGraphType);
			break;
	}
}

- (void) drawGraph:(CGContextRef)context
{
    int barCount=0;
	for (valueObj *vo in self.tracker.valObjTable) {
		if (![(vo.optDict)[@"graph"] isEqualToString:@"0"]) {
            if (VOG_BAR == vo.vGraphType) {
                barCount++;
            }
        }
    }
    barCount /= -2;
    
	for (valueObj *vo in self.tracker.valObjTable) {
        if (vo != self.gtvCurrVO) {
            if (![(vo.optDict)[@"graph"] isEqualToString:@"0"]) {
                //DBGLog(@"drawGraph %@",vo.valueName);
                [self plotVO:vo context:context barCount:barCount];
                if (VOG_BAR == vo.vGraphType) {
                    barCount++;
                }
            }
        }
	}
    // plot selected last for best hightlight
    if (![(self.gtvCurrVO.optDict)[@"graph"] isEqualToString:@"0"]) {
        //DBGLog(@"drawGraph %@",vo.valueName);
        [self plotVO:self.gtvCurrVO context:context barCount:barCount];
        if (VOG_BAR == self.gtvCurrVO.vGraphType) {
            barCount++;
        }
    }

    if (self.xMark != NOXMARK) {
        CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
        CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
        MoveTo(self.xMark, 0.0f);
        AddLineTo(self.xMark,self.frame.size.height);
        Stroke;
    }
    if (self.searchXpoints) {
        //UIColor *smColor = [UIColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:0.7];
        UIColor *smColor = [UIColor colorWithRed:1.0 green:0.1 blue:0.1 alpha:1.0];
        CGContextSetFillColorWithColor(context,smColor.CGColor);
        CGContextSetStrokeColorWithColor(context,smColor.CGColor);
        
        CGContextSetLineWidth(context,SRCH_LINE_WIDTH);
        CGFloat lengths[2] = { 3.0f, 3.0f };
        CGContextSetLineDash(context,0.0f,lengths,2);
        
        for (NSNumber *xm in self.searchXpoints) {
            MoveTo([xm floatValue], 0.0f);
            AddLineTo([xm floatValue],self.frame.size.height);
            Stroke;
        }
        
        CGContextSetLineDash(context,0.0f,NULL,0);
    }
}

#pragma mark -
#pragma mark drawRect


// using layers is a tiled approach, speedup realized because only needed tiles are redrawn.  plotVO_ routines work out if data in tiles.
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
    //DBGLog(@"gtv draw stuff now");
    if (self.doDrawGraph) {
        //DBGLog(@"doDrawGraph is true, gtvCurrVo= %@",self.gtvCurrVO.valueName);
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

#if DEBUGLOG
- (NSString*) touchReport:(NSSet*)touches {
    
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	return [NSString stringWithFormat:@"touch at %f, %f.  taps= %lu  numTouches= %lu",
            touchPoint.x, touchPoint.y, (unsigned long)[touch tapCount], (unsigned long)[touches count]];
    //return @"";

}
#endif
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
