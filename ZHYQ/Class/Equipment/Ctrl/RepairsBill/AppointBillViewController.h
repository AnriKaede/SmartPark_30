//
//  AppointBillViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/18.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
@class WranUndealModel;
@class BillListModel;

typedef enum {
    AppointSend = 0,    // 填写信息 派单  "确认派单"  有设备ID
    AppointUnDeal,      // 待接收派单，可提醒维修  "修改派单" "提醒维修"   有设备ID
    AppointRepairing,   // 维修中，只可查看进度  下放无按钮   有设备ID
    AppointComplete,    // 已完成维修，可确认完成，关闭派单 "重新维修" "确认完成"   有维修反馈   有设备ID
    AppointClose        // 已结束维修  下放无按钮  有维修反馈   有设备ID
}AppointState;

@interface AppointBillViewController : BaseTableViewController

@property (nonatomic,assign) AppointState appointState;

@property (nonatomic,retain) WranUndealModel *wranUndealModel;

@property (nonatomic,retain) BillListModel *billListModel;

@end
