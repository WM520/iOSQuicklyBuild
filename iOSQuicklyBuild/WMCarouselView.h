//
//  WMCarouselView.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMCarouselView;
@protocol WMCarouselViewDelegate <NSObject>

- (void) carouselTouch:(WMCarouselView *)carousel atIndex:(NSUInteger)index;

@end

@interface WMCarouselView : UIView
@property (weak, nonatomic) id<WMCarouselViewDelegate> delegate;


-(instancetype)initWithFrame:(CGRect)frame;
-(void) setupWithArray:(NSArray *)array;
-(void) setupWithLocalArray:(NSArray *)array;
+(instancetype)initWithFrame:(CGRect)frame withArray:(NSArray*) array hasTimer:(BOOL) hastimer interval:(NSUInteger) inter;
+(instancetype)initWithFrame:(CGRect)frame hasTimer:(BOOL) hastimer interval:(NSUInteger) inter placeHolder:(UIImage*) image;

@end
