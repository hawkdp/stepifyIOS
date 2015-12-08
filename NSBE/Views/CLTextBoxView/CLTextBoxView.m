//
//  CLTextBoxView.m
//  UPMC
//

#import "CLTextBoxView.h"
#import "KLCPopup.h"

@interface CLTextBoxView ()
@property(weak, nonatomic) IBOutlet UIView *popUpView;
@property(nonatomic, strong) KLCPopup *klcPopup;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;

@property (strong, nonatomic) UIVisualEffectView *visualEffectView;

@property (nonatomic, strong) completionBlock completion;

@end

@implementation CLTextBoxView

- (KLCPopup *)klcPopup {
    if (!_klcPopup) {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.visualEffectView.frame = [UIScreen mainScreen].bounds;
        
        _klcPopup = [KLCPopup popupWithContentView:self];
        [_klcPopup setMaskType:KLCPopupMaskTypeDimmed];
        _klcPopup.dimmedMaskAlpha = .75f;
        [_klcPopup insertSubview:self.visualEffectView atIndex:0];
    }
    return _klcPopup;
}

- (UIView *)parentView {
    if (!_parentView) {
        _parentView = [[UIView alloc] init];
    }
    return _parentView;
}

- (void)awakeFromNib {
    
    self.popUpView.layer.cornerRadius = 5.0f;
    self.popUpView.layer.masksToBounds = YES;
    
    self.dismissButton.layer.cornerRadius = 20.0f;
    self.dismissButton.layer.masksToBounds = YES;
    self.dismissButton.layer.borderWidth = 1.0f;
    self.dismissButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
    
    self.noButton.layer.cornerRadius = 20.0f;
    self.noButton.layer.masksToBounds = YES;
    self.noButton.layer.borderWidth = 1.0f;
    self.noButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
    
    self.yesButton.layer.cornerRadius = 20.0f;
    self.yesButton.layer.masksToBounds = YES;
    self.yesButton.layer.borderWidth = 1.0f;
    self.yesButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
}

- (void)show {
    [self.klcPopup show];
}

- (IBAction)tapOnDismissButton {
    [self.visualEffectView removeFromSuperview];
    [self.klcPopup dismiss:YES];
}

- (IBAction)noButtonPressed:(id)sender
{
    [self.visualEffectView removeFromSuperview];
    [self.klcPopup dismiss:YES];
}

- (IBAction)yesButtonPressed:(id)sender
{
    [self.visualEffectView removeFromSuperview];
    [self.klcPopup dismiss:YES];
    if (self.completion)
    {
        self.completion();
    }
}

+ (void)showWithTitle:(NSString*)title message:(NSString *)message
{
    [self showWithTitle:title message:message completionBlock:nil];
}

+ (void)showWithTitle:(NSString*)title message:(NSString *)message completionBlock:(completionBlock)completion
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CLTextBoxView"
                                                 owner:self
                                               options:nil];
    
    CLTextBoxView *textBoxView = (CLTextBoxView *) nib[0];
    textBoxView.titleLabel.text = title;
    textBoxView.messageLabel.text = message;
    
    if (completion)
    {
        textBoxView.dismissButton.hidden = YES;
        textBoxView.completion = completion;
    }
    else
    {
        textBoxView.noButton.hidden = YES;
        textBoxView.yesButton.hidden = YES;
    }
    
    [textBoxView show];
}

@end
