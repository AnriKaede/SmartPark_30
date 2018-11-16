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

@property (nonatomic,retain) FaceImgHistory *faceImgHistory;

@end

NS_ASSUME_NONNULL_END
