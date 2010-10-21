//
//  configValObjVC.h
//  rTracker
//
//  Created by Robert Miller on 09/10/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "trackerObj.h"
#import "valueObj.h"

@interface configTVObjVC : UIViewController <UITextFieldDelegate> {

	trackerObj *to;
	valueObj *vo;
	
	NSMutableDictionary *wDict;  // widget dictionary
	UITextField	*activeField;
	
	UINavigationBar *navBar;
	UIToolbar *toolBar;

	CGFloat lasty;
	CGRect saveFrame;
}

@property (nonatomic,retain) trackerObj *to;
@property (nonatomic,retain) valueObj *vo;
@property (nonatomic,retain) NSMutableDictionary *wDict;

@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;

@property (nonatomic) CGFloat lasty;
@property (nonatomic) CGRect saveFrame;

- (void) addVOFields:(NSInteger) vot;
- (void) addTOFields;

- (void) removeGraphMinMax;
- (void) addGraphMinMax;


@end
