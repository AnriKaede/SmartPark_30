//
//  WaterTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WaterTableViewCell.h"
#import "YQSwitch.h"

@interface WaterTableViewCell()<switchTapDelegate>

@property (nonatomic,strong) UILabel *waterNameLab;

@property (nonatomic,strong) YQSwitch *yqSwtch;

@property (nonatomic,strong) UILabel *consumLab;

@property (nonatomic,strong) UILabel *consumDetailLab;

@property (nonatomic,strong) UILabel *timeSetLab;

@property (nonatomic,strong) UILabel *timeSetDetailLab;

@property (nonatomic,strong) UIImageView *alarmClockView;

@property (nonatomic,strong) UIView *sepLineView;

@end

@implementation WaterTableViewCell

-(UILabel *)waterNameLab{
    if (_waterNameLab == nil) {
        _waterNameLab = [[UILabel alloc] init];
        _waterNameLab.font = [UIFont systemFontOfSize:16];
        _waterNameLab.textColor = [UIColor blackColor];
        _waterNameLab.textAlignment = NSTextAlignmentLeft;
    }
    return _waterNameLab;
}

-(UILabel *)consumLab{
    if (_consumLab == nil) {
        _consumLab = [[UILabel alloc] init];
        _consumLab.font = [UIFont systemFontOfSize:16];
        _consumLab.textColor = [UIColor blackColor];
        _consumLab.textAlignment = NSTextAlignmentLeft;
    }
    return _consumLab;
}

-(UILabel *)consumDetailLab{
    if (_consumDetailLab == nil) {
        _consumDetailLab = [[UILabel alloc] init];
        _consumDetailLab.font = [UIFont systemFontOfSize:16];
        _consumDetailLab.textColor = [UIColor blackColor];
        _consumDetailLab.textAlignment = NSTextAlignmentRight;
    }
    return _consumDetailLab;
}

-(UILabel *)timeSetLab{
    if (_timeSetLab == nil) {
        _timeSetLab = [[UILabel alloc] init];
        _timeSetLab.font = [UIFont systemFontOfSize:16];
        _timeSetLab.textColor = [UIColor blackColor];
        _timeSetLab.textAlignment = NSTextAlignmentLeft;
    }
    return _timeSetLab;
}

-(UILabel *)timeSetDetailLab
{
    if (_timeSetDetailLab == nil) {
        _timeSetDetailLab = [[UILabel alloc] init];
        _timeSetDetailLab.font = [UIFont systemFontOfSize:16];
        _timeSetDetailLab.textColor = [UIColor blackColor];
        _timeSetDetailLab.textAlignment = NSTextAlignmentRight;
    }
    return _timeSetDetailLab;
}

-(UIImageView *)alarmClockView
{
    if (_alarmClockView == nil) {
        _alarmClockView = [[UIImageView alloc] init];
        _alarmClockView.image = [UIImage imageNamed:@"_dingshi_clock"];
    }
    return _alarmClockView;
}

-(YQSwitch *)yqSwtch
{
    if (_yqSwtch == nil) {
        _yqSwtch = [[YQSwitch alloc] init];
        _yqSwtch.onText = @"ON";
        _yqSwtch.offText = @"OFF";
        _yqSwtch.backgroundColor = [UIColor clearColor];
        _yqSwtch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
        _yqSwtch.tintColor = [UIColor colorWithHexString:@"FF4359"];
        _yqSwtch.switchDelegate = self;
    }
    return _yqSwtch;
}

-(UIView *)sepLineView
{
    if (_sepLineView == nil) {
        _sepLineView = [[UIView alloc] init];
        _sepLineView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    }
    return _sepLineView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _initView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

-(void)_initView
{
    [self.contentView addSubview:self.waterNameLab];
//    [self.contentView addSubview:self.consumLab];
//    [self.contentView addSubview:self.consumDetailLab];
//    [self.contentView addSubview:self.timeSetLab];
//    [self.contentView addSubview:self.timeSetDetailLab];
//    [self.contentView addSubview:self.alarmClockView];
    [self.contentView addSubview:self.yqSwtch];
//    [self.contentView addSubview:self.sepLineView];
    
    _waterNameLab.text = @"-";
    _waterNameLab.frame = CGRectMake(10, 25, 200, 15);
    
    _yqSwtch.frame = CGRectMake(KScreenWidth - 70, 0, 60, 30);
    _yqSwtch.centerY = _waterNameLab.centerY;
    
    /*
    _consumLab.text = @"消耗情况";
    _consumLab.frame = CGRectMake(10, CGRectGetMaxY(_waterNameLab.frame)+25, 100, 15);
    
    _consumDetailLab.text = @"耗水2吨 耗肥2吨";
    _consumDetailLab.frame = CGRectMake(CGRectGetMaxX(_consumLab.frame)+10, 0, KScreenWidth - CGRectGetMaxX(_consumLab.frame)-20, 15);
    _consumDetailLab.centerY = _consumLab.centerY;
    
    _timeSetLab.text = @"定时设置";
    _timeSetLab.frame = CGRectMake(10, CGRectGetMaxY(_consumLab.frame)+25, 100, 15);
    
    _alarmClockView.frame = CGRectMake(KScreenWidth - 30, 0, 20, 20);
    _alarmClockView.centerY = _timeSetLab.centerY;
    
    _timeSetDetailLab.text = @"10:00定时关";
    _timeSetDetailLab.frame = CGRectMake(CGRectGetMaxX(_timeSetLab.frame)+10, 0, KScreenWidth - CGRectGetMaxX(_timeSetLab.frame)-50, 15);
    _timeSetDetailLab.centerY = _timeSetLab.centerY;
     */
    
    _sepLineView.frame = CGRectMake(0, self.height - 0.5, KScreenWidth, 0.5);
}

-(void)setModel:(WaterModel *)model
{
    _model = model;
    
    _waterNameLab.text = [NSString stringWithFormat:@"%@",model.device_name];
    if (model.ctrl_status.integerValue == 3 ) {
        _yqSwtch.on = NO;
    }else{
        _yqSwtch.on = YES;
    }
    
    /*
    _consumDetailLab.text = [NSString stringWithFormat:@"耗水%@吨,耗肥%@吨",model.waterCost,model.fertilizerCost];
    
    _timeSetDetailLab.text = [NSString stringWithFormat:@"%@-%@",model.onTime,model.offTime];
     */
}


#pragma mark 定时设置

-(void)_timeSetTap:(id)sender
{
    
}

#pragma mark 浇灌的开关
-(void)switchTap:(BOOL)on {
    
    [_switchDelegate switchWater:_model withOpen:_yqSwtch.on withAllCon:NO];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
