//
//  CLFloatTableViewCell.m
//  UPMC
//
//  Created by Vasya Pupkin on 7/29/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLFloatTableViewCell.h"

@implementation CLFloatTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.overlay = [UIView new];
    self.overlay.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
    [self.title addSubview:self.overlay];
    self.imgView.layer.cornerRadius = 45/2;
    self.imgView.layer.masksToBounds = YES;
    //    self.title.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    //    self.title.layer.cornerRadius = 5.f;
    //    self.title.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.transform = CGAffineTransformMakeRotation(-M_PI);
}


-(void)setTitle:(NSString*)txt andImage:(UIImage*)img
{
    //    self.title.text = txt;
    //
    //    CGFloat width = ceil([self.title.text sizeWithAttributes:@{NSFontAttributeName: self.title.font}].width);
    //
    //    CGFloat height = ceil([self.title.text sizeWithAttributes:@{NSFontAttributeName: self.title.font}].height);
    //
    //    overlay.frame = CGRectMake(CGRectGetMaxX(self.title.frame), CGRectGetMaxY(self.title.frame), width, height);
    //
    //
    //
    //    self.imgView.image = img;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
