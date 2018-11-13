//
//  OpenRecordCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OpenRecordCell.h"

@interface OpenRecordCell()

@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *typeLab;

@property (weak, nonatomic) IBOutlet UIImageView *nfcImgView;

@end

@implementation OpenRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(OpenRecordModel *)model
{
    _model = model;
    
    if(model.Base_PerName != nil && ![model.Base_PerName isKindOfClass:[NSNull class]]){
        _nameLab.text = [NSString stringWithFormat:@"%@",model.Base_PerName];
    }else {
        _nameLab.text = @"-";
    }
    
    if(model.Base_Access_DateTime != nil && ![model.Base_Access_DateTime isKindOfClass:[NSNull class]]){
        _timeLab.text = [NSString stringWithFormat:@"%@",[self  timeStrWithInt:[NSNumber numberWithString:[NSString stringWithFormat:@"%@", model.Base_Access_DateTime]]]];
    }else {
        _timeLab.text = @"";
    }
    
    
    if(model.Base_PerNo != nil && ![model.Base_PerNo isKindOfClass:[NSNull class]]){
        _numLab.text = [NSString stringWithFormat:@"%@",model.Base_PerNo];
    }else {
        _numLab.text = @"";
    }
    if ([model.Base_Card_Status isEqualToString:@"1"]) {
        _statusLab.text = @"成功";
        _statusLab.textColor = [UIColor colorWithHexString:@"#189517"];
        _typeLab.text = @"权限卡";
    }else{
        _statusLab.text = @"失败";
        _statusLab.textColor = [UIColor colorWithHexString:@"#FF4359"];
        _typeLab.text = @"非权限卡";
    }
    
    if(model.openDoorLogType != nil && ![model.openDoorLogType isKindOfClass:[NSNull class]] && [model.openDoorLogType isEqualToString:@"1"]){
        _nfcImgView.hidden = NO;
    }else {
        _nfcImgView.hidden = YES;
    }
    
}

- (void)setRemoteModel:(RemoteModel *)remoteModel {
    _remoteModel = remoteModel;
    
    // 用户端显示用户名，管理端、pc端区分显示
    if([remoteModel.APP_TYPE isEqualToString:@"user"]){
        // 用户端 查用户名
        if(remoteModel.CUST_NAME != nil && ![remoteModel.CUST_NAME isKindOfClass:[NSNull class]]){
            _nameLab.text = remoteModel.CUST_NAME;
        }else {
            _nameLab.text = @"";
        }
        
        // 卡号
        if(remoteModel.CERT_IDS != nil && ![remoteModel.CERT_IDS isKindOfClass:[NSNull class]]){
            _numLab.text = [NSString stringWithFormat:@"%@",remoteModel.CERT_IDS];
        }else {
            _numLab.text = @"";
        }
        
    }else if([remoteModel.APP_TYPE isEqualToString:@"admin"]){
        // 管理端
        _nameLab.text = remoteModel.OS_USER;
        
        _numLab.text = @"管理端";
    }else if([remoteModel.APP_TYPE isEqualToString:@"pc"]){
        // pc端
        _nameLab.text = remoteModel.OS_USER;
        
        _numLab.text = @"pc端";
    }else {
        _nameLab.text = @"-";
        
        _numLab.text = @"-";
    }
    
    if(remoteModel.CREATE_DATE != nil && ![remoteModel.CREATE_DATE isKindOfClass:[NSNull class]]){
        _timeLab.text = [NSString stringWithFormat:@"%@",[self timeStrWithInt:remoteModel.CREATE_DATE]];
    }else {
        _timeLab.text = @"";
    }
    
//    if(remoteModel.CERT_IDS != nil && ![remoteModel.CERT_IDS isKindOfClass:[NSNull class]]){
//        _numLab.text = [NSString stringWithFormat:@"%@",remoteModel.CERT_IDS];
//    }else {
//        _numLab.text = @"";
//    }
    
    if ([remoteModel.OS_RESULET isEqualToString:@"1"]) {    // 1成功 0失败
        _statusLab.text = @"成功";
        _statusLab.textColor = [UIColor colorWithHexString:@"#189517"];
    }else{
        _statusLab.text = @"失败";
        _statusLab.textColor = [UIColor colorWithHexString:@"#FF4359"];
    }
    
}

- (void)setIsRemote:(BOOL)isRemote {
    _isRemote = isRemote;
    
    if(isRemote){
        _typeLab.text = _nameLab.text;
        _nameLab.text = @"";
    }
    
}

- (NSString *)timeStrWithInt:(NSNumber *)time {
    //时间戳转化成时间
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:time.doubleValue/1000.0];
    return [stampFormatter stringFromDate:stampDate];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
