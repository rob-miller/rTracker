/***************
 gtXAxV.m
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
//  gtXAxV.m
//  rTracker
//
//  Created by Rob Miller on 12/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "gtXAxV.h"
#import "graphTracker-constants.h"
#import "gfx.h"
#import "dbg-defs.h"

#import "rTracker-constants.h"


@implementation gtXAxV
@synthesize mytogd=_mytogd, myFont=_myFont, scaleOriginX=_scaleOriginX, scaleWidthX=_scaleWidthX,graphSV=_graphSV;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // rtm debug
        //[self setBackgroundColor:[UIColor cyanColor]];
        //self.opaque = YES;
        //self.alpha = 1.0f;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect( context , [self bounds] );
    
    [[UIColor whiteColor] set];
    
    MoveTo(self.scaleOriginX,0.0f);
    AddLineTo(self.scaleWidthX, 0.0f);
    Stroke;
    
    [self drawXAxis:context];
}



#define DOFFST 15.0f

- (void) drawXAxis:(CGContextRef)context {
	int i;
    
    CGFloat svOffsetX = [self.graphSV contentOffset].x;
    CGFloat svWidth = [self.graphSV contentSize].width;
    CGFloat secsPerSVX = f(self.mytogd.lastDate - self.mytogd.firstDate) / svWidth;
    CGFloat startDate = self.mytogd.firstDate + (svOffsetX * secsPerSVX);
    CGFloat finDate = self.mytogd.firstDate + ((svOffsetX + self.scaleWidthX) * secsPerSVX);
    
	CGFloat dateStep = (finDate - startDate) / XTICKS;  
	
	//CGFloat len = self.bounds.size.width - (CGFloat) (2*BORDER);
	CGFloat step = (self.scaleWidthX - (1*BORDER)) / XTICKS;  // ignore scaleOrigin as it is 0
    
	//[self flipCTM:context];
	
    CGFloat nextXt= -2* DOFFST ;
    CGFloat nextXd= -2* DOFFST ;
    
	for (i=1; i<= XTICKS; i++) {
		CGFloat x = (f(i) * step);
		CGFloat y = 0.0f; // self.bounds.size.height - BORDER;
		MoveTo(x,y);
		y += TICKLEN;
		//if (i>0)  // from when 1st tick at origin
			AddLineTo(x,y);

		y += 1.0f;   // skip space to time label
        CGFloat y2 = y+4.0f;  // hack to lengthen ticks where date label can be drawn
        CGFloat x2 = x;   
        
		int date = (int) (startDate + (f(i) * dateStep) +0.5f);
        
		NSDate *sd = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) date];
		NSString *datestr = [NSDateFormatter localizedStringFromDate:sd 
														   dateStyle:(NSDateFormatterStyle)NSDateFormatterShortStyle 
														   timeStyle:(NSDateFormatterStyle)NSDateFormatterShortStyle];
		NSArray *dta = [datestr componentsSeparatedByString:@" "];
        
		NSString *ds = (NSString *) dta[0];
		NSString *ts = (NSString *) dta[1];
        
        ds = [ds stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];

        //DBGLog(@"ds= _%@_  ts= _%@_",ds,ts);  // US region gets comma at end of ds
        
        CGSize dsize = [ds sizeWithAttributes:@{NSFontAttributeName:self.myFont}];
        CGSize tsize = [ts sizeWithAttributes:@{NSFontAttributeName:self.myFont}];
        
		x-= DOFFST;
		if ((i == 1
			||
			dateStep < 24*60*60
			||
             i == XTICKS) && x>nextXt) {
            [ts drawAtPoint:(CGPoint) {x,y} withAttributes:@{NSFontAttributeName:self.myFont,NSForegroundColorAttributeName:[UIColor whiteColor]}];
            nextXt = x+tsize.width;
        }
		
		y += tsize.height; // + 1.0f;
        x-=15.0f;
		if ((i == 1
			||
			dateStep >= 24*60*60
			||
             i == XTICKS) && x>(nextXd+10.0f)) {
            if ((i != 1) && (i != XTICKS))
                AddLineTo(x2, y2);
            [ds drawAtPoint:(CGPoint) {x,y} withAttributes:@{NSFontAttributeName:self.myFont,NSForegroundColorAttributeName:[UIColor whiteColor]}];
            nextXd = x+dsize.width;
        }
		
	}
    
	Stroke;
}


@end
