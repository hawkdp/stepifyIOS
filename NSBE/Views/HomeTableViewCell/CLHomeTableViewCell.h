//
//  CLHomeTableViewCell.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/18/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLUser.h"

@interface CLHomeTableViewCell : UITableViewCell

#pragma mark - Home table view cell properties

@property (nonatomic, weak) IBOutlet UIImageView *profilePictureImageView;
@property (nonatomic, weak) IBOutlet UIImageView *deviceIconImageView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

#pragma mark - Home table view cell methods

- (void)setDeviceImage:(CLUserDevice)device;

- (void)setDateLabelDate:(NSDate *)date;

@end
