//
//  NSURLRequest+ForSSL.h
//  XTF_SmartPart_UserTerminal
//
//  Created by 焦平 on 2019/3/25.
//  Copyright © 2019 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (ForSSL)

+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;

+(void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;

@end

NS_ASSUME_NONNULL_END
