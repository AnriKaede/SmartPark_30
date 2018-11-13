//
//  InquiryDeviceViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
@class DeviceInfoModel;

@protocol SelDeviceDelegate <NSObject>

- (void)selDevice:(DeviceInfoModel *)deviceInfoModel;

@end

@interface InquiryDeviceViewController : BaseTableViewController

@property (nonatomic,assign) id<SelDeviceDelegate> selDeviceDelegate;

@end
