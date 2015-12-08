//
//  CLActivityScreenTableViewCell.m
//  NSBE
//

#define CELL_COLOR_1 [UIColor whiteColor]
#define CELL_COLOR_2 [UIColor colorWithRed:233.0/255.0 green:234.0/255.0 blue:236.0/255.0 alpha:1.0]
#define BACKGROUND_CIRCLE_COLOR [UIColor colorWithRed:35.0/255.0 green:64.0/255.0 blue:96.0/255.0 alpha:1.0]
#define BACKGROUND_CIRCLE_LIGHT_COLOR [UIColor colorWithRed:0.0/255.0 green:148.0/255.0 blue:177.0/255.0 alpha:1.0]

#import "CLActivityScreenTableViewCell.h"
#import "CLPushNotification.h"
#import "UIImageView+WebCache.h"

@interface CLActivityScreenTableViewCell ()
@property(weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property(weak, nonatomic) IBOutlet UILabel *activityTextLabel;
@property(weak, nonatomic) IBOutlet UIImageView *backgroundCircleImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityTextSubtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;
@property (weak, nonatomic) IBOutlet UIView *cellContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFistBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFist;

@property (weak, nonatomic) IBOutlet UILabel *labelTop;
@property (weak, nonatomic) IBOutlet UILabel *labelSteps;

@end

@implementation CLActivityScreenTableViewCell

#pragma mark - NSObject

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 1.f;
    self.backgroundCircleImageView.layer.masksToBounds = YES;
    self.backgroundCircleImageView.layer.cornerRadius = 27.f;
    self.cellContentView.layer.cornerRadius = 5.f;
    self.cellContentView.layer.masksToBounds = YES;
    self.imageViewFistBackground.layer.borderColor = BACKGROUND_CIRCLE_LIGHT_COLOR.CGColor;
    self.imageViewFistBackground.backgroundColor = [UIColor clearColor];
}

#pragma mark - UIView

- (void)setFrame:(CGRect)frame {
//    frame.origin.x += 10.f;
//    frame.size.width -= 20.f;
    [super setFrame:frame];
}

#pragma mark - UITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Public methods

- (void)configureCellWithPushNotification:(CLPushNotification *)pushNotification
                                indexPath:(NSIndexPath *)indexPath {
    
//    CLPushNotification *pushNotification = [[CLPushNotification alloc] initWithMessage:@"Hm…No steps today? Get those steps in! jahsdfljkah sdfjh aldfh afasd" type:9 pictureURL:nil picture:nil value:25135];
    
    self.labelSteps.hidden = YES;
    self.labelTop.hidden = YES;
    self.labelCount.hidden = YES;
    self.labelSteps.text = @"STEPS";

    self.imageViewFist.hidden = YES;
    self.imageViewFistBackground.hidden = YES;
    
    self.cellContentView.backgroundColor = indexPath.row % 2 ? CELL_COLOR_2 : CELL_COLOR_1;
    
    self.activityTextLabel.text = pushNotification.message;
    NSString *message = pushNotification.message;
    NSString *title = [self titleStringFromMessage:pushNotification.message];
    
    NSRange range = [message rangeOfString:title];
    
    if (title.length == message.length) {
        self.activityTextLabel.text = title;
        self.activityTextSubtitleLabel.text = nil;
    }
    else
    {
        if (range.location == NSNotFound)
        {
            range = [message rangeOfString:@"."];
        }
        if (range.location == NSNotFound)
        {
            self.activityTextLabel.text = message;
        }
        else
        {
            NSString *substring1 = [message substringToIndex:range.length + 1];
            NSString *substring2 = [message substringFromIndex:range.location + 1 + range.length];
            self.activityTextLabel.text = substring1;
            self.activityTextSubtitleLabel.text = substring2;
        }
    }
    self.contentView.backgroundColor = [UIColor clearColor];

    switch (pushNotification.type) {
        case (CLPushType) 1:
            self.activityImageView.image = nil;
            [self.backgroundCircleImageView sd_setImageWithURL:[NSURL URLWithString:pushNotification.profilePictureURL]
                                              placeholderImage:[UIImage imageNamed:@"NoPhotoIcon"]];
            self.imageViewFist.hidden = NO;
            self.imageViewFistBackground.hidden = NO;
            return;
        case (CLPushType) 2:
            self.activityImageView.image = nil;
            [self.backgroundCircleImageView sd_setImageWithURL:[NSURL URLWithString:pushNotification.profilePictureURL]
                                              placeholderImage:[UIImage imageNamed:@"NoPhotoIcon"]];
            self.imageViewFist.hidden = NO;
            self.imageViewFistBackground.hidden = NO;
            return;
        case (CLPushType) 3:
            self.activityImageView.image = [UIImage imageNamed:@"home_contestconditions"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
        case (CLPushType) 4:
            self.activityImageView.image = [UIImage imageNamed:@"home_contestconditions"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            return;
        case (CLPushType) 5:
            self.activityImageView.image = nil;
            [self.backgroundCircleImageView sd_setImageWithURL:[NSURL URLWithString:pushNotification.profilePictureURL]
                                      placeholderImage:[UIImage imageNamed:@"NoPhotoIcon"]];
            self.imageViewFist.hidden = NO;
            self.imageViewFistBackground.hidden = NO;
            return;
        case (CLPushType) 6:
            self.activityImageView.image = [UIImage imageNamed:@"ico_great_job"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            self.labelCount.hidden = NO;
            self.labelCount.text = [NSString stringWithFormat:@"%liM", pushNotification.value];
            return;
        case (CLPushType) 7:
            self.activityImageView.image = [UIImage imageNamed:@"ico_great_job"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            self.labelTop.hidden = NO;
            self.labelCount.hidden = NO;
            self.labelCount.text = [NSString stringWithFormat:@"%li", pushNotification.value];
            return;
        case (CLPushType) 8:
            self.activityImageView.image = [UIImage imageNamed:@"ico_great_job"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            self.labelTop.hidden = NO;
            self.labelCount.hidden = NO;
            self.labelCount.text = [NSString stringWithFormat:@"%li", pushNotification.value];
            return;
        case (CLPushType) 9:
            self.activityImageView.image = [UIImage imageNamed:@"ico_great_job"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            self.labelSteps.hidden = NO;
            self.labelCount.hidden = NO;
            self.labelCount.text = [NSString stringWithFormat:@"%li0k", pushNotification.value / 10000];
            return;
        case (CLPushType) 10:
            self.activityImageView.image = [UIImage imageNamed:@"ico_great_job"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            self.labelSteps.hidden = NO;
            self.labelCount.hidden = NO;
            self.labelCount.text = [NSString stringWithFormat:@"%li0k", pushNotification.value / 10000];
            return;
        case (CLPushType) 11:
            self.activityImageView.image = [UIImage imageNamed:@"ico_great_job"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            self.labelSteps.hidden = NO;
            self.labelCount.hidden = NO;
            self.labelCount.text = [NSString stringWithFormat:@"%li0k", pushNotification.value / 10000];
            return;
        case (CLPushType) 12:
            //стрелки вверх
            self.activityImageView.image = [UIImage imageNamed:@"TopPlayer"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            return;
        case (CLPushType) 13:
            self.activityImageView.image = [UIImage imageNamed:@"ico_nosteps"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            return;
        case (CLPushType) 14:
            self.activityImageView.image = [UIImage imageNamed:@"ico_great_job"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_COLOR;
            self.labelCount.hidden = NO;
            self.labelSteps.hidden = NO;
            self.labelCount.text = [NSString stringWithFormat:@"%li", pushNotification.value];
            self.labelSteps.text = @"DAYS";
            return;
        case (CLPushType) 15:
            self.activityImageView.image = [UIImage imageNamed:@"cupWithTape"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_LIGHT_COLOR;
            self.labelCount.hidden = NO;

            if (pushNotification.value == 11 || pushNotification.value == 12 || pushNotification.value == 13) {
                self.labelCount.text = [NSString stringWithFormat:@"%lith", pushNotification.value];
            } else {
            self.labelCount.text = [NSString stringWithFormat:@"%li%@", pushNotification.value, [self suffixFromPlace:(pushNotification.value % 10)]];
            }
            return;
        case (CLPushType) 0:
            self.activityImageView.image = [UIImage imageNamed:@"cupWithTape"];
            self.backgroundCircleImageView.image = nil;
            self.backgroundCircleImageView.backgroundColor = BACKGROUND_CIRCLE_LIGHT_COLOR;
            self.labelCount.hidden = NO;

            if (pushNotification.value == 11 || pushNotification.value == 12 || pushNotification.value == 13) {
                self.labelCount.text = [NSString stringWithFormat:@"%lith", pushNotification.value];
            } else {
                self.labelCount.text = [NSString stringWithFormat:@"%li%@", pushNotification.value, [self suffixFromPlace:(pushNotification.value % 10)]];
            }
            return;
        default:
            return;
    }
    
}

- (NSString *)titleStringFromMessage:(NSString *)message
{
    NSArray *hardcodeMessages = @[@"Way to go!", @"Awesome! You won!", @"Awesome!", @"Cool!", @"Nice!", @"Great job!", @"Nice work!", @"You’re on a roll.", @"You are now the top player!", @"Hm…No steps today?", @"Hm… No steps today?", @"You’ve been active.", @"The next challenge starts today.", @"Last day of the game.", @"Wow!"];
    
    for (NSString *string in hardcodeMessages) {
        if ([message containsString:string]) {
            return string;
        }
    }
    
    return message;
}


- (NSString *)suffixFromPlace:(NSInteger)place
{
    switch (place) {
        case 11:
            return @"th";
            break;
        case 12:
            return @"th";
            break;
        case 13:
            return @"th";
            break;
        case 1:
            return @"st";
            break;
        case 2:
            return @"nd";
            break;
        case 3:
            return @"rd";
            break;
        default:
            return @"th";
            break;
    }
}

@end
