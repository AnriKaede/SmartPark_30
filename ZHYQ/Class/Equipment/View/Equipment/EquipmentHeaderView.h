//
//  EquipmentHeaderView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/10/30.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQButton.h"
#import "ParentMenuModel.h"

typedef enum _equipmentEventType {
    equipmentEventFaulty  = 0,
    equipmentEventRepairOrderList,
    equipmentEventInfomationPost
} equipmentEventType;

@protocol equipmentClickDelegate

-(void)EquipmentBtnEvent:(equipmentEventType)type;

@end

@interface EquipmentHeaderView : UICollectionReusableView

@property (nonatomic,strong) YQButton *leftBtn;

@property (nonatomic,strong) YQButton *centerBtn;

@property (nonatomic,strong) YQButton *rightBtn;

@property (nonatomic,strong) UIView *vLineView;

@property (nonatomic,strong) UIView *titleBackGroundView;

@property (nonatomic,strong) UIImageView *hLineView;

@property (nonatomic,strong) UILabel *titleLab;

@property (nonatomic,strong) UIImageView *hLineView1;

@property (nonatomic,strong) UIImageView *hLineView2;

@property (nonatomic,assign) id<equipmentClickDelegate> delegate;

//@property (nonatomic,strong) NSMutableArray *dataArr;;

@property (nonatomic,retain) ParentMenuModel *parentMenuModel;

@property (nonatomic,copy) NSString *subTitle;


@end
