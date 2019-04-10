//
//  DHStreamSelectView.h
//  Pods
//
//  Created by Li_JinLin on 17/3/7.
//
//

#import <UIKit/UIKit.h>

@protocol DSSRealStreamViewDelegate<NSObject>
//DSSRealStreamView
- (void)DSSStreamPanelDelegateSelectHD;
- (void)DSSStreamPanelDelegateSelectSD;
- (void)DSSStreamPanelDelegateSelectLC;
@end

@interface DHStreamSelectView : UIView

@property (nonatomic, weak)   id<DSSRealStreamViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *HDButton;
@property (weak, nonatomic) IBOutlet UIButton *SDButton;
@property (weak, nonatomic) IBOutlet UIButton *LCButton;
- (void)resetHDViewButtonStatue;
- (void)resetHDBtnSelectedStatue:(NSInteger)index;
@end
