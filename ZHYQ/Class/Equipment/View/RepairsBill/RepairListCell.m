//
//  RepairListCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RepairListCell.h"

@implementation RepairListCell
{
    __weak IBOutlet UIView *_nameBgView;
    
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UIImageView *_stateImgView;
    
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_infoLabel;
    
    __weak IBOutlet UIButton *_leftBt;
    __weak IBOutlet UIButton *_rightBt;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _nameBgView.layer.cornerRadius = _nameBgView.width/2;
    _nameBgView.layer.borderColor = [UIColor colorWithHexString:@"#FF4359"].CGColor;
    _nameBgView.layer.borderWidth = 0.8;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (IBAction)dealProgressAction:(id)sender {
    if(_repairMethodDelegate != nil && [_repairMethodDelegate respondsToSelector:@selector(progressMethod:)]){
        [_repairMethodDelegate progressMethod:_billListModel];
    }
}

- (IBAction)rightsAction:(id)sender {
    if(_repairMethodDelegate != nil && [_repairMethodDelegate respondsToSelector:@selector(rightMethod:)]){
        [_repairMethodDelegate rightMethod:_billListModel];
    }
}

- (void)setBillListModel:(BillListModel *)billListModel {
    _billListModel = billListModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", billListModel.createrName];
    
    _timeLabel.text = [self timeForTimeStr:[NSString stringWithFormat:@"%@", billListModel.createDate]];
    
    [_rightBt setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
    NSString *orderState = [NSString stringWithFormat:@"%@", billListModel.orderState];
    // 01 派单 02 处理中 03 完成  04无效
    if([orderState isEqualToString:@"01"]){
        _stateImgView.image = [UIImage imageNamed:@"repairs_un_receive"];
        [_leftBt setTitle:@"处理进度" forState:UIControlStateNormal];
        [_rightBt setTitle:@"立即派单" forState:UIControlStateNormal];
        
    }else if([orderState isEqualToString:@"02"]){
        _stateImgView.image = [UIImage imageNamed:@"repairs_ing"];
        [_leftBt setTitle:@"处理进度" forState:UIControlStateNormal];
        [_rightBt setTitle:@"提醒维修" forState:UIControlStateNormal];
        [_rightBt setTitleColor:[UIColor colorWithHexString:@"#929292"] forState:UIControlStateNormal];
        
    }else if([orderState isEqualToString:@"03"]){
        _stateImgView.image = [UIImage imageNamed:@"repairs_complete"];
        [_leftBt setTitle:@"处理进度" forState:UIControlStateNormal];
        [_rightBt setTitle:@"完成确认" forState:UIControlStateNormal];
        
    }else if([orderState isEqualToString:@"04"]){
        _stateImgView.image = [UIImage imageNamed:@"repairs_close"];
        [_leftBt setTitle:@"处理进度" forState:UIControlStateNormal];
        [_rightBt setTitle:@"维修结束" forState:UIControlStateNormal];
        [_rightBt setTitleColor:[UIColor colorWithHexString:@"#929292"] forState:UIControlStateNormal];
    }
    
    _infoLabel.text = [NSString stringWithFormat:@"%@", billListModel.alarmContent];
    
}

- (NSString *)timeForTimeStr:(NSString *)timeStr {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *expDate = [dateFormat dateFromString:timeStr];
    
    NSDateFormatter *inputDateFormat = [[NSDateFormatter alloc] init];
    [inputDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *inputStr = [inputDateFormat stringFromDate:expDate];
    
    return inputStr;
}

@end
