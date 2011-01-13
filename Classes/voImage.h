//
//  voImage.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "voState.h"
#import "voDataEdit.h"

@interface voImage : voState <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
	UIImageView *imageView;
	UIButton *takePhotoButton;
	UIButton *selectFromCameraRollButton;
	UIButton *pickFromLibraryButton;
	voDataEdit *devc;
}

@property (nonatomic,retain) UIImageView *imageView;
@property (nonatomic,retain) UIButton *takePhotoButton;
@property (nonatomic,retain) UIButton *selectFromCameraRollButton;
@property (nonatomic,retain) UIButton *pickFromLibraryButton;

@property (nonatomic, assign) voDataEdit *devc;

@end
