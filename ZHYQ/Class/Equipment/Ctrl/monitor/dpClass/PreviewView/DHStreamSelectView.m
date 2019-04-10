//
//  DHStreamSelectView.m
//  Pods
//
//  Created by Li_JinLin on 17/3/7.
//
//

#import "DHStreamSelectView.h"

@interface DHStreamSelectView ()
@property (strong, nonatomic)UIView *view;
@end

@implementation DHStreamSelectView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _view = [[[NSBundle mainBundle] loadNibNamed:@"DHStreamSelectView" owner:self options:nil] firstObject];
        [self addSubview:self.view];
    }
    return self;
}

-(void)layoutSubviews{
    self.view.frame = self.bounds;
}

- (void)resetHDViewButtonStatue{
    self.SDButton.selected = NO;
    self.HDButton.selected = NO;
    self.LCButton.selected = NO;
}
- (void)resetHDBtnSelectedStatue:(NSInteger)index{
    switch (index) {
        case 1:
            self.HDButton.selected = YES;
            self.SDButton.selected = NO;
            self.LCButton.selected = NO;
            break;
        case 2:
            self.SDButton.selected = YES;
            self.HDButton.selected = NO;
            self.LCButton.selected = NO;
            break;
        case 3:
            self.LCButton.selected = YES;
            self.SDButton.selected = NO;
            self.HDButton.selected = NO;
            break;
        default:
            break;
    }
}
- (IBAction)SDBtnClick:(UIButton *)sender {
//    sender.selected = !sender.selected;
    if([self.delegate respondsToSelector:@selector(DSSStreamPanelDelegateSelectSD)])
    {
        [self.delegate DSSStreamPanelDelegateSelectSD];
    }
}
- (IBAction)HDBtnClick:(UIButton *)sender {
//    sender.selected = !sender.selected;
    if([self.delegate respondsToSelector:@selector(DSSStreamPanelDelegateSelectHD)])
    {
        [self.delegate DSSStreamPanelDelegateSelectHD];
    }
}
- (IBAction)LCBtnClick:(UIButton *)sender {
//    sender.selected = !sender.selected;
    if([self.delegate respondsToSelector:@selector(DSSStreamPanelDelegateSelectLC)])
    {
        [self.delegate DSSStreamPanelDelegateSelectLC];
    }
}



@end
