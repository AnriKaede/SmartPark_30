//
//  RobotInfoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/28.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RobotInfoModel : BaseModel

/*
{
    headVersion = "RMB101-001-MCU-A0.00";
    kernelVersion = "3.10.0";
    model = "RMB101-8MIC";
    numberVersion = "RMB101-SY8-A3.0.8";
    pinboardVersion = "RMB101-001-A8.3.3";
    pleuralVersion = "RMB101-002-MCU-A0.06";
    rosVersion = "RMB101-ROS-I3-C1.07.23";
    version = "4.4.4";
}
 */

@property (nonatomic,copy) NSString *headVersion;
@property (nonatomic,copy) NSString *kernelVersion;
@property (nonatomic,copy) NSString *model;
@property (nonatomic,copy) NSString *numberVersion;
@property (nonatomic,copy) NSString *pinboardVersion;
@property (nonatomic,copy) NSString *pleuralVersion;
@property (nonatomic,copy) NSString *rosVersion;
@property (nonatomic,copy) NSString *version;

@end

NS_ASSUME_NONNULL_END
