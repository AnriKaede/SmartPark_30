//
//  DHPubfun.h
//  iDMSS
//
//  Created by Fei Wang on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DHPubfun : NSObject

+ (BOOL)illegalCharacterInString:(NSString*)cString;

+ (BOOL)AllNumerics:(NSString*)cString;

+ (NSString*) documentFolder;

+ (NSString*) supportFolder;

+ (BOOL) writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath;

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image waterPrint:(UIImage*)waterPrintImage size:(CGSize)asize;

@end
