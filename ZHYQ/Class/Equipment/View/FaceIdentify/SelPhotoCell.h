//
//  SelPhotoCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelFacePhotoDelegate <NSObject>

- (void)selFacePhoto;
- (void)faceHistory;

@end

@interface SelPhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *selImgView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@property (nonatomic,assign) id<SelFacePhotoDelegate> selFaceDelegate;

- (void)imgCornerRadius;

@end
