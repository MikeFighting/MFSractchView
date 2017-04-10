//
//  UIImage+MFAddition.m
//  ScratchViewDemo
//
//  Created by Mike on 4/10/17.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "UIImage+MFAddition.h"

@implementation UIImage (MFAddition)

-(UIImage *)scaleToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImg;
}


@end
