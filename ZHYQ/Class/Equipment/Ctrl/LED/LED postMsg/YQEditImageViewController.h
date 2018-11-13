//
//  YQEditImageViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQEditImageViewController : UIViewController

/* 图片*/
@property(nonatomic,strong)NSMutableArray *images;
/* 当前位置*/
@property(nonatomic,assign)int currentOffset;
/* 部分刷新*/
@property(nonatomic,copy)void(^reloadBlock)(NSMutableArray *);

@end
