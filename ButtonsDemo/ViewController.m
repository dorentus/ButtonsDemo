//
//  ViewController.m
//  ButtonsDemo
//
//  Created by Rox Dorentus on 2017-4-2.
//  Copyright © 2017年 tardis.cloud. All rights reserved.
//

#import "ViewController.h"

static NSInteger const kNumberOfButtonsPerSide = 3; // 每边三个
static CGFloat const kCenterButtonAnimationDuration = 0.5;
static CGFloat const kOtherButtonAnimationDuration = 0.5;
static CGFloat const kOtherButtonAnimationDelayBase = 0.2;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *centerButton;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *otherButtons;

@property (nonatomic, strong) NSMutableArray *initialTransforms;
@property (nonatomic, strong) UIColor *initialCenterButtonColor;

@property (nonatomic, assign) BOOL buttonsVisible;

@property (weak, nonatomic) IBOutlet UIView *maskView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (UIButton *button in self.otherButtons) {
        button.alpha = 0;
    }

    [self.view bringSubviewToFront:self.centerButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // position of buttons is determined now

    self.initialTransforms = [NSMutableArray array];
    self.initialCenterButtonColor = self.centerButton.backgroundColor;

    CGFloat centerX = self.centerButton.center.x;
    CGFloat baseXOffset = centerX - [self.otherButtons[0] center].x;
    [self.otherButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger offset = idx % kNumberOfButtonsPerSide;
        BOOL inLeftSide = idx < kNumberOfButtonsPerSide;

        // 左一按钮的隐藏位置（显现动画的开始处）为中心
        // 左二按钮的隐藏位置为左一按钮的真实位置（显现动画完成后的位置）
        // 左三按钮的隐藏为左二按钮的真实位置
        // 右边按钮也是一样
        CGFloat xOffset = centerX - button.center.x + (inLeftSide ? -1 : 1) * offset * baseXOffset;

        button.transform = CGAffineTransformMakeTranslation(xOffset, 0);
        button.alpha = 0;
        [self.initialTransforms addObject:[NSValue valueWithCGAffineTransform:button.transform]];
    }];
}

- (IBAction)centerButtonTapped:(UIButton *)sender
{
    if (self.buttonsVisible) {
        [self hideButtons];
    } else {
        [self showButtons];
    }
}

- (void)showButtons
{
    self.buttonsVisible = YES;

    [self.otherButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger offset = idx % kNumberOfButtonsPerSide;

        // spring animation
        // 越往两边的越延迟开始动画
        [UIView animateWithDuration:kOtherButtonAnimationDuration delay:kCenterButtonAnimationDuration + kOtherButtonAnimationDelayBase * offset usingSpringWithDamping:0.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
            button.transform = CGAffineTransformIdentity;
            button.alpha = 1;
        } completion:nil];
    }];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kCenterButtonAnimationDuration];
    self.centerButton.backgroundColor = [UIColor darkGrayColor];
    self.maskView.alpha = 1;
    [UIView commitAnimations];
}

- (void)hideButtons
{
    self.buttonsVisible = NO;

    [self.otherButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger offset = kNumberOfButtonsPerSide - idx % kNumberOfButtonsPerSide;

        // spring animation
        // 越往中间的越延迟开始动画
        [UIView animateWithDuration:kOtherButtonAnimationDuration delay:kCenterButtonAnimationDuration + kOtherButtonAnimationDelayBase * offset usingSpringWithDamping:0.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
            button.transform = [self.initialTransforms[idx] CGAffineTransformValue];
            button.alpha = 0;
        } completion:nil];
    }];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kCenterButtonAnimationDuration];
    self.centerButton.backgroundColor = self.initialCenterButtonColor;
    [UIView commitAnimations];

    // mask 消失得稍微慢些，等按钮都消失复位了再消失
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kCenterButtonAnimationDuration + kOtherButtonAnimationDuration * kNumberOfButtonsPerSide];
    self.maskView.alpha = 0;
    [UIView commitAnimations];
}

@end
