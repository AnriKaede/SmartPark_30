//
//  CarBlackListTabCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CarBlackListModel.h"

@protocol ChangeStateDelegate <NSObject>

- (void)changeState:(CarBlackListModel *)carBlackListModel;

@end

@interface CarBlackListTabCell : UITableViewCell

@property (nonatomic,retain) CarBlackListModel *model;
@property (nonatomic, assign) id<ChangeStateDelegate> changeStatedelegate;


@property (weak, nonatomic) IBOutlet UIView *headLineView;

@end
