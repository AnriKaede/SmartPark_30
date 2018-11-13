//
//  YQPhotoPickerView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQPhotoPickerView : UIView

/* 图片行数*/
@property(nonatomic, assign)    NSInteger rowCount;
/* 添加图片*/
@property(nonatomic, strong)    UIImage *addImage;
/* 当前选择的图片*/
@property(nonatomic, strong)    NSMutableArray *selectedImages;
/* 图片视图*/
@property(nonatomic,strong)     NSMutableArray *imageViews;
/* 刷新视图*/
@property(nonatomic, copy)void(^reloadTableViewBlock)(void);

@end
