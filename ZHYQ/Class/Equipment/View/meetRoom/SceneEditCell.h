//
//  SceneEditCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextChangeDelegate <NSObject>

- (void)changeText:(NSString *)text;

@end

@interface SceneEditCell : UITableViewCell

@property (nonatomic,copy) NSString *sceneName;

@property (weak, nonatomic) IBOutlet UITextField *sceneNameTF;

@property (nonatomic,assign) id<TextChangeDelegate> changeDelegate;

@end
