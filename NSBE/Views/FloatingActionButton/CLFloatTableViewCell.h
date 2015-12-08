//
//  CLFloatTableViewCell.h
//  UPMC
//
//  Created by Vasya Pupkin on 7/29/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLFloatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) UIView *overlay;

-(void)setTitle:(NSString*)txt andImage:(UIImage*)img;

@end
