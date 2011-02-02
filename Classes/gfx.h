/*
 *  gfx.h
 *  rTracker
 *
 *  Created by Rob Miller on 02/02/2011.
 *  Copyright 2011 Robert T. Miller. All rights reserved.
 *
 */

#define MoveTo(x,y) NSLog(@"mov: %f,%f",x,y); CGContextMoveToPoint(self.context,(x),(y))
#define AddLineTo(x,y) NSLog(@"lin: %f,%f",x,y); CGContextAddLineToPoint(self.context,(x),(y))
#define AddCircle(x,y) NSLog(@"cir: %f,%f",x,y); CGContextAddEllipseInRect(self.context, (CGRect) {{(x),(y)},{4.0f,4.0f}})

#define DevPt(x,y) CGContextConvertPointToUserSpace(self.context,(CGPoint){(x),(y)})
#define Stroke CGContextStrokePath(self.context)

#define f(x) ((CGFloat) (x))
#define d(x) ((double) (x))
