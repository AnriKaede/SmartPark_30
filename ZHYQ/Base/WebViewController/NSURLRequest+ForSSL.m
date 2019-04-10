//
//  NSURLRequest+ForSSL.m
//  XTF_SmartPart_UserTerminal
//
//  Created by 焦平 on 2019/3/25.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "NSURLRequest+ForSSL.h"

@implementation NSURLRequest (ForSSL)


+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}

+(void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host
{
    
}

@end
