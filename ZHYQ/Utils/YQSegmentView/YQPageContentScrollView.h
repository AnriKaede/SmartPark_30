//
//  YQPageContentScrollView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YQPageContentScrollView;

@protocol YQPageContentScrollViewDelegate <NSObject>
/// SGPageContentScrollViewDelegate 的代理方法
- (void)pageContentScrollView:(YQPageContentScrollView *)pageContentScrollView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex;
@end

@interface YQPageContentScrollView : UIView
/**
 *  对象方法创建 SGPageContentScrollView
 *
 *  @param frame     frame
 *  @param parentVC     当前控制器
 *  @param childVCs     子控制器个数
 */
- (instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC childVCs:(NSArray *)childVCs;
/**
 *  类方法创建 SGPageContentScrollView
 *
 *  @param frame     frame
 *  @param parentVC     当前控制器
 *  @param childVCs     子控制器个数
 */
+ (instancetype)pageContentScrollViewWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC childVCs:(NSArray *)childVCs;

/** SGPageContentScrollViewDelegate */
@property (nonatomic, weak) id<YQPageContentScrollViewDelegate> delegatePageContentScrollView;
/** 是否需要滚动 SGPageContentScrollView 默认为 YES；设为 NO 时，不必设置 SGPageContentScrollView 的代理及代理方法 */
@property (nonatomic, assign) BOOL isScrollEnabled;

/** 给外界提供的方法，获取 SGPageTitleView 选中按钮的下标 */
- (void)setPageCententScrollViewCurrentIndex:(NSInteger)currentIndex;

/// scrollView
@property (nonatomic, strong) UIScrollView *scrollView;

@end
