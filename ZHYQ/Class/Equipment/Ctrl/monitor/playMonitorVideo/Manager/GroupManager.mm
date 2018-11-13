//
//  GroupManager.m
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-16.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//

#import "GroupManager.h"
#import "XMLParser.h"

static GroupManager* g_shareInstance = nil;

@implementation GroupManager

//业务数据回调
int32_t DPSDKIssueCallback(int32_t nPDLLHandle,Issue_Info_t* pIssueInfo,void* pUserParam )
{
    GroupManager *pGroupManager = nil;
    if (pUserParam)
    {
        pGroupManager = (__bridge GroupManager*)pUserParam;
    }
    
    DeviceTreeNode* rootNode = [[DeviceTreeNode alloc] init]; //根节点
    rootNode.name = @"topGroup";
    
    for (int i = 0; i < pIssueInfo->nSize; i++)
    {
        One_Issue_Info_t stInfo = pIssueInfo->oneIssueInfo[i];
        
        NSString *strUseClass = [NSString stringWithCString:stInfo.szUseClass
                                                   encoding:NSUTF8StringEncoding];
        NSString *strContent = [NSString stringWithCString:stInfo.szContent
                                                  encoding:NSUTF8StringEncoding];
        NSString *strStatName = [NSString stringWithCString:stInfo.szStatName
                                                   encoding:NSUTF8StringEncoding];
        NSString *strIssueName = [NSString stringWithCString:stInfo.szIssueName
                                                    encoding:NSUTF8StringEncoding];
        NSString *strDeviceID = [NSString stringWithCString:stInfo.szDeviceID
                                                   encoding:NSUTF8StringEncoding];
        
        NSString *strContract = [NSString stringWithCString:stInfo.szLinkMan
                                                   encoding:NSUTF8StringEncoding];
        
        NSString *strPhone = [NSString stringWithCString:stInfo.szLinkMethod
                                                encoding:NSUTF8StringEncoding];
        
        NSString *strCompany = [NSString stringWithCString:stInfo.szWorkCompany
                                                  encoding:NSUTF8StringEncoding];
        
        DeviceTreeNode *topNode = [rootNode getGroupByName:strUseClass];
        
        //如果不已经存在该节点则加入
        if (nil == topNode)
        {
            topNode = [[DeviceTreeNode alloc]init];
            topNode.name = strUseClass;
            [rootNode addNode:topNode];
        }
        
        DeviceTreeNode *subNode = [[DeviceTreeNode alloc]init];
        subNode.name = strContent;
        subNode.location = strStatName;
        subNode.company = strCompany;
        subNode.author = strIssueName;
        subNode.contact = strContract;
        subNode.phone = strPhone;
        subNode.device = strDeviceID;
        
        [topNode addNode:subNode];
    }
    
    [DHDataCenter sharedInstance].CamerasGroups = rootNode;
    pGroupManager.isLoadComplete = TRUE;  //数据加载完成
    
    return 0;
}

+ (GroupManager *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareInstance = [[self alloc] init];
    });
    return g_shareInstance;
}

/**
 *  向平台请求数据业务回调
 *  @return 返回错误码见dpsdk_retval_e
 */
- (int)attachIssueCallback
{
    self.isLoadComplete = NO;
    int ret =DPSDK_SetDPSDKIssueCallback([DHDataCenter sharedInstance]->nDPHandle_,
                                         (fDPSDKIssueCallback)DPSDKIssueCallback,
                                         (__bridge void *)self);
    return ret;
}

- (void)loadBasicChildNode:(NSString*)coding parentNode:(DeviceTreeNode*)parentNode
{
    Get_Dep_Count_Info_t depCountInfo = {0};
    strcpy(depCountInfo.szCoding, [coding UTF8String]);
    int ret = DPSDK_GetDGroupCount([DHDataCenter sharedInstance]->nDPHandle_,  &depCountInfo);
    if (ret != DPSDK_RET_SUCCESS) {
        return;
    }
    Get_Dep_Info_t depInfo;
    strcpy(depInfo.szCoding, [coding UTF8String]);
    depInfo.nDepCount = depCountInfo.nDepCount;
    depInfo.nDeviceCount = depCountInfo.nDeviceCount;
    depInfo.pDepInfo = new Dep_Info_t[depInfo.nDepCount];
    depInfo.pDeviceInfo = new Device_Info_Ex_t[depInfo.nDeviceCount];
    memset(depInfo.pDepInfo, 0, sizeof(Dep_Info_t) * depInfo.nDepCount);
    memset(depInfo.pDeviceInfo, 0, sizeof(Device_Info_Ex_t) * depInfo.nDeviceCount);
    ret = DPSDK_GetDGroupInfo([DHDataCenter sharedInstance]->nDPHandle_, &depInfo);
    if (ret != DPSDK_RET_SUCCESS) {
        return;
    }
    for (int i = 0; i < depInfo.nDepCount; ++i) {
        DeviceTreeNode *depNode = [[DeviceTreeNode alloc]init];
        depNode.name = [[NSString alloc]initWithUTF8String:depInfo.pDepInfo[i].szDepName];
        depNode.coding = [[NSString alloc]initWithUTF8String:depInfo.pDepInfo[i].szCoding];
        depNode.nodeType = NODE_TYPE_DEP;
        depNode.parentNode = parentNode;
        depNode.nChannelRight = 0;
        depNode.bOnline = true;
        [self loadBasicChildNode:depNode.coding parentNode:depNode];
        [parentNode.Nodelist addObject:depNode];
    }
    for (int i = 0; i < depInfo.nDeviceCount; ++i){
        if (!((depInfo.pDeviceInfo[i].nDevType > DEV_TYPE_ENC_BEGIN && depInfo.pDeviceInfo[i].nDevType < DEV_TYPE_ENC_END)
              || (depInfo.pDeviceInfo[i].nDevType > DEV_TYPE_IVS_BEGIN && depInfo.pDeviceInfo[i].nDevType < DEV_TYPE_IVS_END)
              || (depInfo.pDeviceInfo[i].nDevType > DEV_TYPE_VIDEO_TALK_BEGIN && depInfo.pDeviceInfo[i].nDevType < DEV_TYPE_VIDEO_TALK_END)
              )) {
            continue;
        }
        DeviceTreeNode *deviceNode = [[DeviceTreeNode alloc]init];
        deviceNode.name = [[NSString alloc]initWithUTF8String:depInfo.pDeviceInfo[i].szName];
        deviceNode.cameraID = [[NSString alloc]initWithUTF8String:depInfo.pDeviceInfo[i].szId];
        deviceNode.nodeType = NODE_TYPE_DEVICE;
        deviceNode.parentNode = parentNode;
        deviceNode.nChannelRight = 0;
        deviceNode.bOnline = depInfo.pDeviceInfo[i].nStatus == DPSDK_DEV_STATUS_ONLINE;
        deviceNode.strCallNum = [[NSString alloc]initWithUTF8String:depInfo.pDeviceInfo[i].szCallNum];
        //将可视对讲节点添加到 [DHDataCenter sharedInstance].arrVTNodes 供后面选择
        if(depInfo.pDeviceInfo[i].nDevType > DEV_TYPE_VIDEO_TALK_BEGIN && depInfo.pDeviceInfo[i].nDevType < DEV_TYPE_VIDEO_TALK_END)
        {
            if([DHDataCenter sharedInstance].arrVTNodes == nil)
            {
                [DHDataCenter sharedInstance].arrVTNodes = [NSMutableArray array];
            }
            NSLog(@"%@   ", deviceNode.strCallNum);
            
            [[DHDataCenter sharedInstance].arrVTNodes addObject:deviceNode];
        }
        
        Get_Channel_Info_Ex_t channelInfo;
        strcpy(channelInfo.szDeviceId, depInfo.pDeviceInfo[i].szId);
        channelInfo.nEncChannelChildCount = depInfo.pDeviceInfo[i].nEncChannelChildCount;
        channelInfo.pEncChannelnfo = new Enc_Channel_Info_Ex_t[channelInfo.nEncChannelChildCount];
        memset(channelInfo.pEncChannelnfo, 0,
               sizeof(Enc_Channel_Info_Ex_t) * channelInfo.nEncChannelChildCount);
        ret = DPSDK_GetChannelInfoEx([DHDataCenter sharedInstance]->nDPHandle_, &channelInfo);
        if (ret != DPSDK_RET_SUCCESS) {
            delete [] channelInfo.pEncChannelnfo;
            continue;
        }
        for (int j = 0; j < channelInfo.nEncChannelChildCount; ++j) {
            DeviceTreeNode *channelNode = [[DeviceTreeNode alloc]init];
            channelNode.cameraID = [[NSString alloc]initWithUTF8String:channelInfo.pEncChannelnfo[j].szId];
            channelNode.name = [[NSString alloc]initWithUTF8String:channelInfo.pEncChannelnfo[j].szName];
            channelNode.nodeType = NODE_TYPE_CHANNEL;
            channelNode.nChannelRight = channelInfo.pEncChannelnfo[j].nRight;
            channelNode.parentNode = deviceNode;
            channelNode.bOnline = deviceNode.bOnline;
            //默认显示预览与回放的并集
            UNLLONG right = DSL_RIGHT_MONITOR|DSL_RIGHT_PLAYBACK;
            if(channelNode.nChannelRight & right){
                [deviceNode.Nodelist addObject:channelNode];
            }
     
            DeviceTreeNode *encNode;
            DeviceTreeNode *doorNode;
            dpsdk_dev_unit_type_e unitType;
            const char* str = [channelNode.cameraID cStringUsingEncoding:NSUTF8StringEncoding];
            char* chnlID = new char[strlen(str)+1];
            strcpy(chnlID, str);
            DPSDK_GetChnlType([DHDataCenter sharedInstance]->nDPHandle_,chnlID,&unitType);
            if(unitType == DPSDK_DEV_UNIT_DOORCTRL)
            {
                encNode = channelNode;
            }
            else if(unitType == DPSDK_DEV_UNIT_ENC)
            {
                doorNode = channelNode;
            }
            else
            {
                encNode = channelNode;
            }
        }
        delete [] channelInfo.pEncChannelnfo;
        [parentNode.Nodelist addObject:deviceNode];
    }
    delete[] depInfo.pDepInfo;
    delete [] depInfo.pDeviceInfo;
}

/**
 *  加载组织设备信息.
 *  @return 返回错误码见dpsdk_retval_e
 */
- (int)loadGroupInfo
{
    self.isLoadComplete = NO;
    //int ret = DPSDK_LoadDGroupInfo([DHDataCenter sharedInstance]->nDPHandle_,
    //                               &_groupLen,
    //                              [DHDataCenter sharedInstance].nTimeout);

    int nGroupLen = 0;
    int ret = DPSDK_LoadDGroupInfo([DHDataCenter sharedInstance]->nDPHandle_, &nGroupLen, DPSDK_CORE_DEFAULT_TIMEOUT);
    if (ret != DPSDK_RET_SUCCESS) {
        return ret;
    }
    if(DPSDK_HasLogicOrg([DHDataCenter sharedInstance]->nDPHandle_)){
        return [self loadLogicGroup];
    }else {
        return [self loadBasicGroup];
    }
    return ret;
}

- (int)loadBasicGroup{
    Dep_Info_t rootDepInfo = {0};
    int ret = DPSDK_GetDGroupRootInfo([DHDataCenter sharedInstance]->nDPHandle_, &rootDepInfo);
    if (ret != DPSDK_RET_SUCCESS) {
        return ret;
    }
    DeviceTreeNode *root = [[DeviceTreeNode alloc]init];
    root.name = [[NSString alloc]initWithUTF8String:rootDepInfo.szDepName];
    root.coding = [[NSString alloc]initWithUTF8String:rootDepInfo.szCoding];
    root.nodeType = NODE_TYPE_DEP;
    root.nChannelRight = -1;
    root.bOnline = true;
    [self loadBasicChildNode:root.coding parentNode:root];
    [DHDataCenter sharedInstance].CamerasGroups = root;
    self.isLoadComplete = YES;
    if ( root && root.Nodelist.count > 0)
    {
        [self performSelectorOnMainThread:@selector(refreshOrganData) withObject:self waitUntilDone:YES];
    }
    return ret;
}

- (int)loadLogicGroup{
    Dep_Info_Ex_t rootDepInfo = {0};
    int ret = DPSDK_GetLogicRootDepInfo([DHDataCenter sharedInstance]->nDPHandle_, &rootDepInfo);
    if (ret != DPSDK_RET_SUCCESS) {
        return ret;
    }
    DeviceTreeNode *root = [[DeviceTreeNode alloc]init];
    root.name = [[NSString alloc]initWithUTF8String:rootDepInfo.szDepName];
    root.coding = [[NSString alloc]initWithUTF8String:rootDepInfo.szCoding];
    root.nodeType = NODE_TYPE_DEP;
    root.nChannelRight = -1;
    root.bOnline = true;
    [self loadLogicChildNode:root.coding parentNode:root];
    [DHDataCenter sharedInstance].CamerasGroups = root;
    self.isLoadComplete = YES;
    if ( root && root.Nodelist.count > 0)
    {
        [self performSelectorOnMainThread:@selector(refreshOrganData) withObject:self waitUntilDone:YES];
    }
    return ret;
}

- (void)loadLogicChildNode:(NSString*)coding parentNode:(DeviceTreeNode*)parentNode{
    int dpHandle = [DHDataCenter sharedInstance]->nDPHandle_;
    
    const char* str = [coding cStringUsingEncoding:NSUTF8StringEncoding];
    char* codeid = new char[strlen(str)+1];
    strcpy(codeid, str);
    
    int nOrgNum = 0;    //子组织个数
    NSLog(@"DPSDK_GetLogicDepNodeNum");
    DPSDK_GetLogicDepNodeNum(dpHandle, codeid, DPSDK_CORE_NODE_DEP, &nOrgNum);
    
    int nChannelNum = 0; //组织下的通道个数
    NSLog(@"DPSDK_GetLogicDepNodeNum");
    DPSDK_GetLogicDepNodeNum(dpHandle, codeid, DPSDK_CORE_NODE_CHANNEL, &nChannelNum);
    
    if (nOrgNum == 0 && nChannelNum == 0) {
        return ;
    }
    
    //组织
    for (int i = 0; i < nOrgNum; i++)
    {
        Dep_Info_Ex_t depInfo = {0};
        NSLog(@"DPSDK_GetLogicSubDepInfoByIndex");
        DPSDK_GetLogicSubDepInfoByIndex(dpHandle, codeid, i, &depInfo);
   
        DeviceTreeNode *depNode = [[DeviceTreeNode alloc]init];
        depNode.name = [[NSString alloc]initWithUTF8String:depInfo.szDepName];
        depNode.coding = [[NSString alloc]initWithUTF8String:depInfo.szCoding];
        depNode.nodeType = NODE_TYPE_DEP;
        depNode.parentNode = parentNode;
        depNode.nChannelRight = 0;
        depNode.bOnline = true;
        [self loadLogicChildNode:depNode.coding parentNode:depNode];
        [parentNode.Nodelist addObject:depNode];
    }
    
    //通道
    for (int i = 0; i < nChannelNum; i++)
    {
        char logicID[128] = {0};
        NSLog(@"DPSDK_GetLogicID");
        int error = DPSDK_GetLogicID(dpHandle, codeid, i, true, logicID);
        if ( error!= DPSDK_RET_SUCCESS){
            continue;
        }
        NSString *channelID = [NSString stringWithFormat:@"%s",logicID];
        NSString *deviceID = [channelID substringToIndex:[channelID rangeOfString:@"$"].location];
        
        NSInteger result = [GroupManager Platform_GetDeviceType:deviceID];
        BOOL isValidDevice = YES;
        dpsdk_dev_type_e deviceType = DEV_TYPE_ENC_BEGIN;
        
        if (result != -1)
        {
            deviceType = (dpsdk_dev_type_e)result;
            isValidDevice = [GroupManager Platform_IsValidEncodeDevice:deviceType];
        }
        
        if (!isValidDevice)
        {
            //不添加非指定类型的设备
            continue;
        }
        
        Enc_Channel_Info_Ex_t channelInfo;
        NSLog(@"DPSDK_GetChannelInfoById");
        if (DPSDK_GetChannelInfoById(dpHandle, logicID, &channelInfo) != DPSDK_RET_SUCCESS) {
            continue;
        }

        DeviceTreeNode *channelNode = [[DeviceTreeNode alloc]init];
        channelNode.cameraID = [NSString stringWithFormat:@"%s",channelInfo.szId];
        channelNode.name = [NSString stringWithUTF8String:channelInfo.szName];
        channelNode.nodeType = NODE_TYPE_CHANNEL;
        channelNode.nChannelRight = channelInfo.nRight;
        channelNode.parentNode = parentNode;
        channelNode.device = deviceID;
        //获取通道状态(根据设备的状态来对应到通道状态)
        Device_Info_Ex_t deviceInfo = {0};
        NSLog(@"DPSDK_GetDeviceInfoExById");
        DPSDK_GetDeviceInfoExById(dpHandle, [deviceID UTF8String], &deviceInfo);
        channelNode.bOnline = deviceInfo.nStatus == DPSDK_DEV_STATUS_ONLINE;
        [parentNode.Nodelist addObject:channelNode];
    }
        
}

+ (NSInteger)Platform_GetDeviceType:(NSString *)deviceID
{
    if (deviceID == nil)
    {
        NSLog(@"%s:设备ID不可为空!",__FILE__);
        return -1;
    }
    
    dpsdk_dev_type_e type;
    NSLog(@"DPSDK_GetDeviceTypeByDevId");
    int error = DPSDK_GetDeviceTypeByDevId([DHDataCenter sharedInstance]->nDPHandle_,
                                           [deviceID UTF8String],
                                           &type);
    return (error == DPSDK_RET_SUCCESS) ? type : -1;
}

+ (BOOL)Platform_IsValidEncodeDevice:(dpsdk_dev_type_e)type
{
    NSMutableArray *validTypes = [NSMutableArray arrayWithArray:@[@(DEV_TYPE_DVR), @(DEV_TYPE_IPC), @(DEV_TYPE_NVS),
                                                                  @(DEV_TYPE_MDVR),@(DEV_TYPE_NVR), @(DEV_TYPE_SMART_NVR),
                                                                  @(DEV_TYPE_EVS), @(DEV_TYPE_SMART_IPC)]];
    for (NSInteger i = DEV_TYPE_IVS_BEGIN + 1; i < DEV_TYPE_IVS_END; i ++) {
        [validTypes addObject:@(i)];
    }
    return [validTypes containsObject:@(type)];
}

- (void)refreshOrganData
{
    [self refreshOrganTreeWithChannelRight];
}
/**
 *  根据预览、回放权限来设置树的状态
 */
- (void)refreshOrganTreeWithChannelRight
{
    DeviceTreeNode *node = [DHDataCenter sharedInstance].CamerasGroups;
  
    [DHDataCenter refreshOrganTreeHiddenStatus:node ignoreCollectionNode:YES];
}
//解析通道信息
- (void)parseChannelInfo
{
    char *szGroupBuf = new char[_groupLen + 1];
    memset(szGroupBuf, 0, _groupLen + 1);
    int32_t ret = DPSDK_GetDGroupStr([DHDataCenter sharedInstance]->nDPHandle_,
                                     szGroupBuf,
                                     _groupLen,
                                     [DHDataCenter sharedInstance].nTimeout);
    if (ret != 0)
    {
        NSLog(@"解析通道信息失败");
        return;
    }
    
    NSMutableArray *gInfo = [[NSMutableArray alloc]init]; // 解析出来结果存放此处
    
    NSString *strXML = [NSString stringWithCString:szGroupBuf encoding:NSUTF8StringEncoding];
    if ([strXML length] > 0)
    {
        NSData *xmlData = [strXML dataUsingEncoding:NSUTF8StringEncoding];
        
        XMLParser *xmlParser = [[XMLParser alloc] init];
        [xmlParser parseData:xmlData
                     success:^(id parsedData)
                            {
                                NSDictionary *topNode = [parsedData objectForKey:@"Organization"];
                                NSDictionary *DeviceNode = [topNode objectForKey:@"Devices"];
                                NSArray *DeviceArray = [DeviceNode objectForKey:@"DevicesArray"];
                                int DeviceArrayCount = (!DeviceArray) ? 1 : DeviceArray.count;   //计数
                                
                                for (int i = 0; i < DeviceArrayCount; i++)
                                {
                                    NSDictionary *DeviceNode = nil;
                                    if (1 == DeviceArrayCount)
                                    {
                                        DeviceNode = [DeviceNode objectForKey:@"Device"];
                                        if (!DeviceNode)
                                        {
                                            return;
                                        }
                                    }
                                    else
                                    {
                                        DeviceNode = [DeviceArray objectAtIndex:i];
                                    }
                                    
                                    /***************begin****************/
                                    NSString *strDeviceId = [DeviceNode objectForKey:@"id"];                        //设备ID
                                    NSString *strName = [DeviceNode objectForKey:@"name"];
                                    NSMutableArray *arrChannelNO = [[NSMutableArray alloc] init];     //通道ID数组
                                    NSMutableArray *arrChannelName = [[NSMutableArray alloc] init];   //通道名称数组
                                    
                                    NSMutableDictionary *dicInfoNode = [[NSMutableDictionary alloc]init];  //一个设备的通道信息
                                    [dicInfoNode setObject:strDeviceId forKey:@"deviceId"];
                                    [dicInfoNode setObject:strName forKey:@"name"];
                                    [dicInfoNode setObject:arrChannelName forKey:@"channelName"];
                                    [dicInfoNode setObject:arrChannelNO forKey:@"channelNO"];
                                    /****************end***************/
                                    
                                    NSArray *NodeArr = [DeviceNode objectForKey:@"UnitNodessArray"];
                                    int NodeArrCount = (!NodeArr) ? 1 : NodeArr.count;   //计数
                                    
                                    for (int k = 0; k < NodeArrCount; k++)
                                    {
                                        NSDictionary *chTreeNode = nil;
                                        if (1 == NodeArrCount)
                                        {
                                            chTreeNode = [DeviceNode objectForKey:@"UnitNodes"];
                                            if (!chTreeNode) continue;
                                        }
                                        else
                                        {
                                            chTreeNode = [NodeArr objectAtIndex:k];
                                        }
                                        
                                        NSArray *chTree = [chTreeNode objectForKey:@"ChannelsArray"];
                                        int chTreeCount = (!chTree) ? 1 : chTree.count;   //计数
                                        
                                        for (int m = 0; m < chTreeCount; m++)
                                        {
                                            NSDictionary *lstNode = nil;
                                            if (1 == chTreeCount)
                                            {
                                                lstNode = [chTreeNode objectForKey:@"Channel"];
                                                if (!lstNode) continue;
                                            }
                                            else
                                            {
                                                lstNode = [chTree objectAtIndex:m];
                                            }
                                            [arrChannelNO addObject:[lstNode objectForKey:@"id"]];
                                            [arrChannelName addObject:[lstNode objectForKey:@"name"]];
                                        }
                                    }
                                    
                                    [gInfo addObject:dicInfoNode]; //增加一个设备的所有通道信息
                                }
                                
                                //[self loadChannelInfo:gInfo];
                                [self addChannelInfo:gInfo];
                            }
                     failure:^(NSError *error)
                            {
                                NSLog(@"解析通道信息失败");
                                self.isLoadComplete = YES;

                            }];
    }
    
    SAFE_DELETE_ARRAY(szGroupBuf)
}

- (void)addChannelInfo:(NSMutableArray *)arrayData
{
    DeviceTreeNode *parent = [[DeviceTreeNode alloc]init];
    for (NSDictionary *dicDeviceInfo in arrayData)
    {
        NSString *deviceID = [dicDeviceInfo objectForKey:@"deviceId"];
        NSArray *channelNameArray = [dicDeviceInfo objectForKey:@"channelName"];
        NSArray *channelIDArray   = [dicDeviceInfo objectForKey:@"channelNO"];
        
        DeviceTreeNode *group = [[DeviceTreeNode alloc]init];
        group.device = deviceID;
        group.name = [dicDeviceInfo objectForKey:@"name"];
        
        for (int i = 0; i < channelNameArray.count; i++)
        {
            DeviceTreeNode *node = [[DeviceTreeNode alloc]init];
            node.cameraID = [channelIDArray objectAtIndex:i];
            node.name = [channelNameArray objectAtIndex:i];
            [group.Nodelist addObject:node];
        }
        [parent addNode:group];
    }
    
    [DHDataCenter sharedInstance].CamerasGroups = parent;
    self.isLoadComplete = YES;
}

@end
