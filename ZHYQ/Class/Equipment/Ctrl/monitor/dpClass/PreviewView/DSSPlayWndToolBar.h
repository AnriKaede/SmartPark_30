//
//  DSSPlayWndToolBar.h
//  Pods
//
//  Created by Li_JinLin on 17/2/20.
//
//

#import <UIKit/UIKit.h>

@protocol DSSPlayWndToolBarDelegate <NSObject>
//DSSPlayWndToolBar
-(void)DSSPlayWndToolbarViewDidClickPlay:(BOOL)isOn;
-(void)DSSPlayWndToolbarViewDidClickVoice:(BOOL)isOn;
-(void)DSSPlayWndToolbarViewDidClickStream:(BOOL)isOn;
-(void)DSSPlayWndToolbarViewDidClickFav:(BOOL)isOn;
-(void)DSSPlayWndToolbarViewDidClickFull:(BOOL)isOn;
@end

@interface DSSPlayWndToolBar : UIView

@property (weak, nonatomic) IBOutlet UIButton *streamBtn;  //码流 stream
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;   //声音 voice
@property (weak, nonatomic) IBOutlet UIButton *playBtn;    //播放暂停 play
@property (nonatomic, weak)   id<DSSPlayWndToolBarDelegate> delegate;

-(void)setButtonIndex:(int)ind Selected:(BOOL)isSelected;
-(void)isBarBtnEnable:(BOOL)isEnable;
@end
