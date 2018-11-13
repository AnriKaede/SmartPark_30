//
//  CardUserInfoCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/21.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "CardUserInfoCell.h"

@implementation CardUserInfoCell
{
    __weak IBOutlet UILabel *_menuNameLabel;
    __weak IBOutlet UILabel *_infoLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setInfoDic:(NSDictionary *)infoDic {
    _infoDic = infoDic;
    
//    @"title":title,
//    @"info":@"",
//    @"editFlag":@1
    
    _menuNameLabel.text = infoDic[@"title"];
    _infoLabel.text = infoDic[@"info"];
    NSNumber *editFlag = infoDic[@"editFlag"];
    if(editFlag.integerValue == 0){
        self.accessoryType = UITableViewCellAccessoryNone;
    }else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

@end
