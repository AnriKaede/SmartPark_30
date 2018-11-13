//
//  DeviceTree.h
//  iDSSClient
//
//  Created by nobuts on 14-3-10.
//  Copyright (c) 2014年 mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

enum NodeType_e
{
    NODE_TYPE_DEP,
    NODE_TYPE_DEVICE,
    NODE_TYPE_CHANNEL,
};

//节点
@interface DeviceTreeNode : NSObject

typedef void(^QueryBlock)(DeviceTreeNode *node);

@property enum NodeType_e nodeType;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* cameraID;
@property (nonatomic,strong) NSMutableArray *Nodelist;//CameraNode数组
@property (nonatomic,strong) NSString* coding;
@property (nonatomic,strong) NSString* location;
@property (nonatomic,strong) NSString* company;
@property (nonatomic,strong) NSString* author;
@property (nonatomic,strong) NSString* contact;
@property (nonatomic,strong) NSString* phone;
@property (nonatomic,strong) NSString* device;
@property (nonatomic,assign) unsigned long long nChannelRight;   //通道权限
@property (nonatomic, assign) BOOL bSelected;
@property (nonatomic, assign) BOOL bOnline;
@property (nonatomic, assign) BOOL needHidden;
@property (nonatomic, strong) NSString* strCallNum;
@property (nonatomic, assign) DeviceTreeNode* parentNode;

- (DeviceTreeNode*)getGroupByName:(NSString*)strName;
- (void) addNode:(DeviceTreeNode*)node;
- (DeviceTreeNode*) nodeAtIndex:(int)nIndex;
- (int) count;
- (NSInteger)showCount; //需要显示子节点的数量

// 新增一个根据cameraID查找对应状态
- (void)queryNodeByCareraId:(NSString*)careraId withBlock:(QueryBlock)queryBlock;

@end

