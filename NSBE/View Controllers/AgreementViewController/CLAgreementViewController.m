//
//  CLAgreementViewController.m
//  Stepify
//
//  Created by Vasya Pupkin on 10/7/15.
//  Copyright © 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLAgreementViewController.h"

@interface CLAgreementViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textViewPrivacy;
@property (strong, nonatomic) CAGradientLayer *gradient;
@property (weak, nonatomic) IBOutlet UIButton *buttonDismiss;
@property (weak, nonatomic) IBOutlet UIView *gradientLayerView;
@property (weak, nonatomic) IBOutlet UITextView *textViewTerms;

@end

@implementation CLAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureForMode];
    
    // Do any additional setup after loading the view.
    self.gradient = [CAGradientLayer layer];
    
    self.gradient.frame = self.gradientLayerView.bounds;
    self.gradient.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    self.gradient.locations = @[@0.0, @0.03, @0.97, @1.0];
    
    self.gradientLayerView.layer.mask = self.gradient;
    [self.view bringSubviewToFront:self.buttonDismiss];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.gradient.frame = self.gradientLayerView.bounds;
}

- (void)configureForMode
{
    if (self.displayMode == CLAgreementControllerModeConditions) {
        self.textViewTerms.hidden = NO;
    } else if (self.displayMode == CLAgreementControllerModePrivacy) {
        self.textViewPrivacy.hidden = NO;
    }
}

- (IBAction)buttonDismissAction:(UIButton *)sender

{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
