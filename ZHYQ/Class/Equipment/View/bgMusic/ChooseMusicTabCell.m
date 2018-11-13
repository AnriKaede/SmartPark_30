//
//  ChooseMusicTabCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ChooseMusicTabCell.h"

@interface ChooseMusicTabCell()
{
    
    __weak IBOutlet UILabel *_musicNameLab;
    
    __weak IBOutlet UILabel *_playStateLab;
    
    __weak IBOutlet UIButton *playBtn;
    
}

@end

@implementation ChooseMusicTabCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)_playThisMusicBtnClick:(id)sender {
    _model.isPlay = YES;
    if(_playMusicDelegate){
        [_playMusicDelegate playMusicWithFile:_model];
    }
}

-(void)setModel:(MusicListModel *)model
{
    _model = model;
    
    if (model.isPlay) {
        _playStateLab.hidden = NO;
        [playBtn setImage:[UIImage imageNamed:@"_choosemusic_stop_icon"] forState:UIControlStateNormal];
    }else{
        _playStateLab.hidden = YES;
        [playBtn setImage:[UIImage imageNamed:@"_choosemusic_play_icon"] forState:UIControlStateNormal];
    }
    
    _musicNameLab.text = [NSString stringWithFormat:@"%@",model.name];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
