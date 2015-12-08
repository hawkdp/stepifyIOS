//
//  CLSteps.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/10/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLSteps.h"
#import "CLUser+API.h"
#import "AFNetworking.h"
#import "CLFitbitOAuthHandler.h"
#import "Utils.h"
#import "CLHistoryManager.h"

@implementation CLSteps

#pragma mark - Private singletones

+ (void)healthStoreWithCompletion:(void (^)(BOOL success, HKHealthStore *healthStore, NSError *error))completion; {
    static HKHealthStore *healthStore;

    @synchronized (self) {

        if (!healthStore) {

            // Create a new instace of health store
            healthStore = [[HKHealthStore alloc] init];

            // Set read and write data types for HealthKit if available
            if ([HKHealthStore isHealthDataAvailable]) {
                NSSet *readDataTypes = [NSSet setWithObject:[HKObjectType
                        quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
                // Request authorization
                [healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:
                        ^(BOOL success, NSError *error) {

                            // Destroy health store instance if authorization has not been granted
                            if (!success) {
                                healthStore = nil;
                            }

                            // Call completion block if available
                            if (completion) {
                                completion(success, healthStore, error);
                            }
                        }];
            } else {

                // HealthData is not available, call completion block if available
                if (completion) {
                    completion(NO, nil, [NSError errorWithDomain:STEPS_RETRIEVAL_DOMAIN_ERROR
                                                            code:kCLStepsRetrievalErrorHealthDataNotAvailable
                                                        userInfo:@{NSLocalizedDescriptionKey :
                                                                NSLocalizedString(@"HealthDataNotAvailable", nil)}]);
                }
            }
        } else {

            // Call completion block if available
            if (completion) {
                completion(YES, healthStore, nil);
            }
        }
    }
}

+ (DTOAuthClient *)OAuthClient {
    static DTOAuthClient *OAuthClient;

    @synchronized (self) {

        if (!OAuthClient) {

            // Create a new instace of OAUth 1.0a
            OAuthClient = [[DTOAuthClient alloc] initWithConsumerKey:USER_FITBIT_CLIENT_KEY
                                                      consumerSecret:USER_FITBIT_CLIENT_SECRET];
            // Set OAuth client properties
            OAuthClient.requestTokenURL = [NSURL URLWithString:USER_FITBIT_REQUEST_TOKEN_URL];
            OAuthClient.accessTokenURL = [NSURL URLWithString:USER_FITBIT_ACCESS_TOKEN_URL];
            OAuthClient.userAuthorizeURL = [NSURL URLWithString:USER_FITBIT_AUTHORIZE_URL];

            // Load token and token secret from user defaults
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *tokenBase64 = [userDefaults objectForKey:kUserDefaultsFitbitTokenKey];
            NSString *tokenSecretBase64 = [userDefaults objectForKey:kUserDefaultsFitbitTokenSecretKey];

            // Only if we have token and token secret from user default, decode them Base64 and assign
            // to OAuth client
            if ([tokenBase64 length] != 0 && [tokenSecretBase64 length] != 0) {

                // Decode token and token secret
                OAuthClient.token = [Utils decodedBase64String:tokenBase64];
                OAuthClient.tokenSecret = [Utils decodedBase64String:tokenSecretBase64];
            }
        }
    }

    // Return OAuth 1.0a client
    return OAuthClient;
}

#pragma mark - Generic type steps retrieval method

+ (void)getStepsFromDate:(NSDate *)startDate
                  toDate:(NSDate *)endDate
                    from:(CLStepsFramework)framework
            successBlock:(CLStepsSuccessBlock)successBlock
            failureBlock:(CLStepsFailureBlock)failureBlock {
    // Sanity check
    if (!startDate || !endDate) {

        // Call failure block if this is available
        if (failureBlock) {
            failureBlock(nil, [NSError errorWithDomain:STEPS_RETRIEVAL_DOMAIN_ERROR
                                                  code:kCLStepsRetrievalErrorDateNotProvided
                                              userInfo:@{NSLocalizedDescriptionKey :
                                                      NSLocalizedString(@"StartEndDateNotProvided", nil)}]);
        }
        return;
    }
    [[CLUser user].stepsForDay removeAllObjects];
    [[CLUser user].stepsForDayWithoutLimit removeAllObjects];
    // Call specific type steps retrieval method
    switch (framework) {
        case kCLStepsFrameworkHealthKit: {
            [CLSteps getHealthKitStepsFromDate:startDate toDate:endDate successBlock:successBlock failureBlock:failureBlock];
            break;
        }
        case kCLStepsFrameworkFitbit: {
            [CLSteps getFitbitStepsFromDate:startDate toDate:endDate successBlock:successBlock failureBlock:failureBlock];
            break;
        }
        case kCLStepsFrameworkJawbone: {
            [CLSteps getJawboneStepsFromDate:startDate toDate:endDate retryCount:1 successBlock:successBlock
                                failureBlock:failureBlock];
            break;
        }
        case kCLStepsFrameworkNone: {
            // Call failure block if this is available
            if (failureBlock) {
                failureBlock(nil, [NSError errorWithDomain:STEPS_RETRIEVAL_DOMAIN_ERROR
                                                      code:kCLStepsRetrievalErrorFrameworkNotProvided
                                                  userInfo:@{NSLocalizedDescriptionKey :
                                                          NSLocalizedString(@"FrameworkNotProvided", nil)}]);
            }
            break;
        }
    }
}

#pragma mark - Sepcific type steps retrieval methods

+ (void)getHealthKitStepsFromDate:(NSDate *)startDate
                           toDate:(NSDate *)endDate
                     successBlock:(CLStepsSuccessBlock)successBlock
                     failureBlock:(CLStepsFailureBlock)failureBlock {

    [CLSteps pullStepsDataFromHealthKitForStartDate:startDate
                                         andEndDate:endDate
                                       successBlock:successBlock
                                       failureBlock:failureBlock];

}

+ (void)getFitbitStepsFromDate:(NSDate *)startDate
                        toDate:(NSDate *)endDate
                  successBlock:(CLStepsSuccessBlock)successBlock
                  failureBlock:(CLStepsFailureBlock)failureBlock {
    // Get OAuth 1.0a client
    DTOAuthClient *OAuthClient = [CLSteps OAuthClient];

    // Check if we have user's token and token secret
    if ([OAuthClient.token length] != 0 && [OAuthClient.tokenSecret length] != 0) {

        // We have user's tokens, pull user steps data for dates
        [CLSteps pullStepsDataFromFitbitFromDate:startDate toDate:endDate successBlock:successBlock failureBlock:failureBlock];

    } else {

        // Request user authorization
        __block CLFitbitOAuthHandler *fitbitOAuthHandler =
                [CLFitbitOAuthHandler authorizeUserWithClient:[CLSteps OAuthClient] successBlock:
                        ^(DTOAuthClient *OAuthClient, NSString *token, NSString *verifier) {

                            // User authorized
                            NSLog(@"user fitbit authorization success");

                            // Save token and token secret to user defaults encoded in Base64
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            [userDefaults setObject:[Utils encodedBase64String:OAuthClient.token] forKey:kUserDefaultsFitbitTokenKey];
                            [userDefaults setObject:[Utils encodedBase64String:OAuthClient.tokenSecret]
                                             forKey:kUserDefaultsFitbitTokenSecretKey];
                            [userDefaults synchronize];

                            // Pull user steps data for dates
                            [CLSteps pullStepsDataFromFitbitFromDate:startDate toDate:endDate successBlock:successBlock failureBlock:failureBlock];

                            // Release fitbit OAuth handler
                            fitbitOAuthHandler = nil;

                        }                        failureBlock:^(DTOAuthClient *OAuthClient, NSError *error) {

                    NSLog(@"user fitbit authorization failure: %@", [error localizedDescription]);

                    // Call failure block if this is available
                    if (failureBlock) {
                        failureBlock(nil, error);
                    }

                    // Release fitbit OAuth handler
                    fitbitOAuthHandler = nil;
                }];
    }
}

+ (void)getJawboneStepsFromDate:(NSDate *)startDate
                         toDate:(NSDate *)endDate
                     retryCount:(NSInteger)retryCount
                   successBlock:(CLStepsSuccessBlock)successBlock
                   failureBlock:(CLStepsFailureBlock)failureBlock {
    // Auhtorize the user
    [[UPPlatform sharedPlatform] startSessionWithClientID:USER_JAWBONE_CLIENT_KEY
                                             clientSecret:USER_JAWBONE_CLIENT_SECRET
                                                authScope:(UPPlatformAuthScopeExtendedRead | UPPlatformAuthScopeMoveRead)
                                              redirectURI:USER_JAWBONE_CALLBACK_URI
                                               completion:
                                                       ^(UPSession *session, NSError *error) {

                                                           // Check if you have a session
                                                           if (session && !error) {

                                                               // Validate the session
                                                               [[UPPlatform sharedPlatform] validateSessionWithCompletion:^(UPSession *session, NSError *error) {

                                                                   // Check for errors
                                                                   if (session && !error) {

                                                                       // User authorized and the session is valid, proceed to steps data pulling
                                                                       [CLSteps pullStepsDataFromJawboneFromDate:startDate toDate:endDate successBlock:successBlock
                                                                                                    failureBlock:failureBlock];
                                                                   } else {

                                                                       // Session is invalied or an error has occured, try again if retry count if greater than 0
                                                                       if (retryCount > 0) {

                                                                           NSLog(@"jawbone session failed: %@\n%td retries left", error, retryCount);

                                                                           [CLSteps getJawboneStepsFromDate:startDate toDate:endDate retryCount:retryCount - 1
                                                                                               successBlock:successBlock failureBlock:failureBlock];
                                                                       } else {

                                                                           NSLog(@"jawbone session failed multiple times: %@", error);

                                                                           // No more retries left, call failure block if this is available
                                                                           if (failureBlock) {
                                                                               failureBlock(session, error);
                                                                           }
                                                                       }
                                                                   }
                                                               }];
                                                           } else {

                                                               NSLog(@"no active jawbone session: %@", error);

                                                               // No active session, call failure block if this is available
                                                               if (failureBlock) {
                                                                   failureBlock(session, error);
                                                               }
                                                           }
                                                       }];
}

#pragma mark - HealthKit helper methods

+ (void)pullStepsDataFromHealthKitForStartDate:(NSDate *)startDate
                                    andEndDate:(NSDate *)endDate
                                  successBlock:(CLStepsSuccessBlock)successBlock
                                  failureBlock:(CLStepsFailureBlock)failureBlock {
    // Get health store
    [CLSteps healthStoreWithCompletion:^(BOOL success, HKHealthStore *healthStore, NSError *error) {

        if (success) {

            [[CLUser user] setZeroStepsForStartDate:startDate
                                             toDate:endDate];
            
            NSDateComponents *interval = [[NSDateComponents alloc] init];
            interval.hour = 1;
            
            HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            
            // Create the query
            HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                                   quantitySamplePredicate:nil
                                                                                                   options:HKStatisticsOptionCumulativeSum
                                                                                                anchorDate:startDate
                                                                                        intervalComponents:interval];
            
            // Set the results handler
            query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
                if (error) {
                    // Perform proper error handling here
                    NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
                }
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
                
                __block NSDate *stepsActivityDate = query.anchorDate;
                __block double sumOfStepsPerDay = 0;
                __block double sumOfStepsPerDayWithoutLimit = 0;
                
                __block NSString *dateString = [dateFormatter stringFromDate:stepsActivityDate];
                
                NSMutableArray *stepsArray = [NSMutableArray array];
                
                NSMutableDictionary *totalStepsForDay = [NSMutableDictionary dictionary];
                NSMutableDictionary *totalStepsForDayWithoutLimit = [NSMutableDictionary dictionary];
                
                NSDate *endDate = [NSDate date];
                
                [results enumerateStatisticsFromDate:startDate
                                              toDate:endDate
                                           withBlock:^(HKStatistics *result, BOOL *stop) {
                                               
                                               HKQuantity *quantity = result.sumQuantity;
                                               if (quantity)
                                               {
                                                   NSDate *newDate = result.startDate;

                                                   if (![Utils isDate:stepsActivityDate sameDayAsDate:newDate]) {
                                                       dateString = [dateFormatter stringFromDate:newDate];
                                                       stepsActivityDate = result.startDate;

                                                       sumOfStepsPerDay = 0;
                                                       sumOfStepsPerDayWithoutLimit = 0;
                                                   }
                                                   
                                                   NSNumber *stepsForHour = @([quantity doubleValueForUnit:[HKUnit countUnit]]);
                                                   NSDate *dateWithHours = result.startDate;
                                                   
                                                   sumOfStepsPerDay += stepsForHour.integerValue;
                                                   sumOfStepsPerDayWithoutLimit += stepsForHour.integerValue;
                                                   
                                                   if (sumOfStepsPerDay >= [CLUser user].maxSteps.integerValue)
                                                   {
                                                       sumOfStepsPerDay = [CLUser user].maxSteps.integerValue;
                                                   }
                                            
                                                   if (stepsArray.count == [[[CLHistoryManager sharedManager] numberOfHoursForObserve] integerValue] || [[[CLHistoryManager sharedManager] numberOfHoursForObserve] integerValue] == 0)
                                                   {
                                                       [stepsArray removeObject:stepsArray.firstObject];
                                                   }
                                                   
                                                   [stepsArray addObject:stepsForHour];
                                                   
                                                   [[CLHistoryManager sharedManager] checkStepsArray:stepsArray];
                                                   
                                                   [totalStepsForDay setValue:@(sumOfStepsPerDay) forKey:dateString];
                                                   [totalStepsForDayWithoutLimit setValue:@(sumOfStepsPerDayWithoutLimit) forKey:dateString];
                                                   
                                                   NSLog(@"\n%@ steps in %@", stepsForHour, dateWithHours);
                                               }
                                           }];
                [[CLUser user] updateStepsDataWithDictionary:totalStepsForDay];
                [[CLUser user] updateStepsForDayWithoutLimit:totalStepsForDayWithoutLimit];
                successBlock(@[]);
            };
            
            [healthStore executeQuery:query];
        } else {

            // Call failure block if this is available
            if (failureBlock) {
                failureBlock(nil, error);
            }
        }
    }];
}

#pragma mark - Fitbit helper methods

+ (void)pullStepsDataFromFitbitFromDate:(NSDate *)startDate
                                 toDate:(NSDate *)endDate
                           successBlock:(CLStepsSuccessBlock)successBlock
                           failureBlock:(CLStepsFailureBlock)failureBlock {
    // Get OAUth 1.0a client
    DTOAuthClient *OAuthClient = [CLSteps OAuthClient];

    // Create URL for requesting user steps
    // https://api.fitbit.com/1/user/-/activities/steps/date/2015-02-19/2015-02-23.json
    NSString *stringURL = USER_FITBIT_STEPS_API_URL;
    stringURL = [stringURL stringByReplacingOccurrencesOfString:USER_APP_URL_PARAMETER_START_DATE
                                                     withString:[Utils dateToSQLDate:startDate]];
    stringURL = [stringURL stringByReplacingOccurrencesOfString:USER_APP_URL_PARAMETER_END_DATE
                                                     withString:[Utils dateToSQLDate:endDate]];
    // Create URL request
    NSURL *url = [NSURL URLWithString:stringURL];
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:url];
    [URLRequest addValue:[OAuthClient authenticationHeaderForRequest:URLRequest] forHTTPHeaderField:@"Authorization"];

    // Create request manager and set it's request and response type
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    // Remove NULL values
    [(AFJSONResponseSerializer *) manager.responseSerializer setRemovesKeysWithNullValues:YES];

    // Make the HTTP request
    [[manager HTTPRequestOperationWithRequest:URLRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {

        // Check request status code
        if (operation.response.statusCode == 200) {

            NSLog(@"pull steps data from fitbit success: %@", responseObject);

            // 200 OK
            // Get steps array
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[USER_REST_PARAMATER_ACTIVITIES_STEPS] && [responseObject[USER_REST_PARAMATER_ACTIVITIES_STEPS] isKindOfClass:[NSArray class]]) {

                [[CLUser user] setZeroStepsForStartDate:startDate
                                                 toDate:endDate];
                
                NSMutableArray *activitiesStepsArray = [responseObject[USER_REST_PARAMATER_ACTIVITIES_STEPS] mutableCopy];

                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
                
                __block NSDate *stepsActivityDate = [dateFormatter dateFromString:[activitiesStepsArray firstObject][@"dateTime"]];
                __block double sumOfStepsPerDay = 0;
                __block double sumOfStepsPerDayWithoutLimit = 0;
                
                NSMutableDictionary *stepsDict = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *stepsWithoutLimitDict = [[NSMutableDictionary alloc] init];
                
                [activitiesStepsArray enumerateObjectsUsingBlock:^(NSDictionary *fitbitStepActivityObject, NSUInteger idx, BOOL *stop) {
                    
                    if (![Utils isDate:stepsActivityDate sameDayAsDate:[dateFormatter dateFromString:fitbitStepActivityObject[@"dateTime"]]]) {
                        stepsActivityDate             = [dateFormatter dateFromString:fitbitStepActivityObject[@"dateTime"]];
                        
                        sumOfStepsPerDay              = [fitbitStepActivityObject[@"value"] doubleValue];
                        sumOfStepsPerDayWithoutLimit  = [fitbitStepActivityObject[@"value"] doubleValue];
                    }
                    else
                    {
                        sumOfStepsPerDay              += [fitbitStepActivityObject[@"value"] doubleValue];
                        sumOfStepsPerDayWithoutLimit  += [fitbitStepActivityObject[@"value"] doubleValue];
                    }
                    
                    if (sumOfStepsPerDay >= [CLUser user].maxSteps.doubleValue)
                    {
                        sumOfStepsPerDay = [CLUser user].maxSteps.doubleValue;
                    }
                    
                    NSString *dateString = [dateFormatter stringFromDate:stepsActivityDate];
                    [stepsDict setValue:@(sumOfStepsPerDay) forKey:dateString];
                    [stepsWithoutLimitDict setValue:@(sumOfStepsPerDayWithoutLimit) forKey:dateString];
                }];
                
                [[CLUser user] updateStepsDataWithDictionary:stepsDict];
                [[CLUser user] updateStepsForDayWithoutLimit:stepsWithoutLimitDict];
                
                // Call success block if this is available
                if (successBlock) {
                    successBlock(@[]);
                }
            } else {

                // Incorrect data type, call failure block if this is available
                if (failureBlock) {
                    failureBlock(responseObject, [NSError errorWithDomain:STEPS_RETRIEVAL_DOMAIN_ERROR
                                                                     code:kCLStepsRetrievalErrorIncorrectDataType
                                                                 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"IncorrectDataType", nil)}]);
                }
            }
        } else {

            // Unknown status code, call failure block if this is available
            if (failureBlock) {
                failureBlock(responseObject, [NSError errorWithDomain:STEPS_RETRIEVAL_DOMAIN_ERROR
                                                                 code:kCLStepsRetrievalErrorUnknownStatusCode
                                                             userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"UnknownStatusCode", nil)}]);
            }
        }
    }                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        // Check request status code
        if (operation.response.statusCode == 401) {

            NSLog(@"pull steps data from fitbit failure: %@\ntoken and token secret are incorrect or expired, clear them and "
                    "request user authorization again", error);

            // 401 Unauthorized HTTP responses
            // Token and token secret are incorrect or expired, clear them and request user authorization again
            [[CLSteps OAuthClient] setToken:nil];
            [[CLSteps OAuthClient] setTokenSecret:nil];
            [CLSteps getFitbitStepsFromDate:startDate toDate:endDate successBlock:successBlock failureBlock:failureBlock];
        } else {

            NSLog(@"pull steps data from fitbit failure: %@", error);

            // Other error, call failure block if this is available
            if (failureBlock) {
                failureBlock(nil, error);
            }
        }
    }] start];
}

#pragma mark - Jawbone helper methods

+ (void)pullStepsDataFromJawboneFromDate:(NSDate *)startDate
                                  toDate:(NSDate *)endDate
                            successBlock:(CLStepsSuccessBlock)successBlock
                            failureBlock:(CLStepsFailureBlock)failureBlock {
    NSDateComponents *startDateComps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                                       fromDate:startDate];

    NSDate *startDateWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:startDateComps];
    // Get moves from start date to end date

//    int startTimestamp = (int) [startDate timeIntervalSince1970];
//    int endTimestamp = (int) [endDate timeIntervalSince1970];
//
//    NSDictionary *params = @{
//            @"start_time": @(startTimestamp),
//            @"end_time": @(endTimestamp)
//    };
//
//    UPURLRequest *request = [UPURLRequest getRequestWithEndpoint:@"nudge/api/v.1.1/users/@me/moves"
//                                                           params:params];
//
//    [[UPPlatform sharedPlatform] sendRequest:request
//                                  completion:^(UPURLRequest *request, UPURLResponse *response, NSError *error) {
//                                      NSLog(@"%@", response.data);
//                                  }];

    [UPMoveAPI getMovesFromStartDate:startDate toEndDate:endDate completion:^(NSArray *results, UPURLResponse *response, NSError *error) {

        static NSString *keyItems        = @"items";
        static NSString *keyDetails      = @"details";
        static NSString *keyDate         = @"date";
        static NSString *keyHourlyTotals = @"hourly_totals";
        static NSString *keySteps        = @"steps";
        
        if (!error) {
        
            [[CLUser user] setZeroStepsForStartDate:startDateWithoutTime
                                             toDate:endDate];
            
            NSArray *arrayOfSteps = response.data[keyItems];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            
            NSDateFormatter *dateFormatterForHours = [[NSDateFormatter alloc] init];
            [dateFormatterForHours setDateFormat:@"yyyyMMddHH"];
            
            NSDateFormatter *dateFormatterCorrect = [[NSDateFormatter alloc] init];
            [dateFormatterCorrect setDateFormat:@"yyyy-MM-dd 00:00:00"];
            
            NSDate *firstDate = [dateFormatter dateFromString:[[arrayOfSteps firstObject][keyDate] stringValue]];
            
            NSString *dateString = [dateFormatterCorrect stringFromDate:firstDate];

            NSMutableDictionary *totalStepsForDay = [NSMutableDictionary dictionary];
            NSMutableDictionary *totalStepsForDayWithoutLimit = [NSMutableDictionary dictionary];

            for (NSDictionary *stepsDict in arrayOfSteps) {
                NSDate *newDate = [dateFormatter dateFromString:[stepsDict[keyDate] stringValue]];
                
                if (![Utils isDate:firstDate sameDayAsDate:newDate]) {
                    dateString = [dateFormatterCorrect stringFromDate:newDate];
                }
                
                NSArray *allKeys = [stepsDict[keyDetails][keyHourlyTotals] allKeys]; //key = hour
                allKeys = [allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]]; //sorting from lower to higher value
                
                NSInteger sumOfStepsPerDay = 0;
                NSInteger sumOfStepsPerDayWithoutLimit = 0;
                NSMutableArray *stepsArray = [NSMutableArray array];
                
                for (int i = 0; i < allKeys.count; i++) { //getting steps/hour
                    NSDictionary *hourlyStepsDict = [stepsDict[keyDetails][keyHourlyTotals] objectForKey:allKeys[i]];
                    NSNumber *stepsForHour = hourlyStepsDict[keySteps];
                    NSDate *dateWithHours = [dateFormatterForHours dateFromString:allKeys[i]];
                    
                    sumOfStepsPerDay += stepsForHour.integerValue;
                    sumOfStepsPerDayWithoutLimit += stepsForHour.integerValue;
                    
                    if (sumOfStepsPerDay >= [CLUser user].maxSteps.integerValue)
                    {
                        sumOfStepsPerDay = [CLUser user].maxSteps.integerValue;
                    }

                    if (stepsArray.count == [[[CLHistoryManager sharedManager] numberOfHoursForObserve] integerValue] || [[[CLHistoryManager sharedManager] numberOfHoursForObserve] integerValue] == 0)
                    {
                        [stepsArray removeObject:stepsArray.firstObject];
                    }
                    
                    [stepsArray addObject:stepsForHour];

                    [[CLHistoryManager sharedManager] checkStepsArray:stepsArray];
                    
                }
                [totalStepsForDay setValue:@(sumOfStepsPerDay) forKey:dateString];
                [totalStepsForDayWithoutLimit setValue:@(sumOfStepsPerDayWithoutLimit) forKey:dateString];
            }
            
            [[CLUser user] updateStepsDataWithDictionary:totalStepsForDay];
            [[CLUser user] updateStepsForDayWithoutLimit:totalStepsForDayWithoutLimit];
            
            // Call success block if this is available
            if (successBlock) {
                successBlock(nil);
            }
        
        } else {
            NSLog(@"pull steps data from jawbone failure: %@", error);
            // An error has occurred, call failure block if this is available
            if (failureBlock) {
                failureBlock(response, error);
            }
        }
    }];
}

@end
