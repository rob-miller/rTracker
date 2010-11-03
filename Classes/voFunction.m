//
//  voFunction.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voFunction.h"

@interface voFunction ()
- (void) updateFnTitles;
//@property (nonatomic, retain) NSNumber *foo;
@end

#define MyTracker ((trackerObj*) self.vo.parentTracker)

@implementation voFunction

@synthesize epTitles, fnTitles, fnStrs, fnArray, fnSegNdx, ctvovcp;

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
	
	[super dealloc];
}

#pragma mark voFunction ivar getters

- (NSArray*) epTitles {
	if (epTitles == nil) {
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

- (BOOL) currCanCompute {
	return YES;
}

- (NSString*) currFunctionValue {

	if ([self currCanCompute]) {
		return @"42";
	} else {
		return @"-";
	}
}

- (UIView*) voDisplay:(CGRect)bounds {
	NSLog(@"func not implemented");
	
	//trackerObj *to = (trackerObj*) parentTracker;
	
	UILabel *rlab = [[UILabel alloc] initWithFrame:bounds];
	rlab.textAlignment = UITextAlignmentRight;
	if ([self currCanCompute]) {
		rlab.backgroundColor = [UIColor whiteColor];
		rlab.text = [self currFunctionValue];
	} else {
		rlab.backgroundColor = [UIColor lightGrayColor];
		rlab.text = @"-";
	}
	
	return [rlab autorelease];
}

- (NSArray*) voGraphSet {
	return [voState voGraphSetNum];
}

#pragma mark -
#pragma mark function configTVObjVC 
#pragma mark -

#pragma mark range definition page 

//
// convert endpoint from left or right picker to offset symbol (hours, months, ...) or valobj
//

- (NSInteger) epToRow:(NSInteger)component {
	NSString *key = [NSString stringWithFormat:@"frep%d",component];
	NSNumber *n = [self.vo.optDict objectForKey:key];
	NSInteger ep = [n integerValue];
	if (n == nil || ep == FREPDFLT) 
		return 0;
	if (ep >= 0)
		return ep+1;
	return (ep * -1) + [MyTracker.valObjTable count] -1;
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
		NSString *key = [NSString stringWithFormat:@"frep%d",component];
		NSString *vtfkey = [NSString stringWithFormat:@"fr%dTF",component];
		NSString *pre_vkey = [NSString stringWithFormat:@"frpre%dvLab",component];
		NSString *post_vkey = [NSString stringWithFormat:@"frpost%dvLab",component];
		
		[self.vo.optDict setObject:[NSNumber numberWithInt:(((row - votc) +1) * -1)] forKey:key];
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
	BOOL closePending = NO;  //square brackets around target of FnFn
	
	for (NSNumber *n in self.fnArray) {
		NSInteger i = [n integerValue];
		if (i<0) {
			NSInteger ndx = (i * -1) -1;
			[fstr appendString:[self.fnStrs objectAtIndex:ndx]];
			if (isFnFn(i)) {
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
	NSUInteger ep2 = n ? (ep+1)*-1 : 0;
	if (n == nil || ep == FREPDFLT) 
		return [NSString stringWithFormat:@"%@ %@", pre, [self.epTitles objectAtIndex:ep2]];  // FREPDFLT
	if (ep >= 0) 
		return [NSString stringWithFormat:@"%@ %@", pre, ((valueObj*)[MyTracker.valObjTable objectAtIndex:ep]).valueName];
	
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
		NSLog(@"funcDone 0: %@",[self.vo.optDict objectForKey:@"func"]);
		[self.vo.optDict setObject:[self.fnArray componentsJoinedByString:@" "] forKey:@"func"];
		NSLog(@"funcDone 1: %@",[self.vo.optDict objectForKey:@"func"]);
	}
}


//
// called for configTVObjVC  viewDidLoad
//
- (void) funcVDL:(configTVObjVC*)ctvovc donebutton:(UIBarButtonItem*)db {
		
	if ([((trackerObj*)self.vo.parentTracker).valObjTable count] > 0) {
		[self.fnArray removeAllObjects];
		[self.fnArray addObjectsFromArray:[[self.vo.optDict objectForKey:@"func"] componentsSeparatedByString:@" "]];
		
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
	NSLog(@"fnSegmentAction: selected segment = %d", self.fnSegNdx);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kAnimationDuration];
	
	[self.ctvovcp removeSVFields];
	[self drawSelectedPage];
	
	[UIView commitAnimations];
}

#pragma mark protocol: voDrawOptions page 

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
	for (i=FNFNFIRST;i>=FNFNLAST;i--) {
		[self.fnTitles addObject:[NSNumber numberWithInt:i]];
	}
}

- (void) ftAdd2OpSet {
	int i;
	for (i=FN2OPFIRST;i>=FN2OPLAST;i--) {
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
		if (last >= 0) { // state = after valObj
			[self ftAdd2OpSet];
			[self ftAddCloseParen];
		} else if (last <= FNFNFIRST && last >= FNFNLAST) {  // state = after fnfn = delta, avg, sum
			[self ftAddVOs];
		} else if (last <= FN2OPFIRST && last >= FN2OPLAST) { // state = after fn2op = +,-,*,/
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
	if (tok >= 0) {
		for (valueObj *valo in MyTracker.valObjTable) {
			if (valo.vid == tok)
				return valo.valueName;
		}
		NSAssert(0,@"fnTokenToStr failed to find valObj");
		return @"unknown vid";
	} else {
		tok = (tok * -1) -1;
		return [self.fnStrs objectAtIndex:tok];
	}
}

- (NSString*) fndRowTitle:(NSInteger)row {
	return [self fnTokenToStr:[[self.fnTitles objectAtIndex:row] integerValue]];
}

- (NSInteger) fnrRowCount:(NSInteger)component {
	NSInteger other = (component ? 0 : 1);
	NSString *otherKey = [NSString stringWithFormat:@"frep%d",other];
	id otherObj = [self.vo.optDict objectForKey:otherKey];
	NSInteger otherVal = [otherObj integerValue];
	if (otherVal < -1) {
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
			[self.vo.optDict setObject:[NSNumber numberWithInt:row-1] forKey:key];
		} else { 
			[self updateValTF:row component:component];
		}
		NSLog(@"picker sel row %d %@ now= %d", row, key, [[self.vo.optDict objectForKey:key] integerValue] );
	} else {
	}
	
	[self updateForPickerRowSelect:row inComponent:component];
	
}


@end
