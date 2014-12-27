//
//  trackerCalViewController.h
//  TimesSquare
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>

#import "trackerObj.h"
#import "dpRslt.h"
#import "TimesSquare/TSQCalendarView.h"



@interface trackerCalViewController : UIViewController <TSQCalendarViewDelegate>
/*
 {
    trackerObj *tracker;
    dpRslt *dpr;
}
*/

@property (nonatomic,strong) trackerObj *tracker;
@property (nonatomic,strong) dpRslt *dpr;

@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic,strong) NSMutableDictionary *dateSelDict;

@property (nonatomic) BOOL SpecDate;

@property (nonatomic,unsafe_unretained) id parentUTC;

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date;


@end
