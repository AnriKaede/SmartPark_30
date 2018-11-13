#import <Foundation/Foundation.h>
@interface BluetoothDeviceModel : NSObject
/// 锁的名字
@property (nonatomic, strong) NSString *name;
/// mac地址
@property (nonatomic, strong) NSString *macAddress;
/// 秘钥Hash
@property (nonatomic, strong) NSString *passwordHash;
@end
