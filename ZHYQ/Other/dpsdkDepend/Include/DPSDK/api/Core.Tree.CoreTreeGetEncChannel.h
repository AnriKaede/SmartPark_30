/**
 *  Auto created by ApiCreator.c on 2016-02-19 05:16:50 GMT.
 *  Should NOT modify!
 */
 
#ifndef _RESTPROTO_API_CoreTreeGetEncChannel_H_
#define _RESTPROTO_API_CoreTreeGetEncChannel_H_

#include "RestProto.h"

/** DESCRIPTION: 
接口注释：
	分级获取编码通道，支持通过设备id过滤
 */

typedef struct CoreTreeGetEncChannelRequest 
{
	PSDKRequest base;

	struct CoreTreeGetEncChannelRequestData
	{
		
		/** 父节点组织编码 */
		CSTR orgCode;
		/** [O]设备编码列表 */
		DECLARE_LIST(CSTR) devices;

	} data;

} CoreTreeGetEncChannelRequest;

C_API CoreTreeGetEncChannelRequest *PSDKAPI_INIT(CoreTreeGetEncChannelRequest);

typedef struct CoreTreeGetEncChannelResponse 
{
	PSDKResponse base;

	struct CoreTreeGetEncChannelResponseData
	{
		
		/** define a list with struct of CoreTreeGetEncChannelResponseData_ChannelListElement */
		DECLARE_LIST(struct CoreTreeGetEncChannelResponseData_ChannelListElement
		{
			/** struct of CoreTreeGetEncChannelResponseData_ChannelListElement_RemoteAttr */
			struct CoreTreeGetEncChannelResponseData_ChannelListElement_RemoteAttr {
				/** 密码 */
				CSTR szPassword;
				/** 设备IP */
				CSTR szIP;
				/** [int]协议类型,参照dgp_dev_protocol_e */
				int emProtocol;
				/** [int]音频输入通道数 */
				int nAudioChannel;
				/** [int]清晰度, 0-标清, 1-高清 */
				int nDefinition;
				/** 用户名 */
				CSTR szUser;
				/** 设备ID */
				CSTR szName;
				/** [int]视频输入通道数 */
				int nVideoChannel;
				/** [int]通道号 */
				int nChnlNum;
				/** [int]端口 */
				int nPort;
			} remoteAttr;
			/** struct of CoreTreeGetEncChannelResponseData_ChannelListElement_EncAttr */
			struct CoreTreeGetEncChannelResponseData_ChannelListElement_EncAttr {
				/** NVR 通道IP */
				CSTR m_strNvrIp;
				/** [int]辅码流端口 */
				int m_subMulticastPort;
				/** [int]类型,参照CameraType_e */
				int m_nCameraType;
				/** 能力集 */
				CSTR m_nCapability;
				/** 经度 */
				CSTR m_strLongitude;
				/** 键盘控制id */
				CSTR m_strCtrlId;
				/** [int]通道是否有拾音器，参见chnl_haspicup_e */
				int m_nHasPickup;
				/** 辅码流IP */
				CSTR m_subMulticastIp;
				/** [int]组播端口 */
				int m_nMulticastPort;
				/** 是否支持可视域 */
				CSTR m_strViewDomain;
				/** 远程通道类型， 范围是 本地编码通道，远程通道，级联通道，模拟矩阵通道 (值分别为1,2,3,4) */
				CSTR m_strChannelRemoteType;
				/** 0:无任何支持功能 1:支持鱼眼 2:支持电动聚焦 */
				CSTR m_cameraFunction;
				/** 组播IP */
				CSTR m_strMulticastIp;
				/** 纬度 */
				CSTR m_strLatitude;
			} encAttr;
			/** struct of CoreTreeGetEncChannelResponseData_ChannelListElement_BaseAttr */
			struct CoreTreeGetEncChannelResponseData_ChannelListElement_BaseAttr {
				/** 通道名称 */
				CSTR m_strChnlName;
				/** [int]通道号 */
				int m_nChnlNum;
				/** define a list with struct of CoreTreeGetEncChannelResponseData_ChannelListElement_BaseAttr_M_sortMapElement */
				DECLARE_LIST(struct CoreTreeGetEncChannelResponseData_ChannelListElement_BaseAttr_M_sortMapElement
				{
					/** 组织编码 */
					CSTR coding;
					/** [int]排序 */
					int sort;
				}) m_sortMap;
				/** [int]通道类型,参照chnl_type_e */
				int m_nChnlType;
				/** [int]单元号 */
				int m_nUnitNo;
				/** 通道信息描述 */
				CSTR m_strChnlDesc;
				/** [int]单元类型,参照Dev_Unit_Type_e */
				int enumUnitType;
				/** 扩展字段（内容为xml） */
				CSTR m_strExtension;
				/** 过期时间 */
				CSTR m_strExpiredDate;
				/** [int]通道状态 */
				int m_nStatus;
				/** 权限掩码，64*(0/1)，见下表权限掩码 */
				CSTR rightsCode;
				/** 互联编码SN */
				CSTR m_strChnlSN;
				/** 设备ID */
				CSTR m_strDevID;
				/** Code */
				CSTR m_strCode;
			} baseAttr;
			/** struct of CoreTreeGetEncChannelResponseData_ChannelListElement_BayAttr */
			struct CoreTreeGetEncChannelResponseData_ChannelListElement_BayAttr {
				/** 连接地址 */
				DECLARE_LIST(CSTR) m_vecLinkChl;
				/** 方向 */
				CSTR m_strDirect;
				/** 录像存储位置 */
				CSTR m_strRecLocation;
			} bayAttr;
			/** 通道编码 */
			CSTR sChnlID;
		}) channelList;
		/** [int]总记录条数 */
		int total;
 
	} data;

} CoreTreeGetEncChannelResponse;

C_API CoreTreeGetEncChannelResponse *PSDKAPI_INIT(CoreTreeGetEncChannelResponse);

#endif
