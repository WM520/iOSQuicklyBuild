//
//  WMCarouselView.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "WMCarouselView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define ScrollWidth self.frame.size.width

@interface WMCarouselView ()<UIScrollViewDelegate>
{
    int i;
}

@property BOOL hasTimer;
@property (assign, nonatomic) NSUInteger interval;

@property (strong, nonatomic) UIImage *placeHolder;
@property (strong, nonatomic) NSArray * imageArray;
@property (strong, nonatomic) UIScrollView *wheelScrollView;
@property (strong, nonatomic) UIPageControl *wheelPageControl;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger currentImageIndex;
@property (strong, nonatomic) UIImageView *image1;
@property (strong, nonatomic) UIImageView *image2;
@property (strong, nonatomic) UIImageView *image3;
@property (assign, nonatomic) NSUInteger imageNum;
@property (strong, nonatomic) UIImageView *mask;
@property (assign, nonatomic) BOOL isLocal;

@end

@implementation WMCarouselView

+(instancetype)initWithFrame:(CGRect)frame withArray:(NSArray*) array hasTimer:(BOOL)hastimer interval:(NSUInteger)inter{
    WMCarouselView * carousel = [[WMCarouselView alloc] initWithFrame:frame];
    carousel.hasTimer = hastimer;
    carousel.interval = inter;
    [carousel setupWithArray:array];
    return carousel;
}

+(instancetype)initWithFrame:(CGRect)frame hasTimer:(BOOL)hastimer interval:(NSUInteger)inter placeHolder:(UIImage *)image{
    
    WMCarouselView * carousel = [[WMCarouselView alloc] initWithFrame:frame];
    carousel.placeHolder = image;
    carousel.hasTimer = hastimer;
    carousel.interval = inter;
    carousel.mask.image = image;
    return carousel;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.mask = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.wheelScrollView];
        [self addSubview:self.wheelPageControl];
        [self addSubview:self.mask];
        self.wheelScrollView.scrollEnabled = NO;
    }
    return self;
}

-(void) setupWithArray:(NSArray *)array{
    
    self.imageArray = nil;
    self.wheelScrollView.scrollEnabled = YES;
    self.mask.hidden = YES;
    self.imageArray = nil;
    self.imageArray = array;
    self.imageNum = self.imageArray.count;
    self.currentImageIndex = 0;
    
    if (array.count == 1) {
        self.interval = 9999;
    }
    
    if (self.imageNum == 1) {
        self.wheelPageControl.hidden = YES;
        self.wheelScrollView.scrollEnabled = NO;
    }
    
    [self setup];
}

-(void) setupWithLocalArray:(NSArray *)array{
    self.imageArray = nil;
    self.isLocal = YES;
    self.wheelScrollView.scrollEnabled = YES;
    self.mask.hidden = YES;
    self.imageArray = array;
    self.imageNum = self.imageArray.count;
    self.currentImageIndex = 0;
    
    if (array.count == 1) {
        self.interval = 9999;
    }
    
    if (self.imageNum == 1) {
        self.wheelPageControl.hidden = YES;
        self.wheelScrollView.scrollEnabled = NO;
    }
    
    [self setup];
}

-(void) setup{
    
    self.wheelPageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.wheelPageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    CGPoint p = CGPointMake(self.frame.size.width * 0.5, 0.9 * self.frame.size.height);
    self.wheelPageControl.center = p;
    
    [self.timer invalidate];
    if (self.hasTimer) {
        [self setupTimer];
    }
    [self updateImage];
}

- (void) updateImage{
    self.imageNum = (int)self.imageArray.count;
    self.wheelPageControl.numberOfPages = self.imageNum;
    [self updateScrollImage];
}

- (void) updateWheel{
    
    [_wheelScrollView setContentOffset:CGPointMake(_wheelScrollView.contentOffset.x +ScrollWidth, 0) animated:YES];
}

-(void) updateScrollImage{
    int left;
    int right;
    int page = self.wheelScrollView.contentOffset.x / self.wheelScrollView.frame.size.width;
    if (page == 0) {
        self.currentImageIndex = (self.currentImageIndex + self.imageNum - 1) % self.imageNum;
    }else if(page == 2){
        self.currentImageIndex = (self.currentImageIndex + 1) % self.imageNum;
    }
    
    left = (int)(self.currentImageIndex + self.imageNum -1) % self.imageNum;
    right = (int)(self.currentImageIndex + 1) % self.imageNum;
    if (self.isLocal) {
        self.image1.image = [UIImage imageNamed:self.imageArray[left]];
        self.image2.image = [UIImage imageNamed:self.imageArray[self.self.currentImageIndex]];
        self.image3.image = [UIImage imageNamed:self.imageArray[right]];
    }else{
        if (left == -1) {
            
        }else{
            if ([self.imageArray count]) {
                [self.image1 sd_setImageWithURL:[NSURL URLWithString:self.imageArray[left]] placeholderImage:self.placeHolder];
                [self.image2 sd_setImageWithURL:[NSURL URLWithString:self.imageArray[self.currentImageIndex]] placeholderImage:self.placeHolder];
                [self.image3 sd_setImageWithURL:[NSURL URLWithString:self.imageArray[right]] placeholderImage:self.placeHolder];
            }
        }
    }
    
    self.wheelPageControl.currentPage = self.currentImageIndex;
    [self.wheelScrollView setContentOffset:CGPointMake(self.wheelScrollView.frame.size.width, 0) animated:NO];
}

-(void) setupTimer{
    if (self.interval == 0) {
        self.interval = 3;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(updateWheel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void) touch{
    
    if ([self.delegate respondsToSelector:@selector(carouselTouch:atIndex:)]) {
        [self.delegate carouselTouch:self atIndex:self.currentImageIndex];
    }
}

-(void) destroy{
    [self.timer invalidate];
}

#pragma mark - UIScrollView
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self updateScrollImage];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateScrollImage];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.timer invalidate];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self setupTimer];
}


#pragma mark - Getter
-(UIScrollView *)wheelScrollView{
    if (!_wheelScrollView) {
        _wheelScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _wheelScrollView.backgroundColor = [UIColor clearColor];
        _wheelScrollView.pagingEnabled = YES;
        _wheelScrollView.delegate = self;
        _wheelScrollView.showsHorizontalScrollIndicator = NO;
        _wheelScrollView.showsVerticalScrollIndicator = NO;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
        [_wheelScrollView addGestureRecognizer:tap];
        
        _image1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _image2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        _image3 = [[UIImageView alloc] initWithFrame:CGRectMake(2*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        _image2.image = self.placeHolder;
        
        for (UIImageView * img in @[_image1,_image2,_image3]) {
            [_wheelScrollView addSubview:img];
        }
        
        [_wheelScrollView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
        _wheelScrollView.scrollEnabled = YES;
        _wheelScrollView.contentSize = CGSizeMake(3*self.frame.size.width, self.frame.size.height);
    }
    return _wheelScrollView;
}

-(UIPageControl *)wheelPageControl{
    if (!_wheelPageControl) {
        _wheelPageControl = [[UIPageControl alloc] init];
        [_wheelPageControl setBackgroundColor:[UIColor clearColor]];
        _wheelPageControl.currentPage = 0;
        _wheelPageControl.numberOfPages = self.imageNum;
    }
    return _wheelPageControl;
}


@end
