//
//  OpenDoorAreaCltViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenDoorModel.h"

@interface OpenDoorAreaCltViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *areaName;
@property (nonatomic, retain) OpenDoorModel *openDoorModel;

@end
