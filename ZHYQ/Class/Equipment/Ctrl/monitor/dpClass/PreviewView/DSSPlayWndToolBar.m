//
//  DSSPlayWndToolBar.m
//  Pods
//
//  Created by Li_JinLin on 17/2/20.
//
//

#import "DSSPlayWndToolBar.h"

@interface DSSPlayWndToolBar ()
@property (strong, nonatomic) UIView *view;
@end


@implementation DSSPlayWndToolBar


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _view = [[[NSBundle mainBundle] loadNibNamed:@"DSSPlayWndToolBar" owner:self options:nil] firstObject];
        self.view.frame = self.bounds;
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.view.frame = self.bounds;
}

-(void)setButtonIndex:(int)ind Selected:(BOOL)isSelected
{
        switch (ind) {
            case 0:
                self.playBtn.selected = isSelected;
                break;
            case 1:
                self.voiceBtn.selected = isSelected;
                break;
            case 2:
                self.streamBtn.selected = isSelected;
                break;
            default:
                break;
        }
}

#pragma mark - btnAction
- (IBAction)playBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(DSSPlayWndToolbarViewDidClickPlay:)]) {
        [self.delegate DSSPlayWndToolbarViewDidClickPlay:!sender.selected];
    }
    
}

- (IBAction)voiceBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(DSSPlayWndToolbarViewDidClickVoice:)]) {
        [self.delegate DSSPlayWndToolbarViewDidClickVoice:!sender.selected];
    }
    
}

- (IBAction)streamBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(DSSPlayWndToolbarViewDidClickStream:)]) {
        [self.delegate DSSPlayWndToolbarViewDidClickStream:!sender.selected];
    }
}

-(void)isBarBtnEnable:(BOOL)isEnable{
    self.playBtn.enabled = isEnable;
    self.voiceBtn.enabled = isEnable;
    self.streamBtn.enabled = isEnable;
}

@end
