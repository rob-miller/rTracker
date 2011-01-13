//
//  voImage.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voImage.h"


@implementation voImage

@synthesize imageView,takePhotoButton,selectFromCameraRollButton,pickFromLibraryButton,devc;

- (void) dealloc {

	[imageView release];
	[takePhotoButton release];
	[selectFromCameraRollButton release];
	[pickFromLibraryButton release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark table cell item display

- (void) imgBtnAction:(id)sender {
	NSLog(@"imgBtn Action.");
	voDataEdit *vde = [[voDataEdit alloc] initWithNibName:@"voDataEdit" bundle:nil ];
	vde.vo = self.vo;
	self.devc = vde; // assign
	[MyTracker.vc.navigationController pushViewController:vde animated:YES];
	[vde release];
	
}

- (UIView*) voDisplay:(CGRect)bounds {
	
	
	UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	imageButton.frame = bounds; //CGRectZero;
	imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
	[imageButton addTarget:self action:@selector(imgBtnAction:) forControlEvents:UIControlEventTouchDown];		
	
	[imageButton setImage:[UIImage imageNamed:@"blueButton.png"] forState: UIControlStateNormal];
	
	imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	
	return imageButton;
}

#pragma mark -
#pragma mark voSDataEdit support -- get image

- (void) getCameraPhoto:(id)sender {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = YES;
	picker.sourceType = 
		(sender == takePhotoButton) ? UIImagePickerControllerSourceTypeCamera :	UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	[self.devc presentModalViewController:picker animated:YES];
	[picker release];
}

- (void) getExistingPhoto:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self.devc presentModalViewController:picker animated:YES];
		[picker release];
	} else {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Error accessing photo library"
							  message:@"Device does not support a photo library" 
							  delegate:nil 
							  cancelButtonTitle:@"Cancel"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) dataEditVDidLoad:(UIViewController*)vc {
	self.imageView = [[[UIImageView alloc] initWithFrame:vc.view.frame] autorelease];
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
		//self.takePhotoButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells

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
- (void) dataEditVWDisappear {
}

- (void) dataEditVDidUnload {
	self.imageView = nil;
	self.takePhotoButton = nil;
	self.selectFromCameraRollButton = nil;
	self.pickFromLibraryButton = nil;
}


#pragma mark -
#pragma mark imagePickerController delegate support 

- (void) imagePickerController:(UIImagePickerController *)picker
		 didFinishPickingImage:(UIImage*)image
				   editingInfo:(NSDictionary*)editingInfo {
	imageView.image = image;
	[picker dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark options page 

- (void) voDrawOptions:(configTVObjVC*)ctvovc {

	CGRect labframe = [ctvovc configLabel:@"need Image Location -- Options:" 
								  frame:(CGRect) {MARGIN,ctvovc.lasty,0.0,0.0}
									key:@"ioLab" 
								  addsv:YES ];
	
	ctvovc.lasty += labframe.size.height + MARGIN;
	[super voDrawOptions:ctvovc];
}


@end
