//
//  ChooseLedTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ChooseLedTableViewCell.h"
#import "LedListModel.h"

@interface ChooseLedTableViewCell ()
{
    __weak IBOutlet UIView *_bgView;
    
}

@end

@implementation ChooseLedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

- (void)setLedData:(NSArray *)ledData {
    _ledData = ledData;
    
    [ledData enumerateObjectsUsingBlock:^(LedListModel *ledListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *reButton = [_bgView viewWithTag:1000+idx];
        if(reButton == nil){
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 1000 + idx;
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.frame = CGRectMake(KScreenWidth/3 * (idx%3), idx/3 * 40, KScreenWidth/3, 40);
            [button setImage:[UIImage imageNamed:@"_round_normal"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"_round_select"] forState:UIControlStateSelected];
            [button setTitle:ledListModel.deviceName forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(selBt:) forControlEvents:UIControlEventTouchUpInside];
            [_bgView addSubview:button];
            
//            button.imageView.frame = CGRectMake(2, 10, 20, 20);
            button.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,20+(ledListModel.deviceName.length * 2));
        }
//        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, (KScreenWidth/3 - 20))];
    }];
}

- (void)selBt:(UIButton *)bt {
    bt.selected = !bt.selected;
    LedListModel *ledListModel = _ledData[bt.tag-1000];
    ledListModel.isSelect = bt.selected;
    
    if(_chooseLedDeleagte != nil && [_chooseLedDeleagte respondsToSelector:@selector(chooseLed:)]){
        [_chooseLedDeleagte chooseLed:_ledData];
    }
    bt.imageView.frame = CGRectMake(4, 10, 20, 20);
}

@end
