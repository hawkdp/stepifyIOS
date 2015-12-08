//
//  CLPushAnimationController.m
//  NSBE
//

#import "CLPushAnimationController.h"

@implementation CLPushAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    
    float factor = self.reverse ? -1.0 : 1.0;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect fromFinalFrame = CGRectOffset(fromViewController.view.frame, factor * -screenBounds.size.width, 0);
    
    CGRect toFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.frame = CGRectOffset(toFinalFrame, factor * screenBounds.size.width, 0);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         fromViewController.view.frame = fromFinalFrame;
                     }
                     completion:nil];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toViewController.view.frame = toFinalFrame;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
