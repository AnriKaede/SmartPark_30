//
//  FaceHistoryViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/13.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "FaceImgHistory+CoreDataClass.h"

@protocol SelHistoryImgDelegate <NSObject>

- (void)selHistoryImg:(FaceImgHistory *)faceImgHistory;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FaceHistoryViewController : RootViewController
@property (nonatomic,assign) id<SelHistoryImgDelegate> selHistoryImgDelegate;
@end

NS_ASSUME_NONNULL_END
