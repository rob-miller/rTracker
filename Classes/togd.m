//
//  togd.m
//  rTracker
//
//  Created by Rob Miller on 10/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "togd.h"
#import "valueObj.h"
#import "vostate.h"

#import "rTracker-constants.h"
#import "dbg-defs.h"

@implementation togd
@synthesize pto, rect, firstDate, lastDate, dateScale;

- (id) init {
    return ([self initWithData:nil rect:CGRectZero]);
}

- (id) initWithData:(trackerObj*)pTracker rect:(CGRect) inRect {
    if ((self = [super init])) {
        self.pto = pTracker;
        self.rect = inRect;
        
        self.pto.sql = @"select min(date) from voData;";
        self.firstDate = [self.pto toQry2Int];
        self.pto.sql = @"select max(date) from voData;";
        self.lastDate =  [self.pto toQry2Int];
        self.pto.sql = nil;
        
        self.dateScale = d(rect.size.width) / (d(self.lastDate) - d(self.firstDate));
        
    }
    return self;
}

- (void) fillVOGDs {
    for (valueObj *vo in self.pto.valObjTable) {
        vo.vogd = [vo.vos getVOGD];
    }    
}

- (void) dealloc {
    self.pto = nil;
    [pto release];
    [super dealloc];
}

@end
