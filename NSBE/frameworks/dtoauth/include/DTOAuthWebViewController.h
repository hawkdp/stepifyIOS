//
//  WebViewController.h
//  OAuthTest
//
//  Created by Oliver Drobnik on 6/20/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTOAuthWebViewController;

@protocol OAuthResultDelegate <NSObject>

@required

/**
 Method for informing the delegate that authorization was denied by the user
 */
- (void)authorizationWasDenied:(DTOAuthWebViewController *)webViewController;

/**
 Method for informing the delegate that authorization was granted by the user
 */
- (void)authorizationWasGranted:(DTOAuthWebViewController *)webViewController forToken:(NSString *)token withVerifier:(NSString *)verifier;

@optional

/**
 Method for informing the delegate that authorization web view did start loading the page
 */
- (void)authWebViewControllerDidStartLoad:(DTOAuthWebViewController *)webViewController;

/**
 Method for informing the delegate that authorization web view did finish loading the page
 */
- (void)authWebViewControllerDidFinishLoad:(DTOAuthWebViewController *)webViewController;

@end


/**
 View controller with a `UIWebView` as main view. Meant to be embedded in a navigation controller for modal presentation.
 */
@interface DTOAuthWebViewController : UIViewController  <UIWebViewDelegate>

// delegate to inform about the authorization result
@property (nonatomic, weak) id <OAuthResultDelegate> authorizationDelegate;

/**
 Load the authorization form with a proper OAuth request, this is the request you get from step 2 in DTOAuthClient.
 */
- (void)startAuthorizationFlowWithRequest:(NSURLRequest *)request completion:(void (^)(BOOL isAuthenticated, NSString *verifier))completion;

@end
