/**
 *  Auto created by ApiCreator.c on 2016-02-19 05:16:51 GMT.
 *  Should NOT modify!
 */
 
#ifndef _RESTPROTO_API_CoreTreeGetOrganization_H_
#define _RESTPROTO_API_CoreTreeGetOrganization_H_

#include "RestProto.h"

/** DESCRIPTION: 
接口注释：
	分级获取组织树
 */

typedef struct CoreTreeGetOrganizationRequest 
{
	PSDKRequest base;

	struct CoreTreeGetOrganizationRequestData
	{
		
		/** 父节点组织编码 */
		CSTR orgCode;
		/** [int]节点类型,参照core_tree_node_type_e定义 */
		int nNodeType;
		/** [int]深度,参照dpsdk_getgroup_operation_e定义 */
		int nOperation;

	} data;

} CoreTreeGetOrganizationRequest;

C_API CoreTreeGetOrganizationRequest *PSDKAPI_INIT(CoreTreeGetOrganizationRequest);

typedef struct CoreTreeGetOrganizationResponse 
{
	PSDKResponse base;

	struct CoreTreeGetOrganizationResponseData
	{
		
		/** define a list with struct of CoreTreeGetOrganizationResponseData_OrgInfoElement */
		DECLARE_LIST(struct CoreTreeGetOrganizationResponseData_OrgInfoElement
		{
			/** 组织编码 */
			CSTR orgCode;
			/** define a list with struct of CoreTreeGetOrganizationResponseData_OrgInfoElement_DeviceListElement */
			DECLARE_LIST(struct CoreTreeGetOrganizationResponseData_OrgInfoElement_DeviceListElement
			{
				/** 设备id */
				CSTR id;
				/** [int]排序码 */
				int sort;
			}) deviceList;
			/** struct of CoreTreeGetOrganizationResponseData_OrgInfoElement_OrgAttr */
			struct CoreTreeGetOrganizationResponseData_OrgInfoElement_OrgAttr {
				/** [int]组织结构类型 */
				int orgType;
				/** [int]排序码 */
				int sort;
				/** 父节点组织编号，根级组织节点父节点为空串 */
				CSTR parentOrgCode;
				/** 组织名称 */
				CSTR orgName;
				/** 唯一标识码，用于公安系统对接 */
				CSTR orgSN;
				/** 描述 */
				CSTR memo;
			} orgAttr;
			/** define a list with struct of CoreTreeGetOrganizationResponseData_OrgInfoElement_ChannelListElement */
			DECLARE_LIST(struct CoreTreeGetOrganizationResponseData_OrgInfoElement_ChannelListElement
			{
				/** 通道id */
				CSTR id;
				/** [int]排序码 */
				int sort;
			}) channelList;
		}) orgInfo;
		/** [int]总记录条数 */
		int total;
 
	} data;

} CoreTreeGetOrganizationResponse;

C_API CoreTreeGetOrganizationResponse *PSDKAPI_INIT(CoreTreeGetOrganizationResponse);

#endif
