//
//  AirBatchCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirLayerModel.h"

@protocol LayerSelDelegate <NSObject>

- (void)selLayer:(AirLayerModel *)airLayerModel withOn:(BOOL)on;

@end

@interface AirBatchCell : UITableViewCell

@property (nonatomic,retain) AirLayerModel *airLayerModel;
@property (nonatomic,assign) id<LayerSelDelegate> layerSelDelegate;

@end
