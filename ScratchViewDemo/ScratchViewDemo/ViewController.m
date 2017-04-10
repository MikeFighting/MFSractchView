//
//  ViewController.m
//  ScratchViewDemo
//
//  Created by Mike on 4/10/17.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "ViewController.h"
#import "MFScratchView.h"
#import "UIImage+MFAddition.h"

#define kContainerWidth (320 - 54)
@interface ViewController ()<MFScratchViewDelegate>
    
@property (nonatomic, strong) HYContainerView *containerView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIView *bottomView;
    
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _containerView = [[HYContainerView alloc]initWithFrame:CGRectMake(27, 100, kContainerWidth, 149)];
    
    CGFloat resultLabelWidth = CGRectGetWidth(self.bottomView.frame);
    CGFloat resultLabelTop = (CGRectGetHeight(self.bottomView.frame) - 20) * 0.5;
    UILabel *resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, resultLabelTop, resultLabelWidth, 20)];
    resultLabel.text = @"恭喜您~，中奖了";
    resultLabel.textAlignment = NSTextAlignmentCenter;
    resultLabel.textColor = [UIColor redColor];
    [self.bottomView addSubview:resultLabel];
    _containerView.delegate = self;
    [_containerView hideBottomView:self.bottomView withMaskView:self.coverImageView];
    [self.view addSubview:_containerView];
    
}
    
- (UIImageView *)coverImageView {
    
    if (!_coverImageView) {
        
        UIImage *originImage = [UIImage imageNamed:@"lottery_scratch_bg"];

        _coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(27, 0, kContainerWidth , 149 )];
        _coverImageView.image = originImage;

    }
    return _coverImageView;
}
    
- (UIView *)bottomView {
        
    if (!_bottomView) {
        
        CGFloat horizontalGap = 27.0f;
        CGFloat bottomWidth = 320 - horizontalGap * 2;
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(horizontalGap, 0, bottomWidth, 149)];
        UIImage *bgImage = [UIImage imageNamed:@"lottery_result_bg"];
        _bottomView.layer.contents = (__bridge id)bgImage.CGImage;
        
    }
    return _bottomView;
        
}
    
- (void)openAllCoverScratchView:(MFScratchView *)scratchView {

    NSLog(@"scratch view open");
    
}
    
- (void)scratchViewBeginScratch:(MFScratchView *)scratchView {

    NSLog(@"begin scratch");
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
