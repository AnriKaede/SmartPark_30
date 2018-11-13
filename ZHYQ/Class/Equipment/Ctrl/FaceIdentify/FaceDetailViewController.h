//
//  FaceDetailViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
#import "FaceListModel.h"

@interface FaceDetailViewController : BaseTableViewController

@property (nonatomic,retain) FaceListModel *faceListModel;

@property (nonatomic,copy) NSString *faceBase64;
@property (nonatomic,retain) UIImage *orgImage;

@end
