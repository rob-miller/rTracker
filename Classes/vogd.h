//
//  vogd.h
//  rTracker
//
//  Created by Rob Miller on 10/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "valueObj.h"

@interface vogd : NSObject {
    valueObj *vo;
    NSArray *xdat;
    NSArray *ydat;
    
    double minVal;
    double maxVal;
    
    double vScale;
    
    CGFloat yZero;
}

@property(nonatomic,retain) valueObj *vo;
@property(nonatomic,retain) NSArray *xdat;
@property(nonatomic,retain) NSArray *ydat;
@property(nonatomic) double minVal;
@property(nonatomic) double maxVal;
@property(nonatomic) double vScale;
@property(nonatomic) CGFloat yZero;

- (vogd*) initAsNum:(valueObj*)vo;
- (vogd*) initAsNote:(valueObj*)vo;
- (vogd*) initAsBool:(valueObj*)vo;
- (vogd*) initAsTBoxLC:(valueObj*)vo;

- (UIColor *) myGraphColor;

@end
