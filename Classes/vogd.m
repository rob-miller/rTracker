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

@synthesize vo=_vo,xdat=_xdat,ydat=_ydat,minVal=_minVal,maxVal=_maxVal,vScale=_vScale,yZero=_yZero;

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
    togd *myTOGD = myTracker.togd;
    NSString *sql = [NSString stringWithFormat:@"select %@(val collate CMPSTRDBL) from voData where id=%ld and val != '' and date >= %d and date <= %d;",targ,(long)self.vo.vid,myTOGD.firstDate,myTOGD.lastDate];
    return [myTracker toQry2Double:sql];
}

- (id) initAsNum:(valueObj*)inVO {
    if ((self = [super init])) {

        self.vo = inVO;
        self.yZero = 0.0F;
        
        //double dscale = d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate);
        
        trackerObj *myTracker = (trackerObj*) self.vo.parentTracker;
        togd *myTOGD = myTracker.togd;
        
        if ((self.vo.vtype == VOT_NUMBER || self.vo.vtype == VOT_FUNC) 
            && ([@"0" isEqualToString:(self.vo.optDict)[@"autoscale"]])
            ) { 
            //DBGLog(@"autoscale= %@", [self.vo.optDict objectForKey:@"autoscale"]);
            self.minVal = [self getMinMax:@"min" alt:(self.vo.optDict)[@"gmin"]];
            self.maxVal = [self getMinMax:@"max" alt:(self.vo.optDict)[@"gmax"]];
        } else if (self.vo.vtype == VOT_SLIDER) {
            NSNumber *nmin = (self.vo.optDict)[@"smin"];
            NSNumber *nmax = (self.vo.optDict)[@"smax"];
            self.minVal = ( nmin ? [nmin doubleValue] : d(SLIDRMINDFLT) );
            self.maxVal = ( nmax ? [nmax doubleValue] : d(SLIDRMAXDFLT) );
        } else if (self.vo.vtype == VOT_BOOLEAN) {
            double offVal = 0.0;
            double onVal = [(self.vo.optDict)[@"boolval"] doubleValue];
            if (offVal < onVal) {
                self.minVal = offVal;
                self.maxVal = onVal;
            } else {
                self.minVal = onVal;
                self.maxVal = offVal;
            }
        } else if (self.vo.vtype == VOT_CHOICE) {
            self.minVal=d(0);
            self.maxVal=d(0);
            int c=0;
            for (int i=0; i<CHOICES; i++) {
                NSString *key = [NSString stringWithFormat:@"cv%d",i];
                NSString *tstVal = [self.vo.optDict valueForKey:key];
                if (nil != tstVal) { // only do specified choices
                    c++;
                    double tval = [tstVal doubleValue];
                    if (self.minVal > tval)
                        self.minVal = tval;
                    if (self.maxVal < tval)
                        self.maxVal = tval;
                }
            }
            if (self.minVal == self.maxVal) {  // if no values set above, default to choice numbers
                self.minVal = d(1);
                self.maxVal = d(CHOICES);
            }

            DBGLog(@"minVal= %lf maxVal= %lf",self.minVal,self.maxVal);
            
            double step = (self.maxVal - self.minVal) / c;  //  CHOICES;
            self.minVal -= step ; //( d( YTICKS - CHOICES ) /2.0 ) * step;   // YTICKS=7, CHOICES=6, so need blank positions at top and bottom
            self.maxVal += step * d(YTICKS - c) ;  // step ; //( d( YTICKS - CHOICES ) /2.0 ) * step;
            DBGLog(@"minVal= %lf maxVal= %lf",self.minVal,self.maxVal);
            DBGLog(@"Foo");
            
            
        } else {  // number or function with autoscale
            
            self.minVal = [self getMinMax:@"min" alt:nil];
            self.maxVal = [self getMinMax:@"max" alt:nil];

            /*
            // should be option ASFROMZERO
            if ((0.0f < self.minVal) && (0.0f < self.maxVal)) {   // confusing if no start at 0
                self.minVal = 0.0f;
            }
            */
            
        }
        
        if (self.minVal == self.maxVal) {
            self.minVal = 0.0f;
        }
        if (self.minVal == self.maxVal) {
            self.maxVal = 1.0f;
        }

        if (VOT_CHOICE != self.vo.vtype) {
        double yScaleExpand = (self.maxVal - self.minVal) * GRAPHSCALE;
        if (nil == (self.vo.optDict)[@"gmax"])
            self.maxVal += yScaleExpand;   // +5% each way for visibility unless specified
        if (nil == (self.vo.optDict)[@"gmin"])
            self.minVal -= yScaleExpand;
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
        
        //myTracker.sql = [NSString stringWithFormat:@"select date,val from voData where id=%d and val != '' order by date;",self.vo.vid];
        // 6.ii.2013 implement maxGraphDays
        NSString *sql = [NSString stringWithFormat:@"select date,val from voData where id=%ld and val != '' and date >= %d and date <= %d order by date;",(long)self.vo.vid,myTOGD.firstDate,myTOGD.lastDate];

        [myTracker toQry2AryID:i1 d1:d1 sql:sql];
      //sql = nil;
        
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
            // fixed by doDrawGraph ? : why does this code run again after rotate to portrait?

            //DBGLog(@"num final: %f %f",d,v);
            
            [mxdat addObject:@(d)];
            [mydat addObject:@(v)];
            
        }
        
        
        self.xdat = [NSArray arrayWithArray:mxdat];
        self.ydat = [NSArray arrayWithArray:mydat];
        
    }
    
    return self;
}

- (id) initAsNote:(valueObj*)inVO {
    if ((self = [super init])) {
        
        self.vo = inVO;
        self.yZero = 0.0F;
        
        trackerObj *myTracker = self.vo.parentTracker;
        togd * myTOGD = myTracker.togd;
        
        self.vScale = d(myTOGD.rect.size.height) / d(1.0 + GRAPHSCALE) ;  // (self.maxVal - self.minVal);
        //self.vScale = d(myTOGD.rect.size.height); // / d(1.05) ;  // (self.maxVal - self.minVal);
        
        NSMutableArray *mxdat = [[NSMutableArray alloc] init];
        NSMutableArray *mydat = [[NSMutableArray alloc] init];
        
        NSMutableArray *i1 = [[NSMutableArray alloc] init];
        
        //NSMutableArray *s1 = [[NSMutableArray alloc] init];
        
        //myTracker.sql = [NSString stringWithFormat:@"select date,val from voData where id=%d and val not NULL and val != '' and date >= %d and date <= %d order by date;",self.vo.vid,myTOGD.firstDate,myTOGD.lastDate];
        //[myTracker toQry2AryIS:i1 s1:s1];
        //NSEnumerator *e = [s1 objectEnumerator];
        NSString *sql = [NSString stringWithFormat:@"select date,val from voData where id=%ld and val not NULL and val != '' and date >= %d and date <= %d order by date;",(long)self.vo.vid,myTOGD.firstDate,myTOGD.lastDate];
        [myTracker toQry2AryI:i1 sql:sql];
      //sql = nil;
        
        for (NSNumber *ni in i1) {
            
            //DBGLog(@"i: %@  ",ni);
            double d = [ni doubleValue];		// date as int secs cast to float
            
            d -= (double) myTOGD.firstDate;
            d *= myTOGD.dateScale;
            //d+= border;
            
            [mxdat addObject:@(d)];
            [mydat addObject: @(self.vScale)];  //[e nextObject]];
        }
        
        
        //[s1 release];
        
        self.xdat = [NSArray arrayWithArray:mxdat];
        self.ydat = [NSArray arrayWithArray:mydat];
        
    }
    
    return self;

}


// not used - boolean treated as number
/*
- (id) initAsBool:(valueObj*)inVO {
    if ((self = [super init])) {
        
        self.vo = inVO;
        self.yZero = 0.0F;
        
        trackerObj *myTracker = self.vo.parentTracker;
        togd *myTOGD = myTracker.togd;
        
        NSMutableArray *mxdat = [[NSMutableArray alloc] init];
        //NSMutableArray *mydat = [[NSMutableArray alloc] init];
        
        NSMutableArray *i1 = [[NSMutableArray alloc] init];
       sql = [NSString stringWithFormat:@"select date from voData where id=%d and val !='' and date >= %d and date <= %d order by date;",self.vo.vid,myTOGD.firstDate,myTOGD.lastDate];
        [myTracker toQry2AryI:i1];
      //sql = nil;
        
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
*/

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
       
        NSString *sql = [NSString stringWithFormat:@"select date,val from voData where id=%ld and val not NULL and val != '' and date >= %d and date <= %d order by date;",(long)self.vo.vid,myTOGD.firstDate,myTOGD.lastDate];
        [myTracker toQry2AryIS:i1 s1:s1 sql:sql];
      //sql = nil;
        
        // TODO: nicer to cache tbox linecounts somehow 
        for (NSString *s in s1) {
            double v = d( [rTracker_resource countLines:s] );
            if (v > self.maxVal)
                self.maxVal = v;
            [i2 addObject:@(v)];
        }
        
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
            
            [mxdat addObject:@(d)];
            [mydat addObject:@(v)];
        }
        
        
        
        self.xdat = [NSArray arrayWithArray:mxdat];
        self.ydat = [NSArray arrayWithArray:mydat];
        
    }
    
    return self;
    
}

- (UIColor*) myGraphColor {
    if (self.vo.vtype != VOT_CHOICE) 
        return( (UIColor *) [rTracker_resource colorSet][self.vo.vcolor] );
    else
        return  [UIColor whiteColor];
}

@end
