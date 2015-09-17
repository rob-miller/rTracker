//
//  numField.m
//  rTracker
//
//  Created by Rob Miller on 15/09/2015.
//  Copyright (c) 2015 Robert T. Miller. All rights reserved.
//

#import "numField.h"
#import "rTracker-resource.h"

@implementation numField

- (void) minusKey {
    self.text = [rTracker_resource negateNumField:self.text];
}

@end
