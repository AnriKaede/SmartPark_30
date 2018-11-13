//
//  AirConTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2018/1/13.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQSwitch.h"
#import "AirConditionModel.h"

@protocol AirCellSwitchDelegate <NSObject>

/**
 空调开关
 
 @param writeId 操作ID
 @param on 开关状态
 */
- (void)siwtchAir:(NSString *)writeId withDeviceId:(NSString *)deviceId withOn:(BOOL)on withModel:(AirConditionModel *)airModel;


/**
 模式切换
 
 @param writeId 操作ID
 */
- (void)modelCut:(NSString *)writeId withDeviceId:(NSString *)deviceId withModel:(AirConditionModel *)airModel;

/**
 温度控制
 @param tepm 温度
 @param writeId 操作ID
 */
- (void)tempCut:(NSString *)tepm withWriteId:(NSString *)writeId withDeviceId:(NSString *)deviceId withModel:(AirConditionModel *)airModel;

/**
 风速控制
 
 @param writeId 操作ID
 */
- (void)speedCut:(NSString *)writeId withDeviceId:(NSString *)deviceId withModel:(AirConditionModel *)airModel;

@end

@interface AirConTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *stateLab;

@property (weak, nonatomic) IBOutlet UIView *selectView;

@property (weak, nonatomic) IBOutlet UIImageView *modelImgView;
@property (weak, nonatomic) IBOutlet UILabel *modelLab;
@property (weak, nonatomic) IBOutlet UILabel *tempLab;
@property (weak, nonatomic) IBOutlet UIImageView *windSpeedImgView;
@property (weak, nonatomic) IBOutlet UILabel *windSpeedLab;

@property (weak, nonatomic) IBOutlet UIImageView *speedImgView;
@property (weak, nonatomic) IBOutlet UILabel *speedLab;

@property (weak, nonatomic) IBOutlet YQSwitch *openOrCloseSwitch;

@property (weak, nonatomic) IBOutlet UILabel *closeLab;

@property (weak, nonatomic) IBOutlet UIButton *reduceBt;

@property (weak, nonatomic) IBOutlet UIButton *addBt;

@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (weak, nonatomic) IBOutlet UIButton *modelBt;

@property (weak, nonatomic) IBOutlet UIButton *speedBt;

@property (nonatomic,assign) id<AirCellSwitchDelegate> switchDelegate;

@property (nonatomic,retain) AirConditionModel *model;

//@property (nonatomic,copy) NSDictionary *stateDic;

@end
