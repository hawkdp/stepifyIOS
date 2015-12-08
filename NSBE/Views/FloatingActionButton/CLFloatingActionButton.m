//
//  CLFloatingActionButton.m
//  UPMC
//
//  Created by Vasya Pupkin on 7/29/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLFloatingActionButton.h"
#import "CLFloatTableViewCell.h"

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

CGFloat animationTime = 0.55;
CGFloat rowHeight = 80.f;
NSInteger noOfRows = 0;
NSInteger tappedRow;
CGFloat previousOffset;
CGFloat buttonToScreenHeight;

@interface CLFloatingActionButton ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIScrollView *bgScroller;
@property (nonatomic, strong) UIImageView *normalImageView, *pressedImageView;
@property (nonatomic, strong) UIWindow *mainWindow;
@property (nonatomic, strong) NSDictionary *menuItemSet;

@property (nonatomic, assign) BOOL isMenuVisible;
@property (nonatomic, strong) UIView *windowView;

@property (nonatomic, strong) UITableView  *menuTable;
@property (nonatomic, strong) UIView       *buttonView;

@end

@implementation CLFloatingActionButton

@synthesize windowView;
@synthesize delegate;

-(id)initWithFrame:(CGRect)frame normalImage:(UIImage*)normalImage andPressedImage:(UIImage*)pressedImage
{
    self = [super initWithFrame:frame];
    if (self)
    {
        windowView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _mainWindow = [UIApplication sharedApplication].keyWindow;
        _buttonView = [[UIView alloc]initWithFrame:frame];
        _buttonView.backgroundColor = [UIColor clearColor];
        _buttonView.userInteractionEnabled = YES;
        
        buttonToScreenHeight = SCREEN_HEIGHT - CGRectGetMaxY(self.frame);
        
        _menuTable = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, 0, 0.75*SCREEN_WIDTH,SCREEN_HEIGHT - (SCREEN_HEIGHT - CGRectGetMaxY(self.frame)) )];
        _menuTable.scrollEnabled = NO;
        
        
        _menuTable.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, CGRectGetHeight(frame))];
        
        _menuTable.delegate = self;
        _menuTable.dataSource = self;
        _menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTable.backgroundColor = [UIColor clearColor];
        _menuTable.transform = CGAffineTransformMakeRotation(-M_PI); //Rotate the table
        
        [self setupButtonWithNormalImage:normalImage pressedImage:pressedImage];
        
    }
    return self;
}


- (void)setupButtonWithNormalImage:(UIImage *)normalImage pressedImage:(UIImage *)pressedImage
{
    _isMenuVisible = false;
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:buttonTap];
    
    
    UITapGestureRecognizer *buttonTap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    [_buttonView addGestureRecognizer:buttonTap3];
    
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *vsview = [[UIVisualEffectView alloc]initWithEffect:blur];
    
    
    _bgView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.alpha = 0;
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5f];
    _bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *buttonTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    buttonTap2.cancelsTouchesInView = NO;
    vsview.frame = _bgView.bounds;
    [_bgView addSubview:vsview];
    [_bgView addGestureRecognizer:buttonTap2];
    
    _normalImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    _normalImageView.userInteractionEnabled = YES;
    _normalImageView.contentMode = UIViewContentModeScaleAspectFit;
    _normalImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _normalImageView.layer.shadowRadius = 5.f;
    _normalImageView.layer.shadowOffset = CGSizeMake(-10, -10);
    
    
    _pressedImageView  = [[UIImageView alloc]initWithFrame:self.bounds];
    _pressedImageView.contentMode = UIViewContentModeScaleAspectFit;
    _pressedImageView.userInteractionEnabled = YES;
    
    _normalImageView.image = normalImage;
    _pressedImageView.image = pressedImage;
    
    
    [_bgView addSubview:_menuTable];
    
    [_buttonView addSubview:_pressedImageView];
    [_buttonView addSubview:_normalImageView];
    
    [self addSubview:_normalImageView];
}

- (void)handleTap:(id)sender //Show Menu
{
    if (_isMenuVisible)
    {
        [self dismissMenu:nil];
    }
    else
    {
        [windowView addSubview:_bgView];
        [windowView addSubview:_buttonView];
        
        [_mainWindow addSubview:windowView];
        [self showMenu:nil];
    }
    _isMenuVisible  = !_isMenuVisible;
}

#pragma mark - Animations

- (void)showMenu:(id)sender
{
    self.pressedImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.pressedImageView.alpha = 0.0; //0.3
    
    [UIView animateWithDuration:animationTime/2 animations:^{
         self.bgView.alpha = 1;
         self.normalImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.alpha = 0.0; //0.7
         self.pressedImageView.transform = CGAffineTransformIdentity;
         self.pressedImageView.alpha = 1;
         noOfRows = _labelsArray.count;
         [_menuTable reloadData];
     } completion:nil];
}

- (void)dismissMenu:(id) sender
{
    [UIView animateWithDuration:animationTime/2 animations:^{
         self.bgView.alpha = 0;
         self.pressedImageView.alpha = 0.f;
         self.pressedImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.transform = CGAffineTransformMakeRotation(0);
         self.normalImageView.alpha = 1.f;
     } completion:^(BOOL finished) {
         noOfRows = 0;
         [_bgView removeFromSuperview];
         [windowView removeFromSuperview];
         [_mainWindow removeFromSuperview];
         
     }];
}

#pragma mark -- Tableview methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return noOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(CLFloatTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    double delay = (indexPath.row*indexPath.row) * 0.004;
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.95, 0.95);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0,-(indexPath.row+1)*CGRectGetHeight(cell.imgView.frame));
    cell.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    cell.alpha = 0.f;
    
    [UIView animateWithDuration:animationTime/2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         
         cell.transform = CGAffineTransformIdentity;
         cell.alpha = 1.f;
         
     } completion:^(BOOL finished)
     {
         
     }];
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLFloatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CLFloatTableViewCell class])];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CLFloatTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([CLFloatTableViewCell class])];
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CLFloatTableViewCell class])];
    }
    
    cell.imgView.image = [self image:[UIImage imageNamed:[_imagesArray objectAtIndex:indexPath.row]] scaledToSize:CGSizeMake(40, 40)];// [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
    cell.imgView.layer.cornerRadius = cell.imgView.frame.size.height / 2;
    cell.imgView.layer.masksToBounds = YES;
    cell.title.text    = [_labelsArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"selected CEll: %tu",indexPath.row);
    [delegate didSelectMenuOptionAtIndex:indexPath.row];
    
}

@end

