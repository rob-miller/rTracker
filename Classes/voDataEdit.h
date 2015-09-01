//
//  voDataEdit.h
//  rTracker
//
//  Created by Robert Miller on 10/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "voState.h"

@interface voDataEdit : UIViewController<UITextViewDelegate>
/*{

	valueObj *vo;
	
}*/

@property (nonatomic,unsafe_unretained) valueObj *vo;
@property (nonatomic,strong) UITextView *textView;

//@property (nonatomic) CGRect saveFrame;

@property (nonatomic,weak) id saveClass;
@property (nonatomic) SEL saveSelector;
@property (nonatomic,weak) NSString *text;

- (void)keyboardWillShow:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;
+ (CGRect) getInitTVF:(UIViewController*)vc;

@end
