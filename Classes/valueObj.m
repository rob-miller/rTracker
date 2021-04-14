/***************
 valueObj.m
 Copyright 2010-2021 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

//
//  valueObj.m
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "valueObj.h"
#import "trackerObj.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"

#import "voNumber.h"
#import "voText.h"
#import "voTextBox.h"
#import "voChoice.h"
#import "voBoolean.h"
#import "voSlider.h"
#import "voImage.h"
#import "voFunction.h"
#import "voInfo.h"

#import "dbg-defs.h"

//@class voState;
@class vogd;

#define f(x) ((CGFloat) (x))

@implementation valueObj

@synthesize vid=_vid, vtype=_vtype, vpriv=_vpriv, valueName=_valueName, value=_value, vcolor=_vcolor, vGraphType=_vGraphType, display=_display, useVO=_useVO, optDict=_optDict, parentTracker=_parentTracker, checkButtonUseVO=_checkButtonUseVO;
@synthesize vos=_vos,vogd=_vogd;  //, retrievedData;

//extern const NSInteger kViewTag;
extern const NSArray *numGraphs,*textGraphs,*pickGraphs,*boolGraphs;

#pragma mark -
#pragma mark core object methods and support


- (id) init {
	return [self initWithData:nil in_vid:0 in_vtype:0 in_vname:@"" in_vcolor:0 in_vgraphtype:0 in_vpriv:0];
}

- (id) initWithData:(id)parentTO 
	 in_vid:(NSInteger)in_vid 
   in_vtype:(NSInteger)in_vtype 
   in_vname:(NSString *)in_vname 
  in_vcolor:(NSInteger)in_vcolor 
in_vgraphtype:(NSInteger)in_vgraphtype
in_vpriv:(NSInteger)in_vpriv
{
	//DBGLog(@"init vObj with args vid: %d vtype: %d vname: %@",in_vid, in_vtype, in_vname);
	if ((self = [super init])) {
		//self.useVO = YES;

		self.parentTracker = parentTO;
		self.vid = in_vid ;
		self.vtype = in_vtype;  // sets useVO
		
		self.valueName = in_vname;
		self.vcolor = in_vcolor;
		self.vGraphType = in_vgraphtype;
	}
	
	return self;
}

- (id) initWithDict:(id)parentTO dict:(NSDictionary*)dict {
    /*
	DBGLog(@"init vObj with dict vid: %d vtype: %d vname: %@",
           [(NSNumber*) [dict objectForKey:@"vid"] integerValue],
           [(NSNumber*) [dict objectForKey:@"vtype"] integerValue],
           (NSString*) [dict objectForKey:@"valueName"]);
     */
	if ((self = [super init])) {
		self.useVO = YES;
		self.parentTracker = parentTO;
		self.vid = [(NSNumber*) dict[@"vid"] integerValue];
        [(trackerObj*) self.parentTracker minUniquev:self.vid];
		self.valueName = (NSString*) dict[@"valueName"];
        //self.optDict = (NSMutableDictionary*) dict[@"optDict"];
        self.optDict = (NSMutableDictionary*) CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)dict[@"optDict"], kCFPropertyListMutableContainersAndLeaves));
        self.vpriv = [(NSNumber*) dict[@"vpriv"] integerValue];
		self.vtype = [(NSNumber*) dict[@"vtype"] integerValue];
        // setting vtype sets vo.useVO through vos init
		self.vcolor = [(NSNumber*) dict[@"vcolor"] integerValue];
		self.vGraphType = [(NSNumber*) dict[@"vGraphType"] integerValue];
        
	}
	
	return self;
}

- (id) initWithParentOnly:(trackerObj*)parentTO {
    return [self initWithData:parentTO in_vid:0 in_vtype:0 in_vname:@"" in_vcolor:0 in_vgraphtype:0 in_vpriv:0];
}

- (id) initFromDB:(trackerObj*)parentTO
             in_vid:(NSInteger)in_vid
{
	if ((self = [super init])) {
		//self.useVO = YES;
        
		self.parentTracker = parentTO;
		self.vid = in_vid ;
        
        NSString *sql = [NSString stringWithFormat:@"select type, color, graphtype from voConfig where id=%ld",(long)in_vid];
        
        NSInteger in_vtype;
        NSInteger in_vcolor;
        NSInteger in_vgraphtype;
        
        [parentTO toQry2IntIntInt:&in_vtype i2:&in_vcolor i3:&in_vgraphtype sql:sql];
        
		self.vtype = in_vtype;  // sets useVO
        self.vcolor = in_vcolor;
		self.vGraphType = in_vgraphtype;
        
        sql = [NSString stringWithFormat:@"select name from voConfig where id==%ld",(long)in_vid];
        self.valueName = [parentTO toQry2Str:sql];
	}
	
	return self;
    
}


#pragma mark -
# pragma mark dictionary to/from

- (NSDictionary*) dictFromVO {
    /*
    NSNumber *myvid = [NSNumber numberWithInteger:self.vid];
    NSNumber *myvtype = [NSNumber numberWithInteger:self.vtype];
    NSNumber *myvpriv = [NSNumber numberWithInteger:self.vpriv];
    NSString *myvaluename = self.valueName;
    NSNumber *myvcolor = [NSNumber numberWithInteger:self.vcolor];
    NSNumber *myvgt = [NSNumber numberWithInteger:self.vGraphType];
    NSDictionary *myoptdict = self.optDict;
    
    DBGLog(@"vid %@  vtype %@  vpriv %@  valuename %@  vcolor %@  vgt %@  optdict  %@",
           myvid, myvtype, myvpriv, myvaluename,myvcolor,myvgt,myoptdict);
    
    DBGLog(@"vid %@  vtype %@  vpriv %@  valuename %@  vcolor  %@ vgt  %@ optdict  %@",
           [NSNumber numberWithInteger:self.vid],
            [NSNumber numberWithInteger:self.vtype],
            [NSNumber numberWithInteger:self.vpriv],
            self.valueName,
            [NSNumber numberWithInteger:self.vcolor],
            [NSNumber numberWithInteger:self.vGraphType],
            self.optDict
           );
    */
     return @{@"vid": @(self.vid),
            @"vtype": @(self.vtype),
            @"vpriv": @(self.vpriv),
            @"valueName": self.valueName,
            @"vcolor": @(self.vcolor),
            @"vGraphType": @(self.vGraphType),
            @"optDict": self.optDict};
}


- (NSMutableDictionary *) optDict
{
	if (_optDict == nil) {
		_optDict = [[NSMutableDictionary alloc] init];
	}
	return _optDict;
}

- (NSMutableString*) value {
    dbgNSAssert(_vos,@"accessing vo.value with nil vos");
    if (_value == nil) {
        _value = [[NSMutableString alloc] initWithCapacity:[self.vos getValCap]];
        //value = [[NSMutableString alloc] init];
        [_value setString:@""];
    }
    [_value setString:[self.vos update:_value]];
    return _value;
}

- (NSString*) csvValue {
    return [self.vos mapValue2Csv];
}

- (void) resetData {
    [self.vos resetData];
	[self.value setString:@""];
    
    //self.retrievedData = NO;
    // do self.useVO in vos resetData
    //DBGLog(@"vo resetData %@",self.valueName);
}

- (void) setVtype:(NSInteger)vt {  // called for setting property vtype
    //DBGLog(@"setVtype - allocating vos");
	_vtype = vt;  // not self as this is set fn!
    id tvos=nil;
	switch (vt) {
		case VOT_NUMBER:
            tvos = [[voNumber alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:10];
			break;
		case VOT_SLIDER:
			tvos = [[voSlider alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:10];
			//[self.value setString:@"0"];
			break;
		case VOT_BOOLEAN:
			tvos = [[voBoolean alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:1];
			//[self.value setString:@"0"];
			break;
		case VOT_CHOICE:
			tvos = [[voChoice alloc] initWithVO:self];
            self.vcolor = -1;
			//value = [[NSMutableString alloc] initWithCapacity:1];
			//[self.value setString:@"0"];
			break;
		case VOT_TEXT:
			tvos = [[voText alloc] initWithVO:self];
            //value = [[NSMutableString alloc] initWithCapacity:32];
			break;
		case VOT_FUNC:
			tvos = [[voFunction alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:32];
			//[self.value setString:@""];
			break;	
            /*
		case VOT_IMAGE:
			tvos = [[voImage alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:64];
			//[self.value setString:@""];
			break;
             */
		case VOT_TEXTB:
			tvos = [[voTextBox alloc] initWithVO:self];
            //value = [[NSMutableString alloc] initWithCapacity:96];
			//[self.value setString:@""];
			break;
		case VOT_INFO:
			tvos = [[voInfo alloc] initWithVO:self];
            self.vcolor = -1;
			//value = [[NSMutableString alloc] initWithCapacity:1];
			//[self.value setString:@"0"];
			break;
		default:
			dbgNSAssert1(0,@"valueObj init vtype %ld not supported",(long)vt);
            tvos = [[voNumber alloc] initWithVO:self]; // to clear analyzer worry 
            _vtype = VOT_NUMBER;  // consistency if we get here
			break;
	}
    self.vos=nil;
    self.vos = tvos;
    NSMutableString *tval;
    tval = [[NSMutableString alloc] initWithCapacity:[self.vos getValCap]];  // causes memory leak
    self.value = nil;
    self.value = tval;
    //[self.value release];   // clear retain count from alloc + retain
}


#pragma mark -
#pragma mark display fn dispatch

- (UIView *) display:(CGRect)bounds {
    if (_display && _display.frame.size.width != bounds.size.width)
        _display = nil;
        
	if (_display == nil) {
        DBGLog(@"vo new display name:  %@ currVal: .%@.",self.valueName,self.value);
		self.display = [self.vos voDisplay:bounds];
        self.display.tag = kViewTag;
	}
	return _display;
}

-(void) setTrackerDateToNow {
    ((trackerObj*) self.parentTracker).trackerDate = [NSDate date];
}

#pragma mark -
#pragma mark checkButton support

- (void) enableVO 
{
	if (!self.useVO) {
		self.useVO = YES;
		[self.checkButtonUseVO setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
	}
}

- (void) disableVO 
{
	if (self.useVO) {
		self.useVO = NO;
		[self.checkButtonUseVO setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
	}
}


// called when the checkmark button is touched 
- (void)checkAction:(id)sender
{
	DBGLog(@"checkbox ticked for %@ new state= %d",_valueName, !self.useVO);
	UIImage *checkImage;
	
	// note: we don't use 'sender' because this action method can be called separate from the button (i.e. from table selection)
	//self.useVO = !self.useVO;

    //TODO: re-write to use voStates as appropriate, vos:update returns '' if disabled so could keep values or should clear .value here
    
	if ((self.useVO = !self.useVO)) { // if new state=TRUE (toggle useVO and set)   // enableVO ... disableVO
		checkImage = [UIImage imageNamed:@"checked.png"];
        //   do in update():
		if (self.vtype == VOT_SLIDER) 
			[self.value setString:[NSString stringWithFormat:@"%f",((UISlider*)self.display).value]];
	} else {          // new state = FALSE
		checkImage = [UIImage imageNamed:@"unchecked.png"];
		if (self.vtype == VOT_CHOICE)
			((UISegmentedControl *) self.display).selectedSegmentIndex =  UISegmentedControlNoSegment;
		else if (self.vtype == VOT_SLIDER) {
			NSNumber *nsdflt = (self.optDict)[@"sdflt"];
			CGFloat sdflt =  nsdflt ? [nsdflt floatValue] : SLIDRDFLTDFLT;
            
            if ([(self.optDict)[@"slidrswlb"] isEqualToString:@"1"]) {  // handle slider option 'starts with last'
                trackerObj *to = (trackerObj*)self.parentTracker;
                NSString *sql = [NSString stringWithFormat:@"select count(*) from voData where id=%ld and date<%d",
                                 (long)self.vid,(int)[to.trackerDate timeIntervalSince1970]];
                int v = [to toQry2Int:sql];
                if (v>0) {
                    sql = [NSString stringWithFormat:@"select val from voData where id=%ld and date<%d order by date desc limit 1;",
                           (long)self.vid,(int)[to.trackerDate timeIntervalSince1970]];
                    sdflt = [to toQry2Float:sql];
                }
            }
            
			[((UISlider *) self.display) setValue:sdflt animated:YES];
		}
	}

    [[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];		
	[self.checkButtonUseVO setImage:checkImage forState:UIControlStateNormal];
	
}

- (UIButton *) checkButtonUseVO
{
	if (_checkButtonUseVO == nil) {
		_checkButtonUseVO = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButtonUseVO.frame = CGRectZero;
		_checkButtonUseVO.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_checkButtonUseVO.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		_checkButtonUseVO.tag = kViewTag;
		[_checkButtonUseVO addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchDown];
	}
	return _checkButtonUseVO;
}


#pragma mark -
#pragma mark utility methods

- (void) describe:(BOOL)od
{
#if DEBUGLOG
    if (od) {
        DBGLog(@"value id %ld name %@ type %ld value .%@. optDict:",(long)self.vid,self.valueName, (long)self.vtype, self.value);
        for (NSString *key in self.optDict) {
            DBGLog(@" %@ = %@ ",key,[self.optDict objectForKey:key] );
        }
    } else {
        	DBGLog(@"value id %ld name %@ type %ld value .%@.",(long)self.vid,self.valueName, (long)self.vtype, self.value);
    }
#endif
}


+ (const NSArray *) allGraphs {
	return @[@"dots", @"bar",@"line", @"line+dots", @"pie"];
}


+ (NSInteger) mapGraphType:(NSString *)gts {
	if ([gts isEqual:@"dots"])
		return VOG_DOTS;
	if ([gts isEqual:@"bar"])
		return VOG_BAR;
	if ([gts isEqual:@"line"])
		return VOG_LINE;
	if ([gts isEqual:@"line+dots"])
		return VOG_DOTSLINE;
	if ([gts isEqual:@"pie"])
		return VOG_PIE;
	if ([gts isEqual:@"no graph"])
		return VOG_NONE;
	
	dbgNSAssert1(0,@"mapGraphTypes: no match for %@",gts);
	
	return 0;
}

#if DEBUGERR
#define VOINF [NSString stringWithFormat:@"t: %@ vo: %li %@",((trackerObj*)self.parentTracker).trackerName,(long)self.vid,self.valueName]
#endif

- (void) validate {
    //DBGLog(@"%@",VOINF);
    
    if (self.vtype < 0) {
        DBGErr(@"%@ invalid vtype (negative): %ld",VOINF,(long)self.vtype);
        self.vtype = 0;
    } else if (self.vtype > VOT_MAX) {
        DBGErr(@"%@ invalid vtype (too large): %ld max vtype= %li",VOINF,(long)self.vtype,(long)VOT_MAX);
        self.vtype = 0;
    }
    
    if (self.vpriv < 0) {
        DBGErr(@"%@ invalid vpriv (too low): %ld minpriv= %i, 0 accepted",VOINF,(long)self.vpriv,MINPRIV);
        self.vpriv = MINPRIV;
    } else if (self.vpriv > MAXPRIV) {
        DBGErr(@"%@ invalid vtype (too large): %ld maxpriv= %i",VOINF,(long)self.vpriv,MAXPRIV);
        self.vpriv = 0;
    }

    if (VOT_CHOICE != self.vtype && VOT_INFO != self.vtype) {
        if (self.vcolor < 0) {
            DBGErr(@"%@ invalid vcolor (negative): %ld",VOINF,(long)self.vcolor);
            self.vcolor = 0;
        } else if (self.vcolor > ([[rTracker_resource colorSet] count] -1) ) {
            DBGErr(@"%@ invalid vcolor (too large): %ld max color= %lu",VOINF,(long)self.vcolor, (unsigned long)([[rTracker_resource colorSet] count] -1));
            self.vcolor = 0;
        }
    }
    
    if (self.vGraphType < 0) {
        DBGErr(@"%@ invalid vGraphType (negative): %ld",VOINF,(long)self.vGraphType);
        self.vGraphType = 0;
    } else if (self.vGraphType > VOG_MAX) {
        DBGErr(@"%@ invalid vGraphType (too large): %ld max vGraphType= %i",VOINF,(long)self.vGraphType,VOG_MAX);
        self.vGraphType = 0;
    }

    if (VOT_CHOICE == self.vtype) {
        if (-1 != self.vcolor) {
            DBGErr(@"%@ invalid choice vcolor (not -1): %ld",VOINF,(long)self.vcolor);
            self.vcolor = -1;
        }
        int i;
        for (i=0; i< CHOICES; i++) {
            NSString *key = [NSString stringWithFormat:@"cc%d",i];
            NSNumber *ncol = (self.optDict)[key];
            if (ncol != nil) {
                NSInteger col = [ncol integerValue];
                if (col < 0) {
                    DBGErr(@"%@ invalid choice %i color (negative): %ld",VOINF,i,(long)col);
                    (self.optDict)[key] = @0;
                } else if (col > ([[rTracker_resource colorSet] count] -1)) {
                    DBGErr(@"%@ invalid choice %i color (too large): %ld max color= %lu",VOINF,i,(long)col, (unsigned long)([[rTracker_resource colorSet] count] -1));
                    (self.optDict)[key] = @0;
                }
            }
        }
    }
    if (VOT_INFO == self.vtype) {
        if (-1 != self.vcolor) {
            DBGErr(@"%@ invalid info vcolor (not -1): %ld",VOINF,(long)self.vcolor);
            self.vcolor = -1;
        }
    }
    
}


- (CGSize) getLabelSize {
    CGSize labelSize = [self.valueName sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}];
    return labelSize;
    
    //return [self.valueName sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont systemFontSize]]}];
}

- (CGSize) getLongTitleSize {
    CGSize labelSize = CGSizeMake(0,0);
    if ((self.optDict)[@"longTitle"] && ![@"" isEqualToString:(self.optDict)[@"longTitle"]]) {
        CGSize maxSize = [rTracker_resource getKeyWindowFrame].size;
        maxSize.height = 9999;
        maxSize.width -= (2*MARGIN);
        NSString *lts = (self.optDict)[@"longTitle"];
        CGRect ltrect = [lts boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:PrefBodyFont} context:nil] ;
        labelSize.height += (ltrect.size.height - ltrect.origin.y);
        labelSize.width = ltrect.size.width;
    }
    return labelSize;
    
    //return [self.valueName sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont systemFontSize]]}];
}


// specific to VOT_CHOICE with optional values - seach dictionary for value, return index
- (int) getChoiceIndexForValue:(NSString *)val {
    //DBGLog(@"gciv val=%@",val);
    CGFloat inValF = [val floatValue];
    CGFloat minValF = 0.0;
    CGFloat maxValF = 0.0;
    //CGFloat closestValF = 99999999999.9F;
    int closestNdx = -1;
    CGFloat closestDistanceF = 99999999999.9F;
    
    NSString *inVal = [NSString stringWithFormat:@"%f",[val floatValue]];
    for (int i=0; i<CHOICES; i++) {
        NSString *key = [NSString stringWithFormat:@"cv%d",i];
        NSString *tstVal = [self.optDict valueForKey:key];
        //if (tstVal) { // bug - don't get to handling default value below - introduced jan/feb, removed 8 mar 2015
            if (nil == tstVal) {
                tstVal = [NSString stringWithFormat:@"%f",(float)i+1];  // added 7.iv.2013 - need default value
            } else {
                tstVal = [NSString stringWithFormat:@"%f",[tstVal floatValue]];
            }
            //DBGLog(@"gciv test against %d: %@",i,tstVal);
            if ([tstVal isEqualToString:inVal]) {
                return i;
            }
            
            CGFloat tstValF = [tstVal floatValue];
            if (minValF > tstValF) minValF = tstValF;
            if (maxValF < tstValF) maxValF = tstValF;
            CGFloat testDistanceF = fabs(tstValF - inValF);
            if (testDistanceF < closestDistanceF) {
                closestDistanceF = testDistanceF;
                closestNdx = i;
            }
        //}
    }
    
    //DBGLog(@"gciv: no match");
    if ((-1 != closestNdx) && (inValF > minValF) && (inValF < maxValF)) return closestNdx;
    return CHOICES;
    
}

@end
