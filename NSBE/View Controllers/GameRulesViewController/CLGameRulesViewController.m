//
//  CLGameRulesViewController.m
//  UPMC
//

#import "CLGameRulesViewController.h"
#import "iCarousel.h"
#import "CLGameRulesFirstViewController.h"
#import "CLGameRulesSecondViewController.h"
#import "CLGameRulesThirdViewController.h"
#import "CLGameRulesFourthViewController.h"
#import "DDPageControl.h"

@interface CLGameRulesViewController () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, weak) IBOutlet iCarousel *carousel;

@property (nonatomic, strong) DDPageControl *pageControl;

@property (nonatomic, strong) NSArray *ruleViewsArray;

@end

@implementation CLGameRulesViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        CLGameRulesFirstViewController *first = [CLGameRulesFirstViewController new];
        CLGameRulesSecondViewController *second = [CLGameRulesSecondViewController new];
        CLGameRulesThirdViewController *third = [CLGameRulesThirdViewController new];
//        CLGameRulesFourthViewController *fourth = [CLGameRulesFourthViewController new];
        
        self.ruleViewsArray = @[first.view, second.view, third.view];//, fourth.view];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.carousel.type = iCarouselTypeLinear;
    self.carousel.pagingEnabled = YES;
    
    [self configurePageControl];
}

#pragma mark - IBActions

- (IBAction)changePage:(UIPageControl *)sender
{
    [self.carousel scrollToItemAtIndex:sender.currentPage animated:YES];
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.ruleViewsArray.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    view = self.ruleViewsArray[index];
    return view;
}

#pragma mark - iCarouselDelegate

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return 0.82f;
//        return self.view.frame.size.width * 0.0023;// 0.82;
    }
    
    return value;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel;
{
    self.pageControl.currentPage = carousel.currentItemIndex;
    
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [UIView animateWithDuration:0.3 animations:^{
            ((UIView*)obj).transform = CGAffineTransformMakeScale(0.8, 0.8);
        }];
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        carousel.currentItemView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - Helpers

- (void)configurePageControl
{
    self.pageControl = [[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull];
    self.pageControl.center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 74);
    self.pageControl.numberOfPages = self.ruleViewsArray.count;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.onColor = [UIColor whiteColor];
    self.pageControl.offColor = [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:0.5];
    self.pageControl.indicatorDiameter = 5.0;
    self.pageControl.indicatorSpace = 6.0;
    [self.view addSubview:self.pageControl];
}

@end
