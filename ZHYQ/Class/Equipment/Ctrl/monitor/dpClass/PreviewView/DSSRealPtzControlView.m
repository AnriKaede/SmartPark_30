//
//  DSSRealPtzControlView.m
//  Pods
//
//  Created by Li_JinLin on 17/3/2.
//
//

#import "DSSRealPtzControlView.h"

@interface DSSRealPtzControlView ()

@property (strong, nonatomic)UIView  *view;

@end

@implementation DSSRealPtzControlView

-(void)awakeFromNib{
    [super awakeFromNib];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _view = [[[NSBundle mainBundle] loadNibNamed:@"DSSRealPtzControlView" owner:self options:nil] firstObject];
        [self addSubview:self.view];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.view.frame = self.bounds;
}

//touchUpInside
- (IBAction)reduceBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ptzBtnClickReduce:touchDown:)]) {
        [self.delegate ptzBtnClickReduce:self.ptzType touchDown:YES];
    }
}
- (IBAction)addBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ptzBtnClickReduce:touchDown:)]) {
        [self.delegate ptzBtnClickAdd:self.ptzType touchDown:YES];
    }
}
//touchDown
- (IBAction)reduceBtnTouchDown:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ptzBtnClickReduce:touchDown:)]) {
        [self.delegate ptzBtnClickReduce:self.ptzType touchDown:NO];
    }
    
}
- (IBAction)addBtnTouchDown:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ptzBtnClickReduce:touchDown:)]) {
        [self.delegate ptzBtnClickAdd:self.ptzType touchDown:NO];
    }
}

-(void)setPtzType:(PtzControlType)ptzType{
    _ptzType = ptzType;
}

@end
