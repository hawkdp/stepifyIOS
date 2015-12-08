//
//  CLWeightModalViewController.m
//  NSBE
//
//  Created by Alexey Titov on 24.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLWeightModalViewController.h"
#import "CLUser.h"
#import "Constants.h"

#define PICKER_TEXT_COLOR [UIColor colorWithRed:44.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0]

@interface CLWeightModalViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@property(nonatomic, strong) NSArray *weightLbsArray;

@end

@implementation CLWeightModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weightLbsArray = WEIGHT_PICKER_LBS_ARRAY;
    
    if (self.weight)
    {
        [self.pickerView selectRow:[self.weight integerValue] - 60 inComponent:0 animated:NO];
    }
    else
    {
        [self.pickerView selectRow:WEIGHT_PICKER_DEFAULT_LBS_INDEX inComponent:0 animated:NO];
    }
    
    self.applyButton.layer.borderColor = [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:1.0].CGColor;
    self.applyButton.layer.borderWidth = 1.0;
    self.applyButton.layer.cornerRadius = 18.0;
}

#pragma mark - IBActions

- (IBAction)applyButtonPressed:(UIButton *)sender
{
    if (!self.weight)
    {
        self.weight = [NSString stringWithFormat:@"%@%@", self.weightLbsArray[WEIGHT_PICKER_DEFAULT_LBS_INDEX], WEIGHT_PICKER_LBS_SUFFIX];
    }
    if ([self.delegate respondsToSelector:@selector(weightModalViewController:didSelectWeight:)])
    {
        [self.delegate weightModalViewController:self didSelectWeight:self.weight];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissModalView:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.weightLbsArray.count;
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Geomanist-Light" size:16];
    
    label.text = [NSString stringWithFormat:@"%@%@", self.weightLbsArray[row], WEIGHT_PICKER_LBS_SUFFIX];
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 42.0;
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    return pickerView.frame.size.width;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //    [pickerView reloadComponent:component];
    
    self.weight = [NSString stringWithFormat:@"%@%@", self.weightLbsArray[[pickerView selectedRowInComponent:0]], WEIGHT_PICKER_LBS_SUFFIX];
}

@end
