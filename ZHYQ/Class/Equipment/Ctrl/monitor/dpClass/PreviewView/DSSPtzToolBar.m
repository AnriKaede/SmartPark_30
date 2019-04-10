//
//  DSSPtzToolBar.m
//  Pods
//
//  Created by Li_JinLin on 17/2/22.
//
//

#import "DSSPtzToolBar.h"

@interface DSSPtzToolBar ()

@property (strong, nonatomic) UIView    *view;
@property (assign, nonatomic) NSInteger curSelectIndex;
@property (strong, nonatomic) UIButton  *curSelectBtn;
@end

@implementation DSSPtzToolBar

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _view = [[[NSBundle mainBundle] loadNibNamed:@"DSSPtzToolBar" owner:self options:nil] firstObject];
        [self addSubview:self.view];
        self.view.frame = self.bounds;
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
//重置按钮状态
//reset button status
-(void)resetButtonStatue{
        self.zoomBtn.selected = NO;
        self.focusBtn.selected = NO;
        self.ringBtn.selected = NO;
}

- (void)resetBtnSelectStatue:(NSInteger)index {
    switch (index) {
        case 0:
            self.focusBtn.selected = NO;
            self.ringBtn.selected = NO;
            break;
        case 1:
            self.zoomBtn.selected = NO;
            self.ringBtn.selected = NO;
            break;
        case 2:
            self.zoomBtn.selected = NO;
            self.focusBtn.selected = NO;
        default:
            break;
    }
}

#pragma mark - btnAction

- (IBAction)zoomBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(DSSPtzToolbarViewDidClickZoom:)]) {
        [self.delegate DSSPtzToolbarViewDidClickZoom:!sender.selected];
    }
}

- (IBAction)focusBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(DSSPtzToolbarViewDidClickFocus:)]) {
        [self.delegate DSSPtzToolbarViewDidClickFocus:!sender.selected];
    }
}

- (IBAction)ringBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(DSSPtzToolbarViewDidClickRing:)]) {
        [self.delegate DSSPtzToolbarViewDidClickRing:!sender.selected];
    }
}
- (IBAction)presetBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(DSSPtzToolbarViewDidClickPoint:)]) {
        [self.delegate DSSPtzToolbarViewDidClickPoint:!sender.selected];
    }
}

@end
