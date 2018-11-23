//
//  FaceWranCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/14.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceWranModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FaceWranCell : UICollectionViewCell

@property (nonatomic,assign) BOOL isDelete;
@property (nonatomic,retain) FaceWranModel *faceWranModel;

@end

NS_ASSUME_NONNULL_END
