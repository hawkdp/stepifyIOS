//
//  CLBirthdateModalViewController.m
//  NSBE
//
//  Created by Alexey Titov on 24.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLBirthdateModalViewController.h"
#import "CLUser.h"
#import "Constants.h"
#import "Utils.h"

#define PICKER_TEXT_COLOR [UIColor colorWithRed:44.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0]

@interface CLBirthdateModalViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@property(nonatomic, strong) NSArray *dateYearsArray;
@property(nonatomic, strong) NSArray *dateMonthsArray;
@property(nonatomic, strong) NSArray *dateDaysArray;

@end

@implementation CLBirthdateModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateYearsArray = [[[Utils getPastYears:DATE_PICKER_PAST_YEAR_COUNT includeCurrentYear:YES] reverseObjectEnumerator] allObjects];
    self.dateMonthsArray = [Utils getAllMonths];
    self.dateDaysArray = [Utils getAllDaysInMonth:[Utils getCurrentMonth] year:[Utils getCurrentYear]];
    
    if (self.birthdate)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.birthdate];
        [self.pickerView selectRow:dateComponents.year - [self.dateYearsArray.firstObject integerValue] inComponent:DATE_PICKER_YEAR_POSITION animated:NO];
        [self.pickerView selectRow:dateComponents.month - 1 inComponent:DATE_PICKER_MONTH_POSITION animated:NO];
        [self.pickerView selectRow:dateComponents.day - 1 inComponent:DATE_PICKER_DAY_POSITION animated:NO];
    }
    else
    {
        [self.pickerView selectRow:[Utils getCurrentMonth] - 1 inComponent:DATE_PICKER_MONTH_POSITION animated:NO];
        [self.pickerView selectRow:[Utils getCurrentDay] - 1 inComponent:DATE_PICKER_DAY_POSITION animated:NO];
        [self.pickerView selectRow:self.dateYearsArray.count - 1 inComponent:DATE_PICKER_YEAR_POSITION animated:NO];
    }
    
    self.applyButton.layer.borderColor = [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:1.0].CGColor;
    self.applyButton.layer.borderWidth = 1.0;
    self.applyButton.layer.cornerRadius = 18.0;
}

#pragma mark - IBActions

- (IBAction)applyButtonPressed:(UIButton *)sender
{
    if (!self.age)
    {
        self.birthdate = [NSDate date];
        self.age = @([Utils getYearCountFromDate:self.birthdate]);
    }
    if ([self.delegate respondsToSelector:@selector(birthdateModalViewController:didSelectAge:birthdate:)])
    {
        [self.delegate birthdateModalViewController:self didSelectAge:self.age birthdate:self.birthdate];
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
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case DATE_PICKER_MONTH_POSITION: return self.dateMonthsArray.count;
        case DATE_PICKER_DAY_POSITION: return self.dateDaysArray.count;
        case DATE_PICKER_YEAR_POSITION: return self.dateYearsArray.count;
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
    
    switch (component)
    {
        case DATE_PICKER_MONTH_POSITION:
        {
            label.text = self.dateMonthsArray[row];
            break;
        }
        case DATE_PICKER_DAY_POSITION:
        {
            label.text = [self.dateDaysArray[row] stringValue];
            break;
        }
        case DATE_PICKER_YEAR_POSITION:
        {
            label.text = [self.dateYearsArray[row] stringValue];
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
//    return pickerView.frame.size.width / 3.0;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:[self.dateYearsArray[[pickerView selectedRowInComponent:DATE_PICKER_YEAR_POSITION]] integerValue]];
    [dateComponents setMonth:[pickerView selectedRowInComponent:DATE_PICKER_MONTH_POSITION] + 1];
    [dateComponents setDay:[self.dateDaysArray[[pickerView selectedRowInComponent:DATE_PICKER_DAY_POSITION]] integerValue]];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [dateComponents setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    self.birthdate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    self.age = @([Utils getYearCountFromDate:self.birthdate]);
}

@end
