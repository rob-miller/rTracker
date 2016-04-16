/***************
 voImage.m
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
//  voImage.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voImage.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

@implementation voImage

@synthesize imageView=_imageView,takePhotoButton=_takePhotoButton,selectFromCameraRollButton=_selectFromCameraRollButton,pickFromLibraryButton=_pickFromLibraryButton,devc=_devc;


- (int) getValCap {  // NSMutableString size for value
    return 64;
}


#pragma mark -
#pragma mark table cell item display

- (void) imgBtnAction:(id)sender {
	DBGLog(@"imgBtn Action.");
	voDataEdit *vde = [[voDataEdit alloc] initWithNibName:@"voDataEdit" bundle:nil ];
	vde.vo = self.vo;
	self.devc = vde; // assign
	[MyTracker.vc.navigationController pushViewController:vde animated:YES];
	
}

- (UIView*) voDisplay:(CGRect)bounds {
	
	
	UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	imageButton.frame = bounds; //CGRectZero;
	imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
	[imageButton addTarget:self action:@selector(imgBtnAction:) forControlEvents:UIControlEventTouchDown];		
	
	[imageButton setImage:[UIImage imageNamed:@"blueButton.png"] forState: UIControlStateNormal];
	
	//imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	
	return imageButton;
}

#pragma mark -
#pragma mark voSDataEdit support -- get image

- (void) getCameraPhoto:(id)sender {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = YES;
	picker.sourceType = 
		(sender == self.takePhotoButton) ? UIImagePickerControllerSourceTypeCamera :	UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	//[self.devc presentModalViewController:picker animated:YES];
    [self.devc presentViewController:picker animated:YES completion:NULL];
}

- (void) getExistingPhoto:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		//[self.devc presentModalViewController:picker animated:YES];
        [self.devc presentViewController:picker animated:YES completion:NULL];
	} else {
        [rTracker_resource alert:@"Error accessing photo library" msg:@"Device does not support a photo library" vc:nil];
	}
}

- (void) dataEditVDidLoad:(UIViewController*)vc {
	self.imageView = [[UIImageView alloc] initWithFrame:vc.view.frame];
	if (![self.vo.value isEqualToString:@""]) {
		self.imageView.image = [UIImage imageWithContentsOfFile:self.vo.value];
	}
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		self.takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.takePhotoButton.frame = CGRectMake(100.0, 100.0, 120.0, 40.0); //CGRectZero;
		self.takePhotoButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.takePhotoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		[self.takePhotoButton addTarget:self action:@selector(getCameraPhoto:) forControlEvents:UIControlEventTouchUpInside];		
		[self.takePhotoButton setTitle:@"take photo" forState:UIControlStateNormal];
		self.takePhotoButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells

		[self.devc.view addSubview:self.takePhotoButton];
		self.takePhotoButton = nil;
		
		self.selectFromCameraRollButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.selectFromCameraRollButton.frame = CGRectMake(100.0, 150.0, 120.0, 40.0); //CGRectZero;
		self.selectFromCameraRollButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.selectFromCameraRollButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		[self.selectFromCameraRollButton addTarget:self action:@selector(getCameraPhoto:) forControlEvents:UIControlEventTouchUpInside];		
		[self.selectFromCameraRollButton setTitle:@"pick from camera roll" forState:UIControlStateNormal];
		
		[self.devc.view addSubview:self.selectFromCameraRollButton];
		self.selectFromCameraRollButton = nil;
		
	}
	
	self.pickFromLibraryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.pickFromLibraryButton.frame = CGRectMake(100.0, 200.0, 120.0, 40.0); //CGRectZero;
	self.pickFromLibraryButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.pickFromLibraryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[self.pickFromLibraryButton addTarget:self action:@selector(getExistingPhoto:) forControlEvents:UIControlEventTouchUpInside];		
	[self.pickFromLibraryButton setTitle:@"pick from library" forState:UIControlStateNormal];
	
	[self.devc.view addSubview:self.pickFromLibraryButton];
	self.pickFromLibraryButton = nil;
	
	
	
}
- (void) dataEditVWAppear:(UIViewController*)vc {
}
- (void) dataEditVWDisappear:(UIViewController*)vc {
}

/*
- (void) dataEditVDidUnload {
	self.imageView = nil;
	self.takePhotoButton = nil;
	self.selectFromCameraRollButton = nil;
	self.pickFromLibraryButton = nil;
}
*/

#pragma mark -
#pragma mark imagePickerController delegate support 


//- (void) imagePickerController:(UIImagePickerController *)picker
//		 didFinishPickingImage:(UIImage*)image
//				   editingInfo:(NSDictionary*)editingInfo {

- (void) imagePickerController:(UIImagePickerController *)picker
		 didFinishPickingMediaWithInfo:(NSDictionary *)mediaInfo {
	self.imageView.image = mediaInfo[UIImagePickerControllerOriginalImage];  // TODO: needs more work could be edited or video
	//[picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	//[picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -
#pragma mark options page 

- (void) setOptDictDflts {
    
    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = (self.vo.optDict)[key];
    if (nil == val) 
        return YES;
    
    return [super cleanOptDictDflts:key];
}


- (void) voDrawOptions:(configTVObjVC*)ctvovc {

	CGRect labframe = [ctvovc configLabel:@"need Image Location -- Options:" 
								  frame:(CGRect) {MARGIN,ctvovc.lasty,0.0,0.0}
									key:@"ioLab" 
								  addsv:YES ];
	
	ctvovc.lasty += labframe.size.height + MARGIN;
	[super voDrawOptions:ctvovc];
}

#pragma mark -
#pragma mark graph display

/*
 - (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    
    [self transformVO_note:xdat ydat:ydat dscale:dscale height:height border:border firstDate:firstDate];
    
}
*/

- (id) newVOGD {
    // TODO: need to handle image differently from note
    return [[vogd alloc] initAsNote:self.vo];
}




@end
