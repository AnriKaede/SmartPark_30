//
//  FaceHistoryCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/13.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "FaceHistoryCell.h"

@implementation FaceHistoryCell
{
    __weak IBOutlet UIImageView *_imgView;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _imgView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
}

@end
