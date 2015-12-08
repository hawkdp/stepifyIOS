//
//  CLLeaderboardTableViewCell.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/12/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLUser.h"

@interface CLLeaderboardTableViewCell : UITableViewCell

#pragma mark - Leaderboard table view cell properties

@property (nonatomic, weak) IBOutlet UIImageView *profilePictureImageView;
@property (nonatomic, weak) IBOutlet UIImageView *deviceIconImageView;
@property (nonatomic, weak) IBOutlet UILabel *leaderboardPositionLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *stepsHighLabel;
@property (nonatomic, weak) IBOutlet UILabel *stepsLowLabel;
@property (nonatomic, weak) IBOutlet UIImageView *flagImageView;
@property (weak, nonatomic) IBOutlet UIView *numberBackgroundCircleView;
@property (weak, nonatomic) IBOutlet UIImageView *positionImageView;
@property (weak, nonatomic) IBOutlet UIView *fadeView;

@property (nonatomic, strong) NSString *profilePictureURL;

#pragma mark - Leaderboard table view cell methods

- (void)setLeaderboardPosition:(NSString *)position atIndexPath:(NSIndexPath *)indexPath;

- (void)setParticipantFirstName:(NSString *)firstName andLastName:(NSString *)lastName;

- (void)setParticipantDeviceIcon:(CLUserDevice)device;

- (void)setParticipantSteps:(NSString *)steps atIndexPath:(NSIndexPath *)indexPath;

@end
