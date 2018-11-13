#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, kQRCodeType) {
    kQRCodeType1,
    kQRCodeType2,
};
@class BluetoothDeviceModel;
@interface WHLockScanUtils : NSObject
+ (instancetype)sharedInstance;
/// 解析二维码 返回一个车位锁对象
- (BluetoothDeviceModel *)analyseQRCodeWithString:(NSString *)QRCode;
@end
