//
//  tictacV.h
//  rTracker
//
//  Created by Robert Miller on 20/01/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "tObjBase.h"

@interface tictacV : UIView
/*
 {
	tObjBase *tob;
	unsigned int key;
	int currX;
	int currY;
	CGRect currRect;
//	BOOL flag;
}*/

@property (nonatomic,strong) tObjBase *tob;
@property (nonatomic) unsigned int key;
@property (nonatomic) CGRect currRect;
@property (nonatomic) int currX;
@property (nonatomic) int currY;

// region definitions
@property (nonatomic) CGFloat vborder;
@property (nonatomic) CGFloat hborder;
@property (nonatomic) CGFloat vlen;
@property (nonatomic) CGFloat hlen;
@property (nonatomic) CGFloat vstep;
@property (nonatomic) CGFloat hstep;

// UI element properties 
@property(nonatomic) CGContextRef context;
@property(nonatomic,strong) UIFont *myFont;

- (id) initWithPFrame:(CGRect)parent;
- (void) showKey:(unsigned int)k;


@end
