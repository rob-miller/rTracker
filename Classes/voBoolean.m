/***************
 voBoolean.m
 Copyright 2010-2016 Robert T. Miller
 
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
//  voBoolean.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voBoolean.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

@implementation voBoolean

@synthesize checkButton=_checkButton;
//@synthesize checkedBtn=_checkedBtn, uncheckedBtn=_uncheckedBtn;

// 25.i.14 allow assigned values so use default (10) size
//- (int) getValCap {  // NSMutableString size for value
//    return 1;
//}
/*
- (UIImage *) boolBtnImage {
	// default is not checked
    return ( [self.vo.value isEqualToString:@""] ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"] );
}
*/
/*
- (NSAttributedString*) checkedBtn {
    if (nil == _checkedBtn) {
        CGFloat psize = [PrefBodyFont pointSize];
        if (psize < 28.0) psize = 28.0;
        _checkedBtn = [[NSAttributedString alloc]
                       initWithString:@"\u2714" //@"\u2611"
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AppleColorEmoji" size:psize]
                                    //,
                                    //NSForegroundColorAttributeName:[UIColor greenColor],
                                    //NSBackgroundColorAttributeName:[rTracker_resource colorSet][[(self.vo.optDict)[@"btnColr"] integerValue]]
                                    }];
                                    //NSForegroundColorAttributeName:[rTracker_resource colorSet][[(self.vo.optDict)[@"btnColr"] integerValue]] }];
    }
    return _checkedBtn;
}
- (NSAttributedString*) uncheckedBtn {
    if (nil == _uncheckedBtn) {
        CGFloat psize = [PrefBodyFont pointSize];
        if (psize < 28.0) psize = 28.0;
        _uncheckedBtn = [[NSAttributedString alloc]
                       initWithString:@"\u2714" //@"\u2611"
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AppleColorEmoji" size:psize]
                                    //,
                                    //NSForegroundColorAttributeName:[UIColor clearColor]
                                    }];
    }
    return _uncheckedBtn;
}
*/
/*
-(UIColor*) boolBtnColor {
	// default is not checked
    return ( [self.vo.value isEqualToString:@""] ? [UIColor whiteColor] : [rTracker_resource colorSet][[(self.vo.optDict)[@"btnColr"] integerValue] ]);
}
*/

- (void)boolBtnAction:(UIButton *)checkButton
{  // default is unchecked or nil // 25.i.14 use assigned val // was "so only certain is if =1" ?
	if ([self.vo.value isEqualToString:@""]) {
        NSString *bv = (self.vo.optDict)[@"boolval"];
        //if (nil == bv) {
            //bv = BOOLVALDFLTSTR;
            //[self.vo.optDict setObject:bv forKey:@"boolval"];
        //}
		[self.vo.value setString:bv];
        [rTracker_resource setCheckButton:self.checkButton colr:[rTracker_resource colorSet][[(self.vo.optDict)[@"btnColr"] integerValue] ]];
        if ([@"1" isEqualToString:(self.vo.optDict)[@"setstrackerdate"]]) {
            [self.vo setTrackerDateToNow];
        }
	} else {
		[self.vo.value setString:@""];
        [rTracker_resource clrCheckButton:self.checkButton colr:[UIColor whiteColor]];
	}

	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (UIButton*) checkButton {
    CGRect frame = self.vosFrame;
    frame.size.height *= 1.1;
    frame.origin.x = (frame.origin.x + frame.size.width) - (frame.size.height);
    frame.size.width = frame.size.height ;
    
    if (_checkButton && _checkButton.frame.size.width != frame.size.width) _checkButton=nil;  // first time around thinks size is 320, handle larger devices

	if (nil == _checkButton) {
        _checkButton = [rTracker_resource getCheckButton:frame];
        [_checkButton addTarget:self action:@selector(boolBtnAction:) forControlEvents:UIControlEventTouchDown];
        _checkButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	}
    return _checkButton;
}

- (UIView*) voDisplay:(CGRect)bounds {
    self.vosFrame = bounds;

    if ([self.vo.value isEqualToString:@""]) {
        [rTracker_resource clrCheckButton:self.checkButton colr:[UIColor whiteColor]];
    } else {
        [rTracker_resource setCheckButton:self.checkButton colr:[rTracker_resource colorSet][[(self.vo.optDict)[@"btnColr"] integerValue] ]];
    }
    
    DBGLog(@"bool data= %@",self.vo.value);
	return self.checkButton;
}

- (NSArray*) voGraphSet {
	return @[@"dots", @"bar"];
}

#pragma mark -
#pragma mark graph display
/*
- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    
    [self transformVO_bool:xdat ydat:ydat dscale:dscale height:height border:border firstDate:firstDate];
    
}
*/

- (id) newVOGD {
    return [[vogd alloc] initAsNum:self.vo];
}



#pragma mark -
#pragma mark options page

- (void) setOptDictDflts {
    NSString *bv = (self.vo.optDict)[@"boolval"];
    if ((nil == bv) || ([@"" isEqualToString:bv])) {
        (self.vo.optDict)[@"boolval"] = BOOLVALDFLTSTR;
    }
    NSString *std = (self.vo.optDict)[@"setstrackerdate"];
    if ((nil == std) || ([@"" isEqualToString:std])) {
        (self.vo.optDict)[@"setstrackerdate"] = (SETSTRACKERDATEDFLT ? @"1" : @"0");
    }
    NSString *bc = (self.vo.optDict)[@"btnColr"];
    if ((nil == bc) || ([@"" isEqualToString:bc])) {
        (self.vo.optDict)[@"btnColr"] = BOOLBTNCOLRDFLTSTR;
    }
    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = (self.vo.optDict)[key];
    if (nil == val)
        return YES;
    
    if (([key isEqualToString:@"boolval"] && ([val floatValue] == f(BOOLVALDFLT)))
        || ([key isEqualToString:@"setstrackerdate"] && ([val isEqualToString:(SETSTRACKERDATEDFLT ? @"1" : @"0")]))
        || ([key isEqualToString:@"btnColr"] && ([val isEqualToString:BOOLBTNCOLRDFLTSTR]))
        ) {
        [self.vo.optDict removeObjectForKey:key];
        //DBGLog(@"cleanDflt for bool: %@",key);
        return YES;
    }
        
    return [super cleanOptDictDflts:key];
}

- (void) boolColorButtonAction:(UIButton *)btn
{
    NSNumber *bc = (self.vo.optDict)[@"btnColr"];
    NSInteger col = [bc integerValue];
    if (++col >= [[rTracker_resource colorSet] count])
        col=0;
    (self.vo.optDict)[@"btnColr"] = [NSString stringWithFormat:@"%ld",(long)col];
    btn.backgroundColor = [rTracker_resource colorSet][col];
}

- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"stored value:" frame:frame key:@"bvLab" addsv:YES];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
    CGFloat tfWidth = [@"9999999999" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight;
	
	frame = [ctvovc configTextField:frame
                        key:@"bvalTF"
                     target:nil
                     action:nil
                        num:YES
                      place:BOOLVALDFLTSTR
                       text:(self.vo.optDict)[@"boolval"]
                      addsv:YES ];
	
    
    
    // sets tracker date option
    
	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
	
	labframe = [ctvovc configLabel:@"Sets tracker date:" frame:frame key:@"stdLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	frame = [ctvovc configCheckButton:frame
                          key:@"stdBtn"
                        state:[(self.vo.optDict)[@"setstrackerdate"] isEqualToString:@"1"] // default:0
                        addsv:YES
     ];
    
    frame.origin.x = MARGIN;
    frame.origin.y += labframe.size.height + MARGIN;
    
    labframe = [ctvovc configLabel:@"Active color:" frame:frame key:@"btnColrLab" addsv:YES];
    
    frame.origin.x += labframe.size.width + MARGIN;
    frame.size.width = frame.size.height;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [[btn layer] setCornerRadius:8.0f];
    [[btn layer] setMasksToBounds:YES];
    [[btn layer] setBorderWidth:1.0f];
    NSString *bc = (self.vo.optDict)[@"btnColr"];
    if (!bc) {
        bc = BOOLBTNCOLRDFLTSTR;
        (self.vo.optDict)[@"btnColr"] = BOOLBTNCOLRDFLTSTR;
    }
    btn.backgroundColor = [rTracker_resource colorSet][[bc integerValue]];
    
    btn.titleLabel.font = PrefBodyFont;
    
    [btn addTarget:self action:@selector(boolColorButtonAction:) forControlEvents:UIControlEventTouchDown];
    (ctvovc.wDict)[@"boolColrBtn"] = btn;
    //[ctvovc.view addSubview:btn];
    [ctvovc.scroll addSubview:btn];


    //-----
    
	ctvovc.lasty = frame.origin.y + labframe.size.height + MARGIN + SPACE ;
    
	[super voDrawOptions:ctvovc];
}

/* rtm here : export value option -- need to parse and match value if choice did not match
 */

- (NSString*) mapCsv2Value:(NSString*)inCsv {
    
    if ([(self.vo.optDict)[@"boolval"] doubleValue] !=  [inCsv doubleValue]) {
        (self.vo.optDict)[@"boolval"] = inCsv;
    }
    return inCsv;
}






@end
