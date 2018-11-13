//
//  FaceListViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "FaceQueryModel.h"

@interface FaceListViewController : RootViewController

@property (nonatomic,retain) FaceQueryModel *faceModel;

@property (nonatomic,copy) NSString *beginTime;
@property (nonatomic,copy) NSString *endTime;
@property (nonatomic,strong) NSNumber *threshold;

@property (nonatomic,retain) UIImage *orgImage;

@end
