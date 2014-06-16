//
//  voBoolean.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voInfo.h"
#import "dbg-defs.h"

@implementation voInfo

//@synthesize imageButton;


// 25.i.14 allow assigned values so use default (10) size
//- (int) getValCap {  // NSMutableString size for value
//    return 1;
//}
/*
- (UIImage *) boolBtnImage {
	// default is not checked
	return ( [self.vo.value isEqualToString:@""] ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"] );
}

- (void)boolBtnAction:(UIButton *)imageButton
{  // default is unchecked or nil // 25.i.14 use assigned val // was "so only certain is if =1" ?
	if ([self.vo.value isEqualToString:@""]) {
        NSString *bv = [self.vo.optDict objectForKey:@"boolval"];
        //if (nil == bv) {
            //bv = BOOLVALDFLTSTR;
            //[self.vo.optDict setObject:bv forKey:@"boolval"];
        //}
		[self.vo.value setString:bv];
		[self.imageButton setImage:[UIImage imageNamed:@"checked.png"] forState: UIControlStateNormal];
	} else {
		[self.vo.value setString:@""];
		[self.imageButton setImage:[UIImage imageNamed:@"unchecked.png"] forState: UIControlStateNormal];
	}

	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (UIButton*) imageButton {
	if (nil == imageButton) {
        imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = self.vosFrame; //CGRectZero;
        imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
        [imageButton addTarget:self action:@selector(boolBtnAction:) forControlEvents:UIControlEventTouchDown];		
        imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
        [imageButton retain];  // rtm 06 feb 2012
	}
    return imageButton;
}
*/

- (UIView*) voDisplay:(CGRect)bounds {
/*    self.vosFrame = bounds;
	[self.imageButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
    
    DBGLog(@"bool voDisplay: %d", ([self.imageButton imageForState:UIControlStateNormal] == [UIImage imageNamed:@"checked.png"] ? 1 : 0) );
    DBGLog(@"bool data= %@",self.vo.value);
	return self.imageButton;
 */
    return nil;
}

- (NSArray*) voGraphSet {
	return nil; //[NSArray arrayWithObjects:@"dots", @"bar", nil];
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
    if (nil == [self.vo.optDict objectForKey:@"infoval"])
        [self.vo.optDict setObject:BOOLVALDFLTSTR forKey:@"infoval"];

    [self.vo.optDict setObject:@"0" forKey:@"graph"];
    [self.vo.optDict setObject:[NSString stringWithFormat:@"%d",PRIVDFLT] forKey:@"privacy"];
    
    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = [self.vo.optDict objectForKey:key];
    if (nil == val)
        return YES;
    
    if (([key isEqualToString:@"infoval"] && ([val floatValue] == f(INFOVALDFLT)))
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    
    return [super cleanOptDictDflts:key];
}

- (NSString*) update:(NSString*)instr {
    return [self.vo.optDict objectForKey:@"infoval"];
}

- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"stored value:" frame:frame key:@"ivLab" addsv:YES];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
	CGFloat tfWidth = [@"9999999999" sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight;
	
	[ctvovc configTextField:frame
                        key:@"ivalTF"
                     target:nil
                     action:nil
                        num:YES
                      place:INFOVALDFLTSTR
                       text:[self.vo.optDict objectForKey:@"infoval"]
                      addsv:YES ];

    frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;

    labframe = [ctvovc configLabel:@"URL:" frame:frame key:@"iurlLab" addsv:YES];

	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
    frame.size.width = ctvovc.view.frame.size.width - (2*MARGIN);
    
    [ctvovc configTextField:frame
                        key:@"iurlTF"
                     target:nil
                     action:nil
                        num:YES
                      place:INFOURLDFLTSTR
                       text:[self.vo.optDict objectForKey:@"infourl"]
                      addsv:YES ];

    
	ctvovc.lasty = frame.origin.y + labframe.size.height + MARGIN + SPACE ;
    
	//[super voDrawOptions:ctvovc];
}

/* rtm here : export value option -- need to parse and match value if choice did not match
 */

- (NSString*) mapCsv2Value:(NSString*)inCsv {
    
    if ([[self.vo.optDict objectForKey:@"infoval"] doubleValue] !=  [inCsv doubleValue]) {
        [self.vo.optDict setObject:inCsv forKey:@"infoval"];
    }
    return inCsv;
}






@end
