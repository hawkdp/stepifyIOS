//
//  CLPushNotification.h
//  NSBE
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLPushType) {
    kCLPushTypeUndefined                    = -1,
    kCLPushTypeGameWinnerOfEachGamePersonal = 0,
    kCLPushTypeGameWinnerOfEachDay          = 1,
    kCLPushTypeGameWinnerOfEachGame         = 2,
    kCLPushTypeChallengeStartDate           = 3,
    kCLPushTypeChallengeEndDate             = 4,
    kCLPushTypeLeadChanges                  = 5,
    kCLPushTypeMillionSteps                 = 6,
    kCLPushTypeOneOfTopGameUser             = 7,
    kCLPushTypeOneOfTopDayUser              = 8,
    kCLPushTypeLogsOver10k                  = 9,
    kCLPushTypeLogsOver10kInGame            = 10,
    kCLPushTypeLogsOver10kIn3Days           = 11,
    kCLPushTypeLeadChangesPersonal          = 12,
    kCLPushTypeNoStepsLogged                = 13,
    kCLPushTypeLogSteps5DaysRow             = 14,
    kCLPushTypeGameWinnerOfEachDayPersonal  = 15
};

@interface CLPushNotification : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *receivedDate;
@property (nonatomic, assign) CLPushType type;
@property (nonatomic, strong) NSString *profilePictureURL;
@property (nonatomic, strong) UIImage *profilePicture;
@property (nonatomic, assign) BOOL readFlag;
@property (nonatomic, assign) NSInteger value;

- (id)initWithMessage:(NSString *)message type:(CLPushType)type pictureURL:(NSString *)pictureURL picture:(UIImage *)picture value:(NSInteger)value;

@end
