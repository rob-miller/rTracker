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

@implementation gtYAxV
@synthesize vogd,myFont,scaleOriginY,scaleHeightY,graphSV,parentGTVC;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) vtChoiceSetColor:(CGContextRef)context val:(CGFloat)val{
    NSString *cc = [NSString stringWithFormat:@"cc%d",(int)(val-1.0f)];
    NSInteger col = [[self.vogd.vo.optDict objectForKey:cc] integerValue];
    [[((trackerObj*)self.vogd.vo.parentTracker).colorSet objectAtIndex:col] set];
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

	//DBGLog(@"svcofy= %f svoffy= %f  svh= %f max= %f min= %f upsvy= %f scaleh= %f start= %f fin= %f ",[self.graphSV contentOffset].y,svOffsetY,
    // svHeight,self.vogd.minVal,self.vogd.maxVal,unitsPerSVY,self.scaleHeightY,startUnit,finUnit);
    
    //CGFloat len = self.bounds.size.height - (CGFloat) (2*BORDER);
	CGFloat step = self.scaleHeightY / YTICKS;
	CGFloat x0 = self.bounds.size.width;
    CGFloat x1 = x0-TICKLEN;
    CGFloat x2 = x1-3.0f;
    
    NSInteger vtype = self.vogd.vo.vtype;
    NSString *fmt = @"%0.2f";
    
	for (i=YTICKS; i>=1; i--) {
		CGFloat y = f(i) * step;
		MoveTo(x0,y);
		AddLineTo(x1,y);
        
        
        CGFloat val = startUnit + (f(YTICKS-i) * unitStep);
        NSString *vstr;
        switch (vtype) {
            case VOT_CHOICE:
                [self vtChoiceSetColor:context val:val];
                NSString *ch = [NSString stringWithFormat:@"c%d",(int)(val-1.0f)];
                vstr = [self.vogd.vo.optDict objectForKey:ch];
                break;
            case VOT_TEXT:
            case VOT_BOOLEAN:
            //case VOT_IMAGE:
                vstr = @"";
                break;
                
            case VOT_TEXTB:
                if ([(NSString*) [self.vogd.vo.optDict objectForKey:@"tbnl"] isEqualToString:@"1"]) { // linecount is a num for graph
                    // fall through to default - handle as number
                } else {
                    vstr = @"";
                    break;
                }
                
                //case VOT_NUMBER:
                //case VOT_SLIDER:
                //case VOT_FUNC:
                
            default:
                if (vtype == VOT_FUNC) {
                    int fnddp = [[self.vogd.vo.optDict objectForKey:@"fnddp"] intValue];
                    fmt = [NSString stringWithFormat:@"%%0.%df",fnddp];
                } else if (vtype == VOT_TEXTB) {
                    fmt = @"%0.1f";
                } else {
                    fmt = @"%0.2f";
                }
                vstr = [NSString stringWithFormat:fmt,val];
                break;
                
        }
        CGSize vh = [vstr sizeWithFont:myFont];
        [vstr drawAtPoint:(CGPoint) {(x2 - vh.width ),(y - (vh.height/1.5f))} withFont:self.myFont];
	}
    
    [[self.vogd myGraphColor] set];
    [self.vogd.vo.valueName drawAtPoint:(CGPoint) {SPACE5,(self.frame.size.height - BORDER)} withFont:self.myFont];
    [[UIColor whiteColor] set];
    
	Stroke;
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
    return [NSString stringWithFormat:@"touch at %f, %f.  taps= %d  numTouches= %d",
            touchPoint.x, touchPoint.y, [touch tapCount], [touches count]];
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


- (void)dealloc
{
    [super dealloc];
}

@end
