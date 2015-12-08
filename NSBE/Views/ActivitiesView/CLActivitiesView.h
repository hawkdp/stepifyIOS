//
//  CLActivitiesView.h
//  NSBE
//

#import <UIKit/UIKit.h>

typedef void (^CLActivitiesViewSuccessBlock)(UIImage *image);

@class CLActivitiesView;


@protocol ActivitiesViewDataSource <NSObject>

- (NSInteger)numberOfCardsInActivitiesView:(CLActivitiesView *)activitiesView;
//- (NSString *)messageForTopCardInActivitiesView:(CLActivitiesView *)activitiesView;
- (UIImage *)imageForTopCardInActivitiesView:(CLActivitiesView *)activitiesView;
//- (void)imageForTopCardInActivitiesView:(CLActivitiesView *)activitiesView completionBlock:(CLActivitiesViewSuccessBlock)block;
- (BOOL)backgroundShoudBeSet:(CLActivitiesView *)activitiesView;
- (NSInteger)numberOfSentencesForTopCardInActivitiesView:(CLActivitiesView *)activitiesView;
- (NSArray *)messagesForTopCardInActivitiesView:(CLActivitiesView *)activitiesView;

@end


@protocol ActivitiesViewDelegate <NSObject>

@optional
- (void)activitiesViewWillBeginSlidingAnimation:(CLActivitiesView *)activitiesView;
- (void)activitiesViewDidEndSlidingAnimation:(CLActivitiesView *)activitiesView;

@end


@interface CLActivitiesView : UIView

@property (nonatomic, assign) NSInteger cardsCount;

@property (nonatomic, weak) id<ActivitiesViewDataSource> dataSource;
@property (nonatomic, weak) id<ActivitiesViewDelegate> delegate;

- (void)updateActivityView;

@end
