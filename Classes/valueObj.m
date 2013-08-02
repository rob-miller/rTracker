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

#import "dbg-defs.h"

#define f(x) ((CGFloat) (x))

@implementation valueObj

@synthesize vid, vtype, vpriv, valueName, value, vcolor, vGraphType, display, useVO, optDict, parentTracker, checkButtonUseVO;
@synthesize vos,vogd;  //, retrievedData;

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
		self.vid = [(NSNumber*) [dict objectForKey:@"vid"] integerValue];
        [(trackerObj*) self.parentTracker minUniquev:self.vid];
		self.valueName = (NSString*) [dict objectForKey:@"valueName"];
        self.optDict = (NSMutableDictionary*) [dict objectForKey:@"optDict"];
        self.vpriv = [(NSNumber*) [dict objectForKey:@"vpriv"] integerValue];
		self.vtype = [(NSNumber*) [dict objectForKey:@"vtype"] integerValue];
        // setting vtype sets vo.useVO through vos init
		self.vcolor = [(NSNumber*) [dict objectForKey:@"vcolor"] integerValue];
		self.vGraphType = [(NSNumber*) [dict objectForKey:@"vGraphType"] integerValue];
        
	}
	
	return self;
}

- (void) dealloc 
{
	//DBGLog(@"dealloc valueObj: %@",valueName);
	//DBGLog(@"valuename retain count= %d",[valueName retainCount] );
	self.valueName = nil;
	[valueName release];
	self.value = nil;
	[value release]; 
	self.display = nil;
	[display release];
	
	self.optDict = nil;
	[optDict release];
	
	self.checkButtonUseVO = nil;
	[checkButtonUseVO release];
	
	//DBGLog(@"vos retain count= %d",[(voState*)vos retainCount] );
	self.vos = nil;
	[(id)vos release];
	//DBGLog(@"vos retain count= %d",[(voState*)vos retainCount] );    
	[super dealloc];
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
     return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:self.vid],@"vid",
            [NSNumber numberWithInteger:self.vtype],@"vtype",
            [NSNumber numberWithInteger:self.vpriv],@"vpriv",
            self.valueName,@"valueName",
            [NSNumber numberWithInteger:self.vcolor],@"vcolor",
            [NSNumber numberWithInteger:self.vGraphType],@"vGraphType",
            self.optDict,@"optDict",
            nil];
}


- (NSMutableDictionary *) optDict
{
	if (optDict == nil) {
		optDict = [[NSMutableDictionary alloc] init];
	}
	return optDict;
}

- (NSMutableString*) value {
    dbgNSAssert(vos,@"accessing vo.value with nil vos");
    if (value == nil) {
        value = [[NSMutableString alloc] initWithCapacity:[self.vos getValCap]];
        //value = [[NSMutableString alloc] init];
        [value setString:@""];
    }
    [value setString:[self.vos update:value]];
    return value;
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
	vtype = vt;  // not self as this is set fn!
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
		default:
			dbgNSAssert1(0,@"valueObj init vtype %d not supported",vt);
            tvos = [[voNumber alloc] initWithVO:self]; // to clear analyzer worry 
            vtype = VOT_NUMBER;  // consistency if we get here
			break;
	}
    self.vos=nil;
    self.vos = tvos;
	[tvos release];
    NSMutableString *tval;
    tval = [[NSMutableString alloc] initWithCapacity:[self.vos getValCap]];  // causes memory leak
    self.value = nil;
    self.value = tval;
    [tval release];
    //[self.value release];   // clear retain count from alloc + retain
}


#pragma mark -
#pragma mark display fn dispatch

- (UIView *) display:(CGRect)bounds {
	if (display == nil) {
        DBGLog(@"vo new display name:  %@ currVal: .%@.",self.valueName,self.value);
		self.display = [self.vos voDisplay:bounds];
        self.display.tag = kViewTag;
	}
	return display;
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
	DBGLog(@"checkbox ticked for %@ new state= %d",valueName, !self.useVO);
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
			NSNumber *nsdflt = [self.optDict objectForKey:@"sdflt"];
			CGFloat sdflt =  nsdflt ? [nsdflt floatValue] : SLIDRDFLTDFLT;
			[((UISlider *) self.display) setValue:sdflt animated:YES];
		}
	}

    [[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];		
	[checkButtonUseVO setImage:checkImage forState:UIControlStateNormal];
	
}

- (UIButton *) checkButtonUseVO
{
	if (checkButtonUseVO == nil) {
		checkButtonUseVO = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		checkButtonUseVO.frame = CGRectZero;
		checkButtonUseVO.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		checkButtonUseVO.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		checkButtonUseVO.tag = kViewTag;
		[checkButtonUseVO addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchDown];		
	}
	return checkButtonUseVO;
}


#pragma mark -
#pragma mark utility methods

- (void) describe:(BOOL)od
{
    if (od) {
        DBGLog(@"value id %d name %@ type %d value .%@. optDict:",self.vid,self.valueName, self.vtype, self.value);
        for (NSString *key in self.optDict) {
            DBGLog(@" %@ = %@ ",key,[self.optDict objectForKey:key] );
        }
    } else {
        	DBGLog(@"value id %d name %@ type %d value .%@.",self.vid,self.valueName, self.vtype, self.value);
    }
}


+ (const NSArray *) allGraphs {
	return [NSArray arrayWithObjects:@"dots", @"bar",@"line", @"line+dots", @"pie", /*@"no graph",*/ nil];
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
#define VOINF [NSString stringWithFormat:@"t: %@ vo: %i %@",((trackerObj*)self.parentTracker).trackerName,self.vid,self.valueName]
#endif

- (void) validate {
    //DBGLog(@"%@",VOINF);
    
    if (self.vtype < 0) {
        DBGErr(@"%@ invalid vtype (negative): %d",VOINF,self.vtype);
        self.vtype = 0;
    } else if (self.vtype > VOT_MAX) {
        DBGErr(@"%@ invalid vtype (too large): %d max vtype= %i",VOINF,self.vtype,VOT_MAX);
        self.vtype = 0;
    }
    
    if (self.vpriv < 0) {
        DBGErr(@"%@ invalid vpriv (too low): %d minpriv= %i, 0 accepted",VOINF,self.vpriv,MINPRIV);
        self.vpriv = MINPRIV;
    } else if (self.vpriv > MAXPRIV) {
        DBGErr(@"%@ invalid vtype (too large): %d maxpriv= %i",VOINF,self.vpriv,MAXPRIV);
        self.vpriv = 0;
    }

    if (VOT_CHOICE != self.vtype) {
        if (self.vcolor < 0) {
            DBGErr(@"%@ invalid vcolor (negative): %d",VOINF,self.vcolor);
            self.vcolor = 0;
        } else if (self.vcolor > ([[rTracker_resource colorSet] count] -1) ) {
            DBGErr(@"%@ invalid vcolor (too large): %d max color= %i",VOINF,self.vcolor, ([[rTracker_resource colorSet] count] -1));
            self.vcolor = 0;
        }
    }
    
    if (self.vGraphType < 0) {
        DBGErr(@"%@ invalid vGraphType (negative): %d",VOINF,self.vGraphType);
        self.vGraphType = 0;
    } else if (self.vGraphType > VOG_MAX) {
        DBGErr(@"%@ invalid vGraphType (too large): %d max vGraphType= %i",VOINF,self.vGraphType,VOG_MAX);
        self.vGraphType = 0;
    }

    if (VOT_CHOICE == self.vtype) {
        if (-1 != self.vcolor) {
            DBGErr(@"%@ invalid choice vcolor (not -1): %d",VOINF,self.vcolor);
            self.vcolor = -1;
        }
        int i;
        for (i=0; i< CHOICES; i++) {
            NSString *key = [NSString stringWithFormat:@"cc%d",i];
            NSNumber *ncol = [self.optDict objectForKey:key];
            if (ncol != nil) {
                NSInteger col = [ncol integerValue];
                if (col < 0) {
                    DBGErr(@"%@ invalid choice %i color (negative): %d",VOINF,i,col);
                    [self.optDict setObject:[NSNumber numberWithInt:0] forKey:key];
                } else if (col > ([[rTracker_resource colorSet] count] -1)) {
                    DBGErr(@"%@ invalid choice %i color (too large): %d max color= %i",VOINF,i,col,([[rTracker_resource colorSet] count] -1));
                    [self.optDict setObject:[NSNumber numberWithInt:0] forKey:key];
                }
            }
        }
    }
    
}
// specific to VOT_CHOICE with optional values - seach dictionary for value, return index
- (int) getChoiceIndexForValue:(NSString *)val {
    //DBGLog(@"gciv val=%@",val);
    NSString *inVal = [NSString stringWithFormat:@"%f",[val floatValue]];
    for (int i=0; i<CHOICES; i++) {
        NSString *key = [NSString stringWithFormat:@"cv%d",i];
        NSString *tstVal = [self.optDict valueForKey:key];
        if (nil == tstVal) {
            tstVal = [NSString stringWithFormat:@"%f",(float)i+1];  // added 7.iv.2013 - need default value
        } else {
            tstVal = [NSString stringWithFormat:@"%f",[tstVal floatValue]];  
        }
        //DBGLog(@"gciv test against %d: %@",i,tstVal);
        if ([tstVal isEqualToString:inVal]) {
            return i;
        }
    }
    //DBGLog(@"gciv: no match");
    return CHOICES;
    
}

@end
