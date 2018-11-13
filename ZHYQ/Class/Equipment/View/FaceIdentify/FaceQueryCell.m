//
//  FaceQueryCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/2.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "FaceQueryCell.h"

@implementation FaceQueryCell
{
    __weak IBOutlet UIButton *_queryBu;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _queryBu.layer.cornerRadius = 4;
    _queryBu.layer.borderColor = CNavBgColor.CGColor;
    _queryBu.layer.borderWidth = 0.6;
    
//    _queryBu.layer.shadowColor = CNavBgColor.CGColor;
//    _queryBu.layer.shadowOffset = CGSizeMake(4, 4);
//    _queryBu.layer.shadowOpacity= 0.8;
//    _queryBu.layer.shadowRadius = 4;
}

- (IBAction)faceQuery:(id)sender {
    if(_faceDelegate && [_faceDelegate respondsToSelector:@selector(faceQuery)]){
        [_faceDelegate faceQuery];
    }
}


@end
