//
//  SceneEditCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SceneEditCell.h"

@interface SceneEditCell()<UITextFieldDelegate>
{
    
}
@end

@implementation SceneEditCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _sceneNameTF.delegate = self;
}

- (void)setSceneName:(NSString *)sceneName {
    _sceneName = sceneName;
    
    _sceneNameTF.text = sceneName;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    _sceneName = text;
    
    if(_changeDelegate){
        [_changeDelegate changeText:text];
    }
    
    return YES;
}

@end
