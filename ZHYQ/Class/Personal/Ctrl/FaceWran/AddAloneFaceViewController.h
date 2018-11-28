//
//  AddAloneFaceViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/24.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
#import "FaceWranModel.h"

@protocol FaceCompleteDelegate <NSObject>

- (void)faceComplete:(FaceWranModel *)model withIsAdd:(BOOL)isAdd;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AddAloneFaceViewController : BaseTableViewController

@property (nonatomic,copy) UIImage *selImg;
@property (nonatomic,assign) BOOL isAdd;

@property (nonatomic,assign) id<FaceCompleteDelegate> faceCompleteDelegate;

@property (nonatomic,retain) FaceWranModel *faceWranModel;

@end

NS_ASSUME_NONNULL_END
