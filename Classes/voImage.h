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

@interface voImage : voState <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
/*{
	UIImageView *imageView;
	UIButton *takePhotoButton;
	UIButton *selectFromCameraRollButton;
	UIButton *pickFromLibraryButton;
	voDataEdit *devc;
}*/

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *takePhotoButton;
@property (nonatomic,strong) UIButton *selectFromCameraRollButton;
@property (nonatomic,strong) UIButton *pickFromLibraryButton;

@property (nonatomic, unsafe_unretained) voDataEdit *devc;

@end
