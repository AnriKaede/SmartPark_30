//
//  OpenRecordCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenRecordModel.h"

#import "RemoteModel.h"

@interface OpenRecordCell : UITableViewCell

@property (nonatomic,strong) OpenRecordModel *model;

@property (nonatomic,strong) RemoteModel *remoteModel;

@property (nonatomic,assign) BOOL isRemote;

@end
