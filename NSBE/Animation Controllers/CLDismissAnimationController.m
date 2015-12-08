//
//  CLDismissAnimationController.m
//  NSBE
//

#import "CLDismissAnimationController.h"

@implementation CLDismissAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    [[transitionContext containerView] addSubview:toViewController.view];
//    [[transitionContext containerView] sendSubviewToBack:toViewController.view];
//    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect finalFrame = CGRectOffset(fromViewController.view.frame, 0, screenBounds.size.height);
    
    UIView *imageView = [[toViewController.view subviews] lastObject];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         fromViewController.view.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
//                         [fromViewController.view removeFromSuperview];
                         [UIView animateWithDuration:[self transitionDuration:transitionContext]
                                          animations:^{
                                              imageView.alpha = 0.0;
                                          }
                                          completion:^(BOOL finished) {
                                              [imageView removeFromSuperview];
                                              [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                                          }];
                     }];
}

@end
