/*
 *  gfx.h
 *  rTracker
 *
 *  Created by Rob Miller on 02/02/2011.
 *  Copyright 2011 Robert T. Miller. All rights reserved.
 *
 */

#import "rTracker-constants.h"

#define GFXHDEBUG 0

#if GFXHDEBUG 
#define MoveTo(x,y) NSLog(@"mov: %f,%f",x,y); CGContextMoveToPoint(context,(x),(y))
#define AddLineTo(x,y) NSLog(@"lin: %f,%f",x,y); CGContextAddLineToPoint(context,(x),(y))
#define AddCircle(x,y) NSLog(@"cir: %f,%f",x,y); CGContextAddEllipseInRect(context, (CGRect) {{(x),(y)},{4.0f,4.0f}})
#else
#define MoveTo(x,y) CGContextMoveToPoint(context,(x),(y))
#define AddLineTo(x,y) CGContextAddLineToPoint(context,(x),(y))
#define AddCircle(x,y)  CGContextAddEllipseInRect(context, (CGRect) {{(x),(y)},{4.0f,4.0f}})
#endif

#define DevPt(x,y) CGContextConvertPointToUserSpace(context,(CGPoint){(x),(y)})
#define Stroke CGContextStrokePath(context)

