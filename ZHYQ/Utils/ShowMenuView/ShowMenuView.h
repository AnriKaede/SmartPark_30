//
//  ShowMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SliderBlock)(float value);
typedef void(^SwitchBlock)(BOOL isOn);

typedef enum {
    DefaultConMenu = 0,     // 默认文字加文字菜单
    SwitchConMenu,      // 开关菜单
    SliderConMenu,      // 滑动条菜单
    ImgConMenu,         // 图片菜单
    TextAndImgConMenu   // 文字加图片菜单
}ShowMenuStyle;

@protocol MenuControlDelegate <NSObject>
@required

- (NSString *)menuTitleViewText;

- (NSInteger)menuNumInView;
- (CGFloat)menuHeightInView:(NSInteger)index;


/**
 左侧Title

 @param index 行编号
 @return 左侧Title文本
 */
- (NSString *)menuTitle:(NSInteger)index;

/**
 根据ShowMenuStyle菜单样式，设置信息

 @param index 当前行编号
 @return 菜单样式
 */
- (ShowMenuStyle)menuViewStyle:(NSInteger)index;

// ------------------------------------------------------------------------------------------
@optional

-(void)closeMenu;

/**
 左侧Title文本颜色
 
 @param index 行编号
 @return 左侧Title文本颜色
 */
- (UIColor *)menuTitleColor:(NSInteger)index;

/**
 左侧Title带图片
 
 @param index 行编号
 @return 左侧Title带图片 name
 */
- (NSString *)menuTitleImgName:(NSInteger)index;

/**
 右侧信息，当右边有信息时实现此协议

 @param index 当前行编号
 @return 右侧信息
 */
- (NSString *)menuMessage:(NSInteger)index;
/**
 右侧信息文本颜色，当右边有信息时实现此协议
 
 @param index 当前行编号
 @return 右侧信息文本颜色
 */
- (UIColor *)menuMessageColor:(NSInteger)index;

/**
 右侧图片名，当右边有图片时实现此协议
 
 @param index 当前行编号
 @return 右侧图片名
 */
- (NSString *)imageName:(NSInteger)index;
/**
 右侧图片大小，当右边为 单独 图片时实现此协议
 
 @param index 当前行编号
 @return 右侧图片大小
 */
- (CGSize)imageSize:(NSInteger)index;

/**
 当ShowMenuStyle为SwitchConMenu时实现此协议
 
 @param index 当前行编号
 @return 开关状态
 */
- (BOOL)isSwitch:(NSInteger)index;
/**
 当ShowMenuStyle为SwitchConMenu时实现此协议
 
 @param isOn 开关状态
 */
- (void)switchState:(NSInteger)index withSwitch:(BOOL)isOn;


/**
 滑动条最小值

 @param index index 当前行编号
 @return  滑动条最小值
 */
- (CGFloat)sliderMinValue:(NSInteger)index;


/**
 滑动条最大值

 @param index index 当前行编号
 @return 滑动条最大值
 */
- (CGFloat)sliderMaxValue:(NSInteger)index;

/**
 当ShowMenuStyle为SliderConMenu时实现此协议
 
 @param index 当前行编号
 @return 滑动条数值
 */
- (CGFloat)sliderDefValue:(NSInteger)index;
/**
 当ShowMenuStyle为SliderConMenu时实现此协议
 
 @param index 当前行编号
 @return 滑动条左右图片数组，数组包含两个元素
 */
- (NSArray *)sliderImgs:(NSInteger)index;
/**
当ShowMenuStyle为SliderConMenu时实现此协议

@param value slider手松开屏幕数值Value
*/
- (void)sliderChangeValue:(CGFloat)value;


/**
 Silder滑块单位

 @param index 行编号
 @return 滑块单位
 */
- (NSString *)silderUnit:(NSInteger)index;

- (NSString *)silderLeftTitle:(NSInteger)leftTitle;
- (NSString *)silderRightTitle:(NSInteger)rightTitle;

/**
 当某行可选中点击时实现(菜单有按钮点击也在此协议中监听)

 @param index 当前行编号
 */
- (void)didSelectMenu:(NSInteger)index;



/**
 是否有播放音乐菜单

 @return 是否有播放音乐菜单
 */
- (BOOL)isPlayMusicMenu;

// 音乐菜单
- (void)playMusic;
- (void)pauseMusic;
- (void)stopMusic;
- (void)upMusic;
- (void)downMusic;

@end

@interface ShowMenuView : UIView

@property (nonatomic, assign) id<MenuControlDelegate> menuDelegate;

@property (nonatomic, strong) UIView *menuBgView;

/**
 菜单重载方法
 */
- (void)reloadMenuData;

@end
