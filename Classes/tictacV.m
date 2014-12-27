//
//  tictacV.m
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "tictacV.h"
#import "gfx.h"
#import "privDefs.h"
#import "dbg-defs.h"

@implementation tictacV

@synthesize context=_context,tob=_tob,key=_key,vborder=_vborder,hborder=_hborder,vlen=_vlen,hlen=_hlen,vstep=_vstep, hstep=_hstep, myFont=_myFont, currRect=_currRect, currX=_currX, currY=_currY;

#pragma mark key singleton access 

static unsigned int theKey;

- (unsigned int) key {
	return theKey;
}
- (void) setKey:(unsigned int)k {
	DBGLog(@"setKey: %u -> %u",theKey,k);
	theKey = k;
}


#pragma mark core object

//- (id)initWithFrame:(CGRect)frame {
//    if ((self = [super initWithFrame:frame])) {
//        // Initialization code
//    }
//    return self;
//}

- (id)initWithPFrame:(CGRect)ttf {
	ttf.origin.x = TICTACHRZFRAC * ttf.size.width;
	ttf.origin.y = TICTACVRTFRAC * ttf.size.height;
	ttf.size.width *= TICTACWIDFRAC;
	ttf.size.height *= TICTACHGTFRAC;
	//DBGLog(@"ttv: x=%f y=%f w=%f h=%f",ttf.origin.x,ttf.origin.y,ttf.size.width, ttf.size.height);
	if ((self = [super initWithFrame:ttf])) {
		self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;  // doesn't work, probably overwriting rectangle elsewhere
    }
    return self;
}




#pragma mark -
#pragma mark draw view

#define TTBF 0.1f
#define TTSF 0.2667f

- (void) drawTicTac {
	int i;
	self.vborder = TTBF * self.frame.size.height;
	self.hborder = TTBF * self.frame.size.width;
	self.vlen = self.bounds.size.height - (CGFloat) (2*self.vborder);
	self.hlen = self.bounds.size.width - (CGFloat) (2*self.hborder);
	self.vstep = self.bounds.size.height * TTSF;
	self.hstep = self.bounds.size.width * TTSF;
	
    CGContextRef context = self.context;
    
	[[UIColor greenColor] set];
	MoveTo(self.hborder,self.vborder);
	AddLineTo(self.hborder+self.hlen,self.vborder);
	AddLineTo(self.hborder+self.hlen,self.vborder+self.vlen);
	AddLineTo(self.hborder,self.vborder+self.vlen);
	AddLineTo(self.hborder,self.vborder);
	Stroke;
	
	[[UIColor blackColor] set];
	
	for (i=1;i<=2;i++) {   // horiz lines
		MoveTo(self.hborder,self.vborder+(i*self.vstep));
		AddLineTo(self.hborder+self.hlen,self.vborder+(i*self.vstep));
	}
	
	for (i=1;i<=2;i++) {   // vert lines
		MoveTo(self.hborder+(i*self.hstep),self.vborder);
		AddLineTo(self.hborder+(i*self.hstep),self.vborder+self.vlen);
	}
	Stroke;
}		

#pragma mark bitfuncs to get selected bits from key

#define REGIONMASK(x,y) ((((unsigned int)0x03) << (y<<1))<<(x*2*3))
#define REGIONINC(x,y)  ((((unsigned int)0x01) << (y<<1))<<(x*2*3))
#define REGIONVAL(v,x,y) ( ( ((v) & REGIONMASK(x,y)) >> (y<<1))>>(x*2*3) )

#pragma mark translate tic-tac-toe regions to view coords upper left corner

- (CGPoint) tt2vc {
	CGPoint ret = (CGPoint) { 0.0f, 0.0f };
	ret.x = self.hborder+(self.currX*self.hstep);
	ret.y = self.vborder+(self.currY*self.vstep);
	//ret.size.width = self.hstep;
	//ret.size.height = self.vstep;

	return ret;
}

#pragma mark draw current state

- (void) drawBlank {
	[[UIColor whiteColor] set];	
	CGContextFillRect(self.context,self.currRect);
    //self.layer.cornerRadius = 8;
    
}

- (void) sDraw:(NSString*)str {
	
	//[str drawAtPoint:self.currRect.origin withFont:myFont];
	//[str drawInRect:self.currRect withFont:self.myFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    [str drawInRect:self.currRect withAttributes:@{NSFontAttributeName:self.myFont, NSParagraphStyleAttributeName: paragraphStyle}];
}

- (void) setCurrPt:(int)x y:(int)y {
	CGRect rect;
	self.currX = x;
	self.currY = y;
	rect.origin = [self tt2vc];
	rect.size.width =self.hstep;
	rect.size.height =self.vstep;
	self.currRect = rect;
	//DBGLog(@"currPt: %d %d",x,y);
}

- (void) setNoCurrPt {
	//DBGLog(@"no curr pt");
	self.currX = -1;
	self.currY = -1;
}

- (BOOL) currPt {
	return (self.currX > -1);
}

- (void) drawCell {
	[self drawBlank];
	[[UIColor blackColor] set];
	switch (REGIONVAL(self.key, self.currX,self.currY)) {
		case 0x00:
			//DBGLog(@"00");
			break;
		case 0x01:
			//DBGLog(@"01");
			[self sDraw:@"X"];
			break;
		case 0x02:
			//DBGLog(@"10");
			[self sDraw:@"O"];
			break;
		case 0x03:
			//DBGLog(@"11");
			[self sDraw:@"+"];
			break;
		default:
			dbgNSAssert(0,@"drawCell bad region val");
			break;
	}
}

- (void) updateTT {
//	if ([self currPt]) {
//		DBGLog(@"updateTT: draw cell %d %d",self.currX,self.currY);
//		[self drawCell];
//	} else {  
		int i,j;
		//DBGLog(@"updateTT: draw all cells");
		for (i=0;i<3;i++) {
			for (j=0;j<3;j++) {
				[self setCurrPt:i y:j];
				[self drawCell];
			}
		}
//	}
	[self setNoCurrPt];
}

#pragma mark handle region press

- (void) press:(int) x y:(int)y {
	[self setCurrPt:x y:y];
	DBGLog(@"press: %d,%d  => %f %f %f %f",x,y,
		  self.currRect.origin.x,self.currRect.origin.y,
		  self.currRect.size.width,self.currRect.size.height);
	
	//unsigned int rmask = REGIONMASK(x,y);
	//unsigned int rinc =  REGIONINC(x,y);
	unsigned int newVal = self.key;					// copy current key
	unsigned int currBits= newVal & REGIONMASK(x,y);	// select bits for this press
	currBits += REGIONINC(x,y);							// inc state
	currBits &= REGIONMASK(x,y);						// wipe overflow 0x3-> 0x4 0b0011 -> 0b0100
	newVal &= ~REGIONMASK(x,y);							// clear bits in current key
	newVal |= currBits;									// set new bits
	
	self.key = newVal;
	[self setNeedsDisplayInRect:self.currRect];
	//[self setNeedsDisplay];
}

#pragma mark translate view coords to tic-tac-toe regions
- (int) ttx:(int)x {
	int i;
	for (i=1;i<3;i++)
		if (x < self.hborder+(i*self.hstep))
			return i-1;
	return i-1;
}

- (int) tty:(int)y {
	int i;
	for (i=1;i<3;i++)
		if (y < self.vborder+(i*self.vstep))
			return i-1;
	return i-1;
}

#pragma mark api: draw current key

- (void) showKey:(unsigned int)k {
	self.key = k;  //rtm lskdfjasldfjasdlfjksldfkj
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark UIView drawing

#define FONTNAME "Helvetica-Bold"
#define FONTSIZE 20

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect {
    // Drawing code
	self.context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(self.context, 1.0f);
	CGContextSetAlpha(self.context, 1.0f);
	self.myFont = [UIFont fontWithName:@FONTNAME size:FONTSIZE];
	[self updateTT];
	[self drawTicTac];
	
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	//DBGLog(@"ttv: I am touched at %f, %f => x:%d y:%d",touchPoint.x, touchPoint.y,[self ttx:touchPoint.x], [self tty:touchPoint.y]);
	[self press:[self ttx:touchPoint.x] y:[self tty:touchPoint.y]];
	[self resignFirstResponder];
}


@end
