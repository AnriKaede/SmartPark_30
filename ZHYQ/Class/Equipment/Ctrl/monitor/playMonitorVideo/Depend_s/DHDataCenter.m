////
//  DHDataCenter.m
//  DahuaVision
//
//  Created by nobuts on 13-6-4.
//  Copyright (c) 2013年 Dahuatech. All rights reserved.
//

#import "DHDataCenter.h"
#import "XMLParser.h"
#import "DeviceTree.h"
#define kConfigFile	@"config.plist"

static DHDataCenter* g_shareInstance = nil;

@implementation DHDataCenter

+ (DHDataCenter *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareInstance = [[self alloc] init];
    });
    return g_shareInstance;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _nTimeout = 5*1000;
    }
    
    return self;
}

- (void) saveAccount
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    if (self.userName != NULL)
    {
        [dic  setObject:self.userName forKey:@"username"];
    }
    
    if (self.passCode != NULL)
    {
        [dic setObject:self.passCode forKey:@"password"];
    }
    
    if (self.serverIP != NULL)
    {
        [dic setObject:self.serverIP  forKey:@"serverip"];
    }
    
    [dic setValue:[NSNumber numberWithInt:self.serverPort] forKey:@"serverport"];
    [dic setValue:[NSNumber numberWithBool:self.bAutoLogin] forKey:@"AutoLogin"];
    [dic setValue:[NSNumber numberWithBool:self.bLogin] forKey:@"Login"];
    
    [dic writeToFile:[self configFilePath] atomically:YES];
}

- (void) loadAccount
{
    NSString* configfilepath = [self configFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:configfilepath])
	{
		NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:configfilepath];
		
        NSString* val = [dic objectForKey:@"username"];
        if (val != NULL)
        {
            self.userName = val;
        }
        
        val = [dic  objectForKey:@"password"];
        if (val != NULL)
        {
            self.passCode = val;
        }
        
        val = [dic objectForKey:@"serverip"];
        if (val != NULL)
        {
            self.serverIP = val;
        }
        
        val = [dic objectForKey:@"serverport"];
        if (val != NULL)
        {
            self.serverPort = [val intValue];
        }
        
        val = [dic objectForKey:@"AutoLogin"];
        if (val != NULL)
        {
            self.bAutoLogin = [val boolValue];
        }
        
        val = [dic objectForKey:@"Login"];
        if (val != NULL)
        {
            self.bLogin = [val boolValue];
        }
	}
    else
    {
        [[NSFileManager defaultManager]  createDirectoryAtPath:[DHPubfun supportFolder]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:nil];
    }
}

- (NSString*)configFilePath
{
	NSString* documentDirectory = [DHPubfun supportFolder];
	return [documentDirectory stringByAppendingPathComponent:kConfigFile];
}

#pragma mark XML parser

- (void)updateDeviceList:(void (^)(int a))success failure:(void (^)(NSError *error))failure
{
    NSString *xml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Devices"ofType:@"xml"]
                                              encoding:NSUTF8StringEncoding error:nil];
    NSData *xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
	
	XMLParser *xmlParser = [[XMLParser alloc] init];
	
	[xmlParser parseData:xmlData
				 success:^(id parsedData) {
                     
                     DeviceTreeNode* topestNode = [[DeviceTreeNode alloc] init];
                     topestNode.name = @"topestNode";
                     
                     NSDictionary* Group_level1 = [parsedData objectForKey:@"Group_level1"];
                     NSArray* Group_TasksArray = [Group_level1 objectForKey:@"Group_TasksArray"];
                     if (NULL == Group_TasksArray)
                     {
                         NSDictionary* Group_Task = [Group_level1 objectForKey:@"Group_Task"];
                         if (Group_Task)
                         {
                             [self ParseTaskGroup:Group_Task toTop:topestNode];
                         }
                     }
                     else
                     {
                         if ([Group_TasksArray isKindOfClass:[NSArray class]])
                         {
                             for (NSDictionary* Group_Task in Group_TasksArray)
                             {
                                 [self ParseTaskGroup:Group_Task toTop:topestNode];
                             }
                         }
                     }
                     
                     self.CamerasGroups = topestNode;
                     
                     success(1);
				 }
				 failure:^(NSError *error) {
					 failure(error);
				 }];
}

// 解析任务组到根结点
- (void) ParseTaskGroup:(NSDictionary*)dicTaskGroup toTop:(DeviceTreeNode*)parent
{
    DeviceTreeNode* node = [[DeviceTreeNode alloc] init];
    node.name = [dicTaskGroup objectForKey:@"name"];
    
    NSArray* TasksArray = [dicTaskGroup objectForKey:@"TasksArray"];
    if (NULL == TasksArray)
    {
        NSDictionary* Task = [dicTaskGroup objectForKey:@"Task"];
        
        if (Task)
        {
            [self ParseTask:Task toGroup:node];
        }
    }
    else
    {
        if ([TasksArray isKindOfClass:[NSArray class]])
        {
            for ( NSDictionary* Task in TasksArray)
            {
                [self ParseTask:Task toGroup:node];
            }
        }
    }
    
    [parent addNode:node];
}

// 解析任务到组
- (void) ParseTask:(NSDictionary*)dicTask toGroup:(DeviceTreeNode*)parent
{
    DeviceTreeNode* node = [[DeviceTreeNode alloc] init];
    node.name = [dicTask objectForKey:@"name"];
    
    // 设备信息
    NSDictionary* dicDevice = [dicTask objectForKey:@"Device"];
    if (dicDevice)
    {
        id channels = [dicDevice objectForKey:@"ChannelsArray"];
        
        if (nil == channels)
        {
            id channel = [dicDevice objectForKey:@"Channel"];
            
            [self ParseCamera:channel toDevice:node];
        }
        else
        {
            if ([channels isKindOfClass:[NSArray class]])
            {
                for (NSDictionary* channel in channels)
                {
                    [self ParseCamera:channel toDevice:node];
                }
            }
        }
    }
    
    // 描述信息
    NSDictionary* description = [dicTask objectForKey:@"Description"];
    if (description)
    {
        node.location = [description objectForKey:@"location"];
        node.company = [description objectForKey:@"company"];
        node.author = [description objectForKey:@"author"];
        node.contact = [description objectForKey:@"contact"];
        node.phone = [description objectForKey:@"phone"];
    }
    
    [parent addNode:node];
}

- (void) ParseCamera:(NSDictionary*)dicCamera toDevice:(DeviceTreeNode*)parent
{
    DeviceTreeNode* cameraNode = [[DeviceTreeNode alloc] init];
    cameraNode.name = [dicCamera objectForKey:@"name"];
    cameraNode.cameraID = [dicCamera objectForKey:@"camerID"];
    
    [parent addNode:cameraNode];
}
+ (void)refreshOrganTree:(DeviceTreeNode *)pNode withChannelRight:(UNLLONG)right
{
    if (pNode.nodeType == NODE_TYPE_CHANNEL) //通道
    {
        //pNode.nSelected = 0;
        
        //如果是收藏夹节点,默认全部显示;注释后,只显示有权限的通道
        /* if (pNode.category == FavoriteTreeNode)
         {
         pNode.needHidden = NO;
         //NSLog(@"####Set %@ to hidden %d", pNode.strKey, NO);
         }
         else
         {
         pNode.needHidden = !(pNode.nChannelRight & right);
         }
         */
        
        pNode.needHidden = !(pNode.nChannelRight & right);
    }
    else //设备或组织
    {
        for (int i = 0; i < pNode.Nodelist.count; i++)
        {
            DeviceTreeNode *tmpNode = pNode.Nodelist[i];;
            [DHDataCenter refreshOrganTree:tmpNode withChannelRight:right];
        }
    }
}
//刷新完组织树权限后，刷新各节点的隐藏状态
+ (void)refreshOrganTreeHiddenStatus:(DeviceTreeNode *)pNode ignoreCollectionNode:(BOOL)ignoreCollection
{
    if (pNode.nodeType == NODE_TYPE_CHANNEL)
    {
        if (pNode.parentNode.nodeType == NODE_TYPE_DEP) {
            //向上找父节点,将needHidden状态恢复
            
            DeviceTreeNode *tmpNode = pNode.parentNode;
            while (tmpNode)
            {
                if (!tmpNode.needHidden) {
                    break;
                }
                
                tmpNode.needHidden = NO;
                //                NSLog(@"tmpNode.strTitle____%@ hidden no",tmpNode.strTitle);
                tmpNode = tmpNode.parentNode;
                
            }
        }
        return;
    }
    
    if (pNode.nodeType == NODE_TYPE_DEVICE)
    {
        //设备下面没有通道显示,设备节点需要隐藏
        //否则设备节点所在的组织增加显示
        if (pNode.showCount == 0)
        {
            pNode.needHidden = YES;
        }
        else
        {
            //向上找父节点,将needHidden状态恢复
            DeviceTreeNode *tmpNode = pNode;
            while (tmpNode)
            {
                tmpNode.needHidden = NO;
                tmpNode = tmpNode.parentNode;
            }
        }
    }
    else if (pNode.nodeType == NODE_TYPE_DEP)
    {
        //组织列表默认需要隐藏
        pNode.needHidden = YES;
        NSArray *childNodes = [NSArray arrayWithArray:pNode.Nodelist];
        for (DeviceTreeNode *node in childNodes)
        {
            [DHDataCenter refreshOrganTreeHiddenStatus:node ignoreCollectionNode:ignoreCollection];
        }
    }
}

@end
