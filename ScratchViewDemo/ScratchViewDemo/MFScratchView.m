//
//  MFScratchView.m
//  58BP
//
//  Created by Mike on 2/3/17.
//  Copyright © 2017 58. All rights reserved.
//

#import "MFScratchView.h"

@interface MFScratchView ()
{
    CGPoint previousTouchLocation;
    CGPoint currentTouchLocation;
    CGImageRef hideImage;
    CGContextRef contextMask;
    CGImageRef scratchImage;
}
@property (nonatomic, assign) BOOL isDrawn;
@property (nonatomic, strong) UIView *hideView;
@property (nonatomic, assign) float brushWidth;
@property (nonatomic, assign) BOOL beginDrawn;
@property (nonatomic, strong) id <MFScratchViewDelegate> scratchViewDelegate;

- (void)setHideView:(UIView *)hideView;

@end

@interface HYContainerView ()
@property (nonatomic, strong) MFScratchView *scratchView;

@end

@implementation HYContainerView

- (void)hideBottomView:(UIView *)bottomView withMaskView:(UIView *)maskView{
    
    bottomView.frame = self.bounds;
    [self addSubview:bottomView];
    _scratchView = [[MFScratchView alloc]initWithFrame:self.bounds];
    [_scratchView setHideView:maskView];
    _scratchView.brushWidth = self.brushWidth;
    _scratchView.scratchViewDelegate = self.delegate;
    [self addSubview:_scratchView];
    
}
    
- (void)setDelegate:(id<MFScratchViewDelegate>)delegate {

    _delegate = delegate;
    _scratchView.scratchViewDelegate = delegate;
}
    
- (void)setBrushWidth:(float)sizeBrush {

    _brushWidth = sizeBrush;
    _scratchView.brushWidth = sizeBrush;
    
}
    
@end

@implementation MFScratchView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setOpaque:NO];
        _brushWidth = 35.0;

    }
    return self;
}

#pragma mark - CoreGraphics methods
// Will be called every touch and at the first init
- (void)drawRect:(CGRect)rect {
    
    UIImage *imageToDraw = [UIImage imageWithCGImage:scratchImage];
    [imageToDraw drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    
}

// Method to change the view which will be scratched
- (void)setHideView:(UIView *)hideView {
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    float scale = [UIScreen mainScreen].scale;
    
    //1.Get Scratch CGImageRef
    UIGraphicsBeginImageContextWithOptions(hideView.bounds.size, NO, 0);
    [hideView.layer renderInContext:UIGraphicsGetCurrentContext()];
    hideView.layer.contentsScale = scale;
    hideImage = UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
    
    size_t imageWidth = CGImageGetWidth(hideImage);
    size_t imageHeight = CGImageGetHeight(hideImage);
    CFMutableDataRef pixels = CFDataCreateMutable(NULL, imageWidth * imageHeight);
    
    //Creat and config CGContext
    contextMask = CGBitmapContextCreate(CFDataGetMutableBytePtr(pixels), imageWidth, imageHeight , 8, imageWidth, colorspace, kCGImageAlphaNone);
    CGContextFillRect(contextMask, self.frame);
    // 这里设置滑动时候产生的线条颜色是白色
    CGContextSetStrokeColorWithColor(contextMask, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(contextMask, _brushWidth);
    CGContextSetLineCap(contextMask, kCGLineCapRound);
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(pixels);
    CGImageRef mask = CGImageMaskCreate(imageWidth, imageHeight, 8, 8, imageWidth, dataProvider, nil, NO);
    //2. 根据iamge mask产生最终的图片
    scratchImage = CGImageCreateWithMask(hideImage, mask);
    CGImageRelease(mask);
    CGColorSpaceRelease(colorspace);
    
}

- (void)scratchTheViewFrom:(CGPoint)startPoint to:(CGPoint)endPoint {
    
    BOOL needRender = [self needRenderWithCurrentLocation:endPoint previousLocation:previousTouchLocation];
    if (!needRender) return;
    
    float scale = [UIScreen mainScreen].scale;
    CGContextMoveToPoint(contextMask, startPoint.x * scale, (self.frame.size.height - startPoint.y) * scale);
    CGContextAddLineToPoint(contextMask, endPoint.x * scale, (self.frame.size.height - endPoint.y) * scale);
    CGContextStrokePath(contextMask);
    [self setNeedsDisplay];
    self.isDrawn = YES;
    
    
}
#pragma mark - Touch event
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.beginDrawn) {
        
        if ([self.scratchViewDelegate respondsToSelector:@selector(scratchViewBeginScratch:)]) {
            
            [self.scratchViewDelegate scratchViewBeginScratch:self];
            
        }
        self.beginDrawn = YES;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event touchesForView:self] anyObject];
    currentTouchLocation = [touch locationInView:self];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [[event touchesForView:self] anyObject];
    currentTouchLocation = [touch locationInView:self];
    previousTouchLocation = [touch previousLocationInView:self];
    
    [self scratchTheViewFrom:previousTouchLocation to:currentTouchLocation];
    //获取touch对象

}

- (BOOL)needRenderWithCurrentLocation:(CGPoint)currentLocation previousLocation:(CGPoint)previounsLocation{
    
    CGFloat currentGapX = fabs(currentTouchLocation.x - previousTouchLocation.x);
    CGFloat currentGapY = fabs(currentTouchLocation.y - previousTouchLocation.y);
    CGFloat movedLength = sqrt(currentGapX * currentGapX + currentGapY *currentGapY);
    return movedLength > 1.0f;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    if (self.isDrawn) {
        [self dismiss];
    }
    
}

- (void)processeTouches:(NSSet *)touches event:(UIEvent *)event{
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    previousTouchLocation = [touch previousLocationInView:self];
    [self scratchTheViewFrom:previousTouchLocation to:currentTouchLocation];
}
    
#pragma mark --从父控件移除
- (void)dismiss {
    
    [self removeFromSuperview];
    if ([self.scratchViewDelegate respondsToSelector:@selector(openAllCoverScratchView:)]) {
        
        [self.scratchViewDelegate openAllCoverScratchView:self];
    }
    
}


@end
