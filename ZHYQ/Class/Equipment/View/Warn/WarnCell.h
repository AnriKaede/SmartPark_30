//
//  WarnCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WranUndealModel.h"

typedef enum {
    WranUnDeal = 0,
    WranUnSend,
    WranRepairing
}WranBillStyle;

@interface WarnCell : UITableViewCell

@property (nonatomic,assign) WranBillStyle wranBillStyle;

@property (nonatomic,retain) WranUndealModel *wranModel;

@end
