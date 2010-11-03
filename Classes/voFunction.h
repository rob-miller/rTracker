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

#define FNFNFIRST		FNSTART
#define FNFNDELTA		(FNFNFIRST)
#define FNFNSUM			(FNFNDELTA-1)
#define FNFNPOSTSUM		(FNFNSUM-1)
#define FNFNPRESUM		(FNFNPOSTSUM-1)
#define FNFNAVG			(FNFNPRESUM-1)
#define FNFNLAST		FNFNAVG

#define isFnFn(i)		((i<=FNFNFIRST) && (i>=FNFNLAST))

#define FN2OPFIRST		(FNFNLAST-1)
#define FN2OPPLUS		(FN2OPFIRST)
#define FN2OPMINUS		(FN2OPPLUS-1)
#define FN2OPTIMES		(FN2OPMINUS-1)
#define FN2OPDIVIDE		(FN2OPTIMES-1)
#define FN2OPLAST		FN2OPDIVIDE

#define FNPARENOPEN		(FN2OPLAST-1)
#define FNPARENCLOSE	(FNPARENOPEN-1)

#define FNPARENLAST		FNPARENCLOSE

#define FNFIN			FNPARENLAST

#define FnArrStrs	@"delta", @"sum", @"post-sum", @"pre-sum", @"avg", @"+", @"-", @"*", @"/", @"(", @")"

#define FNFNSET			FNFNDELTA,FNFNSUM,FNFNAVG
#define FNOPSET			FNOPPLUS,FNOPMINUS,FNOPTIMES,FNOPDIVIDE


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
}

@property (nonatomic,assign) configTVObjVC *ctvovcp;
@property (nonatomic) NSInteger fnSegNdx;
@property (nonatomic,retain) NSArray *epTitles;
@property (nonatomic,retain) NSMutableArray *fnTitles;
@property (nonatomic,retain) NSMutableArray *fnStrs;
@property (nonatomic,retain) NSMutableArray *fnArray;

- (void) funcDone;
- (void) funcVDL:(configTVObjVC*)ctvovc donebutton:(UIBarButtonItem*)db ;

@end
