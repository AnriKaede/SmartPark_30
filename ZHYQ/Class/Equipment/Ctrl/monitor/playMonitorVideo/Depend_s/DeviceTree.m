//
//  DeviceTree.m
//  iDSSClient
//
//  Created by nobuts on 14-3-10.
//  Copyright (c) 2014年 mobile. All rights reserved.
//

#import "DeviceTree.h"

@implementation  DeviceTreeNode

- (id) init
{
    self = [super init];
    if (self) {
        _Nodelist  = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    return self;
}

- (void) addNode:(DeviceTreeNode*)node
{
    if (_Nodelist) {
        [_Nodelist addObject:node];
    }
}

- (DeviceTreeNode*) nodeAtIndex:(int)nIndex
{
    if (nIndex < [_Nodelist count]) {
        return [_Nodelist objectAtIndex:nIndex];
    }
    
    return nil;
}

- (DeviceTreeNode*) getGroupByName:(NSString*)strName
{
    for (int i = 0; i < [self count]; i++)
    {
        DeviceTreeNode *pNode = [_Nodelist objectAtIndex:i];
        if (NSOrderedSame == [pNode.name compare:strName])
        {
            return pNode;
        }
    }
    return nil;
}

#pragma mark 根据相机id 查询节点
- (void)queryNodeByCareraId:(NSString*)strName withBlock:(QueryBlock)queryBlock {
    /*
    __block NSArray *nodeList = _Nodelist;
    do {
        [nodeList enumerateObjectsUsingBlock:^(DeviceTreeNode *deviceTreeNode, NSUInteger idx, BOOL * _Nonnull stop) {
            if(deviceTreeNode.Nodelist != nil && deviceTreeNode.Nodelist.count > 0){
                nodeList = deviceTreeNode.Nodelist;
            }
        }];
    } while (nodeList != nil && nodeList.count > 0);
     */
    
    if(_Nodelist != nil && _Nodelist.count > 0){
        [self findNode:strName withNodeList:_Nodelist withBLock:queryBlock];
    }
    
}

- (void)findNode:(NSString*)strName withNodeList:(NSArray *)nodeList withBLock:(QueryBlock)queryBlock {
    [nodeList enumerateObjectsUsingBlock:^(DeviceTreeNode *deviceTreeNode, NSUInteger idx, BOOL * _Nonnull stop) {
        if([deviceTreeNode.cameraID isEqualToString:strName]){
            queryBlock(deviceTreeNode);
            *stop = YES;
        }
        if(deviceTreeNode.Nodelist != nil && deviceTreeNode.Nodelist.count > 0){
            [self findNode:strName withNodeList:deviceTreeNode.Nodelist withBLock:queryBlock];
        }
    }];
}

- (int) count
{
    return (int)[_Nodelist count];
}

- (NSInteger)showCount
{
    NSInteger count = 0;
    for (DeviceTreeNode *chnNode in _Nodelist)
    {
        count += (!chnNode.needHidden);
    }
    return count;
}

- (void)dealloc
{
    if (_Nodelist) {
        [_Nodelist removeAllObjects];
    }
    
    self.location = nil;
    self.company = nil;
    self.author = nil;
    self.contact = nil;
    self.phone = nil;
    self.device = nil;
}

@end

