//
//  ManholeListTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "ManholeCoverMapModel.h"
#import "NewCoverModel.h"

@protocol UnLockDelegate <NSObject>

- (void)unLockCover:(NewCoverModel *)model;

@end

@interface ManholeListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UILabel *holeNameLab;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UILabel *holeLocationLab;
@property (weak, nonatomic) IBOutlet UILabel *holeAreaLab;
@property (weak, nonatomic) IBOutlet UILabel *holeNumLab;
@property (weak, nonatomic) IBOutlet UILabel *holeNumDetailLab;
@property (weak, nonatomic) IBOutlet UILabel *holeLockLab;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;

@property (nonatomic,strong) NewCoverModel *model;
@property (nonatomic,assign) id<UnLockDelegate> unlockDelegate;

@end
