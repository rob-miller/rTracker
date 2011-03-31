//
//  voFunction.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voFunction.h"
#import "rTracker-constants.h"
#import "dbg-defs.h"

@interface voFunction ()
- (void) updateFnTitles;
//@property (nonatomic, retain) NSNumber *foo;
@end


@implementation voFunction

@synthesize epTitles, fnTitles, fnStrs, fnArray, fnSegNdx, ctvovcp, currFnNdx, rlab;

#pragma mark -
#pragma mark core object methods and support

- (void) dealloc {
	self.epTitles = nil;
	[epTitles release];
	
	self.fnArray = nil;
	[fnArray release];
	self.fnStrs = nil;
	[fnStrs release];
	
	self.fnTitles = nil;
	[fnTitles release];
	
    self.rlab = nil;
    [rlab release];
    
	[super dealloc];
}

- (void) saveFnArray {
	// note this converts NSNumbers to NSStrings
	// works because NSNumber returns an NSString for [description]
	
	//[self.vo.optDict setObject:[self.fnArray componentsJoinedByString:@" "] forKey:@"func"];
	// don't save an empty string
	NSString *ts = [self.fnArray componentsJoinedByString:@" "];
	if (0 < [ts length]) {
		[self.vo.optDict setObject:ts forKey:@"func"];
	}
}

- (void) loadFnArray {

	[self.fnArray removeAllObjects];  
	// all works fine if we load as strings with 
	// [self.fnArray addObjectsFromArray: [[self.vo.optDict objectForKey:@"func"] componentsSeparatedByString:@" "];
	// but prefer to keep as NSNumbers 
	
	NSArray *tmp = [[self.vo.optDict objectForKey:@"func"] componentsSeparatedByString:@" "];
	for (NSString *s in tmp) {
		[self.fnArray addObject:[NSNumber numberWithInteger:[s integerValue]]];
	}
}

#pragma mark protocol: getValCap

- (int) getValCap {  // NSMutableString size for value
    return 32;
}

#pragma mark protocol: loadConfig

- (void) loadConfig {
	[self loadFnArray];
    if ((nil == [self.vo.optDict valueForKey:@"frep0"])) {
        [self.vo.optDict setObject:[NSNumber numberWithInt:FREPDFLT] forKey:@"frep0"];
    }
    if ((nil == [self.vo.optDict valueForKey:@"frep1"])) {
        [self.vo.optDict setObject:[NSNumber numberWithInt:FREPDFLT] forKey:@"frep1"];
    }
    
}

#pragma mark protocol: updateVORefs

- (void) updateVORefs:(NSInteger)newVID old:(NSInteger)oldVID {
	// subclass overrides if need to do anything
	[self loadFnArray];
	NSUInteger i=0;
	NSUInteger max = [self.fnArray count];
	for (i=0; i< max; i++) {
		if ([[self.fnArray objectAtIndex:i] integerValue] == oldVID) {
			[self.fnArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:newVID]];
		}
	}
	[self saveFnArray];
	
	for (i=0;i<2;i++) {
		NSString *key = [NSString stringWithFormat:@"frep%d",i];
		NSNumber *nep = [self.vo.optDict objectForKey:key];
		NSInteger ep = [nep integerValue];
		if (ep == oldVID) {
			[self.vo.optDict setObject:[NSNumber numberWithInteger:newVID] forKey:key];
		}
	}
}


#pragma mark voFunction ivar getters

- (NSArray*) epTitles {
	if (epTitles == nil) {
		// n.b.: tied to FREP symbol defns in voFunctions.h
		epTitles = [[NSArray alloc] initWithObjects: @"entry", @"hours", @"days", @"weeks", @"months", @"years", nil];
	}
	return epTitles;
}

- (NSMutableArray*) fnTitles {
	if (fnTitles == nil) {
		fnTitles = [[NSMutableArray alloc] init];
	}
	return fnTitles;
}

- (NSMutableArray*) fnArray {
	if (fnArray == nil) {
		fnArray = [[NSMutableArray alloc] init];
	}
	return fnArray;
}

- (NSMutableArray*) fnStrs {
	if (fnStrs == nil) {
		fnStrs = [[NSMutableArray alloc] initWithObjects:FnArrStrs,nil];
		for (valueObj* valo in MyTracker.valObjTable) {
			[fnStrs addObject:valo.valueName];
		}
	}
	return fnStrs;
}

#pragma mark -
#pragma mark protocol: voDisplay value 

- (NSString*) qdate:(NSInteger)d {
	return [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)d] 
										  dateStyle:NSDateFormatterShortStyle 
										  timeStyle:NSDateFormatterShortStyle];
}

- (int) getEpDate:(int)ndx maxdate:(int)maxdate {

	NSString *key = [NSString stringWithFormat:@"frep%d",ndx];
	
	NSNumber *nep = [self.vo.optDict objectForKey:key];
	NSInteger ep = [nep integerValue];
	NSInteger epDate;
	trackerObj *to = MyTracker;
	
	if (nep == nil || ep == FREPENTRY) {  // also FREPDFLT
		// use last entry
		to.sql = [NSString stringWithFormat:@"select date from trkrData where date < %d order by date desc limit 1;",maxdate];
		epDate = [to toQry2Int];
		DBGLog2(@"ep %d ->entry: %@", ndx, [self qdate:epDate] );
		to.sql = nil;
	} else if (ep >= 0) {
		// ep is vid
		to.sql = [NSString stringWithFormat:@"select date from voData where id=%d and date < %d order by date desc limit 1;",ep,maxdate];
		epDate = [to toQry2Int];
		DBGLog3(@"ep %d ->vo %@: %@", ndx, self.vo.valueName, [self qdate:epDate] );
		to.sql = nil;
	} else {
		// ep is (offset * -1)+1 into epTitles, with optDict:frv0 multiplier

		NSString *vkey = [NSString stringWithFormat:@"frv%d",ndx];
		NSInteger ival = [[self.vo.optDict objectForKey:vkey] integerValue] * ( ndx ? 1 : -1 ) ; // negative offset if ep0
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];

		NSString *vt=nil;
		
		switch (ep) {
			case FREPHOURS :
				[offsetComponents setHour:ival];
				vt = @"hours";
				break;
			case FREPDAYS :
				[offsetComponents setDay:ival];
				vt = @"days";
				break;
			case FREPWEEKS :
				[offsetComponents setWeek:ival];
				vt = @"weeks";
				break;
			case FREPMONTHS :
				[offsetComponents setMonth:ival];
				vt = @"months";
				break;
			case FREPYEARS :
				vt = @"years";
				[offsetComponents setYear:ival];
				break;
			default:
				NSAssert(0,@"getEpDate: failed to identify ep %d",ep);
				break;
		}
	
		NSDate *targ = [gregorian dateByAddingComponents:offsetComponents 
												  toDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)maxdate]
												 options:0];
		epDate = [targ timeIntervalSince1970];
		DBGLog4(@"ep %d ->offset %d %@: %@", ndx, ival, vt, [self qdate:epDate] );
		
		[gregorian release];
		[offsetComponents release];
	}
	return epDate;
}

- (NSNumber *) calcFunctionValue:(NSArray*)datePair {  // TODO: finish this
	if (datePair == nil) 
		return nil;
	
	int epd0 = [[datePair objectAtIndex:0] intValue];
	int epd1 = [[datePair objectAtIndex:1] intValue];

	NSInteger maxc = [self.fnArray count];
	NSInteger vid;
	trackerObj *to = MyTracker;
	
	double result = 0.0f;
	double v0 = 0.0f;
	double v1 = 0.0f;
	
	while (self.currFnNdx < maxc) {
		NSInteger currTok = [[self.fnArray objectAtIndex:self.currFnNdx] integerValue];
		if (isFn1Arg(currTok)) {
			self.currFnNdx++;
			vid = [[self.fnArray objectAtIndex:self.currFnNdx] integerValue];
			switch (currTok) {
				case FN1ARGDELTA :
					if (epd1 == 0) {
						v1 = [[to getValObj:vid].value doubleValue];
					} else {	
						to.sql = [NSString stringWithFormat:@"select val from voData where vid=%d and date=%d;",vid,epd1];
						v1 = [to toQry2Double];
					}
					to.sql = [NSString stringWithFormat:@"select val from voData where vid=%d and date=%d;",vid,epd0];
					v0 = [to toQry2Double];
					result = v1 - v0;
					break;
				case FN1ARGAVG :
					if (epd1 == 0) {
						v1 = [[to getValObj:vid].value doubleValue];
						to.sql = [NSString stringWithFormat:@"select avg(val) from voData where vid=%d and date >=%d;",vid,epd0];
						result = [to toQry2Float] + v1;
					} else {
						to.sql = [NSString stringWithFormat:@"select avg(val) from voData where vid=%d and date >=%d and date <=%d;",vid,epd0,epd1];
						result = [to toQry2Float];
					}
					break;
				default:
					switch (currTok) {
						case FN1ARGSUM :
						case FN1ARGPOSTSUM :
						case FN1ARGPRESUM :
							break;
							//  Not finished!
					}
			}
				
		}
	}
	
	
	return [NSNumber numberWithDouble:result];
	
}

- (NSNumber *) calcFunctionValueWithCurrent:(int)epd0 {
	
	NSInteger maxc = [self.fnArray count];
	NSInteger vid=0;
	trackerObj *to = MyTracker;
	
	int epd1;
	if (to.trackerDate == nil) {
		epd1 = (int) [[NSDate date] timeIntervalSince1970];
	} else {
		epd1 = (int) [to.trackerDate timeIntervalSince1970];
	}
	
	double result = 0.0f;
	
	while (self.currFnNdx < maxc) {
		NSInteger currTok = [[self.fnArray objectAtIndex:self.currFnNdx++] integerValue];
		if (isFn1Arg(currTok)) {
			vid = [[self.fnArray objectAtIndex:self.currFnNdx++] integerValue];  // get fn arg, can only be valobj vid
			//valueObj *valo = [to getValObj:vid];
			NSString *sv1 = [to getValObj:vid].value;
			double v1 = [sv1 doubleValue];
			
			switch (currTok) {  // all these 'date < epd1' because we will add in curr v1 and need to exclude if stored in db
				case FN1ARGDELTA :
					if (sv1 == nil || [sv1 isEqualToString:@""])
						return nil;  // delta requires v1 to subtract from, sums and avg just get one less result
					to.sql = [NSString stringWithFormat:@"select val from voData where id=%d and date=%d;",vid,epd0];
					double v0 = [to toQry2Double];
					result = v1 - v0;
					break;
				case FN1ARGAVG :
				{
					// this works but need to include any current but unsaved value
					//to.sql = [NSString stringWithFormat:@"select avg(val) from voData where id=%d and date >=%d and date <%d;",
					//		  vid,epd0,epd1];
					//result = [to toQry2Float];  // --> + v1;
					
					double c = [[self.vo.optDict objectForKey:@"frv0"] doubleValue];  // if ep has assoc value, then avg is over that num with date/time range already determined
					if (c == 0.0f) {  // else denom is number of entries
						to.sql = [NSString stringWithFormat:@"select count(val) from voData where id=%d and date >=%d and date <%d;",
								  vid,epd0,epd1];
						c = [to toQry2Float] + 1.0f;  // +1 for current on screen
					}
					
					to.sql = [NSString stringWithFormat:@"select sum(val) from voData where id=%d and date >=%d and date <%d;",
							  vid,epd0,epd1];
					result = ([to toQry2Float] + v1) / c;  // c>0 because at least 1 from above
					break;
				}
				default:
					switch (currTok) {
						case FN1ARGPRESUM :     
							//to.sql = [NSString stringWithFormat:@"select total(val) from voData where id=%d and date >=%d and date <%d;",
							//		  vid,epd0,epd1];
							//break;
						case FN1ARGSUM :
							to.sql = [NSString stringWithFormat:@"select total(val) from voData where id=%d and date >=%d and date <%d;",
									  vid,epd0,epd1];
							break;
						case FN1ARGPOSTSUM :
							to.sql = [NSString stringWithFormat:@"select total(val) from voData where id=%d and date >%d and date <%d;",vid,epd0,epd1];
							break;
					}
					result = [to toQry2Float];
					if (currTok != FN1ARGPRESUM)
						result += v1;
					break;
			}
		} else if (isFn2ArgOp(currTok)) {
			NSNumber *nrnum = [self calcFunctionValueWithCurrent:epd0]; // currFnNdx now at next place already
			double nextResult = [nrnum doubleValue];
			switch (currTok) {
				case FN2ARGPLUS :
					result += nextResult;
					break;
				case FN2ARGMINUS :
					result -= nextResult;
					break;
				case FN2ARGTIMES :
					result *= nextResult;
					break;
				case FN2ARGDIVIDE :
					if (nrnum != nil && nextResult != 0.0f) {
						result /= nextResult;
					} else {
						//result = nil;
						return nil;
					}
					break;
			} 
		} else if (currTok == FNPARENOPEN) {
			NSNumber *nrnum = [self calcFunctionValueWithCurrent:epd0]; // currFnNdx now at next place already
			result = [nrnum doubleValue];
		} else if (currTok == FNPARENCLOSE) {
			return [NSNumber numberWithDouble:result];
		} else {
			result = [[to getValObj:currTok].value doubleValue];
			self.currFnNdx++;  // on to next
		}
	}

	return [NSNumber numberWithDouble:result];

}


//- (NSString*) currFunctionValue {
- (NSString*) update:(NSString*)instr {
    instr = @"";
	int ep0date = [self getEpDate:0 maxdate:(int)[MyTracker.trackerDate timeIntervalSince1970]];
	if (ep0date == 0)
		return instr;
	NSInteger ep1 = [[self.vo.optDict valueForKey:@"frep1"] integerValue];
	if (ep1 >= 0) {  // if ep1 is a valueObj
		valueObj *valo = [MyTracker getValObj:ep1];
		if ( valo == nil
			|| valo.value == nil
			|| [valo.value isEqualToString:@""] 
			/*|| (valo.vtype == VOT_BOOLEAN && [valo.value isEqualToString:@"0"])*/ )
			return instr;
	}
	
	self.currFnNdx=0;
	
	NSNumber *val = [self calcFunctionValueWithCurrent:ep0date];
	
    if (val != nil) {
        NSNumber *nddp = [self.vo.optDict objectForKey:@"fnddp"];
        int ddp = ( nddp == nil ? FDDPDFLT : [nddp intValue] );
        return [NSString stringWithFormat:[NSString stringWithFormat:@"%%0.%df",ddp],[val floatValue]];
    }
    DBGLog1(@"fn update returning: %@",instr);
    
    return instr;
}

- (UILabel*) rlab {
    if (nil == rlab) {
        rlab = [[UILabel alloc] initWithFrame:self.voFrame];
        rlab.textAlignment = UITextAlignmentRight;
    }
    return rlab;
}
- (UIView*) voDisplay:(CGRect)bounds {
		
	//trackerObj *to = (trackerObj*) parentTracker;
	self.voFrame = bounds;
    
	//UILabel *rlab = [[UILabel alloc] initWithFrame:bounds];
	//rlab.textAlignment = UITextAlignmentRight;
	NSString *valstr = self.vo.value;  // evaluated on read so make copy
	if (![valstr isEqualToString:@""]) {
		self.rlab.backgroundColor = [UIColor whiteColor];
        self.rlab.text = valstr;
	} else {
		self.rlab.backgroundColor = [UIColor lightGrayColor];
		self.rlab.text = @"-";
	}
	
	//return [rlab autorelease];
    return self.rlab;
}

- (NSArray*) voGraphSet {
	return [voState voGraphSetNum];
}

#pragma mark -
#pragma mark function configTVObjVC 
#pragma mark -

#pragma mark range definition page 

//
// convert endpoint from left or right picker to rownum for offset symbol (hours, months, ...) or valobj
//

// ep options are : 
//     row 0:      entry 
//     rows 1..m:  [valObjs] (ep = vid)
//     rows n...:  other epTitles entries

- (NSInteger) epToRow:(NSInteger)component {
	NSString *key = [NSString stringWithFormat:@"frep%d",component];
	NSNumber *n = [self.vo.optDict objectForKey:key];
	NSInteger ep = [n integerValue];
	if (n == nil || ep == FREPDFLT) // no endpoint defined, so default row 0
		return 0;
	if (ep >= 0  || ep <= -TMPUNIQSTART)  // ep defined and saved, or ep not saved and has tmp vid, so return ndx in vo table
		return [MyTracker.valObjTable indexOfObjectIdenticalTo:[MyTracker getValObj:ep]] +1;
		//return ep+1;
	
	return (ep * -1) + [MyTracker.valObjTable count] -1;  // ep is offset into hours, months list
}

- (NSString *) fnrRowTitle:(NSInteger)row {
	if (row != 0) {
		NSInteger votc = [MyTracker.valObjTable count];
		if (row <= votc) {
			return ((valueObj*) [MyTracker.valObjTable objectAtIndex:row-1]).valueName;
		} else {
			row -= votc;
		}
	}
	return [self.epTitles objectAtIndex:row];
}

// 
// if picker row is offset (not valobj), display a textfield and label to get number of (hours, months,...) offset
//

- (void) updateValTF:(NSInteger)row component:(NSInteger)component {
	NSInteger votc = [MyTracker.valObjTable count];
	
	if (row > votc) {
		NSString *vkey = [NSString stringWithFormat:@"frv%d",component];
		//NSString *key = [NSString stringWithFormat:@"frep%d",component];
		NSString *vtfkey = [NSString stringWithFormat:@"fr%dTF",component];
		NSString *pre_vkey = [NSString stringWithFormat:@"frpre%dvLab",component];
		NSString *post_vkey = [NSString stringWithFormat:@"frpost%dvLab",component];
		
		UITextField *vtf= [self.ctvovcp.wDict objectForKey:vtfkey];
		vtf.text = [self.vo.optDict objectForKey:vkey];
		[self.ctvovcp.view addSubview:vtf];
		[self.ctvovcp.view addSubview:[self.ctvovcp.wDict objectForKey:pre_vkey]];
		UILabel *postLab = [self.ctvovcp.wDict objectForKey:post_vkey];
		postLab.text = [self fnrRowTitle:row];
		[self.ctvovcp.view addSubview:postLab];
	}
}

- (void) drawFuncOptsRange {
	CGRect frame = {MARGIN,self.ctvovcp.lasty,0.0,0.0};
	
	CGRect labframe = [self.ctvovcp configLabel:@"Function range endpoints:" 
								  frame:frame
									key:@"freLab" 
								  addsv:YES ];
	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
	
	/*labframe =*/ [self.ctvovcp configLabel:@"Previous" 
							   frame:frame
								 key:@"frpLab" 
							   addsv:YES ];
	frame.origin.x = (self.ctvovcp.view.frame.size.width / 2.0) + MARGIN;
	
	labframe = [self.ctvovcp configLabel:@"Current" 
						   frame:frame
							 key:@"frcLab" 
						   addsv:YES ];
	
	frame.origin.y += labframe.size.height + MARGIN;
	frame.origin.x = 0.0;
	
	frame = [self.ctvovcp configPicker:frame key:@"frPkr" caller:self];
	UIPickerView *pkr = [self.ctvovcp.wDict objectForKey:@"frPkr"];
	
	[pkr selectRow:[self epToRow:0] inComponent:0 animated:NO];
	[pkr selectRow:[self epToRow:1] inComponent:1 animated:NO];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
	
	labframe = [self.ctvovcp configLabel:@"-" 
						   frame:frame
							 key:@"frpre0vLab" 
						   addsv:NO ];
	
	frame.origin.x += labframe.size.width + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = self.ctvovcp.LFHeight; 
	
	[self.ctvovcp configTextField:frame 
					  key:@"fr0TF" 
				   target:nil
				   action:nil
					  num:YES 
					place:nil
					 text:[self.vo.optDict objectForKey:@"frv0"] 
					addsv:NO ];
	
	frame.origin.x += tfWidth + 2*SPACE;
	/*labframe =*/ [self.ctvovcp configLabel:@"months" 
							   frame:frame
								 key:@"frpost0vLab" 
							   addsv:NO ];
	
	[self updateValTF:[self epToRow:0] component:0];
	
	frame.origin.x = (self.ctvovcp.view.frame.size.width / 2.0) + MARGIN;
	
	labframe = [self.ctvovcp configLabel:@"+" 
						   frame:frame
							 key:@"frpre1vLab" 
						   addsv:NO ];
	
	frame.origin.x += labframe.size.width + SPACE;
	[self.ctvovcp configTextField:frame 
					  key:@"fr1TF" 
				   target:nil
				   action:nil
					  num:YES 
					place:nil
					 text:[self.vo.optDict objectForKey:@"frv1"] 
					addsv:NO ];
	
	frame.origin.x += tfWidth + 2*SPACE;
	/*labframe =*/ [self.ctvovcp configLabel:@"months" 
							   frame:frame
								 key:@"frpost1vLab" 
							   addsv:NO ];
	
	[self updateValTF:[self epToRow:1] component:1];
	
}

#pragma mark -
#pragma mark function definition page 

//
// generate text to describe function as specified by symbols,vids in fnArray from 
//  strings in fnStrs or valueObj names
//

- (NSString*) voFnDefnStr {
	NSMutableString *fstr = [[NSMutableString alloc] init];
	BOOL closePending = NO;  //square brackets around target of Fn1Arg
	
	for (NSNumber *n in self.fnArray) {
		NSInteger i = [n integerValue];
		if (isFn(i)) {
			NSInteger ndx = (i * -1) -1;
			[fstr appendString:[self.fnStrs objectAtIndex:ndx]];
			if (isFn1Arg(i)) {
				[fstr appendString:@"["];
				closePending=YES;
			}
		} else {
			[fstr appendString:[MyTracker voGetNameForVID:i]];  // could get from self.fnStrs
			if (closePending) {
				[fstr appendString:@"]"];
				closePending=NO;
			}
		}
		if (! closePending)
			[fstr appendString:@" "];
	}
	return [fstr autorelease];
}


- (void) updateFnTV {
	UITextView *ftv = [self.ctvovcp.wDict objectForKey:@"fdefnTV2"];
	ftv.text = [self voFnDefnStr];
}

- (void) btnAdd:(id)sender {
	UIPickerView *pkr = [self.ctvovcp.wDict objectForKey:@"fdPkr"];
	NSInteger row = [pkr selectedRowInComponent:0];
	NSNumber *ntok = [self.fnTitles objectAtIndex:row];
	[self.fnArray addObject:ntok];
	[self updateFnTitles];
	[pkr reloadComponent:0];
	[self updateFnTV];
}

- (void) btnDelete:(id)sender {
	UIPickerView *pkr = [self.ctvovcp.wDict objectForKey:@"fdPkr"];
	[self.fnArray removeLastObject];
	[self updateFnTitles];
	[pkr reloadComponent:0];
	[self updateFnTV];
}

- (void) drawFuncOptsDefinition {
	[self updateFnTitles];
	
	CGRect frame = {MARGIN,self.ctvovcp.lasty,0.0,0.0};
	
	CGRect labframe = [self.ctvovcp configLabel:@"Function definition:" 
								  frame:frame
									key:@"fdLab" 
								  addsv:YES ];
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + labframe.size.height;
	frame.size.width = self.ctvovcp.view.frame.size.width - 2*MARGIN; // 300.0f;
	frame.size.height = self.ctvovcp.LFHeight;
	
	[self.ctvovcp configTextView:frame key:@"fdefnTV2" text:[self voFnDefnStr]];
	
	frame.origin.x = 0.0;
	frame.origin.y += frame.size.height + MARGIN;
	
	frame = [self.ctvovcp configPicker:frame key:@"fdPkr" caller:self];
	//UIPickerView *pkr = [self.ctvovcp.wDict objectForKey:@"fdPkr"];
	
	//[pkr selectRow:[self epToRow:0] inComponent:0 animated:NO];
	//[pkr selectRow:[self epToRow:1] inComponent:1 animated:NO];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
	frame.size.height = labframe.size.height;
	
	[self.ctvovcp configActionBtn:frame key:@"fdaBtn" label:@"Add" target:self action:@selector(btnAdd:)]; 
	frame.origin.x = -1.0f;
	[self.ctvovcp configActionBtn:frame key:@"fddBtn" label:@"Delete" target:self action:@selector(btnDelete:)]; 
	
}

#pragma mark -
#pragma mark function overview page 

//
// nice text string to describe a specified range endpoint
//

- (NSString*) voEpStr:(NSInteger)component {
	NSString *key = [NSString stringWithFormat:@"frep%d",component];
	NSString *vkey = [NSString stringWithFormat:@"frv%d",component];
	NSString *pre = component ? @"current" : @"previous";
	
	NSNumber *n = [self.vo.optDict objectForKey:key];
	NSInteger ep = [n integerValue];
	NSUInteger ep2 = n ? (ep+1)*-1 : 0; // invalid if ep is tmpUniq (negative)
	
	if (n == nil || ep == FREPDFLT) // no endpoint defined, default is 'entry'
		return [NSString stringWithFormat:@"%@ %@", pre, [self.epTitles objectAtIndex:ep2]];  // FREPDFLT
	if (ep >= 0 || ep <= -TMPUNIQSTART )  // endpoint is vid and valobj saved, or tmp vid as valobj not saved
		return [NSString stringWithFormat:@"%@ %@", pre, ((valueObj*)[MyTracker getValObj:ep]).valueName];
	
	// ep is hours / days / months entry
	return [NSString stringWithFormat:@"%@%d %@",  
			(component ? @"+" : @"-"), [[self.vo.optDict objectForKey:vkey] intValue], [self.epTitles objectAtIndex:ep2]];
}

- (NSString*) voRangeStr {
	return [NSString stringWithFormat:@"%@ to %@", [self voEpStr:0], [self voEpStr:1]];
}

- (void) drawFuncOptsOverview {
	CGRect frame = {MARGIN,self.ctvovcp.lasty,0.0,0.0};
	CGRect labframe = [self.ctvovcp configLabel:@"Range:" 
								  frame:frame
									key:@"frLab" 
								  addsv:YES ];
	
	//frame = (CGRect) {-1.0f, frame.origin.y, 0.0f,labframe.size.height};
	//[self configActionBtn:frame key:@"frbBtn" label:@"Build" action:@selector(btnBuild:)]; 
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + labframe.size.height;
	frame.size.width = self.ctvovcp.view.frame.size.width - 2*MARGIN; // 300.0f;
	frame.size.height = self.ctvovcp.LFHeight;
	
	[self.ctvovcp configTextView:frame key:@"frangeTV" text:[self voRangeStr]];
	
	frame.origin.y += frame.size.height + MARGIN;
	labframe = [self.ctvovcp configLabel:@"Definition:" 
						   frame:frame
							 key:@"fdLab" 
						   addsv:YES];
	
	frame = (CGRect) {-1.0f, frame.origin.y, 0.0f,labframe.size.height};
	//[self configActionBtn:frame key:@"fdbBtn" label:@"Build" action:@selector(btnBuild:)]; 
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	frame.size.width = 300.0f;
	frame.size.height = self.ctvovcp.LFHeight;
	
	[self.ctvovcp configTextView:frame key:@"fdefnTV" text:[self voFnDefnStr]];
	
	frame.origin.y += frame.size.height + MARGIN;
	
	labframe = [self.ctvovcp configLabel:@"result display decimal places:" frame:frame key:@"fnddpLab" addsv:YES];
	
	frame.origin.x += labframe.size.width + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = self.ctvovcp.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[self.ctvovcp configTextField:frame 
						key:@"fnddpTF" 
					 target:nil 
					 action:nil
						num:YES 
					  place:[NSString stringWithFormat:@"%d",FDDPDFLT] 
					   text:[self.vo.optDict objectForKey:@"fnddp"]
					  addsv:YES ];
	
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + labframe.size.height;
	
	frame = [self.ctvovcp yAutoscale:frame];
	
	//frame.origin.y += frame.size.height + MARGIN;
	//frame.origin.x = MARGIN;
	
	self.ctvovcp.lasty = frame.origin.y + frame.size.height + MARGIN;
}

#pragma mark -
#pragma mark configTVObjVC general support

//
// called for btnDone in configTVObjVC
//

- (void) funcDone {
	if (fnArray != nil && [self.fnArray count] != 0) {
		//DBGLog1(@"funcDone 0: %@",[self.vo.optDict objectForKey:@"func"]);
		[self saveFnArray];
		DBGLog1(@"funcDone 1: %@",[self.vo.optDict objectForKey:@"func"]);

		// frep0 and 1 not set if user did not click on range picker
		if ([self.vo.optDict objectForKey:@"frep0"] == nil) 
			[self.vo.optDict setObject:[NSNumber numberWithInt:FREPDFLT] forKey:@"frep0"];
		if ([self.vo.optDict objectForKey:@"frep1"] == nil) 
			[self.vo.optDict setObject:[NSNumber numberWithInt:FREPDFLT] forKey:@"frep1"];
		
		DBGLog2(@"ep0= %@  ep1=%@",[self.vo.optDict objectForKey:@"frep0"],[self.vo.optDict objectForKey:@"frep1"]);
		
	}
}


//
// called for configTVObjVC  viewDidLoad
//
- (void) funcVDL:(configTVObjVC*)ctvovc donebutton:(UIBarButtonItem*)db {
		
	if ([((trackerObj*)self.vo.parentTracker).valObjTable count] > 0) {
		
		UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
													initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
													target:nil action:nil];
		
		NSArray *segmentTextContent = [NSArray arrayWithObjects: @"overview", @"range", @"fn definition", nil];
		
		UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
		//[segmentTextContent release];
		
		[segmentedControl addTarget:self action:@selector(fnSegmentAction:) forControlEvents:UIControlEventValueChanged];
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.selectedSegmentIndex = self.fnSegNdx = 0;
		UIBarButtonItem *scButtonItem = [[UIBarButtonItem alloc]
										 initWithCustomView:segmentedControl];
		
		ctvovc.toolBar.items = [NSArray arrayWithObjects: db, flexibleSpaceButtonItem, scButtonItem, flexibleSpaceButtonItem, nil];
		
		[segmentedControl release];
		[scButtonItem release];
		[flexibleSpaceButtonItem release];
	}
}


- (void) drawSelectedPage {
	switch (self.fnSegNdx) {
		case FNSEGNDX_OVERVIEW: 
			[self drawFuncOptsOverview];
			[super voDrawOptions:self.ctvovcp];
			break;
		case FNSEGNDX_RANGEBLD:
			[self drawFuncOptsRange];
			break;
		case FNSEGNDX_FUNCTBLD:
			[self drawFuncOptsDefinition];
			break;
		default:
			NSAssert(0,@"fnSegmentAction bad index!");
			break;
	}
}

- (void) fnSegmentAction:(id)sender
{
	self.fnSegNdx = [sender selectedSegmentIndex];
	//DBGLog1(@"fnSegmentAction: selected segment = %d", self.fnSegNdx);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self.ctvovcp removeSVFields];
	[self drawSelectedPage];
	
	[UIView commitAnimations];
}

#pragma mark protocol: voDrawOptions page 

- (void) setOptDictDflts {
    if (nil == [self.vo.optDict objectForKey:@"frep0"]) 
        [self.vo.optDict setObject:[NSString stringWithFormat:@"%d", FREPDFLT] forKey:@"frep0"];
    if (nil == [self.vo.optDict objectForKey:@"frep1"]) 
        [self.vo.optDict setObject:[NSString stringWithFormat:@"%d", FREPDFLT] forKey:@"frep1"];
    if (nil == [self.vo.optDict objectForKey:@"fnddp"]) 
        [self.vo.optDict setObject:[NSString stringWithFormat:@"%d", FDDPDFLT] forKey:@"fnddp"];
    if (nil == [self.vo.optDict objectForKey:@"func"]) 
        [self.vo.optDict setObject:@"" forKey:@"func"];
    if (nil == [self.vo.optDict objectForKey:@"autoscale"]) 
        [self.vo.optDict setObject:(AUTOSCALEDFLT ? @"1" : @"0") forKey:@"autoscale"];
    
    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = [self.vo.optDict objectForKey:key];
    if (nil == val) 
        return YES;
    
    if (([key isEqualToString:@"frep0"] && ([val intValue] == FREPDFLT))
        ||
        ([key isEqualToString:@"frep1"] && ([val intValue] == FREPDFLT))
        ||
        ([key isEqualToString:@"fnddp"] && ([val intValue] == FDDPDFLT))
        ||
        ([key isEqualToString:@"func"] && ([val isEqualToString:@""]))
        ||
        ([key isEqualToString:@"autoscale"] && [val isEqualToString:(AUTOSCALEDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    
    return [super cleanOptDictDflts:key];
}



- (void) voDrawOptions:(configTVObjVC *)ctvovc {
	self.ctvovcp = ctvovc;
	[self drawSelectedPage];
}

#pragma mark picker support

//
// build list of titles for symbols,operations available for current point in fn definition string
//

- (void) ftAddFnSet {
	int i;
	for (i=FN1ARGFIRST;i>=FN1ARGLAST;i--) {
		[self.fnTitles addObject:[NSNumber numberWithInt:i]];
	}
}

- (void) ftAdd2OpSet {
	int i;
	for (i=FN2ARGFIRST;i>=FN2ARGLAST;i--) {
		[self.fnTitles addObject:[NSNumber numberWithInt:i]];
	}
}

- (void) ftAddVOs {
	for (valueObj *valo in MyTracker.valObjTable) {
		[self.fnTitles addObject:[NSNumber numberWithInteger:valo.vid]];
	}
}

- (void) ftAddCloseParen {
	int pcount=0;
	for (NSNumber *ni in self.fnArray) {
		int i = [ni intValue];
		if (i == FNPARENOPEN) {
			pcount++;
		} else if (i == FNPARENCLOSE) {
			pcount--;
		}
	}
	if (pcount > 0) 
		[self.fnTitles addObject:[NSNumber numberWithInt:FNPARENCLOSE]];
}

- (void) ftStartSet {
	[self ftAddFnSet];
	[self.fnTitles addObject:[NSNumber numberWithInt:FNPARENOPEN]];
	[self ftAddVOs];
}

- (void) updateFnTitles {
	[self.fnTitles removeAllObjects];
	if ([self.fnArray count] == 0) {  // state = start
		[self ftStartSet];
	} else {
		int last = [[self.fnArray lastObject] intValue];
		if (last >= 0 || last <= -TMPUNIQSTART) { // state = after valObj
			[self ftAdd2OpSet];
			[self ftAddCloseParen];
		} else if (isFn1Arg(last)) {  // state = after Fn1 = delta, avg, sum
			[self ftAddVOs];
		} else if (isFn2ArgOp(last)) { // state = after fn2op = +,-,*,/
			[self ftStartSet];
		} else if (last == FNPARENCLOSE) { // state = after close paren
			[self ftAdd2OpSet];
			[self ftAddCloseParen];
		} else if (last == FNPARENOPEN) { // state = after open paren
			[self ftStartSet];
		} else {
			NSAssert(0,@"lost it at updateFnTitles");
		}
	}
}

- (NSString*) fnTokenToStr:(NSInteger)tok {
	if (isFn(tok)) {
		tok = (tok * -1) -1;
		return [self.fnStrs objectAtIndex:tok];
	} else {	
		for (valueObj *valo in MyTracker.valObjTable) {
			if (valo.vid == tok)
				return valo.valueName;
		}
		NSAssert(0,@"fnTokenToStr failed to find valObj");
		return @"unknown vid";
	}
}

- (NSString*) fndRowTitle:(NSInteger)row {
	return [self fnTokenToStr:[[self.fnTitles objectAtIndex:row] integerValue]];
}

- (NSInteger) fnrRowCount:(NSInteger)component {
/*
	NSInteger other = (component ? 0 : 1);
	NSString *otherKey = [NSString stringWithFormat:@"frep%d",other];
	id otherObj = [self.vo.optDict objectForKey:otherKey];
	NSInteger otherVal = [otherObj integerValue];
	if (otherVal < -1) {
 */ // only allow time offset for previous side of range
	if (component == 1) {
		return [MyTracker.valObjTable count]+1;
	} else {
		return [MyTracker.valObjTable count] + 6;
	}
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD)
		return 2;
	else 
		return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD) 
		return [self fnrRowCount:component];
	else 
		return [self.fnTitles count];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component {
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD) {
		return [self fnrRowTitle:row];
	} else {  // FNSEGNDX_FUNCTBLD
		return [self fndRowTitle:row];
	}
	//return [NSString stringWithFormat:@"row %d", row];
}

- (void) updateForPickerRowSelect:(NSInteger)row inComponent:(NSInteger)component {
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD) {
		[((UIPickerView*) [self.ctvovcp.wDict objectForKey:@"frPkr"]) reloadComponent:(component ? 0 : 1)];
	} //else {
		//[((UIPickerView*) [self.wDict objectForKey:@"fnPkr"]) reloadComponent:0];
	//}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{	
	if (self.fnSegNdx == FNSEGNDX_RANGEBLD) {
		NSInteger votc = [MyTracker.valObjTable count];
		
		NSString *key = [NSString stringWithFormat:@"frep%d",component];
		NSString *vtfkey = [NSString stringWithFormat:@"fr%dTF",component];
		NSString *pre_vkey = [NSString stringWithFormat:@"frpre%dvLab",component];
		NSString *post_vkey = [NSString stringWithFormat:@"frpost%dvLab",component];
		
		[((UIView*) [self.ctvovcp.wDict objectForKey:pre_vkey]) removeFromSuperview];
		[((UIView*) [self.ctvovcp.wDict objectForKey:vtfkey]) removeFromSuperview];
		[((UIView*) [self.ctvovcp.wDict objectForKey:post_vkey]) removeFromSuperview];
		
		if (row == 0) {
			[self.vo.optDict setObject:[NSNumber numberWithInt:-1.0f] forKey:key];
		} else if (row <= votc) {
			[self.vo.optDict setObject:[NSNumber numberWithInteger:
										((valueObj*) [MyTracker.valObjTable objectAtIndex:row-1]).vid]
								forKey:key];  
		} else { 
			[self.vo.optDict setObject:[NSNumber numberWithInt:(((row - votc) +1) * -1)] forKey:key];
			[self updateValTF:row component:component];
		}
		DBGLog3(@"picker sel row %d %@ now= %d", row, key, [[self.vo.optDict objectForKey:key] integerValue] );
	} else {
	}
	
	[self updateForPickerRowSelect:row inComponent:component];
	
}


@end
