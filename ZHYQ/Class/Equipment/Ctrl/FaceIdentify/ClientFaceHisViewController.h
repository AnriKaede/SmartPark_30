//
//  ClientFaceHisViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/29.
//  Copyright © 2018 焦平. All rights reserved.
//

/**
 请求服务器历史数据
 */
#import "RootViewController.h"
#import "FaceHistoryModel.h"

@protocol SelClientHistoryImgDelegate <NSObject>

- (void)selHistoryImg:(FaceHistoryModel *)faceHistoryModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ClientFaceHisViewController : RootViewController
@property (nonatomic,assign) id<SelClientHistoryImgDelegate> selClientHistoryImgDelegate;
@end

NS_ASSUME_NONNULL_END
