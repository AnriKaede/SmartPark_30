//
//  PostTimeTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "PostTimeTableViewCell.h"

@interface PostTimeTableViewCell ()
{
    __weak IBOutlet UILabel *tacticsLab;
    __weak IBOutlet UIImageView *listRightView;
    __weak IBOutlet UIView *tacticsBgView;
}

@end

@implementation PostTimeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    listRightView.userInteractionEnabled = YES;
    tacticsLab.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseTacticsAction)];
    [tacticsBgView addGestureRecognizer:tap];
    
}

//选择策略
-(void)chooseTacticsAction
{
    UIAlertController *act =[UIAlertController alertControllerWithTitle:nil message:@"上屏设置" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *manact =[UIAlertAction actionWithTitle:@"立即上屏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tacticsLab.text = @"立即上屏";
        if (self.delegate != nil&&[self.delegate respondsToSelector:@selector(ledPostTactics:)]) {
            [self.delegate ledPostTactics:LEDPostTacticsImmediately];
        }
    }];
    UIAlertAction *femaleact =[UIAlertAction actionWithTitle:@"定时上屏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tacticsLab.text = @"定时上屏";
        if (self.delegate != nil&&[self.delegate respondsToSelector:@selector(ledPostTactics:)]) {
            [self.delegate ledPostTactics:LEDPostTacticsDefiniteTime];
        }
    }];
    
    UIAlertAction *cacel =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [act addAction:manact];
    [act addAction:femaleact];
    [act addAction:cacel];
    [self.viewController presentViewController:act animated:YES completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
