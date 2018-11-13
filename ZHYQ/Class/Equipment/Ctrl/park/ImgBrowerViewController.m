//
//  ImgBrowerViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ImgBrowerViewController.h"

@interface ImgBrowerViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_imgView;
}
@end

@implementation ImgBrowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale=2.0;
    _scrollView.minimumZoomScale=0.5;
    [self.view addSubview:_scrollView];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    _imgView = [[UIImageView alloc] init];
    [_scrollView addSubview:_imgView];
//    _imgUrlStr = @"http://www.qcxunbao.cn/eOut/upload/bann/aa.png";
    if(_imgUrlStr != nil && ![_imgUrlStr isKindOfClass:[NSNull class]] && _imgUrlStr.length > 0){
        [_imgView sd_setImageWithURL:[NSURL URLWithString:_imgUrlStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if(!error){
                CGFloat height = KScreenWidth/image.size.width*image.size.height;
                _imgView.frame = CGRectMake(0, (KScreenHeight - height)/2, KScreenWidth, height);
            }
        }];
    }
    
    UITapGestureRecognizer *hidTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidAction)];
    [self.view addGestureRecognizer:hidTap];
}

#pragma mark - Zoom methods
-(void)handleDoubleTap:(UIGestureRecognizer*)gesture
{
    CGFloat newScale = _scrollView.zoomScale*1.5;
    CGRect zoonRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [_scrollView zoomToRect:zoonRect animated:YES];
}
-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = _scrollView.frame.size.height / scale;
    zoomRect.size.width = _scrollView.frame.size.width /scale;
    zoomRect.origin.x = center.x -(zoomRect.size.width/2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height/2.0);
    return zoomRect;
}
#pragma mark - UIScrollViewDelegate

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imgView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale animated:NO];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imgView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                  scrollView.contentSize.height * 0.5 + offsetY);
    
}

#pragma mark -UITouch
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CGPoint touchPoint  = [[touches anyObject] locationInView:_imgView];
    NSValue *touchValue = [NSValue valueWithCGPoint:touchPoint];
//    [self performSelector:@selector(performTouchTestArea:)
//               withObject:touchValue
//               afterDelay:0.1];
}

#pragma mark 点击关闭图片
- (void)hidAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
