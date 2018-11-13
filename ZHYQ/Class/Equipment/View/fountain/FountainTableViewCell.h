//
//  FountainTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FountainModel.h"

@protocol ConSwitchDelegate <NSObject>

- (void)conSwitch:(BOOL)on withModel:(FountainModel *)fountainModel;

@end

@interface FountainTableViewCell : UITableViewCell

@property (nonatomic,strong) FountainModel *model;
@property (nonatomic,assign) id<ConSwitchDelegate> conSwitchDelegate;

@end
