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
#define FNSETVERSION	1

#define FNSTART			-1

#define FN1ARGFIRST		FNSTART
#define FN1ARGDELTA		(FN1ARGFIRST)
#define FN1ARGSUM			(FN1ARGDELTA-1)
#define FN1ARGPOSTSUM		(FN1ARGSUM-1)
#define FN1ARGPRESUM		(FN1ARGPOSTSUM-1)
#define FN1ARGAVG			(FN1ARGPRESUM-1)
#define FN1ARGLAST		FN1ARGAVG

#define isFn1Arg(i)		((i<=FN1ARGFIRST) && (i>=FN1ARGLAST))

#define FN2ARGFIRST		(FN1ARGLAST-1)
#define FN2ARGPLUS		(FN2ARGFIRST)
#define FN2ARGMINUS		(FN2ARGPLUS-1)
#define FN2ARGTIMES		(FN2ARGMINUS-1)
#define FN2ARGDIVIDE		(FN2ARGTIMES-1)
#define FN2ARGLAST		FN2ARGDIVIDE

#define isFn2ArgOp(i)		((i<=FN2ARGFIRST) && (i>=FN2ARGLAST))

#define FNPARENOPEN		(FN2ARGLAST-1)
#define FNPARENCLOSE	(FNPARENOPEN-1)

#define FNPARENLAST		FNPARENCLOSE

#define FNFIN			FNPARENLAST

#define isFn(i)		((i<=FNSTART) && (i>=FNFIN))

#define FnArrStrs	@"delta", @"sum", @"post-sum", @"pre-sum", @"avg", @"+", @"-", @"*", @"/", @"(", @")"

#define FN1ARGSET			FN1ARGDELTA,FN1ARGSUM,FN1ARGAVG
#define FNOPSET			FNOPPLUS,FNOPMINUS,FNOPTIMES,FNOPDIVIDE



// range endpoint symbols tied to epTitles ivar creation
//   @"entry", @"hours", @"days", @"weeks", @"months", @"years"

#define FREPENTRY  -1
#define FREPHOURS  -2
#define FREPDAYS   -3
#define FREPWEEKS  -4
#define FREPMONTHS -5
#define FREPYEARS  -6


#define FNSEGNDX_OVERVIEW 0
#define FNSEGNDX_RANGEBLD 1
#define FNSEGNDX_FUNCTBLD 2

// end functions 

@interface voFunction : voState <UIPickerViewDelegate, UIPickerViewDataSource> {
	configTVObjVC *ctvovcp;

	NSInteger fnSegNdx;				// overview, range, or fn definition page in configTVObjVC
	NSArray *epTitles;				// available range endpoints: valueObjs or offsets (hour, month, ...)
	NSMutableArray *fnTitles;		// 
	NSMutableArray *fnArray;		// ordered array of symbols (valObj [vid] or operation [<0]) to compute, <=> optDict:@"func"
	NSMutableArray *fnStrs;			// valueObj names or predefined operation names (map to symbols, vids in nfArray)

	NSInteger currFnNdx;			// index as we compute the function
    
    UILabel *rlab;
}

@property (nonatomic,assign) configTVObjVC *ctvovcp;
@property (nonatomic) NSInteger fnSegNdx;
@property (nonatomic,retain) NSArray *epTitles;
@property (nonatomic,retain) NSMutableArray *fnTitles;
@property (nonatomic,retain) NSMutableArray *fnStrs;
@property (nonatomic,retain) NSMutableArray *fnArray;
@property (nonatomic) NSInteger currFnNdx;
@property (nonatomic,retain) UILabel *rlab;

- (void) funcDone;
- (void) funcVDL:(configTVObjVC*)ctvovc donebutton:(UIBarButtonItem*)db ;

@end
