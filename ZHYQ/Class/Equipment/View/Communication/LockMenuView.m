//
//  LockMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LockMenuView.h"

@implementation LockMenuView
{
    __weak IBOutlet UIView *_alpBgView;
    
    __weak IBOutlet UIView *_menuBgView;
    
    __weak IBOutlet UIView *_topBgView;
    
    __weak IBOutlet UILabel *_numLabel;
    __weak IBOutlet UILabel *_stateLabel;
    __weak IBOutlet UILabel *_reasonLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_addressLabel;
    __weak IBOutlet UILabel *_modelLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _initView];
}

- (void)_initView {
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    
    UITapGestureRecognizer *hidTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidMenuAction)];
    [_alpBgView addGestureRecognizer:hidTap];
}

- (IBAction)closeAction:(id)sender {
}

- (IBAction)openLockAction:(id)sender {
}

- (IBAction)findAction:(id)sender {
}

- (void)hidMenuAction {
    self.hidden = YES;
}

- (void)reloadMenu {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    
    [self _initView];
    
    CGRect bgFrame = _menuBgView.frame;
    _menuBgView.frame = CGRectMake(bgFrame.origin.x, KScreenHeight, bgFrame.size.width, bgFrame.size.height);
    [UIView animateWithDuration:0.15 animations:^{
        _menuBgView.frame = bgFrame;
    }];
    
//    self.modelAry = _modelAry;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if(!hidden){
        CGRect bgFrame = _menuBgView.frame;
        _menuBgView.frame = CGRectMake(bgFrame.origin.x, KScreenHeight, bgFrame.size.width, bgFrame.size.height);
        [UIView animateWithDuration:0.15 animations:^{
            _menuBgView.frame = bgFrame;
        }];
    }
}

@end
