//
//  CLFloatingActionButton.h
//  UPMC
//
//  Created by Vasya Pupkin on 7/29/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FloatMenuDelegate;

@interface CLFloatingActionButton : UIView <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *imagesArray, *labelsArray;
@property (nonatomic, strong) id<FloatMenuDelegate> delegate;

- (id)initWithFrame:(CGRect)frame normalImage:(UIImage*)normalImage andPressedImage:(UIImage*)pressedImage;

@end

@protocol FloatMenuDelegate <NSObject>

@optional
- (void)didSelectMenuOptionAtIndex:(NSInteger)row;

@end