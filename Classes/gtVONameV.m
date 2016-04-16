/***************
 gtVONameV.m
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
//  gtVONameV.m
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "gtVONameV.h"

//TODO: is this used???

@implementation gtVONameV

@synthesize currVO=_currVO,myFont=_myFont,voColor=_voColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // rtm debug
        //[self setBackgroundColor:[UIColor purpleColor]];
    }
    return self;
}


// TODO: clean up / eliminate flipCTM calls
- (void) flipCTM:(CGContextRef)context {
    CGAffineTransform tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
    CGContextConcatCTM(context,tm);
} 


- (void) drawCVOnextBtn:(CGContextRef)context {
    CGSize tsize = [@"N" sizeWithAttributes:@{NSFontAttributeName:self.myFont}];  // only need height
    CGPoint tpos = { self.bounds.size.width - tsize.width ,(tsize.height/2.0f) };  // right side
	if (tpos.y > self.bounds.size.height)
		tpos.y = self.bounds.size.height;
    
	[self flipCTM:context];
	[@"N" drawAtPoint:tpos withAttributes:@{NSFontAttributeName:self.myFont,NSForegroundColorAttributeName:[UIColor whiteColor]}];
	[self flipCTM:context];
}

- (void) drawCVOrefreshBtn:(CGContextRef)context {
    CGSize tsize = [@"R" sizeWithAttributes:@{NSFontAttributeName:self.myFont}];  // only need height
    CGPoint tpos = { self.bounds.size.width - (2.0f * tsize.width) ,(tsize.height/2.0f) };  // right side, 1 width in
	if (tpos.y > self.bounds.size.height)
		tpos.y = self.bounds.size.height;
    
	[self flipCTM:context];
	[@"R" drawAtPoint:tpos withAttributes:@{NSFontAttributeName:self.myFont,NSForegroundColorAttributeName:[UIColor whiteColor]}];
	[self flipCTM:context];
}

- (void) drawCVOName:(CGContextRef)context {
    CGSize tsize = [self.currVO.valueName sizeWithAttributes:@{NSFontAttributeName:self.myFont}];
    CGPoint tpos = { 0.0f,(self.bounds.size.height - tsize.height)/2.0f }; // left side of view for vo name
    //CGPoint tpos = { ((self.bounds.size.width/2.0f) - tsize.width)/2.0f,((BORDER - tsize.height)/2.0f) };  // center left half
    //if (tpos.x < 0) 
    //	tpos.x=0;
    if (tpos.y > self.bounds.size.height)
        tpos.y = self.bounds.size.height;
    
    [self flipCTM:context];
    [self.currVO.valueName drawAtPoint:tpos withAttributes:@{NSFontAttributeName:self.myFont,NSForegroundColorAttributeName:[UIColor whiteColor]}];
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
    return [NSString stringWithFormat:@"touch at %f, %f.  taps= %lu  numTouches= %lu",
            touchPoint.x, touchPoint.y, (unsigned long)[touch tapCount], (unsigned long)[touches count]];
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






@end
