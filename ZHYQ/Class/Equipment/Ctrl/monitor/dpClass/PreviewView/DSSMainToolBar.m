//
//  DSSMainToolBar.m
//  Pods
//
//  Created by Li_JinLin on 17/2/20.
//
//

#import "DSSMainToolBar.h"

@interface DSSMainToolBar ()

@property (strong, nonatomic) UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *capLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property (weak, nonatomic) IBOutlet UILabel *talkLabel;
@property (weak, nonatomic) IBOutlet UILabel *ptzLabel;

@end

@implementation DSSMainToolBar

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _view = [[[NSBundle mainBundle] loadNibNamed:@"DSSMainToolBar" owner:self options:nil] firstObject];
        _view.frame = self.bounds;
        [self addSubview:self.view];
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self.capLabel setText:@"Capture"];
    [self.recordLabel setText:@"Record"];
    [self.talkLabel setText:@"Talk"];
    [self.ptzLabel setText:@"Ptz"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.view.frame = self.bounds;
}

-(void)setButtonIndex:(int)ind Selected:(BOOL)isSelected
{
    switch (ind) {
        case 0:
            self.snapShotBtn.selected = isSelected;
            break;
        case 1:
            self.recordBtn.selected = isSelected;
            break;
        case 2:
            self.talkBtn.selected = isSelected;
            break;
        case 3:
            self.ptzBtn.selected = isSelected;
            break;
        default:
            break;
    }
    
}
-(void)setButtonIndex:(int)ind Enabled:(BOOL)isEnabled
{
    switch (ind) {
        case 0:
            self.snapShotBtn.enabled = isEnabled;
            break;
        case 1:
            self.recordBtn.enabled = isEnabled;
            break;
        case 2:
            self.talkBtn.enabled = isEnabled;
            break;
        case 3:
            self.ptzBtn.enabled = isEnabled;
            break;
        default:
            break;
    }
}
#pragma mark - btnAction

- (IBAction)snapBtnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainToolbarViewDidClickSnapshot)]) {
        [self.delegate mainToolbarViewDidClickSnapshot];
    }
}

- (IBAction)recordBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(mainToolbarViewDidClickRecord:)]) {
        [self.delegate mainToolbarViewDidClickRecord:!sender.selected];
    }
}
- (IBAction)talkBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(mainToolbarViewDidClickTalk:)]) {
        [self.delegate mainToolbarViewDidClickTalk:!sender.selected];
    }
    
}
- (IBAction)ptzBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(mainToolbarViewDidClickPTZ:)]) {
        [self.delegate mainToolbarViewDidClickPTZ:!sender.selected];
    }
    
}

-(void)isBtnEnable:(BOOL)isEnable{
    self.snapShotBtn.enabled = isEnable;
    self.recordBtn.enabled = isEnable;
    self.talkBtn.enabled = isEnable;
    self.ptzBtn.enabled = isEnable;
    if (isEnable) {
        [self.capLabel setTextColor:[UIColor blackColor]];
        [self.recordLabel setTextColor:[UIColor blackColor]];
        [self.talkLabel setTextColor:[UIColor blackColor]];
        [self.ptzLabel setTextColor:[UIColor blackColor]];
    } else {
        [self.capLabel setTextColor:[UIColor lightGrayColor]];
        [self.recordLabel setTextColor:[UIColor lightGrayColor]];
        [self.talkLabel setTextColor:[UIColor lightGrayColor]];
        [self.ptzLabel setTextColor:[UIColor lightGrayColor]];
    }
}

@end
