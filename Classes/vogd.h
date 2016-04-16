/***************
 vogd.h
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
//  vogd.h
//
//  Value Object Graph Data
//
//  rTracker
//
//  Created by Rob Miller on 10/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "valueObj.h"

@interface vogd : NSObject
/*{
    valueObj *vo;
    NSArray *xdat;
    NSArray *ydat;
    
    double minVal;
    double maxVal;
    
    double vScale;
    
    CGFloat yZero;
}*/

@property(nonatomic,strong) valueObj *vo;
@property(nonatomic,strong) NSArray *xdat;
@property(nonatomic,strong) NSArray *ydat;
@property(nonatomic) double minVal;
@property(nonatomic) double maxVal;
@property(nonatomic) double vScale;
@property(nonatomic) CGFloat yZero;

- (vogd*) initAsNum:(valueObj*)vo;
- (vogd*) initAsNote:(valueObj*)vo;
//- (vogd*) initAsBool:(valueObj*)vo;
- (vogd*) initAsTBoxLC:(valueObj*)vo;

- (UIColor *) myGraphColor;

@end
