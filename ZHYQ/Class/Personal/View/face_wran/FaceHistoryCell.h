//
//  FaceHistoryCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/13.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceImgHistory+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface FaceHistoryCell : UICollectionViewCell

@property (nonatomic,assign) BOOL isShowDelete;

@property (nonatomic,retain) FaceImgHistory *faceImgHistory;

// 选中标识放入到model中
@property (nonatomic,assign) BOOL isSelDelete;;

@end

NS_ASSUME_NONNULL_END
