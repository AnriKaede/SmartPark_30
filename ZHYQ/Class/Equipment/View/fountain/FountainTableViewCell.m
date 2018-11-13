//
//  FountainTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "FountainTableViewCell.h"
#import "YQSwitch.h"

@interface FountainTableViewCell()<switchTapDelegate>

@property (nonatomic,strong) UILabel *fountainNameLab;

@property (nonatomic,strong) YQSwitch *yqSwtch;

@property (nonatomic,strong) UILabel *timeSetLab;

@property (nonatomic,strong) UILabel *timeSetDetailLab;

@property (nonatomic,strong) UIImageView *alarmClockView;

@property (nonatomic,strong) UIView *sepLineView;

@end

@implementation FountainTableViewCell

-(UILabel *)fountainNameLab{
    if (_fountainNameLab == nil) {
        _fountainNameLab = [[UILabel alloc] init];
        _fountainNameLab.font = [UIFont systemFontOfSize:17];
        _fountainNameLab.textColor = [UIColor blackColor];
        _fountainNameLab.textAlignment = NSTextAlignmentLeft;
    }
    return _fountainNameLab;
}

-(UILabel *)timeSetLab{
    if (_timeSetLab == nil) {
        _timeSetLab = [[UILabel alloc] init];
        _timeSetLab.font = [UIFont systemFontOfSize:15];
        _timeSetLab.textColor = [UIColor blackColor];
        _timeSetLab.textAlignment = NSTextAlignmentLeft;
    }
    return _timeSetLab;
}

-(UILabel *)timeSetDetailLab
{
    if (_timeSetDetailLab == nil) {
        _timeSetDetailLab = [[UILabel alloc] init];
        _timeSetDetailLab.font = [UIFont systemFontOfSize:15];
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
//        [_yqSwtch addTarget:self action:@selector(_fountainOnOrOffClick:) forControlEvents:UIControlEventValueChanged];
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
    [self.contentView addSubview:self.fountainNameLab];
    [self.contentView addSubview:self.yqSwtch];
    /*
    [self.contentView addSubview:self.timeSetLab];
    [self.contentView addSubview:self.timeSetDetailLab];
    [self.contentView addSubview:self.alarmClockView];
    [self.contentView addSubview:self.sepLineView];
    */
     
    _fountainNameLab.text = @"-";
    _fountainNameLab.frame = CGRectMake(10, 30, 150, 20);
    
    _yqSwtch.frame = CGRectMake(KScreenWidth - 70, 0, 60, 30);
    _yqSwtch.centerY = _fountainNameLab.centerY;
    
    /*
    _timeSetLab.text = @"定时设置";
    _timeSetLab.frame = CGRectMake(10, CGRectGetMaxY(_fountainNameLab.frame)+25, 100, 15);
    
    _alarmClockView.frame = CGRectMake(KScreenWidth - 30, 0, 20, 20);
    _alarmClockView.centerY = _timeSetLab.centerY;
    
    _timeSetDetailLab.text = @"10:00定时关";
    _timeSetDetailLab.frame = CGRectMake(CGRectGetMaxX(_timeSetLab.frame)+10, 0, KScreenWidth - CGRectGetMaxX(_timeSetLab.frame)-50, 15);
    _timeSetDetailLab.centerY = _timeSetLab.centerY;
     */
    
    _sepLineView.frame = CGRectMake(0, 104.5, KScreenWidth, 0.5);

    
}

#pragma mark 开关按钮
-(void)switchTap:(BOOL)on {
    if(_conSwitchDelegate){
        [_conSwitchDelegate conSwitch:_yqSwtch.on withModel:_model];
    }
}

-(void)setModel:(FountainModel *)model {
    _model = model;
    
    _fountainNameLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    
    if(model.isOpen){
        _yqSwtch.on = YES;
    }else {
        _yqSwtch.on = NO;
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
