/***************
 tictac.h
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
