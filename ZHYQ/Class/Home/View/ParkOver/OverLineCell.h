//
//  OverLineCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverAlarmModel.h"
#import "OverCheckModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverLineCell : UITableViewCell

@property (nonatomic,strong) NSNumber *totalCount;

@property (nonatomic,retain) OverAlarmModel *alarmModel;
@property (nonatomic,retain) OverCheckModel *checkModel;

@property (nonatomic,copy) NSString *colorStr;

@end

NS_ASSUME_NONNULL_END
