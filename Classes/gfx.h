/***************
 gfx.h
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

#define CGPush CGContextSaveGState(context)
#define CGPop CGContextRestoreGState(context)

#define MTPrim(x,y) CGContextMoveToPoint(context,(x),(y))
#define ALPrim(x,y) CGContextAddLineToPoint(context,(x),(y))
#define AEPrim(x,y) CGContextAddEllipseInRect(context, (CGRect) {{(x-2.0f),(y-2.0f)},{4.0f,4.0f}}); CGContextMoveToPoint(context,(x),(y))
#define AFEPrim(x,y) CGContextFillEllipseInRect(context, (CGRect) {{(x-4.0f),(y-4.0f)},{8.0f,8.0f}}); CGContextMoveToPoint(context,(x),(y))
#define AE2Prim(x,y) CGContextAddEllipseInRect(context, (CGRect) {{(x-3.0f),(y-3.0f)},{6.0f ,6.0f }}); CGContextMoveToPoint(context,(x),(y))
#define ACPrim(x,y) CGPush; CGContextSetLineWidth(context,2); CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);\
CGContextMoveToPoint(context,(x-8.0f),(y)); CGContextAddLineToPoint(context,(x+8.0f),(y)); \
CGContextMoveToPoint(context,(x),(y-8.0f)); CGContextAddLineToPoint(context,(x),(y+8.0f)); \
CGContextMoveToPoint(context,(x),(y)); CGContextDrawPath(context, kCGPathFillStroke); CGPop

#if GFXHDEBUG
#define MoveTo(x,y) NSLog(@"mov: %f,%f",x,y); MTPrim(x,y)
#define AddLineTo(x,y) NSLog(@"lin: %f,%f",x,y); ALPrim(x,y)
#define AddCircle(x,y) NSLog(@"cir: %f,%f",x,y); AEPrim(x,y)
#define AddFilledCircle(x,y) NSLog(@"fcir: %f,%f",x,y); AFEPrim(x,y)
#define AddCross(x,y) NSLog(@"cross: %f,%f",x,y); ACPrim(x,y)
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
#define AddCross(x,y) ACPrim(x,y)
#define AddBigCircle(x,y) AE2Prim(x,y)
#endif

#define DevPt(x,y) CGContextConvertPointToUserSpace(context,(CGPoint){(x),(y)})
#define Stroke CGContextStrokePath(context)

