//
//  OverLineTableView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OverLineTableView : UITableView

@property (nonatomic,strong) NSNumber *totalCount;
@property (nonatomic,copy) NSArray *traceData;

@end

NS_ASSUME_NONNULL_END
