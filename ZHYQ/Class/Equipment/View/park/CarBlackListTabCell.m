//
//  CarBlackListTabCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CarBlackListTabCell.h"

@implementation CarBlackListTabCell
{
    __weak IBOutlet UILabel *_carnoLabel;
    
    __weak IBOutlet UIButton *_stateBt;
    
    __weak IBOutlet UILabel *_noteLabel;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(CarBlackListModel *)model
{
    _model = model;
    
    _carnoLabel.text = [NSString stringWithFormat:@"%@",model.illegalCarno];
    
    // 备注
    if(model.illegalContent != nil && ![model.illegalContent isKindOfClass:[NSNull class]]){
        _noteLabel.text = [NSString stringWithFormat:@"备注: %@", model.illegalContent];
    }else {
        _noteLabel.text = @"";
    }
}

- (IBAction)changeState:(id)sender {
    if(_changeStatedelegate){
        [_changeStatedelegate changeState:_model];
    }
}

@end
