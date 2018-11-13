
#import <Foundation/Foundation.h>

@interface NSString (HexString)
/// 16进制字符串转换成普通字符串
+ (NSString *)stringFromHexString:(NSString *)hexString;
/// 普通字符串转换成16进制字符串
+ (NSString *)hexStringFromString:(NSString *)string;
+ (NSString *)stringWithHexNumber:(NSUInteger)hexNumber;
+ (NSInteger)numberWithHexString:(NSString *)hexString;
- (NSString *)stringWithHexString:(NSString *)hexString;
/// 随机32位字符串
+ (NSString *)random32String;
@end
