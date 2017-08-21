//
//  UIBarButtonItem+MineShopBarButtonCustom.h
//  MineShop
//
//  Created by ChangWingchit on 2017/5/4.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (MineShopBarButtonCustom)

+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image selectImage:(NSString *)selectImage;

+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image selectImage:(NSString *)selectImage title:(NSString *)title;

@end
