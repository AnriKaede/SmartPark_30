/**
 *  Auto created by ApiCreator.c on 2016-02-19 05:16:50 GMT.
 *  Should NOT modify!
 */
 
#ifndef _RESTPROTO_API_CoreTreeGetDevice_H_
#define _RESTPROTO_API_CoreTreeGetDevice_H_

#include "RestProto.h"

/** DESCRIPTION: 
接口注释：
	分级获取设备树，支持通过设备id过滤
 */

typedef struct CoreTreeGetDeviceRequest 
{
	PSDKRequest base;

	struct CoreTreeGetDeviceRequestData
	{
		
		/** 父节点组织编码 */
		CSTR orgCode;
		/** [O]设备编码列表 */
		DECLARE_LIST(CSTR) devices;

	} data;

} CoreTreeGetDeviceRequest;

C_API CoreTreeGetDeviceRequest *PSDKAPI_INIT(CoreTreeGetDeviceRequest);

typedef struct CoreTreeGetDeviceResponse 
{
	PSDKResponse base;

	struct CoreTreeGetDeviceResponseData
	{
		
		/** define a list with struct of CoreTreeGetDeviceResponseData_DeviceListElement */
		DECLARE_LIST(struct CoreTreeGetDeviceResponseData_DeviceListElement
		{
			/** struct of CoreTreeGetDeviceResponseData_DeviceListElement_DeviceAttr */
			struct CoreTreeGetDeviceResponseData_DeviceListElement_DeviceAttr {
				/** 设备所在位置 */
				CSTR dev_Location;
				/** [int]代理端口 */
				int nProxyPort;
				/** 设备联系人 */
				CSTR dev_Maintainer;
				/** 生产商 */
				CSTR szManfac;
				/** 第一联系人座机 */
				CSTR szFirstTel;
				/** IP */
				CSTR szIP;
				/** com口序号 */
				CSTR dev_comCode;
				/** 互联编码SN */
				CSTR szSN;
				/** [int]设备状态 */
				int m_nStatus;
				/** [int]type */
				int nType;
				/** 用户名 */
				CSTR szUser;
				/** 设备名称 */
				CSTR szName;
				/** 主动注册设备ID */
				CSTR szRegID;
				/** 店名 */
				CSTR szShopName;
				/** 模式 */
				CSTR szModel;
				/** 店的地址 */
				CSTR szAddress;
				/** 设备序列号 */
				CSTR szCN;
				/** 设备真实IP */
				CSTR szDevIP;
				/** 设备所在的派出所 */
				CSTR dev_LocalPolice;
				/** define a list with struct of CoreTreeGetDeviceResponseData_DeviceListElement_DeviceAttr_M_sortMapElement */
				DECLARE_LIST(struct CoreTreeGetDeviceResponseData_DeviceListElement_DeviceAttr_M_sortMapElement
				{
					/** 组织编码 */
					CSTR coding;
					/** [int]排序 */
					int sort;
				}) m_sortMap;
				/** 波特率 */
				CSTR dev_baudRate;
				/** 设备呼叫号码 */
				CSTR szCallNum;
				/** 第一联系人姓名 */
				CSTR szFirstOwner;
				/** 设备联系人号码 */
				CSTR dev_MaintainerPh;
				/** 固件版本 */
				CSTR szDevVersion;
				/** 设备型号 */
				CSTR szDevModel;
				/** 密码 */
				CSTR szPassword;
				/** 过期时间 */
				CSTR szExpiredDate;
				/** 第一联系人电话 */
				CSTR szFirstPhone;
				/** 视频类型 */
				CSTR szVideoType;
				/** 所属组织 */
				CSTR szOwnerGroup;
				/** 第一联系人职务 */
				CSTR szFirstPosition;
				/** [int]服务状态 */
				int nServiceType;
				/** [int]设备真实port */
				int nDevPort;
				/** 登陆类型 */
				CSTR szLoginTypeEx;
				/** 登陆类型 */
				CSTR szLoginType;
				/** 权限掩码，64*(0/1)，见下表权限掩码 */
				CSTR rightsCode;
				/** 设备描述 */
				CSTR desc;
				/** [int]单元数目--对于矩阵设备代表卡槽数 */
				int nUnitNum;
				/** [int]port */
				int nPort;
			} deviceAttr;
			/** 设备编码 */
			CSTR szID;
		}) deviceList;
		/** [int]总记录条数 */
		int total;
 
	} data;

} CoreTreeGetDeviceResponse;

C_API CoreTreeGetDeviceResponse *PSDKAPI_INIT(CoreTreeGetDeviceResponse);

#endif
