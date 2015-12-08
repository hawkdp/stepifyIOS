//
//  CLActivitiesView.m
//  NSBE
//

#import "CLActivitiesView.h"

@interface CLActivitiesView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *activitiesLabel;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftGesture;

@property (nonatomic, assign) BOOL activityCardIsSwiping;
@property (nonatomic, assign) BOOL activityViewShouldBeUpdated;

@end

//#define BASE_COLOR [UIColor colorWithRed:89.0/255.0 green:133.0/255.0 blue:232.0/255.0 alpha:1.0]
#define BASE_COLOR [UIColor whiteColor]
#define ICON_BG_COLOR [UIColor colorWithRed:0.0/255.0 green:70.0/255.0 blue:114.0/255.0 alpha:1.0]
#define LABEL_COLOR [UIColor colorWithRed:48.0/255.0 green:55.0/255.0 blue:63.0/255.0 alpha:1.0]
#define LABEL_COLOR_SECOND [UIColor colorWithRed:100.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:1.0]

@implementation CLActivitiesView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //        _cardsCount = 8;
        self.activityCardIsSwiping = NO;
        self.activityViewShouldBeUpdated = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.cardsCount = [self.dataSource numberOfCardsInActivitiesView:self];
    
    self.bottomView = [self activityCardWithFrame:[self bottomViewRect]];
    [self addSubview:self.bottomView];
    
    if (self.cardsCount == 0)
    {
        self.topView = self.bottomView;
        self.middleView = nil;
        self.bottomView = nil;
        [self moveActivityCardUp:self.topView];
        [self moveActivityCardUp:self.topView];
    }
    else if (self.cardsCount == 1)
    {
        self.middleView = [self activityCardWithFrame:self.bottomView.frame];
        [self moveActivityCardUp:self.middleView];
        [self addSubview:self.middleView];
        self.topView = self.middleView;
        self.middleView = self.bottomView;
        self.bottomView = nil;
        [self moveActivityCardUp:self.topView];
        [self moveActivityCardUp:self.middleView];
    }
    else if (self.cardsCount > 1)
    {
        self.middleView = [self activityCardWithFrame:self.bottomView.frame];
        [self moveActivityCardUp:self.middleView];
        [self addSubview:self.middleView];
        self.topView = [self activityCardWithFrame:self.bottomView.frame];
        [self moveActivityCardUp:self.topView];
        [self moveActivityCardUp:self.topView];
        [self addSubview:self.topView];
    }
    
    self.swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeft:)];
    self.swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    if (self.cardsCount > 0)
    {
        [self.topView addGestureRecognizer:self.swipeLeftGesture];
    }
    
    [self updateTopCard];
    
    self.activitiesLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 84) / 2, 1, 84, 22)];
    self.activitiesLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:1.0];
    self.activitiesLabel.layer.cornerRadius = 11;
    self.activitiesLabel.clipsToBounds = YES;
    self.activitiesLabel.font = [UIFont fontWithName:@"Geomanist-Light" size:10.0];
    self.activitiesLabel.textColor = [UIColor whiteColor];
    self.activitiesLabel.textAlignment = NSTextAlignmentCenter;
    self.activitiesLabel.text = @"new activities";
    [self addSubview:self.activitiesLabel];
    self.activitiesLabel.hidden = NO;
    [self bringSubviewToFront:self.activitiesLabel];
}

- (void)updateTopCard
{
    if (self.cardsCount == 0)
    {
        ((UILabel *)self.topView.subviews[1]).hidden = YES;
        ((UILabel *)self.topView.subviews[2]).hidden = NO;
        ((UILabel *)self.topView.subviews[2]).text = @"No recent activities";
        ((UILabel *)self.topView.subviews[3]).hidden = NO;
        ((UILabel *)self.topView.subviews[3]).text = @"   MAKE THEM HAPPEN";
    }
    else
    {
        if ([self.dataSource backgroundShoudBeSet:self])
        {
            ((UIImageView *)self.topView.subviews[0]).backgroundColor = ICON_BG_COLOR;
        }
        else
        {
            ((UIImageView *)self.topView.subviews[0]).backgroundColor = [UIColor clearColor];
        }
        ((UIImageView *)self.topView.subviews[0]).image = [self.dataSource imageForTopCardInActivitiesView:self];
//        [self.dataSource imageForTopCardInActivitiesView:self completionBlock:^(UIImage *image) {
//            ((UIImageView *)self.topView.subviews[0]).image = image;
//        }];
//        ((UILabel *)self.topView.subviews[1]).text = [self.dataSource messageForTopCardInActivitiesView:self];
        NSInteger labelsCount = [self.dataSource numberOfSentencesForTopCardInActivitiesView:self];
        if (labelsCount == 1)
        {
            ((UILabel *)self.topView.subviews[1]).text = [self.dataSource messagesForTopCardInActivitiesView:self][0];
            ((UILabel *)self.topView.subviews[1]).hidden = NO;
            ((UILabel *)self.topView.subviews[2]).hidden = YES;
            ((UILabel *)self.topView.subviews[3]).hidden = YES;
        }
        else
        {
            ((UILabel *)self.topView.subviews[2]).text = [self.dataSource messagesForTopCardInActivitiesView:self][0];
            ((UILabel *)self.topView.subviews[3]).text = [self.dataSource messagesForTopCardInActivitiesView:self][1];
            ((UILabel *)self.topView.subviews[1]).hidden = YES;
            ((UILabel *)self.topView.subviews[2]).hidden = NO;
            ((UILabel *)self.topView.subviews[3]).hidden = NO;
        }
    }
}

- (void)updateMiddleCard
{
    if (self.cardsCount == 0)
    {
        ((UILabel *)self.middleView.subviews[1]).hidden = YES;
        ((UILabel *)self.middleView.subviews[2]).hidden = NO;
        ((UILabel *)self.middleView.subviews[2]).text = @"No recent activities";
        ((UILabel *)self.middleView.subviews[3]).hidden = NO;
        ((UILabel *)self.middleView.subviews[3]).text = @"   MAKE THEM HAPPEN";
        for (UIView *view in self.subviews) {
            if (![view isEqual:self.middleView] && ![view isEqual:self.activitiesLabel]) {
                [view removeFromSuperview];
            }
        }
    }
    else
    {
        if ([self.dataSource backgroundShoudBeSet:self])
        {
            ((UIImageView *)self.middleView.subviews[0]).backgroundColor = ICON_BG_COLOR;
        }
        else
        {
            ((UIImageView *)self.middleView.subviews[0]).backgroundColor = [UIColor clearColor];
        }
        ((UIImageView *)self.middleView.subviews[0]).image = [self.dataSource imageForTopCardInActivitiesView:self];
//        [self.dataSource imageForTopCardInActivitiesView:self completionBlock:^(UIImage *image) {
//            ((UIImageView *)self.topView.subviews[0]).image = image;
//        }];
//        ((UILabel *)self.middleView.subviews[1]).text = [self.dataSource messageForTopCardInActivitiesView:self];
        NSInteger labelsCount = [self.dataSource numberOfSentencesForTopCardInActivitiesView:self];
        if (labelsCount == 1)
        {
            ((UILabel *)self.middleView.subviews[1]).text = [self.dataSource messagesForTopCardInActivitiesView:self][0];
            ((UILabel *)self.middleView.subviews[1]).hidden = NO;
            ((UILabel *)self.middleView.subviews[2]).hidden = YES;
            ((UILabel *)self.middleView.subviews[3]).hidden = YES;
        }
        else
        {
            ((UILabel *)self.middleView.subviews[2]).text = [self.dataSource messagesForTopCardInActivitiesView:self][0];
            ((UILabel *)self.middleView.subviews[3]).text = [self.dataSource messagesForTopCardInActivitiesView:self][1];
            ((UILabel *)self.middleView.subviews[1]).hidden = YES;
            ((UILabel *)self.middleView.subviews[2]).hidden = NO;
            ((UILabel *)self.middleView.subviews[3]).hidden = NO;
        }
    }
}

- (void)slideToLeft:(UISwipeGestureRecognizer *)gesture
{
    if (self.cardsCount == 0) {
        return;
    }
    
    [self.delegate activitiesViewWillBeginSlidingAnimation:self];
    self.cardsCount = [self.dataSource numberOfCardsInActivitiesView:self];
    [self updateMiddleCard];
    self.activitiesLabel.hidden = NO;
    self.activityCardIsSwiping = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        self.topView.frame = CGRectOffset(self.topView.frame, -screenWidth, 0.0);
    } completion:^(BOOL finished) {
        [self removeTopCard];
        [self bringSubviewToFront:self.activitiesLabel];
        if (self.delegate && [self.delegate respondsToSelector:@selector(activitiesViewDidEndSlidingAnimation:)])
        {
            [self.delegate activitiesViewDidEndSlidingAnimation:self];
        }
    }];
}

- (void)removeTopCard
{
    self.cardsCount = [self.dataSource numberOfCardsInActivitiesView:self];
    
    if (self.cardsCount > 1)
    {
        [self.topView removeFromSuperview];
        
        self.topView = self.middleView;
        self.middleView = self.bottomView;
        self.bottomView = [self activityCardWithFrame:[self bottomViewRect]];
        [self insertSubview:self.bottomView belowSubview:self.middleView];
        
        [UIView animateWithDuration:0.5 animations:^{
            [self moveActivityCardUp:self.topView];
            [self moveActivityCardUp:self.middleView];
        } completion:^(BOOL finished) {
            self.activityCardIsSwiping = NO;
            if (self.activityViewShouldBeUpdated)
            {
                [self updateActivityView];
            }
        }];
        
        [self.topView addGestureRecognizer:self.swipeLeftGesture];
    }
    else if (self.cardsCount > 0)
    {
        [self.topView removeFromSuperview];
        
        self.topView = self.middleView;
        self.middleView = self.bottomView;
        self.bottomView = nil;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self moveActivityCardUp:self.topView];
            [self moveActivityCardUp:self.middleView];
        } completion:^(BOOL finished) {
            self.activityCardIsSwiping = NO;
            if (self.activityViewShouldBeUpdated)
            {
                [self updateActivityView];
            }
        }];
        
        [self.topView addGestureRecognizer:self.swipeLeftGesture];
    }
    else if (self.cardsCount == 0)
    {
        [self.topView removeFromSuperview];
        
        self.topView = self.middleView;
        self.middleView = nil;
        self.bottomView = nil;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self moveActivityCardUp:self.topView];
        } completion:^(BOOL finished) {
            self.activityCardIsSwiping = NO;
            if (self.activityViewShouldBeUpdated)
            {
                [self updateActivityView];
            }
        }];
    }
}

- (UIView *)activityCardWithFrame:(CGRect)frame
{
    UIView *activityCard = [[UIView alloc] initWithFrame:frame];
    activityCard.backgroundColor = BASE_COLOR;
    activityCard.alpha = 0.3;
    activityCard.layer.cornerRadius = 4;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 17, 52, 52)];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.layer.cornerRadius = 26;
    imageView.clipsToBounds = YES;
    [activityCard addSubview:imageView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(86, 20, 200, 50)];
    label1.numberOfLines = 2;
    label1.font = [UIFont fontWithName:@"Geomanist-Book" size:16.0];
    label1.textColor = LABEL_COLOR;
    label1.hidden = YES;
    [activityCard addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(86, 20, 200, 30)];
    label2.font = [UIFont fontWithName:@"Geomanist-Book" size:16.0];
    label2.textColor = LABEL_COLOR;
    label2.hidden = YES;
    [activityCard addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(86, 40, 200, 30)];
    label3.font = [UIFont fontWithName:@"Geomanist-Light" size:13.0];
    label3.textColor = LABEL_COLOR_SECOND;
    label3.hidden = YES;
    [activityCard addSubview:label3];
    
    return activityCard;
}

- (CGRect)bottomViewRect
{
    return CGRectMake(24, 36, CGRectGetWidth(self.frame) - 48, 74);
}

- (void)moveActivityCardUp:(UIView *)card
{
    card.frame = CGRectMake(card.frame.origin.x - 8, card.frame.origin.y - 12, CGRectGetWidth(card.frame) + 16, CGRectGetHeight(card.frame) + 6);
    card.alpha += 0.3;
}

- (void)updateActivityView
{
    if (!self.activityCardIsSwiping)
    {
        self.activityViewShouldBeUpdated = NO;
        
        self.cardsCount = [self.dataSource numberOfCardsInActivitiesView:self];
        
        if (self.middleView && !self.bottomView)
        {
            if (self.cardsCount > 1)
            {
                self.bottomView = [self activityCardWithFrame:[self bottomViewRect]];
                [self insertSubview:self.bottomView belowSubview:self.middleView];
            }
        }
        if (!self.middleView)
        {
            if (self.cardsCount > 0)
            {
                self.middleView = [self activityCardWithFrame:[self bottomViewRect]];
                [self moveActivityCardUp:self.middleView];
                [self insertSubview:self.middleView belowSubview:self.topView];
            }
            if (self.cardsCount > 1)
            {
                self.bottomView = [self activityCardWithFrame:[self bottomViewRect]];
                [self insertSubview:self.bottomView belowSubview:self.middleView];
            }
            
            [self.topView addGestureRecognizer:self.swipeLeftGesture];
        }
        
        [self updateTopCard];
        
        [self bringSubviewToFront:self.activitiesLabel];
        self.activitiesLabel.hidden = NO;
    }
    else
    {
        self.activityViewShouldBeUpdated = YES;
    }
}

@end
