//
//  AuthorityCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AuthorityCell.h"

@implementation AuthorityCell
{
    __weak IBOutlet UIView *_topBgView;
    
    __weak IBOutlet UILabel *_doorNumLabel;
    
    __weak IBOutlet UIImageView *_doorImgView;
    
}

-(void)setModel:(DoorModel *)model
{
    _model = model;
    _doorNumLabel.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    
    if ([model.DOOR_STATUS isEqualToString:@"1"]) {
        _doorImgView.image = [UIImage imageNamed:@"door_close"];
        _topBgView.backgroundColor = [UIColor colorWithHexString:@"757575"];
    }else if([model.DOOR_STATUS isEqualToString:@"0"]){
        _doorImgView.image = [UIImage imageNamed:@"door_close"];
        _topBgView.backgroundColor = [UIColor colorWithHexString:@"757575"];
    }else{
        _doorImgView.image = [UIImage imageNamed:@"door_open"];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
