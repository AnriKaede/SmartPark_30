//
//  AirMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AirConditionModel;

@protocol AirMenuDelegate <NSObject>


/**
 点击切换空调

 @param model 空调点位模型
 */
- (void)cutAirControl:(AirConditionModel *)model;

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

@interface AirMenuView : UIView

@property (nonatomic,assign) id<AirMenuDelegate> airMenuDelegate;

@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSArray *devices;
//@property (nonatomic,copy) NSDictionary *stateDic;
@property (nonatomic, retain) AirConditionModel *airConditionModel;

- (void)reloadMenu;

@end
