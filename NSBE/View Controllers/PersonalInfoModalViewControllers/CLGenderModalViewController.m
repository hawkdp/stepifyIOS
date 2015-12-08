//
//  CLGenderModalViewController.m
//  NSBE
//
//  Created by Alexey Titov on 23.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLGenderModalViewController.h"

@interface CLGenderModalViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *maleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *femaleImageView;
@property (weak, nonatomic) IBOutlet UILabel *maleLabel;
@property (weak, nonatomic) IBOutlet UILabel *femaleLabel;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@end

@implementation CLGenderModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isFemaleOptionSelected)
    {
        [self activateFemaleOption];
    }
    else
    {
        [self activateMaleOption];
    }
    
    self.applyButton.layer.borderColor = [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:1.0].CGColor;
    self.applyButton.layer.borderWidth = 1.0;
    self.applyButton.layer.cornerRadius = 18.0;
}

#pragma mark - Helpers

- (void)activateMaleOption
{
    self.maleImageView.alpha = 1.0;
    self.maleLabel.alpha = 1.0;
    
    self.femaleImageView.alpha = 0.4;
    self.femaleLabel.alpha = 0.4;
}

- (void)activateFemaleOption
{
    self.femaleImageView.alpha = 1.0;
    self.femaleLabel.alpha = 1.0;
    
    self.maleImageView.alpha = 0.4;
    self.maleLabel.alpha = 0.4;
}

#pragma mark - IBActions

- (IBAction)applyButtonPressed:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(genderModalViewController:didSelectMaleOption:)])
    {
        [self.delegate genderModalViewController:self didSelectMaleOption:!self.isFemaleOptionSelected];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissModalView:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectMaleTap:(UITapGestureRecognizer *)sender
{
    [self activateMaleOption];
    self.isFemaleOptionSelected = NO;
}

- (IBAction)selectFemaleTap:(UITapGestureRecognizer *)sender
{
    [self activateFemaleOption];
    self.isFemaleOptionSelected = YES;
}

@end
