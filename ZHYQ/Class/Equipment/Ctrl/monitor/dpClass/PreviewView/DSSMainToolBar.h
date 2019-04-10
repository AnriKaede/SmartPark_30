//
//  DSSMainToolBar.h
//  Pods
//
//  Created by Li_JinLin on 17/2/20.
//
//

#import <UIKit/UIKit.h>

@protocol DSSMainToolBarDelegate <NSObject>
- (void)mainToolbarViewDidClickSnapshot;
- (void)mainToolbarViewDidClickRecord:(BOOL)isOn;
- (void)mainToolbarViewDidClickTalk:(BOOL)isOn;
- (void)mainToolbarViewDidClickPTZ:(BOOL)isOn;
@end


@interface DSSMainToolBar : UIView

@property (weak, nonatomic) IBOutlet UIButton *snapShotBtn; //截图 snapShot
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;   //录像 record
@property (weak, nonatomic) IBOutlet UIButton *talkBtn;     //对讲 talk
@property (weak, nonatomic) IBOutlet UIButton *ptzBtn;      //云台 ptz
@property (nonatomic, weak)   id<DSSMainToolBarDelegate> delegate;

-(void)setButtonIndex:(int)ind Selected:(BOOL)isSelected;
-(void)setButtonIndex:(int)ind Enabled:(BOOL)isEnabled;
-(void)isBtnEnable:(BOOL)isEnable;
@end
