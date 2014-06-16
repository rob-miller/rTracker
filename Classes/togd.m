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
@synthesize pto=_pto, rect=_rect, bbox=_bbox, firstDate=_firstDate, lastDate=_lastDate, dateScale=_dateScale, dateScaleInv=_dateScaleInv;

- (id) init {
    return ([self initWithData:nil rect:CGRectZero]);
}

- (id) initWithData:(trackerObj*)pTracker rect:(CGRect) inRect {
    if ((self = [super init])) {
        self.pto = pTracker;
        self.rect = inRect;
        self.bbox = inRect;
        
        self.pto.sql = @"select max(date) from voData;";
        self.lastDate =  [self.pto toQry2Int];
        
        int gmd = [[self.pto.optDict valueForKey:@"graphMaxDays"] intValue];
        if (0 != gmd) {
            int tFirstDate;
            gmd *= 60*60*24; // secs per day
            tFirstDate = self.lastDate - gmd;
            self.pto.sql = [NSString stringWithFormat:@"select min(date) from voData where date >= %d;",tFirstDate];
        } else {
            self.pto.sql = @"select min(date) from voData;";
        }
        self.firstDate = [self.pto toQry2Int];
        self.pto.sql = nil;
        
        if (self.firstDate == self.lastDate) {
            self.firstDate -= 60*60*24; // secs per day -- single data point so arbitrarily set scale to 1 day
        }
        
        int dateScaleExpand = (int) ((((double) self.lastDate - self.firstDate) * GRAPHSCALE) + d(0.5));
        self.lastDate += dateScaleExpand;
        self.firstDate -= dateScaleExpand;
        
        self.dateScale = d(self.rect.size.width) / (d(self.lastDate) - d(self.firstDate));
        self.dateScaleInv = d(self.lastDate - self.firstDate) / d(self.rect.size.width);
        
    }
    return self;
}

- (void) fillVOGDs {
    for (valueObj *vo in self.pto.valObjTable) {
        id tvogd = [vo.vos newVOGD];
        vo.vogd = tvogd;
        //[vo.vogd release]; // rtm 05 feb 2012  +1 for new (alloc), +1 for vo retain
    }    
}


@end
