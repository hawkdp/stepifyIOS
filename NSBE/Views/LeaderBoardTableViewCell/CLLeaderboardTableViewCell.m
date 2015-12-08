//
//  CLLeaderboardTableViewCell.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/12/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLLeaderboardTableViewCell.h"

@implementation CLLeaderboardTableViewCell

#pragma mark - View's lifecycle methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Leaderboard table view cell methods

- (void)setLeaderboardPosition:(NSString *)position atIndexPath:(NSIndexPath *)indexPath {
      self.numberBackgroundCircleView.layer.cornerRadius = 18.f;
    
    if (indexPath.row + 1 <=3) {
        if (indexPath.row + 1 == 1) {
            self.leaderboardPositionLabel.hidden = YES;
            self.positionImageView.hidden = NO;
            self.positionImageView.image = [UIImage imageNamed:@"rating_gold"];
            self.numberBackgroundCircleView.backgroundColor = [UIColor colorWithRed:0.12f green:0.25f blue:0.22f alpha:1.0f];
        } else if (indexPath.row + 1 == 2) {
            self.leaderboardPositionLabel.hidden = YES;
            self.positionImageView.hidden = NO;
            self.positionImageView.image = [UIImage imageNamed:@"rating_silver"];
            self.numberBackgroundCircleView.backgroundColor = [UIColor colorWithRed:0.12f green:0.21f blue:0.27f alpha:1.0f];
        } else if (indexPath.row +1 == 3) {
            self.leaderboardPositionLabel.hidden = YES;
            self.positionImageView.hidden = NO;
            self.positionImageView.image = [UIImage imageNamed:@"rating_bronze"];
            self.numberBackgroundCircleView.backgroundColor = [UIColor colorWithRed:0.14f green:0.17f blue:0.19f alpha:1.0f];
        }
        
    } else {
        self.leaderboardPositionLabel.hidden = NO;
        self.positionImageView.hidden = YES;
         self.leaderboardPositionLabel.text = position ?: [NSString stringWithFormat:@"%td", indexPath.row + 1];
         self.numberBackgroundCircleView.backgroundColor = [UIColor colorWithRed:0.01f green:0.27f blue:0.45f alpha:1.0f];
    }
}

- (void)setParticipantFirstName:(NSString *)firstName andLastName:(NSString *)lastName {
    if (firstName || lastName) {

        // Set first name, last name or both, depending on which one is available
        self.nameLabel.text = [NSString stringWithFormat:@"%@%@%@", firstName, firstName && lastName ? @" " : @"", lastName];
    } else {

        // Set dummy name
        self.nameLabel.text = NSLocalizedString(@"LeaderboardCellNoNameParticipant", nil);
    }
}

- (void)setParticipantDeviceIcon:(CLUserDevice)device {
    self.deviceIconImageView.image = [CLUser getDeviceIconImage:device];
}

- (void)setParticipantSteps:(NSString *)steps atIndexPath:(NSIndexPath *)indexPath {
    NSString *stepsStr = nil;

    [self restoreContent];
 
    if (indexPath.row + 1 <=3) {
        if (indexPath.row + 1 == 1) {
            self.stepsHighLabel.textColor = [UIColor colorWithRed:241.f/255.f green:211.f/255.f blue:53.f/255.f alpha:1.0f];
            self.stepsLowLabel.textColor = [UIColor colorWithRed:241.f/255.f green:211.f/255.f blue:53.f/255.f alpha:1.0f];
        } else if (indexPath.row + 1 == 2) {
            self.stepsHighLabel.textColor = [UIColor colorWithRed:188.f/255.f green:190.f/255.f blue:195.f/255.f alpha:1.0f];
            self.stepsLowLabel.textColor = [UIColor colorWithRed:188.f/255.f green:190.f/255.f blue:195.f/255.f alpha:1.0f];
        } else if (indexPath.row +1 == 3) {
            self.stepsHighLabel.textColor = [UIColor colorWithRed:205.f/255.f green:133.f/255.f blue:67.f/255.f alpha:1.0f];
            self.stepsLowLabel.textColor = [UIColor colorWithRed:205.f/255.f green:133.f/255.f blue:67.f/255.f alpha:1.0f];
        }

    } else {
        self.stepsHighLabel.textColor = [UIColor whiteColor];
        self.stepsLowLabel.textColor = [UIColor whiteColor];
    }

    if (![steps isKindOfClass:[NSString class]]) {
        stepsStr = [NSString stringWithFormat:@"%ld", (long) [steps intValue]];
    } else {
        stepsStr = (NSString *) steps;
        if ([stepsStr isEqualToString:@"DQ"]) {
            self.stepsHighLabel.textColor = [UIColor whiteColor];
            self.stepsLowLabel.textColor = [UIColor whiteColor];
            self.stepsHighLabel.text = @"";
            self.stepsLowLabel.text = @"";
            self.leaderboardPositionLabel.hidden = NO;
            self.flagImageView.hidden = NO;
            self.flagImageView.image = [UIImage imageNamed:@"ico_dq"];
            self.positionImageView.hidden = YES;
            self.leaderboardPositionLabel.text = @"DQ";
            self.numberBackgroundCircleView.backgroundColor = [UIColor colorWithRed:0.01f green:0.27f blue:0.45f alpha:1.0f];
            [self fadeContent];
            return;
        } else if ([stepsStr isEqualToString:@"F"]) {
            self.stepsHighLabel.textColor = [UIColor whiteColor];
            self.stepsLowLabel.textColor = [UIColor whiteColor];
            self.stepsHighLabel.text = @"";
            self.stepsLowLabel.text = @"";
            self.flagImageView.hidden = NO;
            self.leaderboardPositionLabel.hidden = NO;
            self.positionImageView.hidden = YES;
            self.leaderboardPositionLabel.text = @"F";
            self.numberBackgroundCircleView.backgroundColor = [UIColor colorWithRed:0.01f green:0.27f blue:0.45f alpha:1.0f];
            [self fadeContent];
            return;
        }
        else if ([stepsStr length] == 0) {
            self.stepsHighLabel.textColor = [UIColor whiteColor];
            self.stepsLowLabel.textColor = [UIColor whiteColor];
            self.stepsLowLabel.text = nil;
            self.stepsHighLabel.text = nil;
            return;
        }
    }
    
    if (stepsStr.length >= 6 ) {
        self.stepsLowLabel.text = @"k";
        self.stepsHighLabel.text = [NSString stringWithFormat:@"%ld", (steps.integerValue / 1000)];
    } else {
        if ((stepsStr.integerValue % 1000) < 10) {
            self.stepsLowLabel.text = [NSString stringWithFormat:@"00%ld", (stepsStr.integerValue % 1000)]; //[stepsStr substringFromIndex:stepsStr.length - 3];
        } else if ((stepsStr.integerValue % 1000) < 100) {
            self.stepsLowLabel.text = [NSString stringWithFormat:@"0%ld", (stepsStr.integerValue % 1000)]; //[stepsStr substringFromIndex:stepsStr.length - 3];
        } else {
            self.stepsLowLabel.text = [NSString stringWithFormat:@"%ld", (stepsStr.integerValue % 1000)]; //[stepsStr substringFromIndex:stepsStr.length - 3];
        }
        self.stepsHighLabel.text = [NSString stringWithFormat:@"%ld", (steps.integerValue / 1000)];//[stepsStr substringToIndex:stepsStr.length - 3];
    }

}

- (void)fadeContent
{
    self.stepsLowLabel.alpha = .3;
    self.stepsHighLabel.alpha = .3;
    self.nameLabel.alpha = .3;
    self.deviceIconImageView.alpha = .3;
    self.numberBackgroundCircleView.alpha = .3;
    self.profilePictureImageView.alpha = .3;
}

- (void)restoreContent
{
    self.stepsLowLabel.alpha = 1;
    self.stepsHighLabel.alpha = 1;
    self.nameLabel.alpha = 1;
    self.deviceIconImageView.alpha = 1;
    self.numberBackgroundCircleView.alpha = 1;
    self.profilePictureImageView.alpha = 1;
    
    self.fadeView.hidden = YES;
    self.stepsLowLabel.text = nil;
    self.stepsHighLabel.text = nil;
    self.flagImageView.hidden = YES;
    self.flagImageView.image = [UIImage imageNamed:@"ico_flag_r"];
}
@end
