//
//  CLFadeAnimationController.m
//  NSBE
//

#import "CLFadeAnimationController.h"

@implementation CLFadeAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         fromViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:[self transitionDuration:transitionContext]
                                          animations:^{
                                              toViewController.view.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              fromViewController.view.alpha = 1.0;
                                              [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                                          }];
                     }];
}

@end
