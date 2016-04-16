/***************
 voDataEdit.h
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
