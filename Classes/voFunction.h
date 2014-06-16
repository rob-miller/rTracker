//
//  voFunction.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "voState.h"

//function support
// values are negative so positive values will be vid's
#define FNSETVERSION	1

#define FNSTART			-1

// old 1arg begin
#define FN1ARGFIRST		FNSTART
#define FN1ARGDELTA		(FN1ARGFIRST)
#define FN1ARGSUM		(FN1ARGDELTA-1)
#define FN1ARGPOSTSUM	(FN1ARGSUM-1)
#define FN1ARGPRESUM	(FN1ARGPOSTSUM-1)
#define FN1ARGAVG		(FN1ARGPRESUM-1)
#define FN1ARGLAST		FN1ARGAVG
// old 1arg end -- do not edit, add below

// old 2arg begin
#define FN2ARGFIRST		(FN1ARGLAST-1)
#define FN2ARGPLUS		(FN2ARGFIRST)
#define FN2ARGMINUS		(FN2ARGPLUS-1)
#define FN2ARGTIMES		(FN2ARGMINUS-1)
#define FN2ARGDIVIDE	(FN2ARGTIMES-1)
#define FN2ARGLAST		FN2ARGDIVIDE
// old 2arg end -- do not edit, add below

#define FNPARENOPEN		(FN2ARGLAST-1)
#define FNPARENCLOSE	(FNPARENOPEN-1)
#define FNPARENLAST		FNPARENCLOSE

// old time fns begin
#define FNTIMEFIRST     (FNPARENCLOSE-1)
#define FNTIMEWEEKS     (FNTIMEFIRST)
#define FNTIMEDAYS      (FNTIMEWEEKS-1)
#define FNTIMEHRS       (FNTIMEDAYS-1)
#define FNTIMELAST      FNTIMEHRS
// old time fns end -- do not edit, add below

#define FNCONSTANT      (FNTIMELAST-1)

#define FNOLDLAST       FNCONSTANT

// define extra space for new functions below

#define FNNEW1ARGFIRST  FNOLDLAST-10

#define FN1ARGMIN		(FNNEW1ARGFIRST-1)
#define FN1ARGMAX		(FN1ARGMIN-1)
#define FN1ARGCOUNT		(FN1ARGMAX-1)

#define FNNEW1ARGLAST   FNNEW1ARGFIRST-100

#define isFn1Arg(i)		(((i<=FN1ARGFIRST) && (i>=FN1ARGLAST)) || ((i<=FNNEW1ARGFIRST) && (i>=FNNEW1ARGLAST)))

#define FNNEW2ARGFIRST  FNNEW1ARGLAST-10
#define FNNEW2ARGLAST   FNNEW2ARGFIRST-100

#define isFn2ArgOp(i)	(((i<=FN2ARGFIRST) && (i>=FN2ARGLAST)) || ((i<=FNNEW2ARGFIRST) && (i>=FNNEW2ARGLAST)))

#define FNNEWTIMEFIRST  FNNEW2ARGLAST-10
#define FNTIMEMINS      (FNNEWTIMEFIRST-1)
#define FNTIMESECS      (FNTIMEMINS-1)
#define FNNEWTIMELAST   FNNEWTIMEFIRST-100

#define isFnTimeOp(i)   (((i<=FNTIMEFIRST) && (i>=FNTIMELAST)) || ((i<=FNNEWTIMEFIRST) && (i>=FNNEWTIMELAST)))


#define FNFIN           FNNEWTIMELAST

#define isFn(i)	((i<=FNSTART) && (i>=FNFIN))

#define FNCONSTANT_TITLE @"constant"


#define ARG1FNS FN1ARGDELTA,FN1ARGSUM,FN1ARGPOSTSUM,FN1ARGPRESUM,FN1ARGAVG,FN1ARGMIN,FN1ARGMAX,FN1ARGCOUNT
#define ARG1STRS @"change_in", @"sum", @"post-sum", @"pre-sum", @"avg", @"min", @"max", @"count"
#define ARG1CNT 8

#define ARG2FNS FN2ARGPLUS,FN2ARGMINUS,FN2ARGTIMES,FN2ARGDIVIDE
#define ARG2STRS @"+", @"-", @"*", @"/"
#define ARG2CNT 4

#define PARENFNS FNPARENOPEN,FNPARENCLOSE
#define PARENSTRS @"(", @")"
#define PARENCNT 2

#define TIMEFNS FNTIMEWEEKS,FNTIMEDAYS,FNTIMEHRS,FNTIMEMINS,FNTIMESECS
#define TIMESTRS @"weeks",@"days",@"hours",@"minutes",@"seconds"
#define TIMECNT 5

#define OTHERFNS FNCONSTANT
#define OTHERSTRS FNCONSTANT_TITLE
#define OTHERCNT 1

#define TOTFNCNT (ARG1CNT + ARG2CNT + PARENCNT + TIMECNT + OTHERCNT)

//xx c arr = double balance[] = {1000.0, 2.0, 3.4, 17.0, 50.0};

//#define FnArrMap   FN1ARGDELTA,FN1ARGSUM,FN1ARGPOSTSUM,FN1ARGPRESUM,FN1ARGAVG,FN1ARGMIN,FN1ARGMAX,FN1ARGCOUNT,FN2ARGPLUS,FN2ARGMINUS,FN2ARGTIMES,FN2ARGDIVIDE,FNPARENOPEN,FNPARENCLOSE,FNPARENCLOSE,FNTIMEWEEKS,FNTIMEDAYS,FNTIMEHRS,FNCONSTANT
// FnArrStrs must be same order as #defines above
//#define FnArrStrs	@"change_in", @"sum", @"post-sum", @"pre-sum", @"avg", @"min", @"max", @"count", @"+", @"-", @"*", @"/", @"(", @")",@"weeks",@"days",@"hours", FNCONSTANT_TITLE


// range endpoint symbols tied to epTitles ivar creation
//   @"entry", @"hours", @"days", @"weeks", @"months", @"years"

#define FREPENTRY  -1
#define FREPHOURS  -2
#define FREPDAYS   -3
#define FREPWEEKS  -4
#define FREPMONTHS -5
#define FREPYEARS  -6
#define FREPCDAYS   -7
#define FREPCWEEKS  -8
#define FREPCMONTHS -9
#define FREPCYEARS  -10

#define ISCALFREP(x) ((FREPCDAYS >= x) && (FREPCYEARS <= x))

#define MAXFREP 10


#define FNSEGNDX_OVERVIEW 0
#define FNSEGNDX_RANGEBLD 1
#define FNSEGNDX_FUNCTBLD 2

// end functions 

@interface voFunction : voState <UIPickerViewDelegate, UIPickerViewDataSource>
/*{
	configTVObjVC *ctvovcp;

	NSInteger fnSegNdx;				// overview, range, or fn definition page in configTVObjVC
	NSArray *epTitles;				// available range endpoints: valueObjs or offsets (hour, month, ...)
	NSMutableArray *fnTitles;		// 
	NSMutableArray *fnArray;		// ordered array of symbols (valObj [vid] or operation [<0]) to compute, <=> optDict:@"func"
	//NSMutableArray *fnStrs;			// valueObj names or predefined operation names (map to symbols, vids in nfArray)
    NSArray *fn2args;
	NSInteger currFnNdx;			// index as we compute the function
    
    UILabel *rlab;
    
    NSArray *votWoSelf;             // myTracker's valobjtable without reference to self for picking endpoints
}*/

//@property (nonatomic,retain) NSMutableArray *fnStrs;
@property (nonatomic, strong) NSDictionary *fnStrDict;
@property (nonatomic, strong) NSArray *fn1args;
@property (nonatomic, strong) NSArray *fn2args;
@property (nonatomic, strong) NSArray *fnTimeOps;

@property (nonatomic,unsafe_unretained) configTVObjVC *ctvovcp;
@property (nonatomic) NSInteger fnSegNdx;
@property (nonatomic,strong) NSArray *epTitles;
@property (nonatomic,strong) NSMutableArray *fnTitles;
@property (nonatomic,strong) NSMutableArray *fnArray;
@property (nonatomic) NSInteger currFnNdx;
@property (nonatomic,strong) UILabel *rlab;
@property (nonatomic,strong) NSArray *votWoSelf;

- (void) funcDone;
- (void) funcVDL:(configTVObjVC*)ctvovc donebutton:(UIBarButtonItem*)db ;

@end
