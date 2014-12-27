//
//  trackerCalViewController.m
//  TimesSquare
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "trackerCalViewController.h"
#import "trackerCalCalendarRowCell.h"
#import "TimesSquare/TimesSquare.h"

#import "dbg-defs.h"
#import "privacyV.h"
#import "tObjBase.h"
#import "trackerObj.h"
#import "valueObj.h"
#import "rTracker-resource.h"

#import "useTrackerController.h"

@interface trackerCalViewController ()

@property (nonatomic, strong) NSTimer *timer;

@end


@interface TSQCalendarView (AccessingPrivateStuff)

@property (nonatomic, readonly) UITableView *tableView;

@end


@implementation trackerCalViewController

@synthesize tracker=_tracker,dpr=_dpr,parentUTC=_parentUTC;


- (void)loadView;
{
    
    TSQCalendarView *calendarView = [[TSQCalendarView alloc] init];
    _calendar = calendarView.calendar = [NSCalendar currentCalendar];
    _dateSelDict = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *idColors = [[NSMutableDictionary alloc]init];
    self.tracker.sql = @"select id,color from voConfig where id not in  (select id from voInfo where field='graph' and val=0)";
    [self.tracker toQry2DictII:idColors];
    
    NSMutableSet *fnIds = [[NSMutableSet alloc] init];
    self.tracker.sql = @"select id from voConfig where type=6"; // VOT_FUNC hard-coded!
    [self.tracker toQry2SetI:fnIds];

    NSMutableSet *noGraphIds = [[NSMutableSet alloc] init];
    self.tracker.sql = @"select id from voInfo where field='graph' and val=0";
    [self.tracker toQry2SetI:noGraphIds];

    NSArray *colorSet = [rTracker_resource colorSet];
    int pv = [privacyV getPrivacyValue];
    NSMutableArray *dates;
    if (nil == ((useTrackerController*)self.parentUTC).searchSet) {
        dates = [[NSMutableArray alloc]init];
        self.tracker.sql = [NSString stringWithFormat:@"select date from trkrData where minpriv <= %d order by date asc;",pv];
        [self.tracker toQry2AryI:dates];
    } else {
        dates = [NSMutableArray arrayWithArray:((useTrackerController*)self.parentUTC).searchSet];
    }
    
    NSMutableArray *vidSet = [[NSMutableArray alloc]init];
    
    for (id d in dates) {
        NSDateComponents *dc = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSince1970:[d integerValue]]];
        NSDate *date = [_calendar dateFromComponents:dc];
        int dayStart = [date timeIntervalSince1970];

        DBGLog(@"date= %@",date);
        if ((2014 == [dc year]) && (6 == [dc month]) && (13 == [dc day])) {
            DBGLog(@"date 2014 june = %@",date);
        }
        // get array of vids in date range
        self.tracker.sql = [NSString stringWithFormat:
                            @"select t1.id from voData t0, voConfig t1 where t0.id=t1.id and t0.date >= %d and t0.date <= %d and t1.priv <= %d and t1.type != %d order by t1.rank asc",
                            dayStart,dayStart+(24*60*60)-1,pv, VOT_INFO];

        [vidSet removeAllObjects];
        [self.tracker toQry2AryI:vidSet];
        BOOL haveNoGraphNoFn = false;
        int graphFnVid = 0;
        int targVid = 0;
        
        for (id vid in vidSet) {
            if ([noGraphIds containsObject:vid]) {     // not graphed
                if (![fnIds containsObject:vid]) {       // and not a vot_func
                    if (0 != graphFnVid) { // have a graphed fn value already set, this confirms there is privacy-ok data
                        targVid = graphFnVid;
                        break;
                    }
                    haveNoGraphNoFn = true;
                }
            } else if ([fnIds containsObject:vid]) {
                if (0 == graphFnVid) {   // first seen vot_func to graph
                    graphFnVid = [vid intValue];
                    if (haveNoGraphNoFn) {     // already have confirmation of privacy-ok data
                        targVid = graphFnVid;
                        break;
                    }
                }
            } else if (0 != graphFnVid) {  // have a graphed fn value already set, this confirms there is privacy-ok data
                targVid = graphFnVid;
                break;
            } else {
                targVid = [vid intValue];
                break;
            }
        }

        if (haveNoGraphNoFn && (0 == targVid)) {  // only have no graph data point
            [_dateSelDict setObject:@"" forKey:date];   // set for no color
            DBGLog(@"date: %@ - have vid but no graph",date);
        } else if (targVid) {
            int cndx = [[idColors objectForKey:@(targVid)]intValue];
            if ((cndx <0) || (cndx >[colorSet count])) {
                [_dateSelDict setObject:@"" forKey:date];   // set for no color
            } else {
                [_dateSelDict setObject:((UIColor*)[colorSet objectAtIndex:cndx])  forKey:date];
                DBGLog(@"date: %@  valobj %d UIColor %@ name %@",date,targVid,(UIColor*)[colorSet objectAtIndex:cndx],[rTracker_resource colorNames][cndx]);
            }
            
        }
        

        DBGLog(@"data for date %@ = %@",date, (UIColor*) _dateSelDict[date]);
    }
    
    calendarView.rowCellClass = [trackerCalCalendarRowCell class];
    calendarView.firstDate = [NSDate dateWithTimeIntervalSince1970:[self.tracker firstDate]];
    calendarView.lastDate = [[NSDate alloc] init]; // today
    
    calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    calendarView.pagingEnabled = NO;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    calendarView.contentOffset = (CGPoint){ 60.0, 60.0};
    calendarView.delegate=self;
    [calendarView scrollToDate:self.dpr.date animated:NO];
    self.view = calendarView;
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewSwipeRight:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];
    
    
}
- (void) leaveCalendar {
    self.dpr.date = nil;
    self.dpr.action = DPA_CANCEL;
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)handleViewSwipeRight:(UISwipeGestureRecognizer *)gesture {
    [self leaveCalendar];
}

/*
- (void) viewDidLoad {
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}
*/

-(void) viewWillAppear:(BOOL)animated {
    self.SpecDate=true;
    ((TSQCalendarView*)self.view).selectedDate = self.dpr.date;
    self.SpecDate=false;
}

- (void)setCalendar:(NSCalendar *)calendar;
{
    _calendar = calendar;
    
    self.navigationItem.title = calendar.calendarIdentifier;
    self.tabBarItem.title = calendar.calendarIdentifier;
}

- (void)viewDidLayoutSubviews;
{
  // Set the calendar view to show today date on start
  [(TSQCalendarView *)self.view scrollToDate:[NSDate date] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    // Uncomment this to test scrolling performance of your custom drawing
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scroll;
{
    static BOOL atTop = YES;
    TSQCalendarView *calendarView = (TSQCalendarView *)self.view;
    UITableView *tableView = calendarView.tableView;
    
    [tableView setContentOffset:CGPointMake(0.f, atTop ? 10000.f : 0.f) animated:YES];
    atTop = !atTop;
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date {
    if (self.SpecDate) {
        return;
    }
    
    self.dpr.date = date;
	self.dpr.action = DPA_GOTO_POST;
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectDate:(NSDate *)date {
    if (nil != [self.dateSelDict objectForKey:date]) {
        return true;
    }
    NSDateComponents *components = [self.calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [self.calendar dateFromComponents:components];
    components = [self.calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *inDate = [self.calendar dateFromComponents:components];
    
    if([today isEqualToDate:inDate]) {
        return true;
    }
    return false ;
}

-(UIColor*)calendarView:(TSQCalendarView *)calendarView colorForDate:(NSDate *)date {
    id obj = [self.dateSelDict objectForKey:date];
    if (nil == obj) {
        return nil;
    } else if ([@"" isEqual:obj]) {
        return nil;
    }
    return (UIColor*) obj;
}

@end
