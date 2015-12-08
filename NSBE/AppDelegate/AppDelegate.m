//
//  AppDelegate.m
//  NSBE
//
//  Created by Dragos Ionel on 2015-01-18.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "CLUser+API.h"
#import "CLWebImageCache.h"
#import "CLWebServiceCache.h"
#import "CLFacebookHandler.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "CLNotifications.h"
#import "UIImage+Resize.h"
#import "CLNavigationController.h"
#import "CLHomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"test for merged changes");

    // Whenever a person opens the app, check for a cached session
	if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
		
		// If there's one, just open the session silently, without showing the user the login UI
		[FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:NO completionHandler:
		 ^(FBSession *session, FBSessionState state, NSError *error) {
			 // Handler for session state changes
			 // This method will be called EACH time the session state changes,
			 // also for intermediate states and NOT just when the session open
			 [[CLFacebookHandler sharedInstance] sessionStateChanged:session state:state error:error];
		 }];
	}
	
    [[UITextField appearance] setTintColor:[UIColor blueColor]];
	// Enable network activity manager
	[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
//    [application registerForRemoteNotifications];
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
    NSLog(@"application registerUserNotificationSettings");
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey])
    {
        [self propagatePushNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont fontWithName:@"Geomanist-Regular" size:17.0f]}];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSDictionary *pushDict = @{
//                                   @"aps" : @{
//                                           @"alert": @"push text"
//                                           },
//                                   @"type" : @3,
//                                   @"value": @12
//                                   };
//        [self application:application didReceiveRemoteNotification:pushDict];
//    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	// Save all the data to user defaults
	[CLUser saveUserDataToUserDefaults:[CLUser user]];
	[CLWebServiceCache saveCacheDataToUserDefaults:[CLWebServiceCache cache]];
//	[CLUserNotification saveUserNotificationsToUserDefaults:[CLUserNotification notifications]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	// Reset application icon badge number
	if ([UIApplication instancesRespondToSelector:@selector(currentUserNotificationSettings)]) {
		
		UIUserNotificationSettings *notificationSettings = [application currentUserNotificationSettings];
		if (notificationSettings.types != UIUserNotificationTypeNone) {
			
			[application setApplicationIconBadgeNumber:0];
			NSLog(@"icon badge number was reset");
		}
	} else {
		
		[application setApplicationIconBadgeNumber:0];
		NSLog(@"icon badge number was reset");
	}
	
	// Handle the user leaving the app while the Facebook login dialog is being shown
	// For example: when the user presses the iOS "home" button while the login dialog is active
	[FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
	// Save all the data to user defaults
//    CLUser *user = [CLUser loadUserFromUserDefaults];
//    
    [CLUser saveUserDataToUserDefaults:[CLUser user]];
    [CLWebServiceCache saveCacheDataToUserDefaults:[CLWebServiceCache cache]];
//    [[CLUser user] logOut];
    
//	[CLUserNotification saveUserNotificationsToUserDefaults:[CLUserNotification notifications]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
	// After authentication, your app will be called back with the session information.
	// Note this handler block should be the exact same as the handler passed to any open calls.
	[FBSession.activeSession setStateChangeHandler:^(FBSession *session, FBSessionState state, NSError *error) {

		// Call the app delegate's sessionStateChanged:state:error method to handle session state changes
		[[CLFacebookHandler sharedInstance] sessionStateChanged:session state:state error:error];
	}];
	return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
//	if (notificationSettings.types != UIUserNotificationTypeNone) {
//		NSLog(@"local notifications access granted");
//	}
    
    [application registerForRemoteNotifications];
    NSLog(@"application registerForRemoteNotifications");
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [deviceToken description];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"123" message:[NSString stringWithFormat:@"%@",token] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    NSLog(@"SUCCEEDED to get device token: %@", token);
    
    CLUser *user = [CLUser user];
    user.pushToken = token;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"123" message:[NSString stringWithFormat:@"%@",error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];

    NSLog(@"FAILED to get device token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"RECEIVED remote notification: %@", userInfo);
    
    [self propagatePushNotification:userInfo];
}

- (void)propagatePushNotification:(NSDictionary *)userInfo
{
    NSInteger pushType = [[userInfo valueForKey:@"type"] integerValue];
    NSInteger value = [[userInfo valueForKey:@"value"] integerValue];
    NSString *alert = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
    
    if (pushType == 1 || pushType == 2 || pushType == 5)
    {
        NSString *stringUserID = [userInfo valueForKey:@"userId"];
        NSLog(@"GET_USER_ID: %@", stringUserID);
        if (stringUserID)
        {
            NSLog(@"USER_ID_NOT_NULL");
            [CLUser getUserProfilePictureURLByID:[stringUserID integerValue]
                                    successBlock:^(id data) {
                                        if ([data isKindOfClass:[NSDictionary class]])
                                        {
                                            NSString *profilePictureURL = data[USER_REST_PARAMATER_PROFILE_PICTURE];
                                            NSLog(@"GET_PROFILE_PICTURE: %@", profilePictureURL);
                                            if (profilePictureURL == (id)[NSNull null])
                                            {
                                                NSLog(@"PROFILE_PICTURE_NULL");
                                                [[CLNotifications sharedInstance] addNotificationWithMessage:alert type:pushType pictureURL:nil picture:nil value:value];
                                            }
                                            else
                                            {
                                                UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]]];
                                                UIImage *profileImageSmall = [UIImage imageWithImage:profileImage scaledToSize:CGSizeMake(52.0, 52.0)];
                                                [[CLNotifications sharedInstance] addNotificationWithMessage:alert type:pushType pictureURL:profilePictureURL picture:profileImageSmall value:value];
                                            }
                                        }
                                    }
                                    failureBlock:^(id data, NSError *error) {
                                        NSLog(@"GET_PROFILE_ERROR: %@", error);
                                        [[CLNotifications sharedInstance] addNotificationWithMessage:alert type:pushType pictureURL:nil picture:nil value:value];
                                    }];
        }
        else
        {
            NSLog(@"USER_ID_NULL");
            [[CLNotifications sharedInstance] addNotificationWithMessage:alert type:pushType pictureURL:nil picture:nil value:value];
        }
    }
    else
    {
        NSLog(@"TYPE_WITHOUT_PROFILE_PICTURE");
        [[CLNotifications sharedInstance] addNotificationWithMessage:alert type:pushType pictureURL:nil picture:nil value:value];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	NSLog(@"memory warning received");

	// Clear image cache
	[[CLWebImageCache cache] clearAllCache];
	
	NSLog(@"image cache cleared");
}

@end
