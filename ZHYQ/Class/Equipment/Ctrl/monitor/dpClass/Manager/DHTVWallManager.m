//
//  DHTVWallManager.m
//  DataAdapterExample_Example
//
//  Created by caidong on 2018/6/30.
//  Copyright © 2018年 ly. All rights reserved.
//

#import "KissXML.h"
#import "XMLDictionary.h"

#import "DHTVWallManager.h"
#import "DHDeviceManager.h"

#import "DSSPlatformDataAdapterTVWall.h"
#import "DataAdapterRemoteNotifyProtocol.h"

static DHTVWallManager *instanceManager = nil;

@interface DHTVWallManager ()
@property (nonatomic, strong) DSSPlatformDataAdapterTVWall *tvWallAdapter;
@end

@implementation DHTVWallManager

#pragma mark - Life Cycle
+ (instancetype)sharedInstance {
    if (!instanceManager) {
        instanceManager = [[DHTVWallManager alloc] init];
    }
    return instanceManager;
}

+ (void)unSharedInstance {
    if (instanceManager) {
        instanceManager = nil;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _tvWallAdapter = [[DSSPlatformDataAdapterTVWall alloc] init];
        [_tvWallAdapter setRemoteNotifyBlock:^(ADAPTER_NOTIFY_ACTION action, id content) {
            switch (action) {
                case ADAPTER_NOTIFY_ACTION_TVWALL_ADD:           ///< 新增电视墙 add tvwall
                case ADAPTER_NOTIFY_ACTION_TVWALL_MODIFY:        ///< 修改电视墙，本修改通知消息权限字段无效，请勿使用; modify tvwall
                case ADAPTER_NOTIFY_ACTION_TVWALL_DELETE:        ///< 删除电视墙 delete tvwall
                case ADAPTER_NOTIFY_ACTION_TVWALL_MODIFY_RIGHT:  ///< 权限电视墙修改 tvwall modify right
                case ADAPTER_NOTIFY_ACTION_TVWALL_MODIFY_CONFIG: ///< 电视墙生效修改 tvwall modify config
                case ADAPTER_NOTIFY_ACTION_TVWALL_RUN_INFO:      ///<TODO:-电视墙运行信息通知 tvwall run info
                case ADAPTER_NOTIFY_ACTION_TVWALL_NAME_MODIFY:   ///< 电视墙名字修改
                case ADAPTER_NOTIFY_ACTION_TVWALL_LAYOUT_MODIFY: ///< 电视墙布局修改通知（非平台通知，由本地判断，如果修改则通知上层） tvwall
                default:
                    break;
            }
        }];
    }
    return self;
}

#pragma mark - Interface
- (NSArray<TVWallInfo *> *)getTVWallList:(NSError **)error {
    NSArray *tvwallList = [_tvWallAdapter getTVWallList:error];
    NSMutableArray *enabledArray = [[NSMutableArray alloc] init];
    for (TVWallInfo *tvwallInfo in tvwallList) {
        if (tvwallInfo.iRight && tvwallInfo.iState) {
            [enabledArray addObject:tvwallInfo];
        }
    }
    return enabledArray;
}

- (NSArray<TVWallTaskBaseInfo *> *)getTVWallTaskList:(NSInteger)tvWallId error:(NSError **)error {
    return [_tvWallAdapter getTVWallTaskList:tvWallId error:error];
}

- (BOOL)taskMapToWallWithTVWallInfo:(TVWallInfo *)tvWallInfo taskId:(NSInteger)taskId error:(NSError **)error {
    // 1. 获取任务xml
    NSString *taskXMlString = [_tvWallAdapter getTvWallTaskInfo:taskId tvWallId:tvWallInfo.iTVWallId error:error];
    // 2. 把任务xml解析为屏信息字典
    NSDictionary<NSNumber *,TVWallScreenDetailInfo *> *taskScreenDic = [self praseTVWallTaskInfoXml:taskXMlString];
    // 3. 为任务xml加上ChnlExtern；上墙需要该节点
    NSString *taskXMLWithChnlExtern = [self addChnlExternNodeWithTaskScreenInfoDic:taskScreenDic originalTaskXmlString:taskXMlString];
    // 4. 按照解码器Id把屏信息字典分组
    NSArray *taskScreenDicArray = [self groupTaskScreenInfoDic:taskScreenDic];
    BOOL result = NO;
    // 5. 各组分别上墙
    for (NSDictionary<NSNumber *,TVWallScreenDetailInfo *> *dic in taskScreenDicArray) {
        // 5.1 组装上墙对象
        TVWallScreenDetailInfo *info = [dic objectForKey:[[dic allKeys] firstObject]];
        TVWallMatirxInfo *matrixInfo = [[TVWallMatirxInfo alloc] init];
        matrixInfo.eWallType = TVWallMatrixTypePlanTask;
        matrixInfo.iTaskId = taskId;
        matrixInfo.iTvWallId = tvWallInfo.iTVWallId;
        matrixInfo.iTvWallVersion = tvWallInfo.iVersion;
        matrixInfo.strMatrixId = info.strDecoderId;
        // 5.2 组装上墙xml
        // 任务名改为matrix，并且只保留原xml中该组屏信息
        NSString *groupedXMLString = [self modifyMapToWallXmlStringWithTaskScreenInfoDic:dic originalXmlString:taskXMLWithChnlExtern];
        BOOL ret = [_tvWallAdapter taskMapToWall:matrixInfo taskXmlString:groupedXMLString error:error];
        result = (result || ret);
    }
    return result;
}

#pragma mark - Private
/**
 解析任务xml为 屏信息字典
 @param xmlString 任务xml
 @return 屏信息字典
 */
- (NSDictionary<NSNumber *,TVWallScreenDetailInfo *> *)praseTVWallTaskInfoXml:(NSString *)xmlString
{
    XMLDictionaryParser* parse =  [XMLDictionaryParser sharedInstance];
    parse.alwaysUseArrays = YES;
    parse.stripEmptyNodes = NO;
    parse.wrapRootNode = YES;
    
    
    // 上墙任务中 所有屏的分割/开窗信息
    // 这里使用字典，是因为抓包发现有重复数据，使用字典来去除重复数据
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    
    NSDictionary *dic = [NSDictionary dictionaryWithXMLString:xmlString];
    NSDictionary *tvWallSchemeDic = [dic objectForKey:@"TVWallScheme"];
    NSDictionary *tasksDic = [(NSArray *)[tvWallSchemeDic objectForKey:@"Tasks"] firstObject];  // 只有一个task;
    
    NSDictionary *taskDic = [(NSArray *)[tasksDic objectForKey:@"Task"] firstObject];
    NSArray *screenArray = [taskDic objectForKey:@"Screen"];
    
    for (NSDictionary *screenDic in screenArray) {
        // 上墙任务中 屏的分割/开窗信息
        TVWallScreenDetailInfo *info = [[TVWallScreenDetailInfo alloc] init];
        info.iScreenId = [[screenDic objectForKey:@"_screenId"] integerValue];                                      // 屏ID（Web端配置的ID）
        info.iSplitNum = [[screenDic objectForKey:@"_splitNum"] integerValue];                                      // 屏分割/开窗数目
        info.strDecoderId = [screenDic objectForKey:@"_decodeId"];                                                  // 解码设备Id
        info.enumScreenMode = (TVWallScreenMode)[[screenDic objectForKey:@"_screenMode"] integerValue];             // 分割=1；开窗=2
        info.iTvIndex = [[screenDic objectForKey:@"_tvIdx"] integerValue];
        
        NSArray *subTVArr = [screenDic objectForKey:@"SubTv"];
        NSMutableDictionary<NSNumber*, TVWallWindowInfo*>* dictWindowInfo = [[NSMutableDictionary alloc] init];
        NSMutableDictionary<NSNumber*, NSMutableArray<TWWindowBandInfo*>*>* dictWindowBandInfo = [[NSMutableDictionary alloc] init];
        for (NSDictionary *subTVDic in subTVArr) {
            NSInteger iId = [[subTVDic objectForKey:@"_id"] integerValue];
            NSNumber *subTVId = [NSNumber numberWithInteger:iId];
            // 窗体信息
            TVWallWindowInfo *subWindowInfo = [[TVWallWindowInfo alloc] init];
            
            subWindowInfo.iId = iId;                                                            // 窗体ID，即1,2,3⋯⋯
            subWindowInfo.fLeft = [[subTVDic objectForKey:@"_left"] floatValue];                // 窗口位置 左
            subWindowInfo.fTop = [[subTVDic objectForKey:@"_top"] floatValue];                  // 上
            subWindowInfo.fWidth = [[subTVDic objectForKey:@"_width"] floatValue];              // 宽
            subWindowInfo.fHeight = [[subTVDic objectForKey:@"_height"] floatValue];            // 高
            subWindowInfo.iZorder = [[subTVDic objectForKey:@"_zorder"] integerValue];          // z序（画面分割可忽略此参数）
            subWindowInfo.strName = [subTVDic objectForKey:@"_name"];                           // 窗标题（画面分割为""）
            subWindowInfo.isAlarm = [[subTVDic objectForKey:@"_isAlarm"] integerValue];         // 报警上墙=1；客户端上墙=0
            subWindowInfo.isHighLight = [[subTVDic objectForKey:@"_isHighLight"] integerValue]; // 高亮=1；非高亮=0；不处理=-1
            subWindowInfo.isOpenAudio = [[subTVDic objectForKey:@"_isOpenAudio"] integerValue]; // 音频打开=1；音频关闭；不处理=-1
            
            [dictWindowInfo setObject:subWindowInfo forKey:subTVId];
            info.dictWindowInfo = dictWindowInfo;
            
            NSMutableArray<TWWindowBandInfo*>* windowBandInfoList = [[NSMutableArray alloc] init];
            NSArray *channelArr = [subTVDic objectForKey:@"Channel"];
            for (NSDictionary *channelDic in channelArr) {
                // 窗体绑定视频信息
                TWWindowBandInfo *windowBandInfo = [[TWWindowBandInfo alloc] init];
                
                windowBandInfo.strChannelId = [channelDic objectForKey:@"_id"];                         // 通道编号
                windowBandInfo.strDeviceId = [channelDic objectForKey:@"_deviceId"];                    // 设备ID
                windowBandInfo.iChnlNo = [[channelDic objectForKey:@"_no"] integerValue];               // 通道序号
                windowBandInfo.iSubStream = [[channelDic objectForKey:@"_subStream"] integerValue];     // 码流类型 主码流=1；辅码流=2；辅码流3=3；辅码流3=4；预览方式=5
                windowBandInfo.iTimeSpan = [[channelDic objectForKey:@"_timeSpan"] integerValue];       // 停留时间
                windowBandInfo.strOsdText = [channelDic objectForKey:@"_OsdText"];                      // OSD信息
                windowBandInfo.bEnableOsd = [[channelDic objectForKey:@"_enableOsd"] boolValue];        // OSD使能
                windowBandInfo.iPatrolMode = [[channelDic objectForKey:@"_patrolMode"] integerValue];   // 轮巡模式 轮巡=0；非轮巡上墙=1；轮巡预览=2；
                windowBandInfo.iFishFitMode = [[channelDic objectForKey:@"_fishFitMode"] integerValue];
                windowBandInfo.iFishShowMode = [[channelDic objectForKey:@"_fishShowMode"] integerValue];
                windowBandInfo.iPrePoint = [[channelDic objectForKey:@"_presetPos"] integerValue];      // 预置点序号
                windowBandInfo.iProvider = [[channelDic objectForKey:@"_manufacturerType"] integerValue];      // 设备厂商
                windowBandInfo.iTrackID = [[channelDic objectForKey:@"_trackID"] integerValue];      // 取流方式
                
                [windowBandInfoList addObject:windowBandInfo];
            }
            [dictWindowBandInfo setObject:windowBandInfoList forKey:subTVId];
            info.dictWindowBandInfo = dictWindowBandInfo;
        }
        [retDic setObject:info forKey:[NSNumber numberWithInteger:info.iScreenId]];
    }
    return retDic;
}

/**
 任务屏按解码器分组，绑定相同解码器通道的屏分到一组
 @param dic 任务屏字典
 @return 分组字典数组
 */
- (NSArray<NSDictionary<NSNumber *,TVWallScreenDetailInfo *> *> *)groupTaskScreenInfoDic:(NSDictionary<NSNumber *, TVWallScreenDetailInfo*> *)screenInfoDic {
    // 1.把screenInfoDic按照decoderId分组
    NSMutableArray *tvwallGroupArray = [[NSMutableArray alloc] init];
    NSArray *keys = [screenInfoDic allKeys];
    for (int i = 0; i < keys.count; i ++) {
        BOOL hasSaved = NO;
        for (NSDictionary *dic in tvwallGroupArray) {
            if ([dic objectForKey:[keys objectAtIndex:i]]) {
                hasSaved = YES;
                break;
            }
        }
        if (!hasSaved) {
            NSNumber *keyI = [keys objectAtIndex:i];
            NSMutableDictionary<NSNumber *, TVWallScreenDetailInfo*> *tvwallGroupDic = [[NSMutableDictionary alloc] init];
            TVWallScreenDetailInfo *screenInfoI = [screenInfoDic objectForKey:keyI];
            [tvwallGroupDic setObject:screenInfoI forKey:keyI];
            for (int j = i + 1; j < keys.count; j++) {
                if (j < keys.count) {
                    NSNumber *keyJ = [keys objectAtIndex:j];
                    TVWallScreenDetailInfo *screenInfoJ = [screenInfoDic objectForKey:keyJ];
                    if ([screenInfoI.strDecoderId isEqualToString:screenInfoJ.strDecoderId]) {
                        [tvwallGroupDic setObject:screenInfoJ forKey:keyJ];
                    }
                }
            }
            [tvwallGroupArray addObject:tvwallGroupDic];
        }
    }
    
    // 2.过滤掉解码器离线的分组,(若所有解码器都离线，则取第一个加入数组)
    NSMutableArray *finalGroupArray = [[NSMutableArray alloc] init];
    if (tvwallGroupArray.count > 0) {
        for (NSDictionary<NSNumber *, TVWallScreenDetailInfo*> *dic in tvwallGroupArray) {
            TVWallScreenDetailInfo *info = [dic objectForKey:[[dic allKeys] firstObject]];
            DSSDeviceInfo *decoderInfo = [[DHDeviceManager sharedInstance] getDeviceInfo:info.strDecoderId];
            if (decoderInfo.isOnline) {
                [finalGroupArray addObject:dic];
            }
        }
        if (finalGroupArray.count == 0) {
            [finalGroupArray addObject:[tvwallGroupArray firstObject]];
        }
    }
    
    return finalGroupArray;
}


/**
 为任务xml添加ChnlExtern节点
 @param screenInfoDic 任务内屏信息字典
 @param originalTaskXmlString 原任务xml
 @return 添加ChnlExtern节点的任务xml
 */
- (NSString *)addChnlExternNodeWithTaskScreenInfoDic:(NSDictionary<NSNumber *, TVWallScreenDetailInfo*> *)screenInfoDic originalTaskXmlString:(NSString *)originalTaskXmlString
{
    if (!originalTaskXmlString) {
        return nil;
    }
    
    NSError *documentError;
    DDXMLDocument *doucument = [[DDXMLDocument alloc] initWithXMLString:originalTaskXmlString options:0 error:&documentError];
    DDXMLElement *rootelement = doucument.rootElement;
    // 修改xml
    [self addChnlExternNodeToXmlElement:rootelement taskScreenInfoDic:screenInfoDic];
    
    return [doucument XMLStringWithOptions:DDXMLNodePrettyPrint];
}

/**
 为任务根节点添加ChnlExtern节点
 @param node 任务xml根节点
 @param screenInfoDic 任务内屏信息字典
 */
- (void)addChnlExternNodeToXmlElement:(DDXMLNode *)node taskScreenInfoDic:(NSDictionary<NSNumber *, TVWallScreenDetailInfo*> *)screenInfoDic
{
    
    for (DDXMLNode *item in node.children) {
        // 删除ChnlExtern节点
        if ([item isKindOfClass:[DDXMLElement class]] && [item.name isEqualToString:@"ChnlExtern"]) {
            [((DDXMLElement *)node) removeChildAtIndex:[node.children indexOfObject:item]];
        }
    }
    
    for (DDXMLNode *item in node.children) {
        // 一、Tasks 任务节点
        if ([item.name isEqualToString:@"Tasks"]) {
            if (item.children.count > 0) {
                DDXMLElement *taskElement = (DDXMLElement *)item.children.firstObject;
                if ([taskElement.name isEqualToString:@"Task"]) {
                    NSMutableArray *chnlExternArray = [[NSMutableArray alloc] init];
                    
                    // 1. 解析Screen节点(屏)
                    // <Screen wndNo="0" decodeId="1000125" tvIdx="0" splitNum="4" visitorMode="2" screenId="8" screenMode="1" isCombined="false" name="...5" left="33.29" top="33.33" width="33.29" height="33.33" screenAlarmWall="0" screenSeq="0">
                    for (DDXMLElement *screenElement in taskElement.children) {
                        NSString *decoderId;
                        // 1.1 解析Screen节点的属性
                        TVWallScreenDetailInfo *screenDetailInfo;
                        for (DDXMLNode *screenAttr in screenElement.attributes) {
                            if ([screenAttr.name isEqualToString:@"screenId"]) {
                                NSNumber *screenIdNum = [NSNumber numberWithInteger:[screenAttr.stringValue integerValue]];
                                screenDetailInfo = [screenInfoDic objectForKey:screenIdNum];
                            }
                            if ([screenAttr.name isEqualToString:@"decodeId"]) {
                                decoderId = screenAttr.stringValue;
                            }
                        }
                        // 1.2 每次修改xml，都重新设置解码模式（防止管理端修改了解码设备的解码模式）
                        for (DDXMLNode *screenAttr in screenElement.attributes) {
                            if ([screenAttr.name isEqualToString:@"visitorMode"]) {
                                int visitorMode = [self getDecoderModeByDecoderId:decoderId];
                                screenAttr.stringValue = [NSString stringWithFormat:@"%d", visitorMode];
                                break;
                            }
                        }
                        if (screenDetailInfo) {
                            for (DDXMLNode *screenAttr in screenElement.attributes) {
                                if ([screenAttr.name isEqualToString:@"splitNum"]) {
                                    screenAttr.stringValue = [NSString stringWithFormat:@"%d", (int)screenDetailInfo.iSplitNum];
                                    break;
                                }
                            }
                        }
                        
                        // 1.3 创建ChnlExtern节点
                        for (NSNumber *key in screenDetailInfo.dictWindowInfo) {
                            NSArray<TWWindowBandInfo*> *bindInfos = [screenDetailInfo.dictWindowBandInfo objectForKey:key];
                            for (TWWindowBandInfo *info in bindInfos) {
                                // 1.3.1 找到所有窗口绑定的编码通道
                                // 解码通道的解码模式如果为直连，则需要带上ChnlExtern节点
                                if ([self getDecoderModeByDecoderId:decoderId] == 1) {
                                    BOOL hasAddedExternChannel = NO;
                                    for (DDXMLElement *externChannelElement in chnlExternArray) {
                                        for (DDXMLNode *externChannelAttrNode in externChannelElement.children) {
                                            if ([externChannelAttrNode.name isEqualToString:@"id"] && [info.strChannelId isEqualToString:externChannelAttrNode.stringValue]) {
                                                hasAddedExternChannel = YES;
                                                break;
                                            }
                                        }
                                    }
                                    // 未添加过的通道才添加到数组
                                    if (!hasAddedExternChannel) {
                                        DDXMLElement *externChannelElement = [self createExternChannelElementWithDecoderId:decoderId encodeChannelId:info.strChannelId];
                                        if (externChannelElement) {
                                            [chnlExternArray addObject:externChannelElement];
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // 2. 添加ChnlExtern节点
                    // chnlExternArray数组元素个数大于0才把这个节点加到xml
                    if (chnlExternArray.count > 0) {
                        DDXMLElement *chnlExternElement = [[DDXMLElement alloc] initWithName:@"ChnlExtern"];
                        for (DDXMLElement *externChannelElement in chnlExternArray) {
                            [chnlExternElement addChild:externChannelElement];
                        }
                        [((DDXMLElement *)node) addChild:chnlExternElement];
                    }
                }
            }
            return;
        }
    }
}

/**
 通过解码器Id获取解码器解码模式
 @param decoderId 解码器Id
 @return  解码模式:直连（1）、拉流（2）、推流给解码器（3）
 */
- (int)getDecoderModeByDecoderId:(NSString *)decoderId
{
    DSSDeviceInfo *decoderInfo = [[DHDeviceManager sharedInstance] getDeviceInfo:decoderId];
    for (NSString *chlId in decoderInfo.channels) {
        DSSChannelInfo *channelInfo = [[DHDeviceManager sharedInstance] getChannelInfo:chlId];
        if (decoderInfo.devicetype == MBL_DEV_TYPE_BIGSCREEN) {
            if (channelInfo.tvWallOutChannelInfo) {
                return channelInfo.tvWallOutChannelInfo.decodeMode;
            }
        } else {
            if (channelInfo.decChannelInfo) {
                return channelInfo.decChannelInfo.decodeMode;
            }
        }
    }
    // 默认直连
    return 2;
}

/**
 通过解码器Id和编码通道Id创建ChnlExtern下的channel节点
 @param decoderId 解码器Id
 @param channelId 编码通道Id
 @return channel节点
 */
- (DDXMLElement *)createExternChannelElementWithDecoderId:(NSString *)decoderId encodeChannelId:(NSString *)channelId
{
    //    ip    设备IP（单播下）或者组播IP（组播下）
    //    port    端口（单播下）或者组播端口（组播下）
    //    username    用户名
    //    password    密码
    //    no     通道号
    //    type    设备类型
    //    channelNum    通道总数
    //    channelName    通道名称
    
    //    .<ChnlExtern>
    //    ..<Channel id="1000667$1$0$0" ip="172.31.117.216" port="37777" username="admin" password="******" no="0" type="0" channelNum="1" channelName="" />
    //    .</ChnlExtern>
    
    DSSDeviceInfo *decoderInfo = [[DHDeviceManager sharedInstance] getDeviceInfo:decoderId];        // 编码器
    DSSChannelInfo *videoChannelInfo = [[DHDeviceManager sharedInstance] getChannelInfo:channelId]; // 解码通道
    NSString *channelDeviceId = videoChannelInfo.deviceId;
    DSSDeviceInfo *deviceInfo = [[DHDeviceManager sharedInstance] getDeviceInfo:channelDeviceId];   // 解码通道所在设备
    
    DDXMLElement *channelElement = [[DDXMLElement alloc] initWithName:@"Channel"];
    DDXMLNode *channelIdAttr = [DDXMLNode attributeWithName:@"id" stringValue:channelId];
    
    //M30/M60/M70/UDS/海康解码器直连海康设备，直接用设备真实IP
    DDXMLNode *channelIpAttr, *channelPortAttr;
    if ( (decoderInfo.devicetype == MBL_DEV_TYPE_MATRIX_M60 ||
          decoderInfo.devicetype == MBL_DEV_TYPE_BIGSCREEN ||
          decoderInfo.devicetype == MBL_DEV_TYPE_UDS ||
          decoderInfo.deviceProvide == MBL_DEVICE_PROVIDER_HIK)
        && deviceInfo.deviceProvide == MBL_DEVICE_PROVIDER_HIK) {
        channelIpAttr = [DDXMLNode attributeWithName:@"ip" stringValue:deviceInfo.devIp];
        channelPortAttr = [DDXMLNode attributeWithName:@"port" stringValue:[NSString stringWithFormat:@"%d", deviceInfo.devPort]];
    } else {
        channelIpAttr = [DDXMLNode attributeWithName:@"ip" stringValue:deviceInfo.ip];
        channelPortAttr = [DDXMLNode attributeWithName:@"port" stringValue:[NSString stringWithFormat:@"%d", deviceInfo.port]];
    }
    
    DDXMLNode *channelUserNameAttr = [DDXMLNode attributeWithName:@"username" stringValue:deviceInfo.userName];
    DDXMLNode *channelPasswordAttr = [DDXMLNode attributeWithName:@"password" stringValue:deviceInfo.password];
    DDXMLNode *channelNoAttr = [DDXMLNode attributeWithName:@"no" stringValue:@"0"];
    NSArray *array = [channelId componentsSeparatedByString:@"$"];
    if (array.count == 4) {
        NSString *channelIndex = [array lastObject];
        [channelNoAttr setStringValue:channelIndex];
    }
    DDXMLNode *channelTypeAttr = [DDXMLNode attributeWithName:@"type" stringValue:@"0"];
    DDXMLNode *channelChannelNumAttr = [DDXMLNode attributeWithName:@"channelNum" stringValue:@"0"];
    int channelNum = 0;
    for (NSString *chlId in deviceInfo.channels) {
        DSSChannelInfo *channelInfo = [[DHDeviceManager sharedInstance] getChannelInfo:chlId];
        if (decoderInfo.devicetype == MBL_DEV_TYPE_BIGSCREEN) {
            if (channelInfo.tvWallInChannelInfo) {
                channelNum ++;
            }
        } else {
            if (channelInfo.encChannelInfo) {
                channelNum ++;
            }
        }
    }
    [channelChannelNumAttr setStringValue:[NSString stringWithFormat:@"%d", channelNum]];
    DDXMLNode *channelChannelNameAttr = [DDXMLNode attributeWithName:@"channelName" stringValue:@""];
    
    [channelElement setAttributes:@[channelIdAttr, channelIpAttr, channelPortAttr, channelUserNameAttr, channelPasswordAttr,
                                    channelNoAttr, channelTypeAttr, channelChannelNumAttr, channelChannelNameAttr]];
    
    
    return channelElement;
}

/**
 修改任务上墙xml
 @param taskScreenInfoDic 任务屏信息字典
 @param originalXmlString 原任务xml
 @return 上墙xml
 */
- (NSString *)modifyMapToWallXmlStringWithTaskScreenInfoDic:(NSDictionary<NSNumber *, TVWallScreenDetailInfo*> *)taskScreenInfoDic originalXmlString:(NSString *)originalXmlString
{
    if (!originalXmlString) {
        return nil;
    }
    
    NSError *documentError;
    DDXMLDocument *doucument = [[DDXMLDocument alloc] initWithXMLString:originalXmlString options:0 error:&documentError];
    DDXMLElement *rootelement = doucument.rootElement;
    // 修改xml
    // 1. 把xml中任务名改为 matrix，
    // 2. 把绑定不同解码器的屏去掉
    [self modifyMapToWallXmlWithNode:rootelement taskScreenInfoDic:taskScreenInfoDic];
    
    return [doucument XMLStringWithOptions:DDXMLNodePrettyPrint];
}

/**
 根据屏信息字典修改上墙任务节点
 @param node 上墙任务节点
 @param taskScreenInfoDic 屏信息字典
 */
- (void)modifyMapToWallXmlWithNode:(DDXMLNode *)node taskScreenInfoDic:(NSDictionary<NSNumber *, TVWallScreenDetailInfo*> *)taskScreenInfoDic
{
    if ([node isKindOfClass:[DDXMLElement class]]) {
        if ([node.name isEqualToString:@"Task"]) {
            for (DDXMLNode *attr in ((DDXMLElement *)node).attributes) {
                // task的名字值改为matrix
                if ([attr.name isEqualToString:@"name"]) {
                    attr.stringValue = @"matrix";
                    break;
                }
            }
            
            // 删除绑定不同解码器的屏
            for (DDXMLElement *screenElement in ((DDXMLElement *)node).children) {
                NSString *decoerId;
                NSNumber *screenId;
                for (DDXMLNode *screenAttr in screenElement.attributes) {
                    if ([screenAttr.name isEqualToString:@"decodeId"]) {
                        decoerId = screenAttr.stringValue;
                    }
                    if ([screenAttr.name isEqualToString:@"screenId"]) {
                        screenId = [NSNumber numberWithInteger:[screenAttr.stringValue integerValue]];
                    }
                }
                TVWallScreenDetailInfo *info = [taskScreenInfoDic objectForKey:screenId];
                if (!info) {
                    [((DDXMLElement *)node) removeChildAtIndex:[node.children indexOfObject:screenElement]];
                }
            }
            return;
        }
    }
    
    for (DDXMLNode *item in node.children) {
        [self modifyMapToWallXmlWithNode:item taskScreenInfoDic:taskScreenInfoDic];
    }
}

@end
