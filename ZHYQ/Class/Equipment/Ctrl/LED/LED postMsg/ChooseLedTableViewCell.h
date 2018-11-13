//
//  ChooseLedTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LedListModel.h"

@protocol ChooseLedDeleagte <NSObject>

- (void)chooseLed:(NSArray *)ledList;

@end

@interface ChooseLedTableViewCell : UITableViewCell

@property (nonatomic,retain) NSArray *ledData;
@property (nonatomic,assign) id<ChooseLedDeleagte> chooseLedDeleagte;

@end
