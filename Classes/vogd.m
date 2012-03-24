//
//  vogd.m
//  rTracker
//
//  Created by Rob Miller on 10/05/2011.
//  Copyright 2011 Robert T. Miller. All rights reserved.
//

#import "vogd.h"
#import "trackerObj.h"
#import "togd.h"

#import "dbg-defs.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"
#import "graphTracker-constants.h"

@implementation vogd

@synthesize vo,xdat,ydat,minVal,maxVal,vScale,yZero;

- (id) init {
    DBGErr(@"vogd: invalid init!");
    self = [super init];
    return self;
}

- (double) getMinMax:(NSString*)targ alt:(NSString*)alt {
    double retval=0.0;
    if (nil != alt) {
        if ([[NSScanner localizedScannerWithString:alt] scanDouble:&retval]) {
            return retval;
        }
    }
    trackerObj *myTracker = (trackerObj*) self.vo.parentTracker;
    myTracker.sql = [NSString stringWithFormat:@"select %@(val collate CMPSTRDBL) from voData where id=%d and val != '';",targ,self.vo.vid];
    return [myTracker toQry2Double];
}

- (id) initAsNum:(valueObj*)inVO {
    if ((self = [super init])) {

        self.vo = inVO;
        self.yZero = 0.0F;
        
        //double dscale = d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate);
        
        trackerObj *myTracker = (trackerObj*) self.vo.parentTracker;
        togd *myTOGD = myTracker.togd;
        
        if ((self.vo.vtype == VOT_NUMBER || self.vo.vtype == VOT_FUNC) 
            && ([@"0" isEqualToString:[self.vo.optDict objectForKey:@"autoscale"]])
            ) { 
            //DBGLog(@"autoscale= %@", [self.vo.optDict objectForKey:@"autoscale"]);
            self.minVal = [self getMinMax:@"min" alt:[self.vo.optDict objectForKey:@"gmin"]];
            self.maxVal = [self getMinMax:@"max" alt:[self.vo.optDict objectForKey:@"gmax"]];
        } else if (self.vo.vtype == VOT_SLIDER) {
            NSNumber *nmin = [self.vo.optDict objectForKey:@"smin"];
            NSNumber *nmax = [self.vo.optDict objectForKey:@"smax"];
            self.minVal = ( nmin ? [nmin doubleValue] : d(SLIDRMINDFLT) );
            self.maxVal = ( nmax ? [nmax doubleValue] : d(SLIDRMAXDFLT) );
        } else if (self.vo.vtype == VOT_CHOICE) {
            self.minVal = d(0);
            self.maxVal = CHOICES+1;
        } else {  // number or function with autoscale
            
            self.minVal = [self getMinMax:@"min" alt:nil];
            self.maxVal = [self getMinMax:@"max" alt:nil];

            /*
            // should be option ASFROMZERO
            if ((0.0f < self.minVal) && (0.0f < self.maxVal)) {   // confusing if no start at 0
                self.minVal = 0.0f;
            }
            */
            
            self.maxVal += (self.maxVal - self.minVal) *0.10f;   // +10% for visibility
        }
        
        if (self.minVal == self.maxVal) {
            self.minVal = 0.0f;
        }
        if (minVal == maxVal) {
            self.maxVal = 1.0f;
        }

        DBGLog(@"%@ minval= %f  maxval= %f",self.vo.valueName, self.minVal,self.maxVal);
        
        //double vscale = d(self.bounds.size.height - (2.0f*BORDER)) / (maxVal - minVal);
        self.vScale = d(myTOGD.rect.size.height) / (self.maxVal - self.minVal);

        self.yZero -= (CGFloat) self.minVal;
        self.yZero *= (CGFloat) self.vScale;

        NSMutableArray *mxdat = [[NSMutableArray alloc] init];
        NSMutableArray *mydat = [[NSMutableArray alloc] init];
        
        NSMutableArray *i1 = [[NSMutableArray alloc] init];
        NSMutableArray *d1 = [[NSMutableArray alloc] init];
        myTracker.sql = [NSString stringWithFormat:@"select date,val from voData where id=%d and val != '' order by date;",self.vo.vid];
        [myTracker toQry2AryID:i1 d1:d1];
        myTracker.sql=nil;
        
        NSEnumerator *e = [d1 objectEnumerator];
        
        for (NSNumber *ni in i1) {
            
            NSNumber *nv = [e nextObject];
            
            //DBGLog(@"i: %@  f: %@",ni,nv);
            double d = [ni doubleValue];		// date as int secs cast to float
            double v = [nv doubleValue] ;		// val as float
            
            d -= (double) myTOGD.firstDate; // self.firstDate;
            d *= myTOGD.dateScale;
            v -= self.minVal;
            v *= self.vScale;
            
            //d+= border; //BORDER;
            //v+= border; //BORDER;
            // fixed by doDrawGraph ?  TODONE: why does this code run again after rotate to portrait?

            //DBGLog(@"num final: %f %f",d,v);
            
            [mxdat addObject:[NSNumber numberWithDouble:d]];
            [mydat addObject:[NSNumber numberWithDouble:v]];
            
        }
        
        [i1 release];
        [d1 release];
        
        self.xdat = [NSArray arrayWithArray:mxdat];
        self.ydat = [NSArray arrayWithArray:mydat];
        
        [mxdat release];
        [mydat release];
    }
    
    return self;
}

- (id) initAsNote:(valueObj*)inVO {
    if ((self = [super init])) {
        
        self.vo = inVO;
        self.yZero = 0.0F;
        
        trackerObj *myTracker = self.vo.parentTracker;
        togd * myTOGD = myTracker.togd;
        
        NSMutableArray *mxdat = [[NSMutableArray alloc] init];
        NSMutableArray *mydat = [[NSMutableArray alloc] init];
        
        NSMutableArray *i1 = [[NSMutableArray alloc] init];
        NSMutableArray *s1 = [[NSMutableArray alloc] init];
        
        myTracker.sql = [NSString stringWithFormat:@"select date,val from voData where id=%d and val not NULL and val != '' order by date;",self.vo.vid];
        [myTracker toQry2AryIS:i1 s1:s1];
        myTracker.sql=nil;
        NSEnumerator *e = [s1 objectEnumerator];
        
        for (NSNumber *ni in i1) {
            
            //DBGLog(@"i: %@  ",ni);
            double d = [ni doubleValue];		// date as int secs cast to float
            
            d -= (double) myTOGD.firstDate;
            d *= myTOGD.dateScale;
            //d+= border;
            
            [mxdat addObject:[NSNumber numberWithDouble:d]];
            [mydat addObject:[e nextObject]];
        }
        
        
        [i1 release];
        [s1 release];
        
        self.xdat = [NSArray arrayWithArray:mxdat];
        self.ydat = [NSArray arrayWithArray:mydat];
        
        [mxdat release];
        [mydat release];
    }
    
    return self;

}

- (id) initAsBool:(valueObj*)inVO {
    if ((self = [super init])) {
        
        self.vo = inVO;
        self.yZero = 0.0F;
        
        trackerObj *myTracker = self.vo.parentTracker;
        togd *myTOGD = myTracker.togd;
        
        NSMutableArray *mxdat = [[NSMutableArray alloc] init];
        //NSMutableArray *mydat = [[NSMutableArray alloc] init];
        
        NSMutableArray *i1 = [[NSMutableArray alloc] init];
        myTracker.sql = [NSString stringWithFormat:@"select date from voData where id=%d and val='1' order by date;",self.vo.vid];
        [myTracker toQry2AryI:i1];
        myTracker.sql=nil;
        
        for (NSNumber *ni in i1) {
            
            //DBGLog(@"i: %@  ",ni);
            double d = [ni doubleValue];		// date as int secs cast to float
            
            d -= (double) myTOGD.firstDate;
            d *= myTOGD.dateScale;
            //d+= border;
            
            [mxdat addObject:[NSNumber numberWithDouble:d]];
            
        }
        [i1 release];
        
        
        self.xdat = [NSArray arrayWithArray:mxdat];
        //ydat = [NSArray arrayWithArray:mydat];
        
        [mxdat release];
        //[mydat release];
    }
    
    return self;
    
}

- (id) initAsTBoxLC:(valueObj*)inVO {

    if ((self = [super init])) {
        
        self.vo = inVO;
        self.yZero = 0.0F;
        
        trackerObj *myTracker = self.vo.parentTracker;
        togd * myTOGD = myTracker.togd;

        self.maxVal = self.minVal = 0.0f;

        NSMutableArray *i1 = [[NSMutableArray alloc] init];
        NSMutableArray *s1 = [[NSMutableArray alloc] init];
        NSMutableArray *i2 = [[NSMutableArray alloc] init];
        
        myTracker.sql = [NSString stringWithFormat:@"select date,val from voData where id=%d and val not NULL order by date;",self.vo.vid];
        [myTracker toQry2AryIS:i1 s1:s1];
        myTracker.sql=nil;
        
        // TODO: nicer to cache tbox linecounts somehow 
        for (NSString *s in s1) {
            double v = d( [rTracker_resource countLines:s] );
            if (v > self.maxVal)
                self.maxVal = v;
            [i2 addObject:[NSNumber numberWithDouble:v]];
        }
        [s1 release];
        
        if (self.maxVal < d(YTICKS))
            self.maxVal = d(YTICKS);
        
        self.vScale = d(myTOGD.rect.size.height) / (self.maxVal - self.minVal);
        
        NSMutableArray *mxdat = [[NSMutableArray alloc] init];
        NSMutableArray *mydat = [[NSMutableArray alloc] init];
        
        NSEnumerator *e = [i2 objectEnumerator];
        
        for (NSNumber *ni in i1) {
            
            //DBGLog(@"i: %@  ",ni);
            double d = [ni doubleValue];		// date as int secs cast to float
            double v = [[e nextObject] doubleValue];
            
            d -= (double) myTOGD.firstDate;
            d *= myTOGD.dateScale;
            
            v -= self.minVal;
            v *= self.vScale;            
            
            [mxdat addObject:[NSNumber numberWithDouble:d]];
            [mydat addObject:[NSNumber numberWithDouble:v]];
        }
        
        
        [i1 release];
        [i2 release];
        
        self.xdat = [NSArray arrayWithArray:mxdat];
        self.ydat = [NSArray arrayWithArray:mydat];
        
        [mxdat release];
        [mydat release];
    }
    
    return self;
    
}

- (UIColor*) myGraphColor {
    if (self.vo.vtype != VOT_CHOICE) 
        return( (UIColor *) [[rTracker_resource colorSet] objectAtIndex:self.vo.vcolor] );
    else
        return  [UIColor whiteColor];
}

- (void) dealloc {
    self.vo = nil;
    [vo release];
    self.xdat = nil;
    self.ydat = nil;
    [xdat release];
    [ydat release];
    
    [super dealloc];
}
@end
