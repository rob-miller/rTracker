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
	DBGLog(@"init vObj with args vid: %d vtype: %d vname: %@",in_vid, in_vtype, in_vname);
	if ((self = [super init])) {
		self.useVO = NO;	
		self.parentTracker = parentTO;
		self.vid = in_vid;
		self.vtype = in_vtype;
		
		self.valueName = in_vname;
		self.vcolor = in_vcolor;
		self.vGraphType = in_vgraphtype;
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
	//[(voState*)vos release];
	//DBGLog(@"vos retain count= %d",[(voState*)vos retainCount] );
	//[vos dealloc];
	[super dealloc];
}

- (NSMutableDictionary *) optDict
{
	if (optDict == nil) {
		optDict = [[NSMutableDictionary alloc] init];
	}
	return optDict;
}

- (NSMutableString*) value {
    NSAssert(vos,@"accessing vo.value with nil vos");
    if (value == nil) {
        value = [[NSMutableString alloc] initWithCapacity:[self.vos getValCap]];
        //value = [[NSMutableString alloc] init];
        [value setString:@""];
    }
    [value setString:[self.vos update:value]];
    return value;
}

- (void) resetData {
	[self.value setString:@""];
    //self.retrievedData = NO;
	self.useVO = NO;  // disableVO
}

- (void) setVtype:(NSInteger)vt {  // called for setting property vtype
    DBGLog(@"setVtype - allocating vos");
	vtype = vt;
	switch (vt) {
		case VOT_NUMBER:
			self.vos = [[voNumber alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:10];
			break;
		case VOT_SLIDER:
			self.vos = [[voSlider alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:10];
			//[self.value setString:@"0"];
			break;
		case VOT_BOOLEAN:
			self.vos = [[voBoolean alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:1];
			//[self.value setString:@"0"];
			break;
		case VOT_CHOICE:
			self.vos = [[voChoice alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:1];
			//[self.value setString:@"0"];
			break;
		case VOT_TEXT:
			self.vos = [[voText alloc] initWithVO:self];
            //value = [[NSMutableString alloc] initWithCapacity:32];
			break;
		case VOT_FUNC:
			self.vos = [[voFunction alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:32];
			//[self.value setString:@""];
			break;	
		case VOT_IMAGE:
			self.vos = [[voImage alloc] initWithVO:self];
			//value = [[NSMutableString alloc] initWithCapacity:64];
			//[self.value setString:@""];
			break;
		case VOT_TEXTB:
			self.vos = [[voTextBox alloc] initWithVO:self];
            //value = [[NSMutableString alloc] initWithCapacity:96];
			//[self.value setString:@""];
			break;
		default:
			NSAssert1(0,@"valueObj init vtype %d not supported",vt);
			break;
	}
    self.value = [[NSMutableString alloc] initWithCapacity:[self.vos getValCap]];  // causes memory leak
    [self.value release];   // clear retain count from alloc + retain
	[(id) self.vos release];
}


#pragma mark -
#pragma mark display fn dispatch

- (UIView *) display:(CGRect)bounds {
	if (display == nil) {
        DBGLog(@"vo new display %@",self.valueName);
		self.display = [self.vos voDisplay:bounds];
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

- (void) describe 
{
	DBGLog(@" value id %d name %@ type %d value .%@.",self.vid,self.valueName, self.vtype, self.value);
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
	
	NSAssert1(0,@"mapGraphTypes: no match for %@",gts);
	
	return 0;
}

@end
