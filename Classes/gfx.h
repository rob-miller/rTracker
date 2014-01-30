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

#define MTPrim(x,y) CGContextMoveToPoint(context,(x),(y))
#define ALPrim(x,y) CGContextAddLineToPoint(context,(x),(y))
#define AEPrim(x,y) CGContextAddEllipseInRect(context, (CGRect) {{(x-2.0f),(y-2.0f)},{4.0f,4.0f}}); CGContextMoveToPoint(context,(x),(y))
#define AFEPrim(x,y) CGContextFillEllipseInRect(context, (CGRect) {{(x-4.0f),(y-4.0f)},{8.0f,8.0f}}); CGContextMoveToPoint(context,(x),(y))
#define AE2Prim(x,y) CGContextAddEllipseInRect(context, (CGRect) {{(x-3.0f),(y-3.0f)},{6.0f,6.0f}}); CGContextMoveToPoint(context,(x),(y))

#if GFXHDEBUG
#define MoveTo(x,y) NSLog(@"mov: %f,%f",x,y); MTPrim(x,y)
#define AddLineTo(x,y) NSLog(@"lin: %f,%f",x,y); ALPrim(x,y)
#define AddCircle(x,y) NSLog(@"cir: %f,%f",x,y); AEPrim(x,y)
#define AddFilledCircle(x,y) NSLog(@"fcir: %f,%f",x,y); AFEPrim(x,y)
#define AddBigCircle(x,y) NSLog(@"big cir: %f,%f",x,y); AE2Prim(x,y)
#else
//#define MoveTo(x,y) CGContextMoveToPoint(context,(x),(y))
//#define AddLineTo(x,y) CGContextAddLineToPoint(context,(x),(y))
//#define AddCircle(x,y) CGContextAddEllipseInRect(context, (CGRect) {{(x-2.0f),(y-2.0f)},{4.0f,4.0f}})
//; CGContextAddEllipseInRect(context, (CGRect) {{(x-1.0f),(y-1.0f)},{2.0f,2.0f}})
#define MoveTo(x,y) MTPrim(x,y)
#define AddLineTo(x,y) ALPrim(x,y)
#define AddCircle(x,y) AEPrim(x,y)
#define AddFilledCircle(x,y) AFEPrim(x,y)
#define AddBigCircle(x,y) AE2Prim(x,y)
#endif

#define DevPt(x,y) CGContextConvertPointToUserSpace(context,(CGPoint){(x),(y)})
#define Stroke CGContextStrokePath(context)

