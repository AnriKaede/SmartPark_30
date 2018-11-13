//
//  ReservedDelViewController.m
//  TCBuildingSluice
//
//  Created by 魏唯隆 on 2018/8/27.
//  Copyright © 2018年 魏唯隆. All rights reserved.
//

#import "ReservedDelViewController.h"

@interface ReservedDelViewController ()
{
    __weak IBOutlet UILabel *_beginTimeLabel;
    __weak IBOutlet UILabel *_endTimeLabel;
    
    __weak IBOutlet UILabel *_visNameLabel; // - (
    __weak IBOutlet UILabel *_phoneLabel;
    __weak IBOutlet UILabel *_sexLabel; // )  女
    
    __weak IBOutlet UILabel *_peopleLabel;
    __weak IBOutlet UILabel *_carNoLabel;
    __weak IBOutlet UIImageView *_codeImgView;
    
    __weak IBOutlet UILabel *_reservedTimeLabel;
    
}
@end

@implementation ReservedDelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"预约详情";
    
    self.tableView.tableFooterView = [UIView new];
    
    [self _initView];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _beginTimeLabel.text = [self timeStrWithInt:_reservedModel.beginTime];
    
    _endTimeLabel.text = [self timeStrWithInt:_reservedModel.endTime];
    
    _visNameLabel.text = [NSString stringWithFormat:@"%@ (", _reservedModel.visitorName];
    
    _phoneLabel.text = [NSString stringWithFormat:@"%@", _reservedModel.visitorPhone];
    
    NSString *sex = _reservedModel.visitorSex;
    if(sex != nil && ![sex isKindOfClass:[NSNull class]]){
        if([sex isEqualToString:@"1"]){
            _sexLabel.text = @")  男";
        }else if([sex isEqualToString:@"2"]){
            _sexLabel.text = @")  女";
        }else {
            _sexLabel.text = @")  ";
        }
    }else {
        _sexLabel.text = @")  ";
    }
    
    if(_reservedModel.persionWith != nil && ![_reservedModel.persionWith isKindOfClass:[NSNull class]]){
        _peopleLabel.text = [NSString stringWithFormat:@"%@", _reservedModel.persionWith];
    }else {
        _peopleLabel.text = @"无";
    }
    if(_reservedModel.carNo != nil && ![_reservedModel.carNo isKindOfClass:[NSNull class]]){
        _carNoLabel.text = [NSString stringWithFormat:@"%@", _reservedModel.carNo];
    }else {
        _carNoLabel.text = @"无";
    }
    
    if(_reservedModel.qrCode != nil && ![_reservedModel.qrCode isKindOfClass:[NSNull class]] && _reservedModel.qrCode.length > 0){
        [_codeImgView sd_setImageWithURL:[NSURL URLWithString:_reservedModel.qrCode]];
    }
    
    _reservedTimeLabel.text = [self timeStrWithInt:_reservedModel.createTime];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)timeStrWithInt:(NSNumber *)time {
    if(time == nil || [time isKindOfClass:[NSNull class]]){
        return @"";
    }
    //时间戳转化成时间
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:time.doubleValue/1000.0];
    return [stampFormatter stringFromDate:stampDate];
}

@end
