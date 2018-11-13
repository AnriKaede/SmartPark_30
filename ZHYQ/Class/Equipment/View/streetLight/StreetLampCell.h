//
//  StreetLampCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/8.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreetLampSubModel.h"

@protocol selectConDelegate <NSObject>

- (void)selCon:(StreetLampSubModel *)streetLampSubModel;

@end

@interface StreetLampCell : UITableViewCell

@property (nonatomic, retain) StreetLampSubModel *streetLampSubModel;
@property (nonatomic,assign) id<selectConDelegate> selConDelegate;

@end
