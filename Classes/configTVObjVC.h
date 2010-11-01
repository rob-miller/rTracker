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

@interface configTVObjVC : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {

	trackerObj *to;
	valueObj *vo;
	
	NSMutableDictionary *wDict;  // widget dictionary
	UITextField	*activeField;
	
	UINavigationBar *navBar;
	UIToolbar *toolBar;

	CGFloat lasty;
	CGRect saveFrame;

	NSInteger fnSegNdx;
	NSArray *epTitles;
	NSMutableArray *fnTitles;
	NSMutableArray *fnStrs;
	NSMutableArray *fnArray;
}

@property (nonatomic,retain) trackerObj *to;
@property (nonatomic,retain) valueObj *vo;
@property (nonatomic,retain) NSMutableDictionary *wDict;

@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;

@property (nonatomic) CGFloat lasty;
@property (nonatomic) CGRect saveFrame;
@property (nonatomic) NSInteger fnSegNdx;
@property (nonatomic,retain) NSArray *epTitles;
@property (nonatomic,retain) NSMutableArray *fnTitles;
@property (nonatomic,retain) NSMutableArray *fnStrs;
@property (nonatomic,retain) NSMutableArray *fnArray;

- (void) addVOFields:(NSInteger) vot;
- (void) addTOFields;
- (void) removeSVFields;
- (void) drawGeneralVoOpts;

- (void) removeGraphMinMax;
- (void) addGraphMinMax;

#define FNSEGNDX_OVERVIEW 0
#define FNSEGNDX_RANGEBLD 1
#define FNSEGNDX_FUNCTBLD 2

@end
