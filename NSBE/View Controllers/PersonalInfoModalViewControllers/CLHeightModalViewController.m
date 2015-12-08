//
//  CLHeightModalViewController.m
//  NSBE
//
//  Created by Alexey Titov on 23.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLHeightModalViewController.h"
#import "CLUser.h"
#import "Constants.h"

#define PICKER_TEXT_COLOR [UIColor colorWithRed:44.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0]

@interface CLHeightModalViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@property (nonatomic, strong) NSArray *heightFeetArray;
@property (nonatomic, strong) NSArray *heightInchesArray;

//@property (nonatomic, strong) UILabel *oldLabel;
//@property (nonatomic, strong) UILabel *selectedLabel;

@end

@implementation CLHeightModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.heightFeetArray = HEIGHT_PICKER_FEET_ARRAY;
    self.heightInchesArray = HEIGHT_PICKER_INCHES_ARRAY;
    
    if (self.heightFeet && self.heightInches)
    {
        [self.pickerView selectRow:[self.heightFeet integerValue] inComponent:HEIGHT_PICKER_FEET_POSITION animated:NO];
        [self.pickerView selectRow:[self.heightInches integerValue] inComponent:HEIGHT_PICKER_INCHES_POSITION animated:NO];
    }
    else
    {
        [self.pickerView selectRow:HEIGHT_PICKER_DEFAULT_FEET_INDEX inComponent:HEIGHT_PICKER_FEET_POSITION animated:NO];
        [self.pickerView selectRow:HEIGHT_PICKER_DEFAULT_INCHES_INDEX inComponent:HEIGHT_PICKER_INCHES_POSITION animated:NO];
    }
    
    self.applyButton.layer.borderColor = [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:1.0].CGColor;
    self.applyButton.layer.borderWidth = 1.0;
    self.applyButton.layer.cornerRadius = 18.0;
}

#pragma mark - IBActions

- (IBAction)applyButtonPressed:(UIButton *)sender
{
    if (!self.heightFeet && !self.heightInches)
    {
        self.heightFeet = @(HEIGHT_PICKER_DEFAULT_FEET_INDEX);
        self.heightInches = @(HEIGHT_PICKER_DEFAULT_INCHES_INDEX);
    }
    if ([self.delegate respondsToSelector:@selector(heightModalViewController:didSelectHeightFeet:heightInches:)])
    {
        [self.delegate heightModalViewController:self didSelectHeightFeet:self.heightFeet heightInches:self.heightInches];
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
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case HEIGHT_PICKER_FEET_POSITION: return self.heightFeetArray.count;
        case HEIGHT_PICKER_INCHES_POSITION: return self.heightInchesArray.count;
        default: return 0;
    }
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Geomanist-Light" size:16];
    
//    if (row == [pickerView selectedRowInComponent:component])
//    {
//        label.font = [UIFont fontWithName:@"Geomanist-Light" size:40];
//    }
//    else
//    {
//        label.font = [UIFont fontWithName:@"Geomanist-Light" size:16];
//    }
    
//    if (self.oldLabel != nil)
//    {
//        self.oldLabel.font = [UIFont fontWithName:@"Geomanist-Light" size:16];
//    }
//    self.selectedLabel = (UILabel *)[pickerView viewForRow:row forComponent:0];
//    self.selectedLabel.font = [UIFont fontWithName:@"Geomanist-Light" size:30];
//    [self.selectedLabel setNeedsDisplay];
//    self.oldLabel = self.selectedLabel;
    
    switch (component)
    {
        case HEIGHT_PICKER_FEET_POSITION:
        {
            label.text = [NSString stringWithFormat:@"%@%@", self.heightFeetArray[row], HEIGHT_PICKER_FEET_SUFFIX];
            break;
        }
        case HEIGHT_PICKER_INCHES_POSITION:
        {
            label.text = [NSString stringWithFormat:@"%@%@", self.heightInchesArray[row], HEIGHT_PICKER_INCHES_SUFFIX];
            break;
        }
    }
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 42.0;
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    return pickerView.frame.size.width / 2.0;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    [pickerView reloadComponent:component];
    
    self.heightFeet = self.heightFeetArray[[pickerView selectedRowInComponent:HEIGHT_PICKER_FEET_POSITION]];
    self.heightInches = self.heightInchesArray[[pickerView selectedRowInComponent:HEIGHT_PICKER_INCHES_POSITION]];
}

@end
