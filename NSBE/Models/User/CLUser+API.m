//
//  CLUser+API.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLUser+API.h"
#import "AFNetworking.h"
#import "UIImage+Download.h"
#import "CLWebServiceCache.h"
#import "Constants.h"
#import "Utils.h"
#import "CLMiniGameRuleGenerator.h"
#import "CLMiniGameRule.h"
#import "CLStepSyncHistoryRecord.h"
#import "CLHistoryManager.h"
#import "CLTextBoxView.h"

@implementation CLUser (API)

#pragma mark - API class web service methods

+ (void)registerUser:(CLUser *)user
        successBlock:(CLUserAPISuccessBlock)successBlock
        failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Sanity check
    if (user.email.length == 0) {
        
        // Call failure block if this is available
        if (failureBlock) {
            failureBlock(nil, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                  code:kCLUserAPIErrorEmailNotProvided
                                              userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"EmailNotProvided", nil)}]);
        }
        return;
    }
    
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    // Encode picture to Base64 string
    NSString *base64EncodedImage = @"";
    if (user.profilePicture) {
        NSData *imageData = UIImageJPEGRepresentation(user.profilePicture, PROFILE_PICTURE_THUMBNAIL_QUALITY);
        base64EncodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    // Replace height Unicode characters with ASCII characters
    NSString *userHeight = nil;
    if (user.heightFeet && user.heightInches) {
        userHeight = [NSString stringWithFormat:@"%td%@%td%@", [user.heightFeet integerValue],
                      HEIGHT_PICKER_FEET_SUFFIX_TEXT, [user.heightInches integerValue], HEIGHT_PICKER_INCHES_SUFFIX_TEXT];
    }
    
    int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);
    // Fill parameters into dictionary
    NSMutableDictionary *parameters = [@{USER_REST_PARAMATER_EMAIL : [Utils nilToString:user.email],
                                         USER_REST_PARAMATER_PASSWORD : [Utils nilToString:user.password],
                                         USER_REST_PARAMATER_FIRST_NAME : [Utils nilToString:user.firstName],
                                         USER_REST_PARAMATER_LAST_NAME : [Utils nilToString:user.lastName],
                                         USER_REST_PARAMATER_GENDER : [Utils nilToString:user.gender],
                                         USER_REST_PARAMATER_BIRTHDATE : [Utils dateToSQLDate:user.birthdate],
                                         USER_REST_PARAMATER_PHONE_NUMBER : [Utils nilToString:user.phoneNumber],
                                         USER_REST_PARAMATER_HEIGHT : [Utils nilToString:userHeight],
                                         USER_REST_PARAMATER_WEIGHT : [Utils nilToString:user.weight],
                                         USER_REST_PARAMATER_DEVICE_TYPE : @(user.device),
                                         USER_REST_PARAMATER_FACEBOOK_ID : [Utils nilToString:user.facebookID],
                                         USER_REST_PARAMATER_PROFILE_PICTURE : base64EncodedImage,
                                         USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)} mutableCopy];
    
    if (user.pushToken) {
        [parameters setValue:user.pushToken forKey:USER_REST_PARAMETER_PUSH_TOKEN];
    }
    NSLog(@"POST request to: %@", USER_REST_API_REGISTER_URL);
    
#ifdef DEBUG
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dictionary removeObjectForKey:USER_REST_PARAMATER_PROFILE_PICTURE];
    NSLog(@"request parameters: %@", dictionary);
#endif
    
    // Perform a POST request
    [manager POST:USER_REST_API_REGISTER_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] &&
                  [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      
                      // Call success block if this is available
                      if (successBlock) {
                          successBlock(responseObject);
                      }
                  } else {
                      
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)singInUser:(CLUser *)user
      successBlock:(CLUserAPISuccessBlock)successBlock
      failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Sanity check
    //    if (user.email.length == 0) {
    //
    //        // Call failure block if this is available
    //        if (failureBlock) {
    //            failureBlock(nil, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
    //                                                  code:kCLUserAPIErrorEmailNotProvided
    //                                              userInfo:@{NSLocalizedDescriptionKey :
    //                                                      NSLocalizedString(@"EmailNotProvided", nil)}]);
    //        }
    //        return;
    //    }
    
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    // Fill parameters into dictionary
    NSString *timestampString = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    user.email = [NSString stringWithFormat:@"%@@noreply.com", timestampString];
    NSDictionary *parameters = @{USER_REST_PARAMATER_EMAIL : [Utils nilToString:user.email]};
    
    NSLog(@"POST request to: %@", USER_REST_API_SIGN_IN_URL);
    NSLog(@"request parameters: %@", parameters);
    
    // Perform a POST request
    [manager POST:USER_REST_API_SIGN_IN_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      // Call success block if this is available
                      if (successBlock) {
                          successBlock(responseObject);
                      }
                  } else {
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)getUserProfilePicture:(CLUser *)user
                 successBlock:(CLUserAPISuccessBlock)successBlock
                 failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Sanity check
    if (user.profilePictureURL.length == 0) {
        
        // Call failure block if this is available
        if (failureBlock) {
            failureBlock(nil, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                  code:kCLUserAPIErrorProfilePictureURLNotProvided
                                              userInfo:@{NSLocalizedDescriptionKey :
                                                             NSLocalizedString(@"ProfilePictureURLNotProvided", nil)}]);
        }
        return;
    }
    
    // Download image from URL
    [UIImage downloadImageFromURL:user.profilePictureURL completion:^(UIImage *image, NSError *error) {
        
        // Check for errors
        if (!error) {
            
            // Call success block if this is available
            if (successBlock) {
                successBlock(image);
            }
        } else {
            
            // Call failure block if this is available
            if (failureBlock) {
                failureBlock(image, error);
            }
        }
    }];
}

+ (void)getChallengeDataWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
                            failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    NSLog(@"GET request to: %@", USER_REST_API_CHALLENGE_DATA_URL);
    
    // Perform a POST request
    [manager POST:USER_REST_API_CHALLENGE_DATA_URL
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // Call success block if this is available
              if (successBlock) {
                  successBlock(responseObject);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)getMiniGamesDataForCurrentChallengeWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
                                               failureBlock:(CLUserAPIFailureBlock)failureBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    NSLog(@"GET request to: %@", USER_REST_API_MINIGAMES_DATA_URL);
    
    // Perform a POST request
    [manager POST:USER_REST_API_MINIGAMES_DATA_URL
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // Call success block if this is available
              if (successBlock) {
                  successBlock(responseObject);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}


+ (void)getChallengeDataFromCache:(BOOL)fromCache
                     successBlock:(CLUserAPISuccessCacheBlock)successBlock
                     failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Get data from cache
    if (fromCache) {
        
        // Check if we have data in cache for the current request
        CLWebServiceCache *webServiceCache = [CLWebServiceCache getCacheDataForKey:USER_REST_API_CHALLENGE_DATA_URL];
        if (webServiceCache && ![webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ is available, time to live: %g seconds", USER_REST_API_CHALLENGE_START_DATE_URL,
                  [webServiceCache timeUntilExpiration]);
            
            // We have cached data and it has not expired yet, call success block if this is available
            if (successBlock) {
                successBlock(webServiceCache.data, YES);
            }
            return;
        } else if (webServiceCache && [webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ has expired and is deleted", USER_REST_API_CHALLENGE_START_DATE_URL);
            
            // Cache has expired, delete it
            [CLWebServiceCache deleteCacheDataForKey:USER_REST_API_CHALLENGE_DATA_URL];
        }
    }
    
    // Call the get challenge start date method directly and update the cache on success
    [CLUser getChallengeDataWithSuccessBlock:^(id data) {
        
        NSLog(@"cache for key %@ has beed added", USER_REST_API_CHALLENGE_START_DATE_URL);
        
        // Update web service cache
        [CLWebServiceCache addCacheData:data withCacheExpirationTime:WEB_SERVICE_CACHE_EXPIRATION_TIME_LONG
                                 forKey:USER_REST_API_CHALLENGE_DATA_URL];
        
        // Call success block if this is available
        if (successBlock) {
            successBlock(data, NO);
        }
    }                           failureBlock:failureBlock];
}

+ (void)getMiniGamesDataForCurrentChallengeFromCache:(BOOL)fromCache
                                        successBlock:(CLUserAPISuccessCacheBlock)successBlock
                                        failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Get data from cache
    if (fromCache) {
        
        // Check if we have data in cache for the current request
        CLWebServiceCache *webServiceCache = [CLWebServiceCache getCacheDataForKey:USER_REST_API_CHALLENGE_DATA_URL];
        if (webServiceCache && ![webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ is available, time to live: %g seconds", USER_REST_API_CHALLENGE_START_DATE_URL,
                  [webServiceCache timeUntilExpiration]);
            
            // We have cached data and it has not expired yet, call success block if this is available
            if (successBlock) {
                successBlock(webServiceCache.data, YES);
            }
            return;
        } else if (webServiceCache && [webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ has expired and is deleted", USER_REST_API_CHALLENGE_START_DATE_URL);
            
            // Cache has expired, delete it
            [CLWebServiceCache deleteCacheDataForKey:USER_REST_API_CHALLENGE_DATA_URL];
        }
    }
    
    // Call the get challenge start date method directly and update the cache on success
    [CLUser getMiniGamesDataForCurrentChallengeWithSuccessBlock:^(id data) {
        
        NSLog(@"cache for key %@ has beed added", USER_REST_API_MINIGAMES_DATA_URL);
        
        // Update web service cache
        [CLWebServiceCache addCacheData:data
                withCacheExpirationTime:WEB_SERVICE_CACHE_EXPIRATION_TIME_LONG
                                 forKey:USER_REST_API_MINIGAMES_DATA_URL];
        
        // Call success block if this is available
        if (successBlock) {
            successBlock(data, NO);
        }
    }                                              failureBlock:failureBlock];
}


+ (void)updateStepsForUser:(CLUser *)user
              successBlock:(CLUserAPISuccessBlock)successBlock
              failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Sanity check
    if (user.accessToken.length == 0) {
        
        // Call failure block if this is available
        if (failureBlock) {
            failureBlock(nil, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                  code:kCLUserAPIErrorAccessTokenNotProvided
                                              userInfo:@{NSLocalizedDescriptionKey :
                                                             NSLocalizedString(@"AccessTokenNotProvided", nil)}]);
        }
        return;
    }
    
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:user.accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[[CLUser user] currentMiniGame].minigameId.stringValue
                  forKey:USER_REST_PARAMATER_MINIGAME_ID];
    
    [parameters setValue:[CLUser user].stepsForDay
                  forKey:USER_REST_PARAMATER_DATA];
    
    NSLog(@"POST request to: %@", USER_REST_API_UPDATE_STEPS_URL);
    NSLog(@"request parameters: %@", parameters);
    
    // Perform a POST request
    [manager POST:USER_REST_API_UPDATE_STEPS_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"success"] &&
                  [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      
                      // Call success block if this is available
                      if (successBlock) {
                          successBlock(responseObject);
                      }
                  } else {
                      
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)syncStepsWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
                     failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Ok, let's sync those effing steps... Hope it goes smooth, just like a wet and nice pussy!
    CLUser *user = [CLUser user];
    user.isMaxStepsRulePassed = YES;
    
    CLMiniGameRuleGenerator *miniGameRuleGenerator = [[CLMiniGameRuleGenerator alloc] init];
    
    NSLog(@"start steps synchronization...");
    
    [CLUser getChallengeDataFromCache:NO
                         successBlock:^(id data, BOOL formCache) {
                             
                             NSLog(@"get challenge start date result: %@", data);
                             
                             __block NSInteger challengeStatus = 0;
                             [data[@"challenges"] enumerateObjectsUsingBlock:^(NSDictionary *challenge, NSUInteger idx, BOOL *stop) {
                                 challengeStatus = [challenge[@"challenge_status"] integerValue];
                                 if (challengeStatus == 1) {
                                     user.challengeStartDate = [Utils SQLStringDateToDate:challenge[USER_REST_PARAMATER_CHALLENGE_START_DATE]];
                                     user.challengeId = challenge[@"challenge_id"];
                                     user.challengeName = challenge[@"challenge_name"];
                                     user.challengeDurationMonths = @([challenge[@"challenge_duration"] integerValue]);
                                     *stop = YES;
                                 }
                             }];
                             
                             if (!user.challengeId) {
                                 
                                 [CLTextBoxView showWithTitle:@"Notification" message:@"There's no active challenge!"];
                             }
                             
                             [CLUser getMiniGamesDataForCurrentChallengeFromCache:NO
                                                                     successBlock:^(id miniGamesData, BOOL fromCache) {
                                                                         
                                                                         [user.challengeMiniGames removeAllObjects];
                                                                         
                                                                         [miniGamesData[@"games"] enumerateObjectsUsingBlock:^(NSDictionary *game, NSUInteger idx, BOOL *stop) {
                                                                             CLMiniGame *newGame = [[CLMiniGame alloc] init];
                                                                             
                                                                             newGame.startDate = [Utils SQLStringDateToDate:game[@"game_start_date"]];
                                                                             newGame.durationDays = [game[@"game_duration"] intValue];
                                                                             newGame.minigameId = @([game[@"game_id"] integerValue]);
                                                                             
                                                                             __block NSMutableArray *miniGameRulesContainer = [[NSMutableArray alloc] init];
                                                                             __block CLMiniGameRule *miniGameRule;
                                                                             [game[@"game_rules"] enumerateObjectsUsingBlock:^(NSDictionary *miniGameRuleParams, NSUInteger i, BOOL *s) {
                                                                                 miniGameRule = [miniGameRuleGenerator generateMiniGameRuleWithParameters:miniGameRuleParams];
                                                                                 [miniGameRulesContainer addObject:miniGameRule];
                                                                             }];
                                                                             newGame.setOfRules = [NSSet setWithArray:miniGameRulesContainer];
                                                                             [user.challengeMiniGames addObject:newGame];
                                                                         }];
                                                                         //TODO: REFACTOR THIS CODE!!!
                                                                         // Check if you have the challenge start date
                                                                         if (user.challengeStartDate) {
                                                                             
                                                                             // Date for today and challenge end date
                                                                             NSDate *today = [NSDate date];
                                                                             NSDate *challengeEndDate = [user.challengeStartDate dateByAddingTimeInterval:
                                                                                                         CHALLENGE_TOTAL_DAYS * 24 * 3600 - 3600];
                                                                             
                                                                             // Get current challenge day by calculating the difference between now and challenge start date
                                                                             double currentChallengeDay = 0;
                                                                             // currentChallengeDay = [Utils daysBetweenDate:[user currentMiniGame].startDate andDate:[NSDate date]];
                                                                             NSTimeInterval challengeStartDateDifference = [[user currentMiniGame].startDate timeIntervalSinceNow];
                                                                             NSTimeInterval hourDifference = challengeStartDateDifference / 3600;
                                                                             modf(fabs(hourDifference / 24), &currentChallengeDay);
                                                                             
                                                                             NSLog(@"challenge start date, difference and day: %@, %g, day %d", user.challengeStartDate, hourDifference,
                                                                                   (int) currentChallengeDay);
                                                                             
                                                                             // Check if challenge date is earlier than today
                                                                             if (challengeStartDateDifference >= 0) {
                                                                                 // Call failure block if this is available
                                                                             }
                                                                             
                                                                             // Get steps from challenge start date until today for every day
                                                                             if (currentChallengeDay >= 0 && currentChallengeDay <= CHALLENGE_TOTAL_DAYS) {
                                                                                 [CLUser checkDisqualifiedUserWithSuccessBlock:^(id resp) {
                                                                                     [CLUser user].isDisqualified = [resp[@"ban"] boolValue];
                                                                                     if (![CLUser user].isDisqualified) {
                                                                                         [CLSteps getStepsFromDate:[user currentMiniGame].startDate
                                                                                                            toDate:currentChallengeDay < CHALLENGE_TOTAL_DAYS ? today : challengeEndDate
                                                                                                              from:(CLStepsFramework) user.device
                                                                                                      successBlock:^(NSArray *steps) {
                                                                                                          
                                                                                                          switch ((CLStepsFramework) user.device) {
                                                                                                              case kCLStepsFrameworkHealthKit:
                                                                                                              case kCLStepsFrameworkJawbone: {
                                                                                                                  CLStepSyncHistoryRecord *syncHistoryRecord = [[CLStepSyncHistoryRecord alloc] init];
                                                                                                                  syncHistoryRecord.steps = [[[CLUser user].stepsForCurrentDay allValues] firstObject];
                                                                                                                  syncHistoryRecord.date = [Utils dateTimeWithString:[[[CLUser user].stepsForCurrentDay allKeys] firstObject]];
                                                                                                                  //                                                                                                                          [[CLHistoryManager sharedManager] addStepSyncRecord:syncHistoryRecord];
                                                                                                                  
                                                                                                                  // Check rules
                                                                                                                  [[CLUser user] checkRulesForCurrentMiniGame];
                                                                                                                  [[CLHistoryManager sharedManager] needsToZeroStepsCount];
                                                                                                                  
                                                                                                                  if ((![CLUser user].isDailyRulePassed || ![CLUser user].isHourlyRulePassed) || ![CLUser user].isMaxStepsRulePassed) {
                                                                                                                      [CLUser markCurrentUserAsCheaterWithSuccessBlock:^(id response) {
                                                                                                                          [CLTextBoxView showWithTitle:@"Notification" message:@"You don't play nice.!"];
                                                                                                                          // Update steps on the server
                                                                                                                          [CLUser updateStepsForUser:user
                                                                                                                                        successBlock:^(id stepsData) {

                                                                                                                                            NSLog(@"update steps for user success: %@\nreceived steps:\n%@", data, steps);
                                                                                                                                            // Add current day to the resulted dictionary
                                                                                                                                            NSMutableDictionary *returnSteps = [[NSMutableDictionary alloc] initWithDictionary:user.stepsForDay];
                                                                                                                                            returnSteps[USER_REST_PARAMATER_CURRENT_CHALLENGE_DAY] = @(currentChallengeDay);
                                                                                                                                            // Call success block if this is available
                                                                                                                                            if (successBlock) {
                                                                                                                                                successBlock(returnSteps);
                                                                                                                                            }
                                                                                                                                        }
                                                                                                                                        failureBlock:^(id failureData, NSError *error) {
                                                                                                                                            // Call failure block if this is available
                                                                                                                                            if (failureBlock) {
                                                                                                                                                failureBlock(failureData, error);
                                                                                                                                            }
                                                                                                                                        }];
                                                                                                                      }
                                                                                                                                                          failureBlock:^(id fail, NSError *err) {}];
                                                                                                                  }
                                                                                                                  else if ([CLUser user].isDailyRulePassed && [CLUser user].isHourlyRulePassed && [CLUser user].isMaxStepsRulePassed)
                                                                                                                  {
                                                                                                                      [self unflagCurrentUserWithSuccessBlock:^(id data) {
                                                                                                                          
//                                                                                                                          [CLUser user].isFlagged = NO;
                                                                                                                          // Update steps on the server
                                                                                                                          [CLUser updateStepsForUser:user
                                                                                                                                        successBlock:^(id stepsData) {
                                                                                                                                            NSLog(@"update steps for user success: %@\nreceived steps:\n%@", data, steps);
                                                                                                                                            // Add current day to the resulted dictionary
                                                                                                                                            NSMutableDictionary *returnSteps = [[NSMutableDictionary alloc] initWithDictionary:user.stepsForDay];
                                                                                                                                            returnSteps[USER_REST_PARAMATER_CURRENT_CHALLENGE_DAY] = @(currentChallengeDay);
                                                                                                                                            // Call success block if this is available
                                                                                                                                            if (successBlock) {
                                                                                                                                                successBlock(returnSteps);
                                                                                                                                            }
                                                                                                                                        }
                                                                                                                                        failureBlock:^(id failureData, NSError *error) {
                                                                                                                                            // Call failure block if this is available
                                                                                                                                            if (failureBlock) {
                                                                                                                                                failureBlock(failureData, error);
                                                                                                                                            }
                                                                                                                                        }];
                                                                                                                          
                                                                                                                      } failureBlock:^(id data, NSError *error) {
                                                                                                                          NSLog(@"failure!!!");
                                                                                                                      }];
                                                                                                                  }
                                                                                                                  return;
                                                                                                              }
                                                                                                              case kCLStepsFrameworkFitbit:{
                                                                                                                  CLStepSyncHistoryRecord *syncHistoryRecord = [[CLStepSyncHistoryRecord alloc] init];
                                                                                                                  syncHistoryRecord.steps = [[[CLUser user].stepsForCurrentDay allValues] firstObject];
                                                                                                                  syncHistoryRecord.date = [Utils dateTimeWithString:[[[CLUser user].stepsForCurrentDay allKeys] firstObject]];
                                                                                                                  [[CLHistoryManager sharedManager] addStepSyncRecord:syncHistoryRecord];
                                                                                                                  
                                                                                                                  // Check rules
                                                                                                                  [[CLUser user] checkRulesForCurrentMiniGame];
                                                                                                                  [[CLHistoryManager sharedManager] needsToZeroStepsCount];
                                                                                                                  
                                                                                                                  if ((![CLUser user].isDailyRulePassed || ![CLUser user].isHourlyRulePassed) || ![CLUser user].isMaxStepsRulePassed) {
                                                                                                                      [CLUser markCurrentUserAsCheaterWithSuccessBlock:^(id response) {
                                                                                                                          [CLTextBoxView showWithTitle:@"Notification" message:@"You don't play nice.!"];
                                                                                                                          // Update steps on the server
                                                                                                                          [CLUser updateStepsForUser:user
                                                                                                                                        successBlock:^(id stepsData) {
                                                                                                                                            
                                                                                                                                            NSLog(@"update steps for user success: %@\nreceived steps:\n%@", data, steps);
                                                                                                                                            // Add current day to the resulted dictionary
                                                                                                                                            NSMutableDictionary *returnSteps = [[NSMutableDictionary alloc] initWithDictionary:user.stepsForDay];
                                                                                                                                            returnSteps[USER_REST_PARAMATER_CURRENT_CHALLENGE_DAY] = @(currentChallengeDay);
                                                                                                                                            // Call success block if this is available
                                                                                                                                            if (successBlock) {
                                                                                                                                                successBlock(returnSteps);
                                                                                                                                            }
                                                                                                                                        }
                                                                                                                                        failureBlock:^(id failureData, NSError *error) {
                                                                                                                                            // Call failure block if this is available
                                                                                                                                            if (failureBlock) {
                                                                                                                                                failureBlock(failureData, error);
                                                                                                                                            }
                                                                                                                                        }];
                                                                                                                      }
                                                                                                                                                          failureBlock:^(id fail, NSError *err) {}];
                                                                                                                  }
                                                                                                                  else if ([CLUser user].isDailyRulePassed && [CLUser user].isHourlyRulePassed && [CLUser user].isMaxStepsRulePassed)
                                                                                                                  {
                                                                                                                      [self unflagCurrentUserWithSuccessBlock:^(id data) {
                                                                                                                          
                                                                                                                          //                                                                                                                          [CLUser user].isFlagged = NO;
                                                                                                                          // Update steps on the server
                                                                                                                          [CLUser updateStepsForUser:user
                                                                                                                                        successBlock:^(id stepsData) {
                                                                                                                                            NSLog(@"update steps for user success: %@\nreceived steps:\n%@", data, steps);
                                                                                                                                            // Add current day to the resulted dictionary
                                                                                                                                            NSMutableDictionary *returnSteps = [[NSMutableDictionary alloc] initWithDictionary:user.stepsForDay];
                                                                                                                                            returnSteps[USER_REST_PARAMATER_CURRENT_CHALLENGE_DAY] = @(currentChallengeDay);
                                                                                                                                            // Call success block if this is available
                                                                                                                                            if (successBlock) {
                                                                                                                                                successBlock(returnSteps);
                                                                                                                                            }
                                                                                                                                        }
                                                                                                                                        failureBlock:^(id failureData, NSError *error) {
                                                                                                                                            // Call failure block if this is available
                                                                                                                                            if (failureBlock) {
                                                                                                                                                failureBlock(failureData, error);
                                                                                                                                            }
                                                                                                                                        }];
                                                                                                                          
                                                                                                                      } failureBlock:^(id data, NSError *error) {
                                                                                                                          NSLog(@"failure!!!");
                                                                                                                      }];
                                                                                                                  }
                                                                                                                  return;
                                                                                                              }
                                                                                                              case kCLStepsFrameworkNone: {
                                                                                                                  return;
                                                                                                              }
                                                                                                          }
                                                                                                      }
                                                                                                      failureBlock:^(id failureData, NSError *error) {
                                                                                                          if (failureBlock) {
                                                                                                              failureBlock(failureData, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                                                                                                                            code:kCLUserAPIErrorChallengeStartDateNotProvided
                                                                                                                                                        userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@: %@",
                                                                                                                                                                                                NSLocalizedString(@"ErrorRetrievingSteps", nil), [error localizedDescription]]}]);
                                                                                                          }
                                                                                                      }];
                                                                                     } else {
                                                                                         failureBlock(data, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                                                                                                code:kCLUserAPIErrorUnknown
                                                                                                                            userInfo:@{NSLocalizedDescriptionKey : @"Sync not allowed."}]);
                                                                                     }
                                                                                     
                                                                                 }
                                                                                                                  failureBlock:^(id failedResp, NSError *error) {
                                                                                                                      failureBlock(data, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                                                                                                                             code:kCLUserAPIErrorUnknown
                                                                                                                                                         userInfo:@{NSLocalizedDescriptionKey : @"DQ API failed"}]);
                                                                                                                  }];
                                                                             } else {
                                                                                 // Challenge hasn't started yet or is already over, call success block if this is available
                                                                                 if (successBlock) {
                                                                                     successBlock(nil);
                                                                                 }
                                                                             }
                                                                         } else {
                                                                             // No challenge start date, call failure block if this is available
                                                                             if (failureBlock) {
                                                                                 failureBlock(data, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                                                                                        code:kCLUserAPIErrorChallengeStartDateNotProvided
                                                                                                                    userInfo:@{NSLocalizedDescriptionKey :
                                                                                                                                   NSLocalizedString(@"ChallengeStartDateNotProvided", nil)}]);
                                                                             }
                                                                         }
                                                                     }
                                                                     failureBlock:^(id failureData, NSError *error) {
                                                                         if (failureBlock) {
                                                                             failureBlock(nil, error);
                                                                         }
                                                                     }];
                         }
                         failureBlock:^(id data, NSError *error) {
                             
                             NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];

                             NSString *errorMessage = [error localizedDescription];
                             
                             if (data && data[@"error_code"] && [data[@"error_code"] isKindOfClass:[NSNumber class]]) {
                                 switch ([data[@"error_code"] intValue]) {
                                     case kCLUserAPIErrorUserAlreadyExists:
                                         errorMessage = NSLocalizedString(@"UserAlreadyExists", nil);
                                         break;
                                     case kCLUserAPIErrorEmailNotProvided:
                                         errorMessage = NSLocalizedString(@"EmailNotProvided", nil);
                                         break;
                                     default:
                                         errorMessage = NSLocalizedString(@"UnknownError", nil);
                                         break;
                                 }
                             } else  if (errorData) {
                                 NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:errorData options:0 error:nil];
                                 NSLog(@"jsondata %@", jsonData);
                                 errorMessage = jsonData[0][@"message"];
                             }
                             
                             [CLTextBoxView showWithTitle:nil message:errorMessage];
                             
                             // Call failure block if this is available
                             if (failureBlock) {
                                 failureBlock(nil, error);
                             }
                         }];
}

+ (void)getAllParticipantsTotalSteps:(CLUserAPISuccessBlock)successBlock
                        failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    NSLog(@"GET request to: %@", USER_REST_API_TOTAL_STEPS_URL);
    
    // Perform a POST request
    [manager      GET:USER_REST_API_TOTAL_STEPS_URL parameters:nil success:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         
         // Call success block if this is available
         if (successBlock) {
             successBlock(responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         // Call failure block if this is available
         if (failureBlock) {
             failureBlock(nil, error);
         }
     }];
}

+ (void)getAllParticipantsTotalStepsFromCache:(BOOL)fromCache
                                 successBlock:(CLUserAPISuccessCacheBlock)successBlock
                                 failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Get data from cache
    if (fromCache) {
        
        // Check if we have data in cache for the current request
        CLWebServiceCache *webServiceCache = [CLWebServiceCache getCacheDataForKey:USER_REST_API_TOTAL_STEPS_URL];
        if (webServiceCache && ![webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ is available, time to live: %g seconds", USER_REST_API_TOTAL_STEPS_URL,
                  [webServiceCache timeUntilExpiration]);
            
            // We have cached data and it has not expired yet, call success block if this is available
            if (successBlock) {
                successBlock(webServiceCache.data, YES);
            }
            return;
        } else if (webServiceCache && [webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ has expired and is deleted", USER_REST_API_TOTAL_STEPS_URL);
            
            // Cache has expired, delete it
            [CLWebServiceCache deleteCacheDataForKey:USER_REST_API_TOTAL_STEPS_URL];
        }
    }
    
    // Call the get all participants total steps method directly and update the cache on success
    [CLUser getAllParticipantsTotalSteps:^(id data) {
        
        NSLog(@"cache for key %@ has beed added", USER_REST_API_TOTAL_STEPS_URL);
        
        // Update web service cache
        [CLWebServiceCache addCacheData:data withCacheExpirationTime:WEB_SERVICE_CACHE_EXPIRATION_TIME_MEDIUM
                                 forKey:USER_REST_API_TOTAL_STEPS_URL];
        
        // Call success block if this is available
        if (successBlock) {
            successBlock(data, NO);
        }
    }                       failureBlock:failureBlock];
}

+ (void)fetchWeeklyboardForWeek:(NSInteger)week
                   successBlock:(CLUserAPISuccessBlock)successBlock
                   failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    
    // Fill parameters into dictionary
    NSDictionary *parameters = @{@"week" :[NSString stringWithFormat:@"%i", week]};
    
    
    NSLog(@"POST request to: %@", USER_REST_API_WEEKLYBOARD_URL);
    NSLog(@"request parameters: %@", parameters);
    
    // Perform a POST request
    [manager POST:USER_REST_API_WEEKLYBOARD_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] &&
                  [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      
                      // Call success block if this is available
                      if (successBlock) {
                          successBlock(responseObject);
                      }
                  } else {
                      
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)getLeaderboardForDay:(CLUserLeaderboardDay)day
                successBlock:(CLUserAPISuccessBlock)successBlock
                failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    
    // Fill parameters into dictionary
    NSDictionary *parameters;
    if ([[CLUser user] currentMiniGame].minigameId) {
        parameters = @{@"minigame_id" : [[CLUser user] currentMiniGame].minigameId,
                       USER_REST_PARAMATER_LEADERBOARD_DAY : @(day)};
    } else {
        parameters = @{USER_REST_PARAMATER_LEADERBOARD_DAY : @(day)};
    }
    
    NSLog(@"POST request to: %@", USER_REST_API_LEADERBOARD_URL);
    NSLog(@"request parameters: %@", parameters);
    
    // Perform a POST request
    [manager     POST:USER_REST_API_LEADERBOARD_URL parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         
         // Check if there is a success value in response data
         if ([responseObject isKindOfClass:[NSDictionary class]] &&
             [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
             
             // Test if the request succeeded
             if ([responseObject[@"success"] boolValue]) {
                 
                 // Call success block if this is available
                 if (successBlock) {
                     successBlock(responseObject);
                 }
             } else {
                 
                 // Call failure block if this is available
                 if (failureBlock) {
                     failureBlock(responseObject,
                                  [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                      code:kCLUserAPIErrorRequestDidNotSucceed
                                                  userInfo:@{NSLocalizedDescriptionKey :
                                                                 responseObject[@"message"] ?: @""}]);
                 }
             }
         } else {
             
             // No success value - let's suppose it'a success
             if (successBlock) {
                 successBlock(responseObject);
             }
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         // Call failure block if this is available
         if (failureBlock) {
             failureBlock(nil, error);
         }
     }];
}

+ (void)fetchWeeklyboardForWeek:(NSInteger)week
                      fromCache:(BOOL)fromCache
                   successBlock:(CLUserAPISuccessCacheBlock)successBlock
                   failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create the key for this request
    NSString *requestKey = [NSString stringWithFormat:@"%@_day_%td", USER_REST_API_WEEKLYBOARD_URL, week];
    
    if (fromCache) {
        
        // Check if we have data in cache for the current request
        CLWebServiceCache *webServiceCache = [CLWebServiceCache getCacheDataForKey:requestKey];
        if (webServiceCache && ![webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ is available, time to live: %g seconds", requestKey,
                  [webServiceCache timeUntilExpiration]);
            
            // We have cached data and it has not expired yet, call success block if this is available
            if (successBlock) {
                successBlock(webServiceCache.data, YES);
            }
            return;
        } else if (webServiceCache && [webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ has expired and is deleted", requestKey);
            
            // Cache has expired, delete it
            [CLWebServiceCache deleteCacheDataForKey:requestKey];
        }
    }
    
    // Call the leaderboard method directly and update the cache on success
    [CLUser fetchWeeklyboardForWeek:week successBlock:^(id data) {
        
        NSLog(@"cache for key %@ has beed added", requestKey);
        
        // Update web service cache
        [CLWebServiceCache addCacheData:data withCacheExpirationTime:WEB_SERVICE_CACHE_EXPIRATION_TIME_MEDIUM
                                 forKey:requestKey];
        
        // Call success block if this is available
        if (successBlock) {
            successBlock(data, NO);
        }
    }                  failureBlock:failureBlock];
}

+ (void)getLeaderboardForDay:(CLUserLeaderboardDay)day
                   fromCache:(BOOL)fromCache
                successBlock:(CLUserAPISuccessCacheBlock)successBlock
                failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create the key for this request
    NSString *requestKey = [NSString stringWithFormat:@"%@_day_%td", USER_REST_API_LEADERBOARD_URL, day];
    
    if (fromCache) {
        
        // Check if we have data in cache for the current request
        CLWebServiceCache *webServiceCache = [CLWebServiceCache getCacheDataForKey:requestKey];
        if (webServiceCache && ![webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ is available, time to live: %g seconds", requestKey,
                  [webServiceCache timeUntilExpiration]);
            
            // We have cached data and it has not expired yet, call success block if this is available
            if (successBlock) {
                successBlock(webServiceCache.data, YES);
            }
            return;
        } else if (webServiceCache && [webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ has expired and is deleted", requestKey);
            
            // Cache has expired, delete it
            [CLWebServiceCache deleteCacheDataForKey:requestKey];
        }
    }
    
    // Call the leaderboard method directly and update the cache on success
    [CLUser getLeaderboardForDay:day successBlock:^(id data) {
        
        NSLog(@"cache for key %@ has beed added", requestKey);
        
        // Update web service cache
        [CLWebServiceCache addCacheData:data withCacheExpirationTime:WEB_SERVICE_CACHE_EXPIRATION_TIME_MEDIUM
                                 forKey:requestKey];
        
        // Call success block if this is available
        if (successBlock) {
            successBlock(data, NO);
        }
    }               failureBlock:failureBlock];
}

+ (void)getUserRanking:(CLUser *)user
                forDay:(CLUserLeaderboardDay)day
          successBlock:(CLUserAPISuccessBlock)successBlock
          failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:user.accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    // Fill parameters into dictionary
    NSDictionary *parameters = @{
                                 USER_REST_PARAMATER_LEADERBOARD_DAY : @(day),
                                 USER_REST_PARAMATER_MINIGAME_ID : [[CLUser user] currentMiniGame].minigameId};
    
    NSLog(@"POST request to: %@", USER_REST_API_USER_RANKING_URL);
    NSLog(@"request parameters: %@", parameters);
    
    // Perform a POST request
    [manager POST:USER_REST_API_USER_RANKING_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] &&
                  [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      
                      // Call success block if this is available
                      if (successBlock) {
                          successBlock(responseObject);
                      }
                  } else {
                      
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)fetchUserRanking:(CLUser *)user
                 forWeek:(NSInteger)week
            successBlock:(CLUserAPISuccessBlock)successBlock
            failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:user.accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    // Fill parameters into dictionary
    NSDictionary *parameters = @{ @"week" : [NSString stringWithFormat:@"%i",week] };
    
    NSLog(@"POST request to: %@", USER_REST_API_USER_WEEKLYRANKING_URL);
    NSLog(@"request parameters: %@", parameters);
    
    // Perform a POST request
    [manager POST:USER_REST_API_USER_WEEKLYRANKING_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] &&
                  [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      
                      // Call success block if this is available
                      if (successBlock) {
                          successBlock(responseObject);
                      }
                  } else {
                      
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)fetchUserWeeklyRanking:(CLUser *)user
                       forWeek:(NSInteger)week
                     fromCache:(BOOL)fromCache
                  successBlock:(CLUserAPISuccessCacheBlock)successBlock
                  failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create the key for this request
    NSString *requestKey = [NSString stringWithFormat:@"%@_day_%td", USER_REST_API_USER_WEEKLYRANKING_URL, week];
    
    if (fromCache) {
        
        // Check if we have data in cache for the current request
        CLWebServiceCache *webServiceCache = [CLWebServiceCache getCacheDataForKey:requestKey];
        if (webServiceCache && ![webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ is available, time to live: %g seconds", requestKey,
                  [webServiceCache timeUntilExpiration]);
            
            // We have cached data and it has not expired yet, call success block if this is available
            if (successBlock) {
                successBlock(webServiceCache.data, YES);
            }
            return;
        } else if (webServiceCache && [webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ has expired and is deleted", requestKey);
            
            // Cache has expired, delete it
            [CLWebServiceCache deleteCacheDataForKey:requestKey];
        }
    }
    
    // Call the user ranking method directly and update the cache on success
    [CLUser fetchUserRanking:user forWeek:week successBlock:^(id data) {
        
        NSLog(@"cache for key %@ has beed added", requestKey);
        
        // Update web service cache
        [CLWebServiceCache addCacheData:data withCacheExpirationTime:WEB_SERVICE_CACHE_EXPIRATION_TIME_MEDIUM
                                 forKey:requestKey];
        
        // Call success block if this is available
        if (successBlock) {
            successBlock(data, NO);
        }
    }         failureBlock:failureBlock];
}

+ (void)getUserRanking:(CLUser *)user
                forDay:(CLUserLeaderboardDay)day
             fromCache:(BOOL)fromCache
          successBlock:(CLUserAPISuccessCacheBlock)successBlock
          failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create the key for this request
    NSString *requestKey = [NSString stringWithFormat:@"%@_day_%td", USER_REST_API_USER_RANKING_URL, day];
    
    if (fromCache) {
        
        // Check if we have data in cache for the current request
        CLWebServiceCache *webServiceCache = [CLWebServiceCache getCacheDataForKey:requestKey];
        if (webServiceCache && ![webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ is available, time to live: %g seconds", requestKey,
                  [webServiceCache timeUntilExpiration]);
            
            // We have cached data and it has not expired yet, call success block if this is available
            if (successBlock) {
                successBlock(webServiceCache.data, YES);
            }
            return;
        } else if (webServiceCache && [webServiceCache cacheExpired]) {
            
            NSLog(@"cache for key %@ has expired and is deleted", requestKey);
            
            // Cache has expired, delete it
            [CLWebServiceCache deleteCacheDataForKey:requestKey];
        }
    }
    
    // Call the user ranking method directly and update the cache on success
    [CLUser getUserRanking:user forDay:day successBlock:^(id data) {
        
        NSLog(@"cache for key %@ has beed added", requestKey);
        
        // Update web service cache
        [CLWebServiceCache addCacheData:data withCacheExpirationTime:WEB_SERVICE_CACHE_EXPIRATION_TIME_MEDIUM
                                 forKey:requestKey];
        
        // Call success block if this is available
        if (successBlock) {
            successBlock(data, NO);
        }
    }         failureBlock:failureBlock];
}

+ (void)markCurrentUserAsCheaterWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
                                    failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    NSString *firedRuleType = ![CLUser user].isDailyRulePassed ? @"1" : @"2";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStringParam = [dateFormatter stringFromDate:[NSDate date]];
    // Fill parameters into dictionary
    NSDictionary *parameters = @{
                                 USER_REST_PARAMATER_MINIGAME_ID : [[CLUser user] currentMiniGame].minigameId,
                                 USER_REST_PARAMATER_RULE_TYPE : firedRuleType,
                                 USER_REST_PARAMATER_FLAG_DATE : dateStringParam};
    
    // Perform a POST request
    [manager POST:USER_REST_API_FLAG_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (successBlock) {
                  successBlock(nil);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)unflagCurrentUserWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
                             failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    // Fill parameters into dictionary
    NSDictionary *parameters = @{
                                 USER_REST_PARAMATER_MINIGAME_ID : [[CLUser user] currentMiniGame].minigameId,
                                 };
    
    // Perform a POST request
    [manager DELETE:USER_REST_API_FLAG_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock) {
            failureBlock(nil, error);
        }
    }];
    
}

+ (void)checkDisqualifiedUserWithSuccessBlock:(CLUserAPISuccessBlock)successBlock
                                 failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    [manager GET:USER_REST_API_BAN_MINIGAME
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if (successBlock) {
                 successBlock(responseObject);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Call failure block if this is available
             if (failureBlock) {
                 failureBlock(nil, error);
             }
         }];
}

+ (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
           successBlock:(CLUserAPISuccessBlock)successBlock
           failureBlock:(CLUserAPIFailureBlock)failureBlock {
    
    if (![Utils isValidEmail:email]) {
        if (failureBlock) {
            failureBlock(nil, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                  code:kCLUserAPIErrorEmailNotProvided
                                              userInfo:@{NSLocalizedDescriptionKey :
                                                             NSLocalizedString(@"EmailNotProvided", nil)}]);
        }
        return;
    }
    if (password.length == 0) {
        if (failureBlock) {
            failureBlock(nil, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                  code:kCLUserAPIErrorEmailNotProvided
                                              userInfo:@{NSLocalizedDescriptionKey : @"Provide your password"}]);
        }
        return;
        
    }
    
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    // Fill parameters into dictionary
    NSMutableDictionary *parameters = [@{USER_REST_PARAMATER_EMAIL : [Utils nilToString:email],
                                         USER_REST_PARAMATER_PASSWORD : [Utils nilToString:password]} mutableCopy];
    
    if ([CLUser user].pushToken) {
        [parameters setValue:[CLUser user].pushToken forKey:USER_REST_PARAMETER_PUSH_TOKEN];
    }
    
    // Perform a POST request
    [manager POST:USER_REST_API_SIGN_IN_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      // Call success block if this is available
                      if (successBlock) {
                          [CLUser user].accessToken = responseObject[USER_REST_PARAMATER_ACCESS_TOKEN];
                          [CLUser user].device = (CLUserDevice)[responseObject[USER_REST_PARAMATER_DEVICE_TYPE] integerValue];
                          
                          if (responseObject[USER_REST_PARAMATER_PROFILE_PICTURE])
                          {
                              [CLUser user].profilePictureURL = responseObject[USER_REST_PARAMATER_PROFILE_PICTURE];
                              [[CLUser user] fetchProfilePictureWithCompletionBlock:^(UIImage *profilePic, NSError *error)
                               {
                                   if (!error)
                                   {
                                       [CLUser user].profilePicture = profilePic;
                                   }
                               }];
                          }
                          
                          [CLUser user].firstName = responseObject[USER_REST_PARAMATER_FIRST_NAME];
                          [CLUser user].lastName = responseObject[USER_REST_PARAMATER_LAST_NAME];
                          [CLUser user].email = responseObject[USER_REST_PARAMATER_EMAIL];
                          [CLUser user].gender = responseObject[USER_REST_PARAMATER_GENDER];
                          [CLUser user].userId = responseObject[USER_REST_PARAMATER_USER_ID];
                          NSString *dateString = responseObject[USER_REST_PARAMATER_BIRTHDAY_DATE];
                          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                          [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                          [CLUser user].birthdate = [dateFormatter dateFromString:dateString];
                          [CLUser user].age = @([Utils getYearCountFromDate:[CLUser user].birthdate]);
                          
                          NSArray *heightValues = [responseObject[USER_REST_PARAMATER_HEIGHT] componentsSeparatedByString:@" "];
                          [CLUser user].heightFeet = heightValues[0];
                          [CLUser user].heightInches = heightValues[2];
                          
                          [CLUser user].weight = responseObject[USER_REST_PARAMATER_WEIGHT];
                          
                          successBlock(responseObject);
                      }
                  } else {
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)signInUserWithFacebookAndSuccessBlock:(CLUserAPISuccessBlock)successBlock
                                 failureBlock:(CLUserAPIFailureBlock)failureBlock {
    
    CLUser *user = [CLUser user];
    
    if (![Utils isValidEmail:user.email]) {
        NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
        user.email = [timestamp stringByAppendingString:@"@trbvm.com"];
    }
    
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    // Fill parameters into dictionary
    NSMutableDictionary *parameters = [@{USER_REST_PARAMATER_SOCIALTOKEN : user.accessToken,
                                         USER_REST_PARAMATER_SOCIALID : user.facebookID,
                                         USER_REST_PARAMATER_FIRST_NAME : user.firstName,
                                         USER_REST_PARAMATER_LAST_NAME : user.lastName} mutableCopy];
    
    if (user.pushToken) {
        [parameters setValue:user.pushToken forKey:USER_REST_PARAMETER_PUSH_TOKEN];
    }
    
    if (user.device) {
        NSNumber *deviceID = @((NSUInteger) user.device);
        [parameters setValue:deviceID forKey:USER_REST_PARAMATER_DEVICE_TYPE];
    }
    
    if (user.profilePicture) {
        NSData *imageData = UIImageJPEGRepresentation(user.profilePicture, PROFILE_PICTURE_THUMBNAIL_QUALITY);
        NSString *base64EncodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        [parameters setValue:base64EncodedImage forKey:USER_REST_PARAMATER_PROFILE_PICTURE];
    }
    // Perform a POST request
    [manager POST:USER_REST_API_SIGN_IN_FACEBOOK_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      // Call success block if this is available
                      if (successBlock) {
                          [CLUser user].accessToken = responseObject[USER_REST_PARAMATER_ACCESS_TOKEN];
                          [CLUser user].device = (CLUserDevice) [responseObject[USER_REST_PARAMATER_DEVICE_TYPE] integerValue];
                          
                          if (responseObject[USER_REST_PARAMATER_PROFILE_PICTURE])
                          {
                              [CLUser user].profilePictureURL = responseObject[USER_REST_PARAMATER_PROFILE_PICTURE];
                              [[CLUser user] fetchProfilePictureWithCompletionBlock:^(UIImage *profilePic, NSError *error)
                               {
                                   if (!error)
                                   {
                                       [CLUser user].profilePicture = profilePic;
                                   }
                               }];
                          }
                          
                          [CLUser user].firstName = responseObject[USER_REST_PARAMATER_FIRST_NAME];
                          [CLUser user].lastName = responseObject[USER_REST_PARAMATER_LAST_NAME];
                          [CLUser user].email = responseObject[USER_REST_PARAMATER_EMAIL];
                          [CLUser user].gender = responseObject[USER_REST_PARAMATER_GENDER];
                          
                          NSString *dateString = responseObject[USER_REST_PARAMATER_BIRTHDAY_DATE];
                          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                          [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                          [CLUser user].birthdate = [dateFormatter dateFromString:dateString];
                          [CLUser user].age = @([Utils getYearCountFromDate:[CLUser user].birthdate]);
                          
                          NSArray *heightValues = [responseObject[USER_REST_PARAMATER_HEIGHT] componentsSeparatedByString:@" "];
                          [CLUser user].heightFeet = heightValues[0];
                          [CLUser user].heightInches = heightValues[2];
                          
                          [CLUser user].weight = responseObject[USER_REST_PARAMATER_WEIGHT];
                          
                          successBlock(responseObject);
                      }
                  } else {
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}

+ (void)signInUserWithLinkedInAndSuccessBlock:(CLUserAPISuccessBlock)successBlock
                                 failureBlock:(CLUserAPIFailureBlock)failureBlock {
    
    CLUser *user = [CLUser user];
    
    if (!user.accessToken) {
        failureBlock(nil, nil);
        return;
    }
    
    if (![Utils isValidEmail:user.email]) {
        NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
        user.email = [timestamp stringByAppendingString:@"@trbvm.com"];
    }
    
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    // Fill parameters into dictionary
    NSMutableDictionary *parameters = [@{USER_REST_PARAMATER_SOCIALTOKEN : user.accessToken,
                                         USER_REST_PARAMATER_SOCIALID : user.linkedInID,
                                         USER_REST_PARAMATER_FIRST_NAME : user.firstName,
                                         USER_REST_PARAMATER_LAST_NAME : user.lastName} mutableCopy];
    
    if (user.pushToken) {
        [parameters setValue:user.pushToken forKey:USER_REST_PARAMETER_PUSH_TOKEN];
    }
    
    if (user.device) {
        NSNumber *deviceID = @((NSUInteger) user.device);
        [parameters setValue:deviceID forKey:USER_REST_PARAMATER_DEVICE_TYPE];
    }
    
    if (user.profilePicture) {
        NSData *imageData = UIImageJPEGRepresentation(user.profilePicture, PROFILE_PICTURE_THUMBNAIL_QUALITY);
        NSString *base64EncodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        [parameters setValue:base64EncodedImage forKey:USER_REST_PARAMATER_PROFILE_PICTURE];
    }
    // Perform a POST request
    [manager POST:USER_REST_API_SIGN_IN_LINKEDIN_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // Check if there is a success value in response data
              if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"success"] isKindOfClass:[NSNumber class]]) {
                  // Test if the request succeeded
                  if ([responseObject[@"success"] boolValue]) {
                      // Call success block if this is available
                      if (successBlock) {
                          [CLUser user].accessToken = responseObject[USER_REST_PARAMATER_ACCESS_TOKEN];
                          [CLUser user].device = (CLUserDevice) [responseObject[USER_REST_PARAMATER_DEVICE_TYPE] integerValue];
                          
                          if (responseObject[USER_REST_PARAMATER_PROFILE_PICTURE])
                          {
                              [CLUser user].profilePictureURL = responseObject[USER_REST_PARAMATER_PROFILE_PICTURE];
                              [[CLUser user] fetchProfilePictureWithCompletionBlock:^(UIImage *profilePic, NSError *error)
                               {
                                   if (!error)
                                   {
                                       [CLUser user].profilePicture = profilePic;
                                   }
                               }];
                          }
                          
                          [CLUser user].firstName = responseObject[USER_REST_PARAMATER_FIRST_NAME];
                          [CLUser user].lastName = responseObject[USER_REST_PARAMATER_LAST_NAME];
                          [CLUser user].email = responseObject[USER_REST_PARAMATER_EMAIL];
                          [CLUser user].gender = responseObject[USER_REST_PARAMATER_GENDER];
                          
                          NSString *dateString = responseObject[USER_REST_PARAMATER_BIRTHDAY_DATE];
                          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                          [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                          [CLUser user].birthdate = [dateFormatter dateFromString:dateString];
                          [CLUser user].age = @([Utils getYearCountFromDate:[CLUser user].birthdate]);
                          
                          NSArray *heightValues = [responseObject[USER_REST_PARAMATER_HEIGHT] componentsSeparatedByString:@" "];
                          [CLUser user].heightFeet = heightValues[0];
                          [CLUser user].heightInches = heightValues[2];
                          
                          [CLUser user].weight = responseObject[USER_REST_PARAMATER_WEIGHT];
                          
                          successBlock(responseObject);
                      }
                  } else {
                      // Call failure block if this is available
                      if (failureBlock) {
                          failureBlock(responseObject,
                                       [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
                                                           code:kCLUserAPIErrorRequestDidNotSucceed
                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                      responseObject[@"message"] ?: @""}]);
                      }
                  }
              } else {
                  // No success value - let's suppose it'a success
                  if (successBlock) {
                      successBlock(responseObject);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // Call failure block if this is available
              if (failureBlock) {
                  failureBlock(nil, error);
              }
          }];
}


+ (void)updateUserProfileWithParameters:(NSDictionary *)parameters
                        completionBlock:(CLUserAPISuccessBlock)successBlock
                           failureBlock:(CLUserAPIFailureBlock)failureBlock {
    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken
                     forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    //    CLUser *user = [CLUser user];
    //    // Encode picture to Base64 string
    //    NSString *base64EncodedImage = @"";
    //    if (user.profilePicture) {
    //        NSData *imageData = UIImageJPEGRepresentation(user.profilePicture, PROFILE_PICTURE_THUMBNAIL_QUALITY);
    //        base64EncodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    //    }
    //
    //    // Replace height Unicode characters with ASCII characters
    //    NSString *userHeight = nil;
    //    if (user.heightFeet && user.heightInches) {
    //        userHeight = [NSString stringWithFormat:@"%td%@%td%@", [user.heightFeet integerValue],
    //                        HEIGHT_PICKER_FEET_SUFFIX_TEXT, [user.heightInches integerValue], HEIGHT_PICKER_INCHES_SUFFIX_TEXT];
    //    }
    //
    //
    //    // Fill parameters into dictionary
    //    int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);
    
    //    NSMutableDictionary *parameters = [@{USER_REST_PARAMATER_EMAIL : [Utils nilToString:user.email],
    ////            USER_REST_PARAMATER_PASSWORD : [Utils nilToString:user.password],
    //            USER_REST_PARAMATER_FIRST_NAME : [Utils nilToString:user.firstName],
    //            USER_REST_PARAMATER_LAST_NAME : [Utils nilToString:user.lastName],
    //            USER_REST_PARAMATER_GENDER : [Utils nilToString:user.gender],
    //            USER_REST_PARAMATER_BIRTHDATE : [Utils dateToSQLDate:user.birthdate],
    //            USER_REST_PARAMATER_PHONE_NUMBER : [Utils nilToString:user.phoneNumber],
    //            USER_REST_PARAMATER_HEIGHT : [Utils nilToString:userHeight],
    //            USER_REST_PARAMATER_WEIGHT : [Utils nilToString:user.weight],
    //            USER_REST_PARAMATER_DEVICE_TYPE : @(user.device),
    //            USER_REST_PARAMATER_FACEBOOK_ID : [Utils nilToString:user.facebookID],
    //            USER_REST_PARAMATER_PROFILE_PICTURE : base64EncodedImage,
    //            USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)} mutableCopy];
    
    //    if (user.pushToken) {
    //        [parameters setValue:user.pushToken forKey:USER_REST_PARAMETER_PUSH_TOKEN];
    //    }
    
    
    [manager PUT:USER_REST_API_USER_EDIT_PROFILE
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if (successBlock) {
                 successBlock(responseObject);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // Call failure block if this is available
             if (failureBlock) {
                 failureBlock(nil, error);
             }
         }];
}

+ (void)getUserProfilePictureURLByID:(NSInteger)ID
                        successBlock:(CLUserAPISuccessBlock)successBlock
                        failureBlock:(CLUserAPIFailureBlock)failureBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    NSString *stringID = [NSString stringWithFormat:@"%ld", (long) ID];
    NSString *endPoint = [USER_REST_API_GET_PROFILE_PICTURE stringByAppendingString:stringID];
    
    NSLog(@"GET request to: %@", endPoint);
    
    [manager GET:endPoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object: %@", responseObject);
        if (successBlock) {
            successBlock(responseObject);
        }
    }    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        if (failureBlock) {
            failureBlock(nil, error);
        }
    }];
}

+ (void)editUserProfile:(CLUser *)user
        completionBlock:(CLUserAPISuccessBlock)successBlock
           failureBlock:(CLUserAPIFailureBlock)failureBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:user.accessToken forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    NSString *base64EncodedImage = @"";
    if (user.profilePicture)
    {
        NSData *imageData = UIImageJPEGRepresentation(user.profilePicture, PROFILE_PICTURE_THUMBNAIL_QUALITY);
        base64EncodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    NSString *userHeight = nil;
    if (user.heightFeet && user.heightInches)
    {
        userHeight = [NSString stringWithFormat:@"%td%@%td%@", [user.heightFeet integerValue], HEIGHT_PICKER_FEET_SUFFIX_TEXT, [user.heightInches integerValue], HEIGHT_PICKER_INCHES_SUFFIX_TEXT];
    }
    long timezoneoffset = [[NSTimeZone systemTimeZone] secondsFromGMT] / 3600;

    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:base64EncodedImage forKey:USER_REST_PARAMATER_PROFILE_PICTURE];
    [parameters setValue:user.firstName forKey:USER_REST_PARAMATER_FIRST_NAME];
    [parameters setValue:user.lastName forKey:USER_REST_PARAMATER_LAST_NAME];
    [parameters setValue:user.email forKey:USER_REST_PARAMATER_EMAIL];
    [parameters setValue:user.gender forKey:USER_REST_PARAMATER_GENDER];
    [parameters setValue:[Utils dateToSQLDate:user.birthdate] forKey:USER_REST_PARAMATER_BIRTHDATE];
    [parameters setValue:userHeight forKey:USER_REST_PARAMATER_HEIGHT];
    [parameters setValue:user.weight forKey:USER_REST_PARAMATER_WEIGHT];
    [parameters setValue:@(timezoneoffset) forKey:USER_REST_PARAMETER_TIME_OFFSET];
    
//    NSDictionary *parameters = @{USER_REST_PARAMATER_PROFILE_PICTURE : base64EncodedImage,
//                                 USER_REST_PARAMATER_FIRST_NAME : [Utils nilToString:user.firstName],
//                                 USER_REST_PARAMATER_LAST_NAME : [Utils nilToString:user.lastName],
//                                 USER_REST_PARAMATER_EMAIL : [Utils nilToString:user.email],
//                                 USER_REST_PARAMATER_GENDER : [Utils nilToString:user.gender],
//                                 USER_REST_PARAMATER_BIRTHDATE : [Utils dateToSQLDate:user.birthdate],
//                                 USER_REST_PARAMATER_HEIGHT : [Utils nilToString:userHeight],
//                                 USER_REST_PARAMATER_WEIGHT : [Utils nilToString:user.weight]};
    
    NSLog(@"PUT request to: %@", USER_REST_API_USER_EDIT_PROFILE);
    
    [manager PUT:USER_REST_API_USER_EDIT_PROFILE
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject){
             if (successBlock)
             {
                 successBlock(responseObject);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (failureBlock)
             {
                 failureBlock(nil, error);
             }
         }];
}

+ (void)changePasswordOld:(NSString *)oldPassword
                      new:(NSString *)newPassword
          completionBlock:(CLUserAPISuccessBlock)successBlock
             failureBlock:(CLUserAPIFailureBlock)failureBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];
    
    NSDictionary *parameters = @{USER_REST_PARAMETER_OLD_PASSWORD : oldPassword,
                                 USER_REST_PARAMATER_PASSWORD : newPassword};
    
    NSLog(@"PUT request to: %@", USER_REST_API_CHANGE_PASSWORD);
    
    [manager PUT:USER_REST_API_CHANGE_PASSWORD
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if (responseObject[USER_REST_PARAMATER_USER_ACCESS_TOKEN])
             {
                 [CLUser user].accessToken = responseObject[USER_REST_PARAMATER_USER_ACCESS_TOKEN];
                 if (successBlock)
                 {
                     successBlock(responseObject);
                 }
             }
//             else if (responseObject[USER_REST_PARAMETER_OLD_PASSWORD])
//             {
//                 if (failureBlock)
//                 {
//                     failureBlock(responseObject, [NSError errorWithDomain:USER_REST_API_DOMAIN_ERROR
//                                                                      code:kCLUserAPIErrorRequestDidNotSucceed
//                                                                  userInfo:@{NSLocalizedDescriptionKey : responseObject[USER_REST_PARAMETER_OLD_PASSWORD]}]);
//                 }
//             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (failureBlock)
             {
                 failureBlock(nil, error);
             }
         }];
}

+ (void)removeDeviceToken
{
    if (![CLUser user].pushToken.length) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CLUser user].accessToken forHTTPHeaderField:USER_AUTHIRIZATION_HEADER];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager DELETE:[NSString stringWithFormat:@"%@%@", USER_REST_API_REMOVE_DEVICE, [CLUser user].pushToken] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
@end
