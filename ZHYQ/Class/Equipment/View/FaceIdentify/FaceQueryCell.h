//
//  FaceQueryCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/2.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FaceQueryDelegate <NSObject>

- (void)faceQuery;

@end

@interface FaceQueryCell : UITableViewCell

@property (nonatomic,assign) id<FaceQueryDelegate> faceDelegate;

@end
