//
//  CoverMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "CoverMenuView.h"

@implementation CoverMenuView
{
    __weak IBOutlet UIView *_alpBgView;
    
    __weak IBOutlet UIView *_menuBgView;
    __weak IBOutlet NSLayoutConstraint *_menuBgHeight;
    
    __weak IBOutlet UIView *_topBgView;
    
    __weak IBOutlet UILabel *_titlebel;
    
    __weak IBOutlet UILabel *_numLabel;
    __weak IBOutlet UILabel *_stateLabel;
    __weak IBOutlet UILabel *_eqStateLabel;
    
    __weak IBOutlet UILabel *_wranInfoTitleLabel;
    __weak IBOutlet UILabel *_wranInfoLabel;
    __weak IBOutlet UILabel *_timeTitleLabel;
    __weak IBOutlet UILabel *_timeLabel;
    
    __weak IBOutlet NSLayoutConstraint *_addressTop;
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
    [self hidMenuAction];
}

- (IBAction)findAction:(id)sender {
    if(_coverMenuDelegate && [_coverMenuDelegate respondsToSelector:@selector(queryCover:)]){
        [_coverMenuDelegate queryCover:_coverModel];
    }
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

- (void)setCoverModel:(CommnncCoverModel *)coverModel {
    _coverModel = coverModel;
    
    _titlebel.text = coverModel.deviceName;
    
    if(coverModel.runingStatus != nil && ![coverModel.runingStatus isKindOfClass:[NSNull class]]){
        if([coverModel.runingStatus isEqualToString:@"ABNORMAL"]){
            _eqStateLabel.textColor = [UIColor colorWithHexString:@"#FF2A2A"];
            _eqStateLabel.text = @"异常";
            
            [self eqWran:YES];
        }else if([coverModel.runingStatus isEqualToString:@"FAULT"]) {
            _eqStateLabel.textColor = [UIColor colorWithHexString:@"#FFB400"];
            _eqStateLabel.text = @"故障";
            [self eqWran:NO];
        }else  if([coverModel.runingStatus isEqualToString:@"NORMAL"]){
            _eqStateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
            _eqStateLabel.text = @"正常";
            [self eqWran:NO];
        }else {
            _eqStateLabel.text = @"正常";
            _eqStateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
            
            [self eqWran:NO];
        }
    }
    
    _stateLabel.text = @"在线";
    if(coverModel.state != nil && ![coverModel.state isKindOfClass:[NSNull class]]){
        if([coverModel.state isEqualToString:@"ONLINE"]){
            _stateLabel.text = @"在线";
        }else if([coverModel.runingStatus isEqualToString:@"OFFLINE"]) {
            _stateLabel.text = @"离线";
        }else if([coverModel.runingStatus isEqualToString:@"INBOX"]) {
            _stateLabel.text = @"停用";
        }
    }
    
    _numLabel.text = [NSString stringWithFormat:@"%@", coverModel.equipSn];
    _wranInfoLabel.text = [NSString stringWithFormat:@"%@", coverModel.stateDetail];
    _timeLabel.text = [NSString stringWithFormat:@"%@", coverModel.triggerDate];
    _addressLabel.text = [NSString stringWithFormat:@"%@", coverModel.addressInfo];
    _modelLabel.text = [NSString stringWithFormat:@"%@(%@)", coverModel.modelCode, coverModel.manufactureName];
}

- (void)eqWran:(BOOL)isWran {
    _wranInfoTitleLabel.hidden = !isWran;
    _wranInfoLabel.hidden = !isWran;
    _timeTitleLabel.hidden = !isWran;
    _timeLabel.hidden = !isWran;
    
    if(isWran){
        _addressTop.constant = 20;
        _menuBgHeight.constant = 400;
    }else {
        _addressTop.constant = -63;
        _menuBgHeight.constant = 317;
    }
}

@end
