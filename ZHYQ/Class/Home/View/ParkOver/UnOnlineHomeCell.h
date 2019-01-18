//
//  UnOnlineHomeCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverOffLineModel.h"
#import "OverCloseListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnOnlineHomeCell : UITableViewCell

@property (nonatomic,retain) OverOffLineModel *offlineModel;

@property (nonatomic,retain) OverCloseListModel *overCloseListModel;

@end

NS_ASSUME_NONNULL_END
