//
//  UIView+Extension.h
//  MineTrip
//
//  Created by ChangWingchit on 2017/6/11.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGSize size;

/** 从xib中创建一个控件 */
+ (instancetype)viewFromXib;

@end
