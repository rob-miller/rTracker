/***************
 voImage.h
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

// Image valueObj desired but not implemented due to perceived complexities displaying on graph

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
