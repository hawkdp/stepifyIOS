//
//  CLNavigationController.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/27/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLNavigationController.h"
#import "CLAppAccess.h"
#import "GPUImage.h"

@interface CLNavigationController ()

@property (nonatomic, strong) GPUImageMovie *gpuMovie;
@property (nonatomic, strong) GPUImageView *gpuImageView;

@end

@implementation CLNavigationController

#pragma mark - View controller's lifecycle methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
//    self.gpuImageView = [[GPUImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
////    [self.view addSubview:self.gpuImageView];
////    [self.view sendSubviewToBack:self.gpuImageView];
//    [self.view insertSubview:self.gpuImageView atIndex:0];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_grd_trns"]];
//    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.view insertSubview:imageView aboveSubview:self.gpuImageView];
//    
//    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"steps_video" withExtension:@"mov"];
//    self.gpuMovie = [[GPUImageMovie alloc] initWithURL:fileURL];
//    self.gpuMovie.playAtActualSpeed = YES;
//    self.gpuMovie.shouldRepeat = YES;
//    
//    GPUImageBoxBlurFilter *filter = [[GPUImageBoxBlurFilter alloc] init];
//    filter.blurRadiusInPixels = 8;
//    
//    [self.gpuMovie addTarget:filter];
//    [filter addTarget:self.gpuImageView];
//    
//    [self.gpuMovie startProcessing];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    bgImageView.image = [UIImage imageNamed:@"bg"];
    [self.view insertSubview:bgImageView atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Check for user's application access
//	[CLAppAccess askAccessPassword];
}

#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"memory warning received");
}

@end
