/***************
 gtYAxV.m
 Copyright 2011-2016 Robert T. Miller
 
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
//  gtYAxV.m
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "gtYAxV.h"
#import "vogd.h"
#import "graphTrackerVC.h"
#import "valueObj.h"
#import "trackerObj.h"

#import "graphTracker-constants.h"
#import "gfx.h"

#import "dbg-defs.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"

@implementation gtYAxV
@synthesize vogd=_vogd,myFont=_myFont,scaleOriginY=_scaleOriginY,scaleHeightY=_scaleHeightY,graphSV=_graphSV,parentGTVC=_parentGTVC;  //, backgroundColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // rtm debug
        //[self setBackgroundColor:[UIColor yellowColor]];
        //self.backgroundColor = [UIColor yellowColor];
        //self.opaque = YES;
        //self.alpha = 1.0f;
        
        //DBGLog(@"gtyaxv init done");
    }
    return self;
}

//- (void) setBackgroundColor:(UIColor *) col {
//    DBGLog(@" gtyaxv bg color set to %@", col);
//}

- (void) vtChoiceSetColor:(CGContextRef)context ndx:(int)ndx{
    NSString *cc = [NSString stringWithFormat:@"cc%d",ndx];
    NSInteger col = [(self.vogd.vo.optDict)[cc] integerValue];
    [((UIColor *) [rTracker_resource colorSet][col]) set];
}

NSInteger intSort(id num1, id num2, void *context)
{
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


NSInteger choiceCompare(id ndx0, id ndx1, void *context)
{
    int c0 = [ndx0 intValue];
    int c1 = [ndx1 intValue];
    
    gtYAxV *self = (__bridge gtYAxV *)(context);
    
    NSString *cv0 = [NSString stringWithFormat:@"cv%d", c0];
    NSString *cv1 = [NSString stringWithFormat:@"cv%d", c1];
    
    NSString *v0s = (self.vogd.vo.optDict)[cv0];
    NSString *v1s = (self.vogd.vo.optDict)[cv1];
    
    if ((nil == v0s) || (nil==v1s)) {    // push not-set choices to top of graph
        if (v1s) return NSOrderedDescending;
        else if (v0s) return NSOrderedAscending;
        else return NSOrderedSame;
    }
    
    CGFloat val0 = [ v0s floatValue ] ;
    CGFloat val1 = [ v1s floatValue ] ;
    DBGLog(@"c0 %d c1 %d v0s %@ v1s %@ val0 %f val1 %f",c0,c1,v0s,v1s,val0,val1);
    // need results descending, so reverse test outcome
    if (val0  < val1) return NSOrderedAscending;
    else if (val0 > val1) return NSOrderedDescending;
    else return NSOrderedSame;
}

- (void) drawYAxis:(CGContextRef)context
{
	int i;
    CGFloat svHeight = [self.graphSV contentSize].height;
    CGFloat svOffsetY = svHeight - (self.graphSV.frame.size.height + [self.graphSV contentOffset].y);
    CGFloat unitsPerSVY = f(self.vogd.maxVal - self.vogd.minVal) / svHeight;
    CGFloat startUnit = self.vogd.minVal + (svOffsetY * unitsPerSVY);
    CGFloat finUnit = self.vogd.minVal + ((svOffsetY + self.graphSV.frame.size.height) * unitsPerSVY);
    
	CGFloat unitStep = (finUnit - startUnit) / YTICKS;  

	DBGLog(@"svcofy= %f svoffy= %f  svh= %f min= %f max= %f upsvy= %f scaleh= %f start= %f fin= %f ",[self.graphSV contentOffset].y,svOffsetY,
     svHeight,self.vogd.minVal,self.vogd.maxVal,unitsPerSVY,self.scaleHeightY,startUnit,finUnit);
    
    //CGFloat len = self.bounds.size.height - (CGFloat) (2*BORDER);
	CGFloat step = self.scaleHeightY / YTICKS;
    
    DBGLog(@" %f %f %f",self.scaleHeightY, YTICKS, step);
	CGFloat x0 = self.bounds.size.width;
    CGFloat x1 = x0-TICKLEN;
    CGFloat x2 = x1-3.0f;
    
    NSInteger vtype = self.vogd.vo.vtype;
    NSString *fmt = @"%0.2f";
    
    /*
    NSArray *choiceMap;

    if (VOT_CHOICE == vtype) {
        choiceMap = [CHOICEARR sortedArrayUsingFunction:choiceCompare context:(void*)self];
    }
     */
    //NSString *vsCopy = nil;
    
    for (i=YTICKS; i>=1; i--) {
		CGFloat y = f(i) * step;
		MoveTo(x0,y);
		AddLineTo(x1,y);
        
        
        CGFloat val = startUnit + (f(YTICKS-i) * unitStep);
        NSString *vstr;
        switch (vtype) {
            case VOT_CHOICE:
            {
                if (YTICKS == i) {
                    vstr = @"";
                } else {
                    //DBGLog(@"choiceMap: %@",choiceMap);
                    //NSUInteger ndx = (YTICKS-i)-1;
                    
                    //DBGLog(@"i= %d ndx= %lu",i, (unsigned long) ndx);
                    //DBGLog(@"obj= %@",[choiceMap objectAtIndex:ndx]);
                    //DBGLog(@"choice= %d", [ [choiceMap objectAtIndex:ndx] intValue ]);
                    //int choice = [ [choiceMap objectAtIndex:ndx] intValue ];
                    int choice = [self.vogd.vo getChoiceIndexForValue:[NSString stringWithFormat:@"%f",val]];
                    [self vtChoiceSetColor:context ndx:choice];
                    NSString *ch = [NSString stringWithFormat:@"c%d",choice];
                    vstr = (self.vogd.vo.optDict)[ch];
                }
                break;
            }
                
            case VOT_BOOLEAN:
                if (1 == i) {
                    vstr = (self.vogd.vo.optDict)[@"boolval"];
                    y = 0.2 * step;
                } else {
                    vstr = @"";
                }
                break;

            case VOT_TEXT:
                //case VOT_IMAGE:
                if (1 == i) {
                    vstr = @"1";
                    y = 0.2 * step;
                } else {
                    vstr = @"";
                }
                break;
                
            case VOT_TEXTB:
                if ([(NSString*) (self.vogd.vo.optDict)[@"tbnl"] isEqualToString:@"1"]) { // linecount is a num for graph
                    // fall through to default - handle as number
                } else if (1 == i) {
                    vstr = @"1";
                    y = 0.2 * step;
                    break;
                } else {
                    vstr = @"";
                    break;
                }
                
                //case VOT_NUMBER:
                //case VOT_SLIDER:
                //case VOT_FUNC:

            default:
                if (vtype == VOT_FUNC) {
                    int fnddp = [(self.vogd.vo.optDict)[@"fnddp"] intValue];
                    fmt = [NSString stringWithFormat:@"%%0.%df",fnddp];
                } else if (vtype == VOT_TEXTB) {
                    fmt = @"%0.1f";
                } else {
                    //figure out sig figs for input data and set format here accordingly?
                    //fmt = @"%0.2f";
                    NSString *numddps = (self.vogd.vo.optDict)[@"numddp"];
                    int numddp = [numddps intValue];
                    if ((nil == numddps) || (-1 == numddp)) {
                        if (unitStep < 1.0) {
                            fmt = @"%0.2f";
                        } else if (unitStep < 2.0) {
                            fmt = @"%0.1f";
                        } else {
                            fmt = @"%0.0f";
                        }
                    } else {
                        fmt = [NSString stringWithFormat:@"%%0.%df",numddp];
                    }

                }
                vstr = [NSString stringWithFormat:fmt,val];
                //if ([vstr isEqualToString:vsCopy])
                //    vstr = nil;  // just do once, tho could do better at getting closer to actual value
                //else
                //    vsCopy = vstr;
                
                break;
                
        }
        //CGSize vh = [vstr sizeWithFont:self.myFont];
        //[vstr drawAtPoint:(CGPoint) {(x2 - vh.width ),(y - (vh.height/1.5f))} withFont:self.myFont];
        
        CGSize vh = [vstr sizeWithAttributes:@{NSFontAttributeName:self.myFont}];
        [vstr drawAtPoint:(CGPoint) {(x2 - vh.width ),(y - (vh.height/1.5f))} withAttributes:@{NSFontAttributeName:self.myFont, NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
	}
    
    //[[self.vogd myGraphColor] set];  dictionaryWithObjects
    if (self.vogd) { // can get here with no graph data if only vot_info entries
        [self.vogd.vo.valueName drawAtPoint:(CGPoint) {SPACE5,(self.frame.size.height - BORDER)} withAttributes:@{NSFontAttributeName:self.myFont,NSForegroundColorAttributeName: [self.vogd myGraphColor]}];
    }
    //[self.vogd.vo.valueName drawAtPoint:(CGPoint) {SPACE5,(self.frame.size.height - BORDER)} withFont:self.myFont];
    [[UIColor whiteColor] set];
    
	Stroke;

    // rtm debug
    [self setBackgroundColor:[UIColor yellowColor]];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect( context , [self bounds] );
    [[UIColor whiteColor] set];
    
    MoveTo(self.bounds.size.width,self.scaleOriginY);
    AddLineTo(self.bounds.size.width,self.scaleHeightY);  // scaleOriginY = 0
 
    [self drawYAxis:context];
 
}


#pragma mark -
#pragma mark touch support

- (NSString*) touchReport:(NSSet*)touches {
    
#if DEBUGLOG
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    return [NSString stringWithFormat:@"touch at %f, %f.  taps= %lu  numTouches= %lu",
            touchPoint.x, touchPoint.y, (unsigned long)[touch tapCount], (unsigned long)[touches count]];
#endif
    return @"";
    
}
/*
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches began: %@", [self touchReport:touches]);
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches cancelled: %@", [self touchReport:touches]);
}
*/

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //DBGLog(@"gvc touches ended: %@", [self touchReport:touches]);
    
    UITouch *touch = [touches anyObject];
    if ((1 == [touch tapCount]) && (1 == [touches count]))
        [(graphTrackerVC*) self.parentGTVC yavTap];
    
}

/*
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches moved: %@", [self touchReport:touches]);
}
*/



@end
