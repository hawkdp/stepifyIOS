//
//  CLRulesShowAnimationController.m
//  UPMC
//

#import "CLRulesShowAnimationController.h"
#import "UIImage+ImageEffects.h"

@implementation CLRulesShowAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);
    
    UIImage *image = [self blurWithImageEffects:[self takeSnapshotOfView:fromViewController.view]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:fromViewController.view.frame];
    imageView.image = image;
    
    [fromViewController.view addSubview:imageView];
    imageView.alpha = 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         imageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:[self transitionDuration:transitionContext]
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              toViewController.view.frame = finalFrame;
                                          }
                                          completion:^(BOOL finished) {
                                              [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                                          }];
                     }];
}

#pragma mark - Helpers

- (UIImage *)takeSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)blurWithImageEffects:(UIImage *)image
{
    return [image applyBlurWithRadius:5 tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.8] saturationDeltaFactor:1.5 maskImage:nil];
}

@end
