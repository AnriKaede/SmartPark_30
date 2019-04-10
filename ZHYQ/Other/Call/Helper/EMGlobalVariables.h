//
//  EMGlobalVariables.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HomeViewController.h"

NS_ASSUME_NONNULL_BEGIN

extern HomeViewController *gMainController;

extern BOOL gIsInitializedSDK;

extern BOOL gIsCalling;

@interface EMGlobalVariables : NSObject

+ (void)setGlobalMainController:(nullable HomeViewController *)aMainController;

@end

NS_ASSUME_NONNULL_END
