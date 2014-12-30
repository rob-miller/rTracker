//
//  voBoolean.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voBoolean.h"
#import "dbg-defs.h"

@implementation voBoolean

@synthesize imageButton=_imageButton;


// 25.i.14 allow assigned values so use default (10) size
//- (int) getValCap {  // NSMutableString size for value
//    return 1;
//}

- (UIImage *) boolBtnImage {
	// default is not checked
	return ( [self.vo.value isEqualToString:@""] ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"] );
}

- (void)boolBtnAction:(UIButton *)imageButton
{  // default is unchecked or nil // 25.i.14 use assigned val // was "so only certain is if =1" ?
	if ([self.vo.value isEqualToString:@""]) {
        NSString *bv = (self.vo.optDict)[@"boolval"];
        //if (nil == bv) {
            //bv = BOOLVALDFLTSTR;
            //[self.vo.optDict setObject:bv forKey:@"boolval"];
        //}
		[self.vo.value setString:bv];
		[self.imageButton setImage:[UIImage imageNamed:@"checked.png"] forState: UIControlStateNormal];
        if ([@"1" isEqualToString:(self.vo.optDict)[@"setstrackerdate"]]) {
            [self.vo setTrackerDateToNow];
        }
	} else {
		[self.vo.value setString:@""];
		[self.imageButton setImage:[UIImage imageNamed:@"unchecked.png"] forState: UIControlStateNormal];
	}

	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (UIButton*) imageButton {
    if (_imageButton && _imageButton.frame.size.width != self.vosFrame.size.width) _imageButton=nil;  // first time around thinks size is 320, handle larger devices

	if (nil == _imageButton) {
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageButton.frame = self.vosFrame; //CGRectZero;
        _imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
        [_imageButton addTarget:self action:@selector(boolBtnAction:) forControlEvents:UIControlEventTouchDown];
        _imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
          // rtm 06 feb 2012
	}
    return _imageButton;
}

- (UIView*) voDisplay:(CGRect)bounds {
    self.vosFrame = bounds;
	[self.imageButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
    
    DBGLog(@"bool voDisplay: %d", ([self.imageButton imageForState:UIControlStateNormal] == [UIImage imageNamed:@"checked.png"] ? 1 : 0) );
    DBGLog(@"bool data= %@",self.vo.value);
	return self.imageButton;
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
    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = (self.vo.optDict)[key];
    if (nil == val)
        return YES;
    
    if (([key isEqualToString:@"boolval"] && ([val floatValue] == f(BOOLVALDFLT)))
        || ([key isEqualToString:@"setstrackerdate"] && ([val isEqualToString:(SETSTRACKERDATEDFLT ? @"1" : @"0")]))
        ) {
        [self.vo.optDict removeObjectForKey:key];
        DBGLog(@"cleanDflt for bool: %@",key);
        return YES;
    }
        
    return [super cleanOptDictDflts:key];
}


- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"stored value:" frame:frame key:@"bvLab" addsv:YES];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
    CGFloat tfWidth = [@"9999999999" sizeWithAttributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]}].width;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight;
	
	[ctvovc configTextField:frame
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
	
	[ctvovc configCheckButton:frame
                          key:@"stdBtn"
                        state:[(self.vo.optDict)[@"setstrackerdate"] isEqualToString:@"1"] // default:0
                        addsv:YES
     ];
    
    

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
