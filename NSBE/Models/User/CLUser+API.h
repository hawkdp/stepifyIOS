//
//  CLUser+API.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLUser.h"
#import "CLSteps.h"
#import "CLMiniGame.h"

#pragma mark - Web services API URLs

// Dev server
//#define USER_REST_API_SERVER_URL @"http://dev-nsbe.cloudapp.net"

// Stage server
//#define USER_REST_API_SERVER_URL @"http://dev-nsbe.cloudapp.net:1313"

// Production server
//#define USER_REST_API_SERVER_URL @"http://ubuntu-nsbe.cloudapp.net"

// UPMC server
//#define USER_REST_API_SERVER_URL @"http://upmc-nsbe.cloudapp.net"

// Cleveroad server
//#define USER_REST_API_SERVER_URL @"http://148.251.187.5:3666"
#define USER_REST_API_SERVER_URL @"http://52.24.63.242"

#define USER_REST_API_REGISTER_URL SERVER_WEB_SERVICE(@"/api/v1/registration")
#define USER_REST_API_SIGN_IN_URL SERVER_WEB_SERVICE(@"/api/v1/login")
#define USER_REST_API_SIGN_IN_FACEBOOK_URL SERVER_WEB_SERVICE(@"/api/v1/login/facebook")
#define USER_REST_API_SIGN_IN_LINKEDIN_URL SERVER_WEB_SERVICE(@"/api/v1/login/linkedin")
#define USER_REST_API_CHALLENGE_START_DATE_URL SERVER_WEB_SERVICE(@"GetDay.php")
#define USER_REST_API_CHALLENGE_DATA_URL SERVER_WEB_SERVICE(@"/api/v1/challenge")
#define USER_REST_API_TOTAL_STEPS_URL SERVER_WEB_SERVICE(@"/api/v1/steps/total")
#define USER_REST_API_UPDATE_STEPS_URL SERVER_WEB_SERVICE(@"/api/v1/steps/update")
#define USER_REST_API_LEADERBOARD_URL SERVER_WEB_SERVICE(@"/api/v1/game/leaderBoard")
#define USER_REST_API_WEEKLYBOARD_URL SERVER_WEB_SERVICE(@"/api/v1/challenge/weeklyBoard")
#define USER_REST_API_USER_RANKING_URL SERVER_WEB_SERVICE(@"/api/v1/user/ranking")
#define USER_REST_API_USER_WEEKLYRANKING_URL SERVER_WEB_SERVICE(@"/api/v1/user/rankingWeekly")
#define USER_REST_API_MINIGAMES_DATA_URL SERVER_WEB_SERVICE(@"/api/v1/game")
#define USER_REST_API_FLAG_URL SERVER_WEB_SERVICE(@"/api/v1/flags")
#define USER_REST_API_BAN_MINIGAME SERVER_WEB_SERVICE(@"/api/v1/ban/minigame")
#define USER_REST_API_USER_EDIT_PROFILE SERVER_WEB_SERVICE(@"/api/v1/user")
#define USER_REST_API_GET_PROFILE_PICTURE SERVER_WEB_SERVICE(@"/api/v1/user/")
#define USER_REST_API_CHANGE_PASSWORD SERVER_WEB_SERVICE(@"/api/v1/user/changePassword")
#define USER_REST_API_REMOVE_DEVICE SERVER_WEB_SERVICE(@"/api/v1/user/deviceToken/")

// Production server
//#define USER_REST_API_SERVER_URL @"http://cardio.azurewebsites.net/nsbe/service/"
//#define USER_REST_API_REGISTER_URL SERVER_WEB_SERVICE(@"Registration.php")
//#define USER_REST_API_SIGN_IN_URL SERVER_WEB_SERVICE(@"Login.php")
//#define USER_REST_API_CHALLENGE_START_DATE_URL SERVER_WEB_SERVICE(@"GetDay.php")
//#define USER_REST_API_CHALLENGE_DATA_URL SERVER_WEB_SERVICE(@"challenges.php")
//#define USER_REST_API_MINIGAMES_DATA_URL SERVER_WEB_SERVICE(@"games.php")
//#define USER_REST_API_TOTAL_STEPS_URL SERVER_WEB_SERVICE(@"TotalSteps.php")
//#define USER_REST_API_UPDATE_STEPS_URL SERVER_WEB_SERVICE(@"UpdateSteps.php")
//#define USER_REST_API_LEADERBOARD_URL SERVER_WEB_SERVICE(@"LeaderBoard.php")
//#define USER_REST_API_USER_RANKING_URL SERVER_WEB_SERVICE(@"UserRanking.php")
//#define USER_REST_API_FLAG_URL SERVER_WEB_SERVICE(@"flags.php")

#define USER_REST_API_FACEBOOK_PROFILE_PICTURE_URL @"https://graph.facebook.com/%id%/picture?type=large"

#define SERVER_WEB_SERVICE(web_service_name) [USER_REST_API_SERVER_URL stringByAppendingString:web_service_name]


#pragma mark - User app credentials

#define USER_FITBIT_CLIENT_KEY @"b0eed08097da800d37e70d70c4a4749d"
#define USER_FITBIT_CLIENT_SECRET @"11a7525612638e8efeee944b1339673f"
#define USER_FITBIT_AUTHORIZE_PHONE_SCREEN_PARAMETER @"display=touch"
#define USER_JAWBONE_CLIENT_KEY @"TXGxzoGqwy4"
#define USER_JAWBONE_CLIENT_SECRET @"5b4ce11aecef31fd2fccf278211907d86494bfdd"


#pragma mark - User app URLs

#define USER_FITBIT_REQUEST_TOKEN_URL @"https://api.fitbit.com/oauth/request_token"
#define USER_FITBIT_ACCESS_TOKEN_URL @"https://api.fitbit.com/oauth/access_token"
#define USER_FITBIT_AUTHORIZE_URL @"https://www.fitbit.com/oauth/authorize"
#define USER_FITBIT_CALLBACK_URI @"stepify://redirect"
#define USER_FITBIT_STEPS_API_URL @"https://api.fitbit.com/1/user/-/activities/steps/date/%start_date%/%end_date%.json"
#define USER_JAWBONE_AUTHORIZE_URL @"https://jawbone.com/auth/oauth2/auth"
#define USER_JAWBONE_CALLBACK_URI @"stepify://redirect"


#pragma mark - Web services API and app URLs parameters

#define USER_REST_API_PARAMETER_ID @"%id%"
#define USER_APP_URL_PARAMETER_START_DATE @"%start_date%"
#define USER_APP_URL_PARAMETER_END_DATE @"%end_date%"


#pragma mark - User external URL links

#define USER_URL_CARDIO_LEGEND @"http://cardiolegend.com/"
#define USER_URL_NSBE_TERMS_AND_CONDITIONS @"http://cardiolegend.com/terms-and-conditions/"
#define USER_URL_NSBE_PRIVACY_POLICY @"http://cardiolegend.com/privacy-policy/"


#pragma mark - Web services API parameters

#define USER_REST_PARAMATER_ID @"id"
#define USER_REST_PARAMATER_MINIGAME_ID @"id_minigame"
#define USER_REST_PARAMATER_DATA @"data"
#define USER_REST_PARAMETER_TIME_OFFSET @"usr_time_difference"
#define USER_REST_PARAMATER_FIRST_NAME @"usr_first_name"
#define USER_REST_PARAMATER_LAST_NAME @"usr_last_name"
#define USER_REST_PARAMATER_EMAIL @"usr_email"
#define USER_REST_PARAMATER_PASSWORD @"usr_password"
#define USER_REST_PARAMETER_OLD_PASSWORD @"old_password"
#define USER_REST_PARAMATER_GENDER @"usr_gender"
#define USER_REST_PARAMATER_USER_ID @"usr_id"
#define USER_REST_PARAMATER_BIRTHDATE @"usr_age"
#define USER_REST_PARAMATER_BIRTHDAY_DATE @"usr_birthdate"
#define USER_REST_PARAMATER_PHONE_NUMBER @"usr_cellphone"
#define USER_REST_PARAMATER_HEIGHT @"usr_height"
#define USER_REST_PARAMATER_WEIGHT @"usr_weight"
#define USER_REST_PARAMATER_DEVICE_TYPE @"usr_device_id"
#define USER_REST_PARAMATER_USER_ACCESS_TOKEN @"usr_device_token"
#define USER_REST_PARAMATER_ACCESS_TOKEN @"device_token"
#define USER_REST_PARAMATER_FACEBOOK_ID @"usr_fb_id"
#define USER_REST_PARAMATER_LEADERBOARD_POSITION @"usr_rank"
#define USER_REST_PARAMATER_USER_RANKING @"UserRanking"
#define USER_REST_PARAMATER_PROFILE_PICTURE @"usr_profile_photo"
#define USER_REST_PARAMATER_TOTAL_STEPS @"usr_steps"
#define USER_REST_PARAMATER_LEADERBOARD_DAY @"_leaderboard_day"
#define USER_REST_PARAMATER_LEADERBOARD @"LeaderBoard"
#define USER_REST_PARAMATER_CHALLENGE_START_DATE @"challenge_start_date"
#define USER_REST_PARAMATER_CURRENT_CHALLENGE_DAY @"current_competition_day"
#define USER_REST_PARAMATER_USER_STEPS_DAY @"usr_steps_day"
#define USER_REST_PARAMATER_ACTIVITIES_STEPS @"activities-steps"
#define USER_REST_PARAMATER_RULE_TYPE @"rule_type"
#define USER_REST_PARAMATER_DATE_TIME @"dateTime"
#define USER_REST_PARAMATER_FLAG_DATE @"flag_date"
#define USER_REST_PARAMATER_VALUE @"value"
#define USER_REST_PARAMATER_ERROR_CODE @"error_code"
#define USER_AUTHIRIZATION_HEADER @"Authorization"
#define USER_REST_PARAMATER_SOCIALTOKEN @"socials_token"
#define USER_REST_PARAMATER_SOCIALID @"socials_network_id"
#define USER_REST_PARAMETER_PUSH_TOKEN @"push_token"

#pragma mark - Web services errors

#define USER_REST_API_DOMAIN_ERROR @"CLUserAPIErrorDomain"

typedef NS_ENUM(NSInteger, CLUserAPIErrors) {
	kCLUserAPIErrorRequestDidNotSucceed				= 1,
	kCLUserAPIErrorDatebaseInsertionFailed			= 15,
	kCLUserAPIErrorUserAlreadyExists				= 20,
	kCLUserAPIErrorEmailNotProvided					= 25,
	kCLUserAPIErrorProfilePictureURLNotProvided		= 26,
	kCLUserAPIErrorAccessTokenNotProvided			= 27,
	kCLUserAPIErrorIncorrectDataType				= 30,
	kCLUserAPIErrorChallengeStartDateNotProvided	= 31,
	kCLUserAPIErrorChallengeStartYetToCome			= 32,
	kCLUserAPIErrorEmailNotFoundInDatabase			= 35,
	kCLUserAPIErrorDeviceTypeNotProvided			= 95,
	kCLUserAPIErrorUnknown							= 99
};


#pragma mark - Type defines and enums

typedef void (^CLUserAPISuccessBlock)(id data);
typedef void (^CLUserAPISuccessCacheBlock)(id data, BOOL fromCache);
typedef void (^CLUserAPIFailureBlock)(id data, NSError *error);

typedef NS_ENUM(NSInteger, CLUserLeaderboardDay) {
    kCLUserLeaderboardOverall						= -1,
	kCLUserLeaderboardDay1							= 1,
	kCLUserLeaderboardDay2							= 2,
	kCLUserLeaderboardDay3							= 3,
	kCLUserLeaderboardDay4							= 4,
	kCLUserLeaderboardDay5							= 5,
	kCLUserLeaderboardDay6							= 6,
	kCLUserLeaderboardDay7							= 7
};


@interface CLUser (API)

#pragma mark - Web services API class methods

+ (void)registerUser:(CLUser *)user
		successBlock:(CLUserAPISuccessBlock)successBlock
		failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)singInUser:(CLUser *)user
	  successBlock:(CLUserAPISuccessBlock)successBlock
	  failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
           successBlock:(CLUserAPISuccessBlock)successBlock
           failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)signInUserWithFacebookAndSuccessBlock:(CLUserAPISuccessBlock)successBlock
                                 failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)signInUserWithLinkedInAndSuccessBlock:(CLUserAPISuccessBlock)successBlock
                                 failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)updateUserProfileWithParameters:(NSDictionary *)parameters
                        completionBlock:(CLUserAPISuccessBlock)successBlock
                           failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)getUserProfilePicture:(CLUser *)user
				 successBlock:(CLUserAPISuccessBlock)successBlock
				 failureBlock:(CLUserAPIFailureBlock)failureBlock;

//+ (void)getChallengeStartDateWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
//								 failureBlock:(CLUserAPIFailureBlock)failureBlock;

//+ (void)getChallengeStartDateFromCache:(BOOL)fromCache
//						  successBlock:(CLUserAPISuccessCacheBlock)successBlock
//						  failureBlock:(CLUserAPIFailureBlock)failureBlock;
//
//+ (void)getChallengeDataWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
//                            failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)updateStepsForUser:(CLUser *)user
			  successBlock:(CLUserAPISuccessBlock)successBlock
			  failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)syncStepsWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
					 failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)getAllParticipantsTotalSteps:(CLUserAPISuccessBlock)successBlock
						failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)getAllParticipantsTotalStepsFromCache:(BOOL)fromCache
								 successBlock:(CLUserAPISuccessCacheBlock)successBlock
								 failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)getLeaderboardForDay:(CLUserLeaderboardDay)day
				successBlock:(CLUserAPISuccessBlock)successBlock
				failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)fetchWeeklyboardForWeek:(NSInteger)week
                      fromCache:(BOOL)fromCache
                   successBlock:(CLUserAPISuccessCacheBlock)successBlock
                   failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)getLeaderboardForDay:(NSInteger)week
                      fromCache:(BOOL)fromCache
                   successBlock:(CLUserAPISuccessCacheBlock)successBlock
                   failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)getUserRanking:(CLUser *)user
				forDay:(CLUserLeaderboardDay)day
		  successBlock:(CLUserAPISuccessBlock)successBlock
		  failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)getUserRanking:(CLUser *)user
				forDay:(CLUserLeaderboardDay)day
			 fromCache:(BOOL)fromCache
		  successBlock:(CLUserAPISuccessCacheBlock)successBlock
		  failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)fetchUserWeeklyRanking:(CLUser *)user
                        forWeek:(NSInteger)week
                     fromCache:(BOOL)fromCache
                  successBlock:(CLUserAPISuccessCacheBlock)successBlock
                  failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)getUserProfilePictureURLByID:(NSInteger)ID
                        successBlock:(CLUserAPISuccessBlock)successBlock
                        failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)editUserProfile:(CLUser *)user
        completionBlock:(CLUserAPISuccessBlock)successBlock
           failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)changePasswordOld:(NSString *)oldPassword
                      new:(NSString *)newPassword
          completionBlock:(CLUserAPISuccessBlock)successBlock
             failureBlock:(CLUserAPIFailureBlock)failureBlock;

+ (void)removeDeviceToken;

@end
