//
//  MFScratchView.h
//  58BP
//
//  Created by Mike on 2/3/17.
//  Copyright © 2017 58. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class MFScratchMasker;

@protocol MFScratchViewDelegate <NSObject>

/**
 *  打开全部图层之后的代理方法
 */
- (void)openAllCoverScratchView:(MFScratchMasker *)scratchView;
- (void)scratchViewBeginScratch:(MFScratchMasker *)scratchView;

@end

@interface MFScratchView : UIView

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) float brushWidth;
@property (nonatomic, assign) id<MFScratchViewDelegate>delegate;
- (void)hideBottomView:(UIView *)bottomView withMaskView:(UIView *)maskView;

@end

@interface MFScratchMasker : UIView

@end


