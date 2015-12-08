//
//  CLTextBoxView.h
//  UPMC
//

@import UIKit;

typedef void(^completionBlock)();

@interface CLTextBoxView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) UIView *parentView;

- (void)show;

+ (void)showWithTitle:(NSString*)title message:(NSString *)message;
+ (void)showWithTitle:(NSString*)title message:(NSString *)message completionBlock:(completionBlock)completion;

@end
