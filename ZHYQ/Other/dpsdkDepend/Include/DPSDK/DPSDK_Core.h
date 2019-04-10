/**
 * Copyright (c) 2012, 浙江大华
 * All rights reserved.
 *
 * 文件名称：DPSDK_Core.h
 * 文件标识：
 * 摘　　要：DPSDK_Core 接口文件 
 *
 * 当前版本：1.0
 * 原作者　：yu_lexin
 * 完成日期：
 * 修订记录：创建
*/

#ifndef INCLUDED_DPSDK_CORE_H
#define INCLUDED_DPSDK_CORE_H

#include "DPSDK_Core_Define.h"

/***************************************************************************************
 @ 接口定义
***************************************************************************************/

/** 创建SDK句柄.
 @param   IN	nType			SDK类型
 @param   OUT	nPDLLHandle		返回SDK句柄，后续操作需要以此作为参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark									
*/
int32_t DPSDK_CALL_METHOD	DPSDK_Create( IN dpsdk_sdk_type_e nType,
													  OUT int32_t* pnPDLLHandle );

int32_t DPSDK_CALL_METHOD	DPSDK_CreateWithParam( IN dpsdk_sdk_type_e nType, 
													 OUT int32_t* nPDLLHandle,
													 IN DPSDK_CreateParam_t* pDPSDKParam);

/** 删除SDK句柄.
 @param   IN	nPDLLHandle		SDK句柄
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
	1、需要和DPSDK_Create成对使用
*/
int32_t DPSDK_CALL_METHOD	DPSDK_Destroy( IN int32_t nPDLLHandle );

/** 设置日志.
 @param   IN	nLevel			日志等级
 @param   IN	szFilename		文件名称
 @param   IN	bScreen			是否输出到屏幕
 @param   IN	bDebugger		是否输出到调试器
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark									
*/
int32_t DPSDK_CALL_METHOD	DPSDK_SetLog( IN int32_t nPDLLHandle,
													  IN dpsdk_log_level_e nLevel, 
													  IN const char* szFilename, 
													  IN bool bScreen, 
													  IN bool bDebugger );

/** 设置DPSDK状态回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD	DPSDK_SetDPSDKStatusCallback( IN int32_t nPDLLHandle,
																	  IN fDPSDKStatusCallback fun, 
																	  IN void* pUser );

/** 设置DPSDK设备变更回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD	DPSDK_SetDPSDKDeviceChangeCallback( IN int32_t nPDLLHandle,
																			IN fDPSDKDeviceChangeCallback fun, 
																			IN void* pUser );

/** 设置DPSDK新组织设备变更回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKOrgDevChangeNewCallback( IN int32_t nPDLLHandle, 
																			  IN fDPSDKOrgDevChangeNewCallback fun, 
																			  IN void* pUser );
																			  
/** 设置DPSDK设备状态回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD	DPSDK_SetDPSDKDeviceStatusCallback( IN int32_t nPDLLHandle,
																			IN fDPSDKDevStatusCallback fun, 
																			IN void* pUser );
/** 设置DPSDK组织（部门辖区）变更回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKOrgChangeCallback( IN int32_t nPDLLHandle,
																		 IN fDPSDKOrgChangeCallback fun,
																		 IN void* pUser);
/** 设置DPSDK人员变更回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKPersonChangeCallback( IN int32_t nPDLLHandle,
																			IN fDPSDKPersonChangeCallback fun,
																			IN void* pUser);
///** 设置DPSDK车辆回调.
// @param   IN	nPDLLHandle		SDK句柄
// @param   IN	fun				回调函数
// @param   IN	pUser			用户参数
// @return  函数返回错误类型，参考dpsdk_retval_e
// @remark
//*/
// int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKCarChangeCallback( IN int32_t nPDLLHandle,
//																		 IN fDPSDKCarChangeCallback fun,
//																		 IN void* pUser);


/** 注册平台.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	pLoginInfo		用户登录信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_Login( IN int32_t nPDLLHandle,
													 IN Login_Info_t* pLoginInfo, 
													 IN int32_t nTimeout);

/** 登出平台.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_Logout( IN int32_t nPDLLHandle,
													  IN int32_t nTimeout);

/** 重连CMS.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_ReconnectToCMS( IN int32_t nPDLLHandle, 
												IN int32_t nTimeout );

/** 获取用户Id.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	nUserId			用户Id
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetUserID( IN int32_t nPDLLHandle,
														 OUT uint32_t* pnUserId );

/** 获取用户等级.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	nUserLevel		用户等级
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetUserLevel( IN int32_t nPDLLHandle,
                                                OUT uint32_t* pnUserLevel );

/** 获取组织结构时，设置是否采用压缩格式获取.
 @param   IN	nPDLLHandle			SDK句柄
 @param   IN	nCompressType		是否采用压缩格式
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark									
*/
int32_t DPSDK_CALL_METHOD	DPSDK_SetCompressType( IN int32_t nPDLLHandle, 
																IN dpsdk_get_devinfo_compress_type_e nCompressType);
/** 获取电子地图服务配置信息
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	mapAddrInfo		电子地图服务配置信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetMapAddrInfo( IN int32_t nPDLLHandle,
                                                OUT Config_Emap_Addr_Info_t* pEmapAddrInfo,
                                                IN int32_t nTimeout);
/** 更改用户密码.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szOldPsw		原有密码
 @param   IN	szNewPsw		新密码
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_ChangeUserPassword( IN int32_t nPDLLHandle,
                                                    IN const char* szOldPsw,
                                                    IN const char* szNewPsw,
                                                    IN int32_t nTimeout );

/** 加载组织设备信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	nGroupLen       组织结构信息长度
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_LoadDGroupInfo( IN int32_t nPDLLHandle,
															  OUT int32_t* pnGroupLen,
															  IN int32_t nTimeout);
/** 加载特定类型组织信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN    type            通用节点类型
 @param   OUT	nOrgCount       返回组织信息的数量
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_LoadOrgInfoByType( IN int32_t nPDLLHandle,
																 IN dpsdk_org_node_e type,
																 OUT int32_t* pnOrgCount,
																 IN int32_t nTimeout);

/** 获取组织下子组织个数.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN    type            节点类型
 @param   INOUT	pGetInfo        获取组织个数请求信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetOrgCountByType( IN int32_t nPDLLHandle,
																 IN dpsdk_org_node_e type,
																 INOUT Get_Org_Count_Info_t* pGetInfo );

/** 获取组织下子组织和子设备的信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN    type            组织类型
 @param   INOUT	pGetInfo       获取组织请求信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetOrgInfoByType( IN int32_t nPDLLHandle,
																IN dpsdk_org_node_e type,
																INOUT Get_Org_Info_t* pGetInfo);

/** 获取部门和辖区关系记录数.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT    nCount         记录数目
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDeptAreaRelationCount( IN int32_t nPDLLHandle,
																		OUT int32_t* pnCount,
																		IN int32_t nTimeout);
/** 获取部门和辖区关系记录.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT pGetInfo        获取部门辖区关系请求信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetAllDeptAreaRelation( IN int32_t nPDLLHandle,
																	  INOUT Get_DeptArea_Relation_t* pGetInfo);

/** 加载所有人员信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	nPersonCount	所有人员数目
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_LoadAllPersonInfo( IN int32_t nPDLLHandle,
																 OUT int32_t* pnPersonCount,
																 IN int32_t nTimeout);
/** 获取特定部门的所有人员数.
 @param   IN	nPDLLHandle	   SDK句柄
 @param   IN szDeptCode        部门编号
 @param   IN nPersonCount      人数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetPersonCountByDept( IN int32_t nPDLLHandle,
																	IN char* szDeptCode,
																	OUT int32_t* pnPersonCount);
/** 获取部门的所有人员信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT pGetInfo        人员信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetPersonInfoByDept( IN int32_t nPDLLHandle,
															       INOUT Get_Person_Info_t * pGetInfo);
///** 加载所有车辆信息.
// @param   IN	nPDLLHandle		SDK句柄
// @param   INOUT	nPersonCount	所有车辆数目
// @return  函数返回错误类型，参考dpsdk_retval_e
// @remark
// */
// int32_t DPSDK_CALL_METHOD DPSDK_LoadAllCarInfo( IN int32_t nPDLLHandle, 
//															  OUT int32_t* nCarCount,
//															  IN int32_t nTimeout = DPSDK_CORE_DEFAULT_TIMEOUT);


/** 分级加载组织设备信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	pGetInfo		分级获取的节点信息 
 @param   OUT	nGroupLen       组织结构信息长度
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_LoadDGroupInfoLayered( IN int32_t nPDLLHandle,
																	 IN Load_Dep_Info_t* pGetInfo, 
																	 OUT int32_t* pnGroupLen,
																	 IN int32_t nTimeout);

/** 获取组织设备信息串.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szGroupBuf		组织结构缓存,需要外部创建缓存，大小为nGroupLen+1
 @param   OUT	nGroupLen       组织结构信息长度
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、szGroupBuf需要在外面创建好
 2、szGroupBuf的大小与nGroupLen需要一致或者大于nGroupLen
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetDGroupStr( IN int32_t nPDLLHandle,
															OUT char* szGroupBuf, 
															IN int32_t nGroupLen, 
															IN int32_t nTimeout);

/** 获取分级加载的组织设备信息串.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	szGroupBuf		组织结构缓存,需要外部创建缓存，大小为nGroupLen+1
 @param   IN	nGroupLen       组织结构信息长度
 @param   IN	szCoding		节点code
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、szGroupBuf需要在外面创建好
 2、szGroupBuf的大小与nGroupLen需要一致或者大于nGroupLen
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetDGroupLayeredStr( IN int32_t nPDLLHandle, 
													 OUT char* szGroupBuf, 
													 IN int32_t nGroupLen,
													 IN const char* szCoding, 
													 IN int32_t nTimeout );

/** 获取根节点信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pGetInfo		根节点信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetDGroupRootInfo(IN int32_t nPDLLHandle,
																OUT Dep_Info_t* pGetInfo );

/** 获取组织下子组织和子设备的个数.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	pGetInfo		获取组织个数请求信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetDGroupCount( IN int32_t nPDLLHandle,
															  INOUT Get_Dep_Count_Info_t* pGetInfo );

/** 获取组织下子组织和子设备的信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	pGetInfo		子组织子设备信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、pDepInfo、pDeviceInfo需要在外面创建好
 2、pDepInfo、pDeviceInfo的大小与DPSDK_GetDGroupCount返回需要一致
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDGroupInfo( IN int32_t nPDLLHandle,
															 INOUT Get_Dep_Info_t* pGetInfo );

/** 获取组织下子组织、子设备、子通道的信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	pGetInfo		子组织子设备通道信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、pDepInfo、pDeviceInfo需要在外面创建好
 2、pDepInfo、pDeviceInfo的大小与DPSDK_GetDGroupCount返回需要一致
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDGroupInfoEx( IN int32_t nPDLLHandle, 
															 INOUT Get_Dep_Info_Ex_t* pGetInfo );															  
															 
/** 设置缓存组织树文件路径.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szFilePath		文件路径,android默认为"/sdcard"
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、szFilePath android默认为"/sdcard"
 */
int32_t DPSDK_CALL_METHOD DPSDK_SetSaveGroupFilePath( IN int32_t nPDLLHandle, 
													  IN const char* szFilePath );

/** 获取设备下子通道的信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	pGetInfo		子通道信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、pEncChannelnfo需要在外面创建好
 2、pEncChannelnfo的大小与DPSDK_GetDGroupInfo中通道个数返回需要一致
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetChannelInfo( IN int32_t nPDLLHandle,
															  INOUT Get_Channel_Info_t* pGetInfo );

/** 获取设备下子通道的信息(扩展).
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	pGetInfo		子通道信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、pEncChannelnfo需要在外面创建好
 2、pEncChannelnfo的大小与DPSDK_GetDGroupInfo中通道个数返回需要一致
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetChannelInfoEx( IN int32_t nPDLLHandle,
                                                               INOUT Get_Channel_Info_Ex_t* pGetInfo );

/** 获取组织下编码器通道的信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	pGetInfo		子通道信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、pEncChannelnfo需要在外面创建好
 2、pEncChannelnfo的大小与DPSDK_GetDGroupInfo中通道个数返回需要一致
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDepChannelInfo( IN int32_t nPDLLHandle, INOUT Get_Dep_Channel_Info_t* pGetInfo );

/** 获取设备支持的码流类型.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	pGetInfo		获取信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDevStreamType( IN int32_t nPDLLHandle,
																INOUT Get_Dev_StreamType_Info_t* pGetInfo );


/** 通过设备IP和端口以及通道号获取通道编码.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szDevIp			设备IP
 @param   IN	nPort			设备port
 @param   IN	nChnlNum		通道号（从0开始）
 @param   OUT	szCameraId		通道编码
 @param	  IN	nUnitType		单元类型（1-编码单元，2-）
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetCameraIdbyDevInfo( IN int32_t nPDLLHandle,
																	IN const char* szDevIp,
																	IN const int nPort,
																	IN const int nChnlNum,
																	OUT char* szCameraId,
																	IN dpsdk_dev_unit_type_e nUnitType);

/** 获取通道类型
 @param   IN	nPDLLHandle			SDK句柄
 @param   IN	szCameraId			设备ID
 @param   OUT	pUnitType			通道类型
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetChnlType( IN int32_t nPDLLHandle,
                                                          IN char *szCameraId,
                                                          OUT dpsdk_dev_unit_type_e* pUnitType);

/** 是否有业务树
 @param   IN	nPDLLHandle		SDK句柄
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
bool DPSDK_CALL_METHOD DPSDK_HasLogicOrg(IN int32_t nPDLLHandle);

/** 获取业务树根节点信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pDepInfoEx		业务树根节点信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetLogicRootDepInfo(IN int32_t nPDLLHandle,
                                                                  OUT Dep_Info_Ex_t* pDepInfoEx );

/** 获取业务树指定节点下 节点/通道/设备的数目
 @param   IN	nPDLLHandle						SDK句柄
 @param   IN    szDepCoding						节点Coding
 @param   IN    nNodeType						组织/通道/设备
 @param   OUT   pnDepNodeNum					节点下 节点/通道/设备的数目
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetLogicDepNodeNum(IN int32_t nPDLLHandle,
                                                                 IN char* szDepCoding,
                                                                 IN dpsdk_node_type_e nNodeType,
                                                                 OUT int32_t* pnDepNodeNum);

/** 获取业务树指定节点下 节点信息
 @param   IN	nPDLLHandle						SDK句柄
 @param   IN    szDepCoding						节点Coding
 @param   IN    nIndex							序号
 @param   OUT   pDepInfoEx						组织节点信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetLogicSubDepInfoByIndex(IN int32_t nPDLLHandle,
																		IN char* szDepCoding,
																		IN int32_t nIndex,
																		OUT Dep_Info_Ex_t* pDepInfoEx);

/** 获取业务树指定节点下 设备或者通道ID
 @param   IN	nPDLLHandle						SDK句柄
 @param   IN    szDepCoding						节点Coding
 @param   IN    nIndex							序号
 @param   IN	bChnl							=true 为通道，否则是设备
 @param   OUT	szCodeID						节点ID
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark     
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetLogicID(IN int32_t nPDLLHandle,
                                                         IN char* szDepCoding, 
                                                         IN int nIndex, 
                                                         IN bool bChnl, 
                                                         OUT char* szCodeID);
/** 保存操作员日志
 @param   IN	nPDLLHandle		 SDK句柄
 @param   IN	szCameraId		 通道编号
 @param   IN    optTime			 操作时间
 @param   IN    optType	         操作类型
 @param   IN    optDesc		     操作描述
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_SaveOptLog(  IN int32_t nPDLLHandle,
														   IN const char* szCameraId,
														   IN uint64_t optTime,
														   IN dpsdk_log_optType_e optType,
														   IN const char* optDesc);


/** 获取实况码流.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	nRealSeq		码流请求序号,可作为后续操作标识 
 @param   IN	pGetInfo		码流请求信息 
 @param   IN    pFun			码流回调函数				
 @param   IN    pUser			码流回到用户参数
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetRealStream( IN int32_t nPDLLHandle,
															 OUT int32_t* pnRealSeq,
															 IN Get_RealStream_Info_t* pGetInfo, 
															 IN fMediaDataCallback pFun, 
															 IN void* pUser, 
															 IN int32_t nTimeout);


/** 按请求序号关闭码流.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	nRealSeq		码流请求序号
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_CloseRealStreamBySeq( IN int32_t nPDLLHandle,
																	IN int32_t nRealSeq, 
																    IN int32_t nTimeout);


 /** 获取实时流的URL
 @param   IN	nPDLLHandle				SDK句柄
 @param   INOUT	pRealStreamUrlInfo		查询实时流Url信息
 @param   IN	nTimeout				超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetRealStreamUrl( IN int32_t nPDLLHandle,INOUT Get_RealStreamUrl_Info_t* pRealStreamUrlInfo ,IN int32_t nTimeout);

//  /** 获取DSS平台对外的媒体流URL
//  @param   IN	nPDLLHandle						SDK句柄
//  @param   INOUT	pExternalRealStreamUrlInfo		查询实时流Url信息
//  @param   IN	nTimeout						超时时长，单位毫秒
//  @return  函数返回错误类型，参考dpsdk_retval_e
//  @remark  
// */
int32_t DPSDK_CALL_METHOD DPSDK_GetExternalRealStreamUrl( IN int32_t nPDLLHandle,
 																		 INOUT Get_ExternalRealStreamUrl_Info_t* pExternalRealStreamUrlInfo, 
 																		 IN int32_t nTimeout);


/**按请求序号释放播放视频的URL路径
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	nRealSeq		按请求序号
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  												
*/
// int32_t DPSDK_CALL_METHOD DPSDK_CloseStreamUrlBySeq( IN int32_t nPDLLHandle,
//															         IN int32_t nRealSeq, 
//															         IN int32_t nTimeout = DPSDK_CORE_DEFAULT_TIMEOUT);

/** 按cameraId释放播放视频的URL路径
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szCameraId		通道编号
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  												
*/
// int32_t DPSDK_CALL_METHOD DPSDK_CloseStreamUrlByCameraId( IN int32_t nPDLLHandle, 
//																	      IN const char* szCameraId, 
//															  		      IN int32_t nTimeout = DPSDK_CORE_DEFAULT_TIMEOUT );

/** 获取语音码流
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	nTalkSeq		码流请求序号,可作为后续操作标识 
 @param   IN	pGetInfo		码流请求信息 
 @param   IN    pFun			码流回调函数				
 @param   IN    pUser			码流回到用户参数
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetTalkStream( IN int32_t nPDLLHandle,
														     OUT int32_t* pnTalkSeq,
														     IN Get_TalkStream_Info_t* pGetInfo, 
														     IN fMediaDataCallback pFun, 
														     IN void* pUser, 
														     IN int32_t nTimeout);
/** 按请求序列停止语音码流的获取
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	nRealSeq		码流请求序号,可作为后续操作标识 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_CloseTalkStreamBySeq( IN int32_t nPDLLHandle,
															        IN int32_t nRealSeq, 
															        IN int32_t nTimeout);
/** 按CameralId停止语音码流获取.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szCameraId		通道编号 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_CloseTalkStreamByCameralId( IN int32_t nPDLLHandle,
															              IN const char* szCameraId,
															              IN int32_t nTimeout);

/** 获取语音采集回调信息
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pCallBackFun	回调函数
 @param   OUT	pUserParam   	回调函数用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetSdkAudioCallbackInfo(IN int32_t nPDLLHandle,
															          OUT void** pCallBackFun,
																      OUT AudioUserParam_t** pUserParam);

/** 查询录像.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	pQueryInfo		查询信息
 @param   OUT	nRecordCount	录像记录个数
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
   1、nRecordCount最大5000个记录
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryRecord( IN int32_t nPDLLHandle,
														   IN Query_Record_Info_t* pQueryInfo, 
														   OUT int32_t* pnRecordCount,
														   IN int32_t nTimeout);

/** 通过码流类型查询录像.
 @param   IN	nPDLLHandle				SDK句柄
 @param   IN	pQueryInfo				查询信息
 @param   IN	nStreamType				码流类型
 @param   OUT	nRecordCount			录像记录个数
 @param   IN	nTimeout				超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、nRecordCount最大5000个记录
 */
int32_t DPSDK_CALL_METHOD DPSDK_QueryRecordByStreamType( IN int32_t nPDLLHandle,
                                                        IN Query_Record_Info_t* pQueryInfo,
                                                        IN dpsdk_stream_type_e nStreamType,
                                                        OUT int32_t* pnRecordCount,
                                                        IN int32_t nTimeout);

/** 获取录像信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pRecords		录像信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
   1、必须先查询后获取
   2、DPSDK_QueryRecord会返回记录个数,
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetRecordInfo( IN int32_t nPDLLHandle,
															 INOUT Record_Info_t* pRecords );

/** 按文件请求录像流.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   OUT	nPlaybackSeq	回放请求序号,作为后续操作标识  
 @param	  IN	pRecordInfo		录像信息 
 @param   IN    pFun			码流回调函数				
 @param   IN    pUser			码流回到用户参数
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetRecordStreamByFile( IN int32_t nPDLLHandle,
																	 OUT int32_t* pnPlaybackSeq,
																	 IN Get_RecordStream_File_Info_t* pRecordInfo, 
																	 IN fMediaDataCallback pFun, 
																	 IN void* pUser, 
																	 IN int32_t nTimeout);

/** 按时间请求录像流.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   OUT	nPlaybackSeq	回放请求序号,作为后续操作标识  
 @param	  IN	pRecordInfo		录像信息 
 @param   IN    pFun			码流回调函数				
 @param   IN    pUser			码流回到用户参数
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetRecordStreamByTime( IN int32_t nPDLLHandle, 
													  OUT int32_t* nPlaybackSeq, 
													  IN Get_RecordStream_Time_Info_t* pRecordInfo, 
													  IN fMediaDataCallback pFun, 
													  IN void* pUser, 
													  IN int32_t nTimeout);


/** 根据码流类型按时间请求录像流.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   OUT	pnPlaybackSeq	回放请求序号,作为后续操作标识  
 @param	  IN	pRecordInfo		录像信息
 @param   IN	nStreamType		码流类型
 @param   IN    pFun			码流回调函数				
 @param   IN    pUser			码流回调用户参数
 @param   IN	nTimeout		超时时长，单位毫秒
 @param   IN	nTransMode		传输模式，1:TCP 0:UDP 默认1
 @param   IN	bBack			是否倒放 默认false
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetRecordStreamByStreamType( IN int32_t nPDLLHandle, 
															OUT int32_t* nPlaybackSeq, 
															IN Get_RecordStream_Time_Info_t* pRecordInfo, 
															IN dpsdk_stream_type_e nStreamType, 
															IN fMediaDataCallback pFun, 
															IN void* pUser, 
															IN int32_t nTimeout, 
															IN int32_t nTransMode, 
															bool bBack );

/** 暂停录像流.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	nPlaybackSeq	回放请求序号 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PauseRecordStreamBySeq( IN int32_t nPDLLHandle,
																	  IN int32_t nPlaybackSeq, 
																	  IN int32_t nTimeout);

/** 恢复录像流.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	nPlaybackSeq	回放请求序号 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_ResumeRecordStreamBySeq( IN int32_t nPDLLHandle,
																	   IN int32_t nPlaybackSeq, 
																	   IN int32_t nTimeout);

/** 设置录像流速率.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	nPlaybackSeq	回放请求序号 
 @param   IN    nSpeed,         录像流回放速度
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetRecordStreamSpeed( IN int32_t nPDLLHandle,
																	IN int32_t nPlaybackSeq, 
																	IN dpsdk_playback_speed_e nSpeed,
																	IN int32_t nTimeout);

/** 定位回放.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	nPlaybackSeq	回放请求序号 
 @param   IN    seekBegin,		定位起始值.文件模式时,是定位处的文件大小值;时间模式时,是定位处的时间值;
 @param   IN    seekEnd,		定位结束值.文件模式时,无意义;时间模式时,是期待的结束时间.
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark 
			seekBegin在文件模式下的计算方式可以是:(文件大小值)/100*(定位处相对文件的百分比)  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SeekRecordStreamBySeq(IN int32_t nPDLLHandle,
																	IN int32_t nPlaybackSeq, 
																	IN uint64_t seekBegin, 
																	IN uint64_t seekEnd, 
																	IN int32_t nTimeout);

/** 关闭录像流.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	nPlaybackSeq	回放请求序号 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_CloseRecordStreamBySeq( IN int32_t nPDLLHandle,
																	  IN int32_t nPlaybackSeq, 
																	  IN int32_t nTimeout);

/** 按通道关闭录像流.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	szCameraId   	通道编号 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_CloseRecordStreamByCameraId( IN int32_t nPDLLHandle,
																		   IN const char* szCameraId, 
																		   IN int32_t nTimeout);

/** 录像打标.
 @param   IN	nPDLLHandle		SDK句柄
 @param   INOUT	pTagInfo		录像打标信息
 @param	  IN	nOpType			打标操作，1：新增，2：修改，3：删除
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_OperatorTagInfo( IN int32_t nPDLLHandle, 
															   INOUT Tag_Info_t* pTagInfo,
															   IN dpsdk_operator_type_e nOpType, 
															   IN int32_t nTimeout );
															   
/** 云台方向控制.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	pDirectInfo		云台方向控制信息 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzDirection( IN int32_t nPDLLHandle,
															IN Ptz_Direct_Info_t* pDirectInfo, 
															IN int32_t nTimeout);

/** 云台镜头控制.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	pOperationInfo	云台镜头控制信息 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzCameraOperation( IN int32_t nPDLLHandle,
																  IN Ptz_Operation_Info_t* pOperationInfo, 
																  IN int32_t nTimeout);


/** 云台三维定位.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	pSitInfo		云台三维定位信息 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzSit( IN int32_t nPDLLHandle,
													  IN Ptz_Sit_Info_t* pSitInfo, 
													  IN int32_t nTimeout);

/** 云台锁定控制.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	pLockInfo	    云台锁定控制信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzLockCamera( IN int32_t nPDLLHandle,
															 IN Ptz_Lock_Info_t* pLockInfo, 
															 IN int32_t nTimeout);

/** 云台灯光控制.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	szCameraId		通道ID 
 @param   IN	bOpen			开启标识
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzLightControl( IN int32_t nPDLLHandle,
															   IN Ptz_Open_Command_Info_t* Cmd, 
															   IN int32_t nTimeout);

/** 云台雨刷控制.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	szCameraId		通道ID 
 @param   IN	bOpen			开启标识
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzRainBrushControl( IN int32_t nPDLLHandle,
																   IN Ptz_Open_Command_Info_t* Cmd, 
																   IN int32_t nTimeout);

/** 云台红外控制.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	szCameraId		通道ID 
 @param   IN	bOpen			开启标识
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzInfraredControl( IN int32_t nPDLLHandle,
																  IN Ptz_Open_Command_Info_t* Cmd, 
																  IN int32_t nTimeout);

/** 云台查询预置点信息.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  INOUT	pPrepoint		预置点信息 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryPrePoint( IN int32_t nPDLLHandle,
															 INOUT Ptz_Prepoint_Info_t* pPrepoint, 
															 IN int32_t nTimeout);

/** 云台预置点操作.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	pOperation		预置点操作信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzPrePointOperation( IN int32_t nPDLLHandle,
																	IN Ptz_Prepoint_Operation_Info_t* pOperation, 
																	IN int32_t nTimeout);

/** 云台扩展命令.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pExtCmd			扩展命令信息 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PtzExtendCommand( IN int32_t nPDLLHandle,
																IN Ptz_Extend_Command_Info_t* pExtCmd, 
																IN int32_t nTimeout);

/** 获取人流量
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pGetPCount		人流量信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetPeopleCount( IN int32_t nPDLLHandle,
															  IN Get_People_Count_t* pGetPCount, 
															  IN int32_t nTimeout);



/** 设置报警状态回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
	1、需要和DPSDK_Create成对使用
*/
int32_t DPSDK_CALL_METHOD	DPSDK_SetDPSDKAlarmCallback( IN int32_t nPDLLHandle,
																	 IN fDPSDKAlarmCallback fun, 
																	 IN void* pUser );
/** 设置新报警状态回调
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
	1、需要和DPSDK_Create成对使用
*/
int32_t DPSDK_CALL_METHOD	DPSDK_SetDPSDKNewAlarmCallback( IN int32_t nPDLLHandle, 
																	 IN fDPSDKNewAlarmCallback fun, 
																	 IN void* pUser );

/** 报警布控.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pSourceInfo		报警方案 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
 1、布控时需要明白不同的报警类型对应不同的参数
*/
int32_t DPSDK_CALL_METHOD DPSDK_EnableAlarm( IN int32_t nPDLLHandle,
														   IN Alarm_Enable_Info_t* pSourceInfo, 
														   IN int32_t nTimeout);

/** 报警撤控.
 @param	  IN	nPDLLHandle		SDK句柄
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_DisableAlarm( IN int32_t nPDLLHandle,
															IN int32_t nTimeout);
/** 查询报警个数.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN    pQuery          查询信息
 @param	  OUT	nCount			报警个数返回 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryAlarmCount( IN int32_t nPDLLHandle,
															   IN Alarm_Query_Info_t* pQuery, 
															   OUT int32_t* pnCount,
															   IN int32_t nTimeout);

/** 查询报警信息.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN    pQuery          查询信息
 @param	  		pInfo			报警信息 
 @param	  IN	nFirstNum		从第几个开始获取 
 @param	  IN	nQueryCount		获取多少个 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
 1、支持分批获取
 2、此接口推荐和DPSDK_QueryAlarmCount一起使用
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryAlarmInfo( IN int32_t nPDLLHandle,
															  IN Alarm_Query_Info_t* pQuery, 
															  INOUT Alarm_Info_t* pInfo, 
															  IN int32_t nFirstNum, 
															  IN int32_t nQueryCount, 
															  IN int32_t nTimeout);
/** 查询报警图片信息.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN    optype          操作类型
 @param	  IN	szCameraId		通道ID 
 @param	  IN	szIvsURL		图片URL 
 @param	  IN	szSavePath		保存路径 
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
 1、支持分批获取
 2、此接口推荐和DPSDK_QueryAlarmCount一起使用
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryIvsbAlarmPicture( IN int32_t nPDLLHandle,
																   IN dpsdk_operator_ftp_type_e optype, 
																   IN const char* szCameraId,
																   IN const char* szIvsURL, 
																   IN const char* szSavePath,
																   IN int32_t nTimeout);



/** 发送报警到服务.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN    Client_Alarm_Info_t		报警信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SendAlarmToServer( IN int32_t nPDLLHandle,
																 IN Client_Alarm_Info_t* pAlarmInfo,
															     IN int32_t nTimeout);

//////////////////////////////////////////////////////////////////////////
// 电视墙业务接口 开始

/** 查询电视墙列表个数.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  OUT	nCount			返回个数
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryTvWallList( IN int32_t nPDLLHandle,
															   OUT uint32_t* pnCount,
															   IN int32_t nTimeout);

/** 获取电视墙列表信息.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  INOUT	pInfo			电视墙列表信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetTvWallList( IN int32_t nPDLLHandle,
															 INOUT TvWall_List_Info_t* pTvWallListInfo );

/** 查询电视墙布局信息
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	nTvWallId		电视墙ID
 @param	  OUT	nCount			返回个数
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryTvWallLayout( IN int32_t nPDLLHandle,
																 IN int32_t nTvWallId, 
																 OUT uint32_t* pnCount,
																 IN int32_t nTimeout);

/** 获取电视墙布局信息.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  INOUT	pInfo			电视墙布局信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetTvWallLayout( IN int32_t nPDLLHandle,
															   INOUT TvWall_Layout_Info_t* pTvWallLayoutInfo );

/** 屏分割.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pSplitInfo		电视墙屏分割信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetTvWallScreenSplit( IN int32_t nPDLLHandle,
																	IN TvWall_Screen_Split_t* pSplitInfo,
																	IN int32_t nTimeout);
/** 屏开窗.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  INOUT	pOpenWindowInfo		电视墙屏开窗信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_TvWallScreenOpenWindow( IN int32_t nPDLLHandle,
																	  INOUT TvWall_Screen_Open_Window_t* pOpenWindowInfo,
																	  IN int32_t nTimeout);

/** 窗口移动.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  INOUT	pMoveWindowInfo		电视墙屏窗口移动信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_TvWallScreenMoveWindow( IN int32_t nPDLLHandle,
																	  INOUT TvWall_Screen_Move_Window_t* pMoveWindowInfo,
																	  IN int32_t nTimeout);

/** 屏关窗.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pCloseWindowInfo		电视墙屏关窗信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_TvWallScreenColseWindow( IN int32_t nPDLLHandle,
																	   IN TvWall_Screen_Close_Window_t* pCloseWindowInfo,
																	   IN int32_t nTimeout);

/** 屏窗口置顶（对于开窗有效）.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pTopWindowInfo		电视墙屏窗口置顶信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_TvWallScreenSetTopWindow( IN int32_t nPDLLHandle,
																     	IN TvWall_Screen_Set_Top_Window_t* pTopWindowInfo,
																     	IN int32_t nTimeout);

/** 设置屏窗口视频源.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pWindowSourceInfo		电视墙屏窗口视频源信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetTvWallScreenWindowSource( IN int32_t nPDLLHandle,
															        	   IN Set_TvWall_Screen_Window_Source_t* pWindowSourceInfo,
																           IN int32_t nTimeout);

/** 关闭屏窗口视频源.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pCloseSourceInfo		电视墙屏窗口关闭视频源信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_CloseTvWallScreenWindowSource( IN int32_t nPDLLHandle,
																	         IN TvWall_Screen_Close_Source_t* pCloseSourceInfo,
																	         IN int32_t nTimeout);

/** 清空电视墙屏
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	nTvWallId		电视墙ID
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_ClearTvWallScreen( IN int32_t nPDLLHandle,
																 IN int32_t nTvWallId,
																 IN int32_t nTimeout);

/* @fn    
 * @brief 获取电视墙任务列表总数
 * @param <IN>		nPDLLHandle		SDK句柄
 * @param <IN>		nTvWallId		电视墙ID
 * @param <OUT>		nCount			返回个数 
 * @param <IN>		nTimeout		超时时长，单位毫秒
 * @return 函数返回错误类型，参考dpsdk_retval_e.
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetTvWallTaskListCount(int32_t nPDLLHandle, 
																uint32_t nTVWallId,
																uint32_t* nCount, 
																int32_t nTimeout);

/* @fn    
 * @brief 获取电视墙任务列表信息
 * @param <IN>		nPDLLHandle		SDK句柄
 * @param <IN>		nTvWallId		电视墙ID
 * @param <OUT>		pTVWallTaskInfoList		电视墙任务列表信息 
 * @param <IN>		nTimeout		超时时长，单位毫秒
 * @return 函数返回错误类型，参考dpsdk_retval_e.
 */
//int32_t DPSDK_CALL_METHOD DPSDK_GetTvWallTaskList(int32_t nPDLLHandle, 
//																uint32_t nTVWallId,
//																TvWall_Task_Info_List_t* pTVWallTaskInfoList,
//																int32_t nTimeout);

/* @fn    
 * @brief 查询电视墙任务信息
 * @param <IN>		nPDLLHandle		SDK句柄
 * @param <IN>		nTvWallId		电视墙ID
 * @param <IN>		nTaskId		    电视墙任务ID
 * @param <OUT>		mapSaveChlCofInfo		电视墙任务通道信息 
 * @param <OUT>		mapBandOprTaskInfo		电视墙任务窗口信息 
 * @param <IN>		nTimeout		超时时长，单位毫秒
 * @return 函数返回错误类型，参考dpsdk_retval_e.
 */
//int32_t DPSDK_CALL_METHOD DPSDK_GetTVWallTaskInfo(int32_t nPDLLHandle, 
//																uint32_t nTVWallId, 
//																uint32_t nTaskId,
//																TvWall_Task_Channel_Info_Ex_List3_t* list3ChannelInfo, 
//																TvWall_Task_Window_Info_List2_t* list2WindowInfo,
//																int32_t nTimeout);

/* @fn    
 * @brief 添加电视墙任务,调用之前请确认nTaskId和szName没有重复
 * @param <IN>		nPDLLHandle		SDK句柄
 * @param <IN>		nTvWallId		电视墙ID
 * @param <IN>		nTaskId		    电视墙任务ID
 * @param <IN>		szName		    电视墙任务名称
 * @param <IN>		szDesp		    电视墙任务描述
 * @param <IN>		mapSaveChlCofInfo		电视墙任务通道信息 
 * @param <IN>		mapBandOprTaskInfo		电视墙任务窗口信息 
 * @param <IN>		nTimeout		超时时长，单位毫秒
 * @return 函数返回错误类型，参考dpsdk_retval_e.
 */
//int32_t DPSDK_CALL_METHOD DPSDK_AddTvWallTask(int32_t nPDLLHandle, 
//															int32_t nTVWallId, 
//															int32_t nTaskId,
//															const char* szName,
//															const char* szDesp,
//															TvWall_Task_Channel_Info_Ex_List3_t* list3ChannelInfo, 
//															TvWall_Task_Window_Info_List2_t* list2WindowInfo,
//															int32_t nTimeout);

/* @fn    
 * @brief 修改电视墙任务
 * @param <IN>		nPDLLHandle		SDK句柄
 * @param <IN>		nTvWallId		电视墙ID
 * @param <IN>		nTaskId		    电视墙任务ID
 * @param <IN>		szName		    电视墙任务名称
 * @param <IN>		szDesp		    电视墙任务描述
 * @param <IN>		nTimeout		超时时长，单位毫秒
 * @return 函数返回错误类型，参考dpsdk_retval_e.
 */
//int32_t DPSDK_CALL_METHOD DPSDK_ModifyTvWallTask(int32_t nPDLLHandle, 
//													int32_t nTVWallId, 
//													int32_t nTaskId,
//													const char* szName,
//													const char* szDesp,
//													TvWall_Task_Channel_Info_Ex_List3_t* list3ChannelInfo, 
//													TvWall_Task_Window_Info_List2_t* list2WindowInfo,
//													int32_t nTimeout);

/* @fn    
 * @brief 修改电视墙任务的名称和描述,调用之前请确认szName没有重复
 * @param <IN>		nPDLLHandle		SDK句柄
 * @param <IN>		nTvWallId		电视墙ID
 * @param <IN>		nTaskId		    电视墙任务ID
 * @param <IN>		mapSaveChlCofInfo		电视墙任务通道信息 
 * @param <IN>		mapBandOprTaskInfo		电视墙任务窗口信息 
 * @param <IN>		nTimeout		超时时长，单位毫秒
 * @return 函数返回错误类型，参考dpsdk_retval_e.
 */
int32_t DPSDK_CALL_METHOD DPSDK_ModifyTvWallTaskBaseInfo(int32_t nPDLLHandle, 
													int32_t nTVWallId, 
													int32_t nTaskId,
													const char* szName,
													const char* szDesp,
													int32_t nTimeout);

/* @fn    
 * @brief 删除电视墙任务
 * @param <IN>		nPDLLHandle		SDK句柄
 * @param <IN>		nTvWallId		电视墙ID
 * @param <IN>		nTaskId		    电视墙任务ID
 * @param <IN>		nTimeout		超时时长，单位毫秒
 * @return 函数返回错误类型，参考dpsdk_retval_e.
 */
int32_t DPSDK_CALL_METHOD DPSDK_DeleteTvWallTask(int32_t nPDLLHandle, 
													int32_t nTVWallId, 
													int32_t nTaskId,
													int32_t nTimeout);

// 电视墙业务接口 结束
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// 卡口业务接口 开始

/** 设置违章报警回调
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKTrafficAlarmCallback( IN int32_t nPDLLHandle,
																			IN fDPSDKTrafficAlarmCallback fun,
																			IN void* pUser);

///** 订阅交通违章报警（原有的违章报警是不需要订阅的，PCS主动推动给客户端，因此该函数是否有存在的必要）
// @param  IN	nPDLLHandle		SDK句柄
// @param  IN	pGetInfo		订阅违章上报请求信息，参考Subscribe_Traffic_Alarm_Info_t
// @param  IN	nTimeout		超时时长，单位毫秒
// @return  函数返回错误类型，参考dpsdk_retval_e
// @remark  
//*/
//  int32_t DPSDK_CALL_METHOD DPSDK_SubscribeTrafficAlarm(IN int32_t nPDLLHandle,
// 																   IN Subscribe_Traffic_Alarm_Info_t* pGetInfo,
// 																   IN int32_t nTimeout = DPSDK_CORE_DEFAULT_TIMEOUT);

/** 车辆违章图片信息写入
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pGetInfo		详细违章信息,参考Traffic_Violation_Info_t
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_WriteTrafficViolationInfo(IN int32_t nPDLLHandle,
																		INOUT Traffic_Violation_Info_t* pGetInfo,
																		IN int32_t nTimeout);

/** 车辆违章图片信息查询
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pGetInfo		详细违章信息,参考Traffic_Violation_Info_t
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetTrafficViolationInfo(IN int32_t nPDLLHandle,
																	  INOUT Traffic_Violation_Info_t* pGetInfo,
																	  IN int32_t nTimeout);

/** 设置流量上报回调.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKGetTrafficFlowCallback(IN int32_t nPDLLHandle,
					   													     IN fDPSDKGetTrafficFlowCallback fun,
																			 IN void* pUser);
/** 设置车道流量状态上报回调.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    fun             回调函数
 @param   IN    pUser           用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKGetDevTrafficFlowCallback(IN int32_t nPDLLHandle,
																				IN fDPSDKGetDevTrafficFlowCallback fun,
																				IN void* pUser);

/** 订阅流量上报.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pGetInfo		订阅设备流量上报请求信息，参考Subscribe_Traffic_Flow_Info_t
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SubscribeTrafficFlow( IN int32_t nPDLLHandle,
																	IN Subscribe_Traffic_Flow_Info_t* pGetInfo,
																	IN int32_t nTimeout);

/** 订阅卡口过车信息上报.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    pGetInfo        订阅卡口过车信息上报请求信息，参考Subscribe_Bay_Car_Info_t
 @param   IN    nTimeout        超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SubscribeBayCarInfo( IN int32_t nPDLLHandle,
																   IN Subscribe_Bay_Car_Info_t* pGetInfo,
																   IN int32_t nTimeout);
 
/** 设置卡口过车信息（不带图片）上报回调.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    fun             回调函数
 @param   IN    pUser           用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKGetBayCarInfoCallback(IN int32_t nPDLLHandle,
																			IN fDPSDKGetBayCarInfoCallback fun,
																			IN void* pUser);

/** 订阅区间测速上报.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    nSubscribeFlag  订阅标记:1订阅；0；取消订阅
 @param   IN    nTimeout        超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SubscribeAreaSpeedDetectInfo( IN int32_t nPDLLHandle,
																		    IN int32_t nSubscribeFlag,
																            IN int32_t nTimeout);
/** 设置区间测速上报回调.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    fun             回调函数
 @param   IN    pUser           用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKGetAreaSpeedDetectCallback(IN int32_t nPDLLHandle,
																				 IN fDPSDKGetAreaSpeedDetectCallback fun, 
																				 IN void* pUser);

 
// 卡口业务接口 结束

/** 设置事件上报回调.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    fun             回调函数
 @param   IN    pUser           用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKIssueCallback(IN int32_t nPDLLHandle,
																	IN fDPSDKIssueCallback fun, 
																	IN void* pUser);

/** 根据时间段查询FTP图片信息
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    szCameraId      通道编号
 @param   IN    nBeginTime      开始时间
 @param   IN    nEndTime		结束时间
 @param   IN    nTimeout        超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryFtpPic(IN int32_t nPDLLHandle,
															IN const char *szCameraId, 
															IN uint64_t nBeginTime,
															IN uint64_t nEndTime,
															IN int32_t nTimeout);

// /** Ftp图片回调.
//  @param   IN    nPDLLHandle     SDK句柄
//  @param   IN    fun             回调函数
//  @param   IN    pUser           用户参数
//  @return  函数返回错误类型，参考dpsdk_retval_e
//  @remark  
// */
//  int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKFtpPicCallback(IN int32_t nPDLLHandle,
// 																	IN fDPSDKFtpPicCallback fun, 
// 																	IN void* pUser);

/** 获取Ftp图片信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	ftpPicInfo		Ftp图片信息
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
   1、必须先查询后获取
   2、DPSDK_QueryFtpPic会返回记录个数,
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetFtpPicInfo( IN int32_t nPDLLHandle,
															 OUT Ftp_Pic_Info_t *pFtpPicInfo );

/** 删除FTP图片信息
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    szFtpPicPath	Ftp图片路径
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_DelFtpPic(IN int32_t nPDLLHandle,
														IN const char *szFtpPicPath);


/** 获取设备列表信息长度.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	nGroupLen       设备列表信息长度
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDeviceListLen( IN int32_t nPDLLHandle,
                                                               OUT int32_t* pnDevListLen,
                                                               IN int32_t nTimeout);

/** 获取设备列表信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	szDevList       设备列表xml字符串
 @param   IN	nGroupLen       设备列表信息长度
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、需要2次函数调用才能最终获取设备列表信息。
 2、先使用DPSDK_GetDeviceListLen，获取nDevListLen的值。
 3、获取到nDevListLen的值之后，创建一个长度为（nDevListLen+1）的char数组，并作为参数szDevList传入。
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDeviceListStr( IN int32_t nPDLLHandle,
                                                               OUT char *szDevList,
                                                               IN int32_t nDevListLen,
                                                               IN int32_t nTimeout);

/** 获取多个设备详细信息长度.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szDevicesId     需要查询的多个设备ID字符串数组
 @param   IN	nDevicesCount   设备ID字符串数组的长度
 @param   OUT   nDevInfoLen     需要查询的多个设备详细信息组成的xml字符串的长度
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDevicesInfoLen( IN int32_t nPDLLHandle, OUT int32_t* pnDevInfoLen);

/** 获取多个设备详细信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	szDevicesInfo   需要查询的多个设备详细信息组成的xml字符串
 @param   IN	nDevInfoLen     设备详细信息组成的xml字符串的长度
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、需要2次函数调用才能最终获取设备列表信息。
 2、先使用DPSDK_GetDevicesInfoLen获取nDevicesCount的值。
 3、获取到nDevicesCount的值之后，创建一个长度为（nDevicesCount+1）的char数组，并作为参数szDevicesInfo传入。
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetDevicesInfoStr( IN int32_t nPDLLHandle,
												  OUT char* szDevicesInfo, 
												  IN int32_t nDevInfoLen);

/** 从服务器获取设备信息.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szDeviceId		设备ID
 @param   OUT   pDeviceInfoEx   设备信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetDeviceInfoFromService( IN int32_t nPDLLHandle, 
														IN const char* szDeviceId,
														OUT Device_Info_Ex_t* pDeviceInfoEx, 
														IN int32_t nTimeout );
																		
/** 根据CemeraId获取通道信息
@param   IN    nPDLLHandle     SDK句柄
@param   IN    szCameraId      通道ID
@param   OUT   pChannelInfo    通道信息，参见Enc_Channel_Info_Ex_t
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetChannelInfoById(IN int32_t nPDLLHanle, 
																 IN const char *szCameraId, 
																 OUT Enc_Channel_Info_Ex_t *pChannelInfo);
																 
/** 根据CemeraId获取通道状态，不支持NVR通道状态获取
@param   IN    nPDLLHandle     SDK句柄
@param   IN    szCameraId      通道ID
@param   OUT   nStatus         状态值，参见dpsdk_dev_status_e
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetChannelStatus(IN  int32_t nPDLLHanle, 
															   IN  const char *szCameraId, 
															   OUT dpsdk_dev_status_e* nStatus);

/** 语音对讲失败后参数回调.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    fun             回调函数
 @param   IN    pUser           用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDPSDKTalkParamCallback(IN int32_t nPDLLHandle,
																		IN fDPSDKTalkParamCallback fun, 
																		IN void* pUser);

/** 根据设备ID获取设备类型
@param   IN    nPDLLHandle     SDK句柄
@param   IN    szDevId		   设备ID
@param   OUT   nDeviceType     设备类型，参考dpsdk_dev_type_e
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetDeviceTypeByDevId(	IN  int32_t nPDLLHandle, 
																	IN  const char *szDevId, 
																	OUT dpsdk_dev_type_e* nDeviceType);

/** 根据通道ID获取设备ID.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szChanId		通道编号
 @param   OUT	szDevId			设备编号
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetDevIdByChnId( IN int32_t nPDLLHandle, 
															   IN char* szChanId,
															   OUT char* szDevId);

/** 根据设备ID获取设备信息
@param   IN    nPDLLHandle     SDK句柄
@param   IN    szDevId		   设备ID
@param   OUT   pDeviceInfoEx   设备信息
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetDeviceInfoExById(IN  int32_t nPDLLHanle, 
													IN  const char *szDevId, 
													OUT Device_Info_Ex_t* pDeviceInfoEx);

/** 视频报警主机：设备布撤防/通道旁路/消除通道报警.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    szDeviceId      设备id
 @param   IN    channelId       通道号，-1表示对设备操作
 @param   IN    controlType     操作类型, 参考dpsdk_AlarmhostOperator_e
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
 1、视频报警主机类型为:1101
*/
int32_t DPSDK_CALL_METHOD DPSDK_ControlVideoAlarmHost(IN int32_t nPDLLHandle,
																	IN const char *szDeviceId, 
																	IN int32_t channelId, 
																	IN int32_t controlType,
																	IN int32_t nTimeout);

/** 网络报警主机：设备布撤防/通道旁路/消除通道报警.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    szId			设备id/通道id
 @param   IN    opttype			设备/通道操作,参考dpsdk_netalarmhost_operator_e
 @param   IN    controlType     操作类型, 参考dpsdk_AlarmhostOperator_e
 @param   IN    iStart			开始时间,默认为0
 @param   IN    iEnd			结束时间,默认为0
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
 1、网络报警主机类型为:601
*/
int32_t DPSDK_CALL_METHOD DPSDK_ControlNetAlarmHostCmd(IN int32_t nPDLLHandle,
																	 IN const char* szId, 
																	 IN int32_t opttype, 
																	 IN int32_t controlType, 
																	 IN int64_t iStart, 
																	 IN int64_t iEnd, 
																	 IN int32_t nTimeout);

/**通过Json协议发送命令给cms.
@param   IN    nPDLLHandle		SDK句柄
@param   IN    szJson			Json字符串,
形如:"{ \"DevID\": \"1000000\",\"CameraId\":\"1000000$1$0$1\", \"DevChannel\": 1,\"PicNum\": 1,\"CourtTime\": \"2014-09-17 16:00:00\"}"
@param   OUT   szJsonResult		平台返回的Json字符串,
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_SendCammandToCMSByJson(IN int32_t nPDLLHandle,
																	 IN const char* szJson, 
																	 OUT char* szJsonResult,
																	 IN int32_t nTimeout);

/**通过Json协议发送命令给DMS.
@param   IN    nPDLLHandle		SDK句柄
@param   IN    szJson			Json字符串,
形如:"{ \"DevID\": \"1000000\",\"CameraId\":\"1000000$1$0$1\", \"DevChannel\": 1,\"PicNum\": 1,\"CourtTime\": \"2014-09-17 16:00:00\"}"
@param   IN    szDeviceId		设备ID,
@param   OUT   szJsonResult		平台返回的Json字符串,
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_SendCammandToDMSByJson(IN int32_t nPDLLHandle,
																	 IN const char* szJson,
																	 IN const char* szDeviceId,
																	 OUT char* szJsonResult,
																	 IN int32_t nTimeout );

/** 获取用户详情.以后有关用户的信息都在DPSDK_UserInfo_t里面增加
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pstruUserInfo	用户信息结构体
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark	
 1、登陆平台以后用户信息已经获取到
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetUserInfo( IN int32_t nPDLLHandle, 
															OUT DPSDK_UserInfo_t* pstruUserInfo, 
															IN int32_t nTimeout);


/** 根据设备ID获取报警输入通道信息
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pstruUserInfo	用户信息结构体
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
 1、pAlarmInChannelnfo需要在外面创建好
 2、pAlarmInChannelnfo的个数与DPSDK_GetDGroupInfo返回时有报警主机设备id和报警输入通道个数
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetAlarmInChannelInfo( IN int32_t nPDLLHandle, 
																	INOUT Get_AlarmInChannel_Info_t* pstruUserInfo);

/** 查询网络报警主机状态
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szDeviceId		设备id
 @param   IN	nChannelcount	通道个数
 @param   OUT	pDefence		通道信息结构体
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 1、pDefence需要在外面创建好，根据通道个数new
 2、没有单独设备的布撤防状态，需要根据通道的状态判断
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryNetAlarmHostStatus( IN int32_t nPDLLHandle, 
																	   IN const char* szDeviceId,
																	   IN int32_t nChannelcount,
																	   OUT dpsdk_AHostDefenceStatus_t* pDefence,
																	   IN int32_t nTimeout);

/** 设置视频报警主机布撤防/旁路状态回调.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    fun             回调函数
 @param   IN    pUser           用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
 1、登陆平台的时候平台先回调设备布撤防状态，接着回调通道旁路状态
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetVideoAlarmHostStatusCallback(IN int32_t nPDLLHandle,
																			  IN fDPSDKVideoAlarmHostStatusCallback fun, 
																			  IN void* pUser);

/** 设置网络报警主机布撤防/旁路状态回调.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    fun             回调函数
 @param   IN    pUser           用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
 1、有其他客户端修改了网络报警主机状态以后，回调通知
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetNetAlarmHostStatusCallback(IN int32_t nPDLLHandle,
																			  IN fDPSDKNetAlarmHostStatusCallback fun, 
																			  IN void* pUser);

/** 报警订阅设置-报警运营平台.
 @param   IN    nPDLLHandle     SDK句柄
 @param   IN    userParam       用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_PhoneSubscribeAlarm(IN int32_t nPDLLHandle,
																  INOUT dpsdk_phone_subscribe_alarm_t* userParam, 
																  IN int32_t nTimeout);

/** 设置收到别人分享视频消息后的回调函数
@param   IN    nPDLLHandle     SDK句柄
@param   IN    fun             回调函数
@param   IN    pUser           用户参数
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetShareVideoCallback(IN int32_t nPDLLHandle,
														IN fDPSDKShareVideoCallback fun, 
														IN void* pUser);

/** 分享视频
@param   IN    nPDLLHandle     SDK句柄
@param   IN    pVideoInfo	   分享的视频信息结构数组
@param   IN    nVideoCount	   视频信息数组的长度
@param   IN    pUserId	       分享对象用户ID数组
@param   IN    nUserCount	   分享对象的数量
@param   IN    szMsg	       附加的信息
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_ShareVideo(IN int32_t nPDLLHanle,
											 IN struct ShareVideoInfo* pVideoInfo,
											 IN int32_t nVideoCount,
											 IN int32_t* pUserId,
											 IN int32_t nUserCount,
											 IN const char* szMsg,
											 IN int32_t nTimeout);

/** 订阅NVR通道状态
@param   IN    nPDLLHandle     SDK句柄
@param   IN    deviceId	       设备的ID
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryNVRChnlStatus(IN int32_t nPDLLHandle, 
												   IN const char* deviceId,
												   IN int32_t nTimeout);

/** 设置NVR通道状态回调
@param   IN	nPDLLHandle		SDK句柄
@param   IN	fun				回调函数
@param   IN	pUser			用户参数
@return  函数返回错误类型，参考dpsdk_retval_e
@remark
*/
int32_t DPSDK_CALL_METHOD	DPSDK_SetDPSDKNVRChnlStatusCallback(IN int32_t nPDLLHandle, 
																IN fDPSDKNVRChnlStatusCallback fun, 
																IN void* pUser );

/** 设置Json协议回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e	
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetGeneralJsonTransportCallback(IN int32_t nPDLLHandle,
                                                                              IN fDPSDKGeneralJsonTransportCallback fun,
                                                                              IN void * pUser);

/**通过Json协议发送命令给平台cms/dms等模块,返回结果是json串通过DPSDK_SetGeneralJsonTransportCallback回调
@param   IN    nPDLLHandle		SDK句柄
@param   IN    szJson			Json字符串,
@param   IN    mdltype			模块,
@param   IN    trantype			JSON 传输类型,
@param	 IN    nTimeout			超时时间
@return  函数返回错误类型，参考dpsdk_retval_e
@remark 
*/
int32_t DPSDK_CALL_METHOD DPSDK_GeneralJsonTransport(IN int32_t nPDLLHandle,
                                                                   IN const char* szJson,
                                                                   IN dpsdk_mdl_type_e mdltype,
                                                                   IN generaljson_trantype_e trantype,
                                                                   IN int32_t nTimeout);
/** 获取日期模板数量
 @param   IN    nPDLLHandle		SDK句柄
 @param   OUT   pCount			日期模板数量
 @param   IN	nTimeout		超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetCustomTimeTemplateCount(IN int32_t nPDLLHandle,
                                                                         IN uint32_t* pCount,
                                                                         IN int32_t nTimeout);

/**	获取自定义日期模板.
@param		IN		nPDLLHandle			SDK句柄
@param		IN		id					时间模板id(如果传入0，则获取所有时间模板)
@param		OUT		pTimeTemplate		日期模板信息
@param		IN		nTimeout			超时时间
@param		IN		nTimeout			超时时间
@return									函数返回错误类型，参考dpsdk_retval_e
@remark  
1、如果想要获取所有模板，必须先查询后获取
2、DPSDK_GetCustomTimeTemplateCount会返回记录个数,pTimeTemplate根据记录个数在外面申请相应内存
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetCustomTimeTemplate(IN int32_t nPDLLHandle,
                                                                    IN int32_t id,
                                                                    OUT TimeTemplateInfo_t* pTimeTemplate,
                                                                    IN int32_t nTimeout );

/**	获取单个报警预案文件长度.
@param		IN		nPDLLHandle			SDK句柄
@param		IN		id					预案数据库id
@param		OUT		pLen				预案文件数据长度
@param		IN		nTimeout			超时时间
@return									函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetSchemeFileDataLen(IN int32_t nPDLLHandle,
                                                                   IN int32_t id,
                                                                   OUT int32_t* pLen,
                                                                   IN int32_t nTimeout);

/**	获取单个报警预案.
@param		IN		nPDLLHandle			SDK句柄
@param		IN		id					预案数据库id
@param		OUT		pTimeTemplate		预案信息
@param		IN		nTimeout			超时时间
@return									函数返回错误类型，参考dpsdk_retval_e
@remark  
1. pTimeTemplate内存需要在外面分配;
2. 调用此函数前必须先调用DPSDK_GetSchemeFileDataLen获取预案文件长度，根据此长度分配data内存,data内存也需要在外面分配.
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetSchemeFile(IN int32_t nPDLLHandle,
                                                            IN int32_t id,
                                                            OUT AlarmSchemeFileInfo_t* pTimeTemplate,
                                                            IN int32_t nTimeout);

/** 删除报警预案.
@param		IN		nPDLLHandle			SDK句柄
@param		IN		id					预案数据库id
@param		IN		nTimeout			超时时间
@return									函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_DelSchemeFile(IN int32_t nPDLLHandle,
                                                            IN uint32_t id,
                                                            IN bool bNotifyAll,
                                                            IN int32_t nTimeout);

/** 通知预案失效.
@param		IN		nPDLLHandle			SDK句柄
@param		IN		schemeID			预案ID
@param		IN		notifyType			变更类型： (7)所有信息（时间段索引、报警源、动作）,(1)时间段索引,(2)报警源,(4)动作或其他组合.
@param		IN		nTimeout			超时时间
@return									函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_NotifySchemeInvalidate(IN int32_t nPDLLHandle,
                                                                     IN int64_t schemeID,
                                                                     IN uint32_t notifyType,
                                                                     IN int32_t nTimeout);

/** 设置报警预案变更回调.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e	
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetAlarmSchemeCallback(IN int32_t nPDLLHandle,
                                                                     IN fDPSDKAlarmSchemeCallback fun,
                                                                     IN void * pUser);
/** 获取报警预案数量
 @param   IN    nPDLLHandle		SDK句柄
 @param   OUT   pCount			报警预案数量
 @param   IN	nTimeout		超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetAlarmSchemeCount(IN int32_t nPDLLHandle,
                                                                  OUT uint32_t* pCount,
                                                                  IN int32_t nTimeout);


/** 获取报警预案列表
 @param		IN		nPDLLHandle			SDK句柄
 @param		OUT		pAlarmSchemeList	报警预案
 @param		IN		nCount				报警预案数量
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetAlarmSchemeList(IN int32_t nPDLLHandle,
                                                                 OUT AlarmSchemeInfo_t* pAlarmSchemeList,
                                                                 IN uint32_t nCount,
                                                                 IN int32_t nTimeout);

/** 保存报警预案
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		pAlarmScheme		报警预案
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_SaveAlarmScheme(IN int32_t nPDLLHandle,
                                                              IN const AlarmSchemeInfo_t* pAlarmScheme,
                                                              IN int32_t nTimeout);

/** 保存报警预案文件
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		id					预案数据库id
 @param		IN		schemeName			预案名称
 @param		IN		status				预案开关
 @param		IN		templateId			时间模板id
 @param		IN		desc				预案描述
 @param		IN		data				预案内容
 @param		IN		len					预案内容长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_SaveSchemeFile(IN int32_t nPDLLHandle,
                                                             IN uint32_t id,
                                                             IN const char* schemeName,
                                                             IN dpsdk_alarmScheme_status_e status, 
                                                             IN uint32_t templateId, 
                                                             IN const char* desc, 
                                                             IN const char* data, 
                                                             IN uint32_t len,
                                                             IN bool bNotifyAll,
                                                             IN int32_t nTimeout);

//////////////////////////////////////////////////////////////////////////


/** 大图抽取人脸图片
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN      szCameraId						人脸识别设备的指定通道ID
 @param		IN      requestFlag						用户自定义的请求标记，无特殊限制
 @param		IN		picData							图片数据
 @param		IN		nFileLength						图片文件大小
 @param		IN		nPicWidth						图片宽度
 @param		IN		nPicHeight						图片高度
 @param		OUT		faceDataLength					返回的人脸数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_ExtractFacePicDataLength(int32_t nPDLLHandle,
															 const char* szCameraId, 
															 long requestFlag, 
															 char* picData, 
															 uint32_t nFileLength, 
															 uint32_t nPicWidth, 
															 uint32_t nPicHeight,
															 long* faceDataLength,
															 int32_t nTimeout);

/** 大图抽取人脸图片
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN      szCameraId						人脸识别设备的指定通道ID
 @param		IN      requestFlag						用户自定义的请求标记，无特殊限制
 @param		IN		picData							图片数据
 @param		IN		nFileLength						图片文件大小
 @param		IN		nPicWidth						图片宽度
 @param		IN		nPicHeight						图片高度
 @param		OUT		faceData						返回的人脸数据
 @param		IN		faceDataLength					返回的人脸数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_ExtractFacePicData(int32_t nPDLLHandle,
															 const char* szCameraId, 
															 long requestFlag, 
															 char* picData, 
															 uint32_t nFileLength, 
															 uint32_t nPicWidth, 
															 uint32_t nPicHeight,
															 char*	faceData,
															 long faceDataLength,
															 int32_t nTimeout);

/** 根据查询条件，获取人脸库中匹配的数量
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		const char* szCameraId						    人脸识别设备的指定通道ID
 @param		IN		long requestFlag								用户自定义的请求标记，无特殊限制
 @param		IN		const char* data								查询条件
 @param		IN		uint32_t len									查询条件的数据长度
 @param		OUT		int32_t count									匹配总数
 @param		OUT		uint32_t querySession							查询会话
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryFaceCount(int32_t nPDLLHandle,
															 const char* szCameraId, 
															 long requestFlag, 
															 const char* data, 
															 uint32_t len,
															 int32_t* count,
															 uint32_t* querySession,
															 int32_t nTimeout);

/** 根据查询人脸库后获取到的Session，获取指定区间的匹配数据
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId						    人脸识别设备的指定通道ID
 @param		IN		nQuerySession						查询匹配数目时获取到的Session
 @param		IN		nStartIndex							起始数据索引
 @param		IN		nQueryNum							数据条数
 @param		OUT		dataLength							返回的数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryFaceDataLength(int32_t nPDLLHandle,
															const char* szCameraId, 
															uint32_t nQuerySession, 
															uint32_t nStartIndex, 
															uint32_t nQueryNum,	
															uint32_t* dataLength,
															int32_t nTimeout);

/** 根据查询人脸库后获取到的Session，获取指定区间的匹配数据
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId						    人脸识别设备的指定通道ID
 @param		IN		nQuerySession						查询匹配数目时获取到的Session
 @param		IN		nStartIndex							起始数据索引
 @param		IN		nQueryNum							数据条数
 @param		OUT		personData							返回的具体数据
 @param		IN		dataLength							返回的数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryFaceData(int32_t nPDLLHandle,
															 const char* szCameraId, 
															 uint32_t nQuerySession, 
															 uint32_t nStartIndex, 
															 uint32_t nQueryNum,
															 char*	personData,		
															 uint32_t dataLength,
															 char* szPicServerIp,
															 int32_t nTimeout);

/** 人脸注册数据操作
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId							人脸识别设备的指定通道ID
 @param		IN		requestFlag							用户自定义的请求标记，无特殊限制
 @param		IN		operateType,						操作类型（添加/修改及删除）
 @param		IN		data								操作的数据
 @param		IN		len									数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_OperateFaceLib(int32_t nPDLLHandle,
															const char* szCameraId, 
															long requestFlag, 
															uint32_t operateType, 
															const char* data, 
															uint32_t len,
															int32_t nTimeout);

/** 断开指定的人脸库查询Session
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId							人脸识别设备的指定通道ID
 @param		IN		nQuerySession						查询匹配数目时获取到的Session
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_StopFaceQuery(int32_t nPDLLHandle,
															 const char* szCameraId, 
															 uint32_t nQuerySession,
															 int32_t nTimeout);

/** 根据查询条件，获取人脸识别报警的匹配数量
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId						人脸识别设备的指定通道ID
 @param		IN		requestFlag						用户自定义的请求标记，无特殊限制
 @param		IN		nStartTime						报警时间的开始区间
 @param		IN		nEndTime						报警时间的结束区间
 @param		IN		szAddress						报警地点
 @param		IN		nAlarmType						报警类型（黑白名单报警）
 @param		OUT		count							匹配总数
 @param		OUT		querySession					查询会话
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryIvsfAlarmCount(int32_t nPDLLHandle,
															const char* szCameraId, 
															long requestFlag, 
															int64_t nStartTime, 
															int64_t nEndTime, 
															const char* szAddress, 
															uint32_t nAlarmType,
															int* count,
															uint32_t* querySession,
															int32_t nTimeout);

/** 根据查询人脸识别报警获取到的Session，获取指定区间的匹配数据
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId						    人脸识别设备的指定通道ID
 @param		IN		nQuerySession						查询匹配数目时获取到的Session
 @param		IN		nStartIndex							起始数据索引
 @param		IN		nQueryNum							数据条数
 @param		OUT		dataLength							返回的数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryIvsfAlarmDataLength(int32_t nPDLLHandle,
																 const char* szCameraId, 
																 uint32_t nQuerySession, 
																 uint32_t nStartIndex, 
																 uint32_t nQueryNum,
																 uint32_t* dataLength,
																 int32_t nTimeout);

/** 根据查询人脸识别报警获取到的Session，获取指定区间的匹配数据
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId						    人脸识别设备的指定通道ID
 @param		IN		nQuerySession						查询匹配数目时获取到的Session
 @param		IN		nStartIndex							起始数据索引
 @param		IN		nQueryNum							数据条数
 @param		OUT		personData							返回的具体数据
 @param		IN		dataLength							返回的数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryIvsfAlarmData(int32_t nPDLLHandle,
																  const char* szCameraId, 
																  uint32_t nQuerySession, 
																  uint32_t nStartIndex, 
																  uint32_t nQueryNum,
																  char*	personData,
																  uint32_t dataLength,
																  int32_t nTimeout);

/** 断开指定的人脸识别报警查询Session
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId							人脸识别设备的指定通道ID
 @param		IN		nQuerySession						查询匹配数目时获取到的Session
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_StopIvsfAlarmQuery(int32_t nPDLLHandle,
															const char* szCameraId, 
															uint32_t nQuerySession,
															int32_t nTimeout);

/** 获取单条人脸识别报警的所有图片数据
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId						人脸识别设备的指定通道ID
 @param		IN		requestFlag						用户自定义的请求标记，无特殊限制
 @param		IN		data							单条人脸识别报警的所有图片信息
 @param		IN		len								图片信息长度
 @param		OUT		picFullDataLength				数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetIvsfAlarmPicLength(int32_t nPDLLHandle,
															  const char* szCameraId, 
															  long requestFlag, 
															  const char* data, 
															  uint32_t len,
															  long* picFullDataLength,
															  int32_t nTimeout);

/** 获取单条人脸识别报警的所有图片数据
 @param		IN		nPDLLHandle			SDK句柄
 @param		IN		szCameraId						人脸识别设备的指定通道ID
 @param		IN		requestFlag						用户自定义的请求标记，无特殊限制
 @param		IN		data							单条人脸识别报警的所有图片信息
 @param		IN		len								图片信息长度
 @param		OUT		picFullData						返回的完整图片数据(多个图片及其描述)
 @param		IN		picFullDataLength				数据长度
 @param		IN		nTimeout			超时时间
 @return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetIvsfAlarmPic(int32_t nPDLLHandle,
																 const char* szCameraId, 
																 long requestFlag, 
																 const char* data, 
																 uint32_t len,
																 char* picFullData,
																 long picFullDataLength,
																 int32_t nTimeout);
//门禁接口 begin

/** 设置门禁开关状态上报回调
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetPecDoorStatusCallback(int32_t nPDLLHandle,
																	   fDPSDKPecDoorStarusCallBack pFun,
																	   void* pUser);
/** 门控制.
 @param	  IN	nPDLLHandle		SDK句柄
 @param	  IN	pRequest		请求信息
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark  
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetDoorCmd(int32_t nPDLLHandle, 
														SetDoorCmd_Request_t* pRequest, 
														int32_t nTimeout);

/** 获取绑定视频资源.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pResponce		绑定视频资源XML
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_QueryLinkResource( int32_t nPDLLHandle,
															     uint32_t* nLen, 
																 int32_t nTimeout);

/** 获取绑定视频资源.
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pResponce		绑定视频资源XML
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark
 */
int32_t DPSDK_CALL_METHOD DPSDK_GetLinkResource( int32_t nPDLLHandle,
															   GetLinkResource_Responce_t* pResponce );
//门禁接口 end


//可视对讲接口 begin
/** 设置可视对讲呼叫邀请参数回调
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetVtCallInviteCallback(int32_t nPDLLHandle,
																	  fDPSDKInviteVtCallParamCallBack pFun,
																	  void* pUser);

/** 设置响铃参数通知回调
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetRingCallback(int32_t nPDLLHandle,
															  fDPSDKRingInfoCallBack pFun,
															  void* pUser);

/** 设置可视对讲繁忙状态通知回调
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	fun				回调函数
 @param   IN	pUser			用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_SetBusyVtCallCallback(int32_t nPDLLHandle,
																	fDPSDKBusyVtCallCallBack pFun,
																	void* pUser);


/** 请求可视对讲
 @param   IN	nPDLLHandle			SDK句柄
 @param   OUT	audioSessionId		音频请求序号,用于关闭对讲
 @param   OUT	videoSessionId		视频请求序号,用于关闭对讲
 @param   OUT	nStartVtCallParm	应答参数，用于本地频频采集和关闭对讲
 @param   IN	nCallType			呼叫类型 0单播；1组播；2可视对讲
 @param   IN	szUserId			呼叫者ID
 @param   IN    pFun				码流回调函数				
 @param   IN    pCBParam			码流回调用户参数
 @param   IN	nTimeout			超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_StartVtCall(int32_t nPDLLHandle, 
														  uint32_t* audioSessionId, 
														  uint32_t* videoSessionId, 
														  StartVtCallParam_t * nStartVtCallParm, 
														  dpsdk_call_type_e nCallType, 
														  const char* szUserId, 
														  fMediaDataCallback funCB, 
														  void* pCBParam, 
														  int32_t nTimeout);


/** 发送取消可视对讲
 @param   IN	nPDLLHandle			SDK句柄
 @param   IN	szUserId			呼叫者ID
 @param   IN	audioSessionId		语音请求序列号
 @param   IN	videoSessionId		视频请求序列号
 @param   IN    nCallId				呼叫ID			
 @param   IN    m_dlgId				回话ID
 @param   IN	nTimeout			超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_SendCancelVtCall(int32_t nPDLLHandle,
															   const char* szUserId,
															   uint32_t audioSessionId,
															   uint32_t videoSessionId,
															   int callId,
															   int dlgId,
															   int32_t nTimeout);

/** 请求可视对讲成功后，停止可视对讲
 @param   IN	nPDLLHandle			SDK句柄
 @param   IN	szUserId			呼叫者ID
 @param   IN	audioSessionId		语音请求序列号
 @param   IN	videoSessionId		视频请求序列号
 @param   IN    nCallId				呼叫ID			
 @param   IN    m_dlgId				回话ID
 @param   IN	nTimeout			超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_StopVtCall(int32_t nPDLLHandle,
														 const char* szUserId,
														 uint32_t audioSessionId,
														 uint32_t videoSessionId,
														 int m_callId,
														 int m_dlgId,
														 int32_t nTimeout);

/** 接受可视对讲邀请
 @param   IN	nPDLLHandle			SDK句柄
 @param   OUT	audioSessionId		音频请求序号,用于关闭对讲
 @param   OUT	videoSessionId		视频请求序号,用于关闭对讲
 @param   IN	nInviteVtCallParam	对讲参数，由DPSDK_SetVtCallInviteCallback获取
 @param   IN	nCallType			呼叫类型 0单播；1组播；2可视对讲
 @param   IN    pFun				码流回调函数				
 @param   IN    pCBParam			码流回调用户参数
 @param   IN	nTimeout			超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_InviteVtCall(int32_t nPDLLHandle,
														   uint32_t* audioSessionId,
														   uint32_t* videoSessionId,
														   InviteVtCallParam_t* nInviteVtCallParam,
														   dpsdk_call_type_e nCallType,
														   fMediaDataCallback funCB,
														   void* pCBParam,
														   int32_t nTimeout);

/** 接受邀请后，挂断可视对讲
 @param   IN	nPDLLHandle			SDK句柄
 @param   IN	szUserId			呼叫者ID
 @param   IN	audioSessionId		语音请求序列号
 @param   IN	videoSessionId		视频请求序列号
 @param   IN    nTid				
 @param   IN	nTimeout			超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_ByeVtCall(int32_t nPDLLHandle,
														const char* szUserId,
														uint32_t audioSessionId,
														uint32_t videoSessionId,
														int nTid,
														int32_t nTimeout);


/** 拒绝可视对讲邀请
 @param   IN	nPDLLHandle			SDK句柄
 @param   IN	szUserId			呼叫者ID
 @param   IN    nCallId				呼叫ID				
 @param   IN    nTid				
 @param   IN	nTimeout			超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_SendRejectVtCall(int32_t nPDLLHandle,
															   const char* szUserId,
															   int nCallId,
															   int dlgId,
															   int nTid,
															   int32_t nTimeout);

/** 拒绝可视对讲邀请
 @param   IN	nPDLLHandle			SDK句柄
 @param   IN	nSendjson			发送json
 @param   OUT   nRecivejson			应答json								
 @param   IN	nTimeout			超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_sendVtCallInfo(int32_t nPDLLHandle,
															 const char* nSendjson,
															 char* nRecivejson,
															 int32_t nTimeout);


/** 修改可视对讲状态
 @param   IN	nPDLLHandle			SDK句柄
 @param   IN	szUserId			呼叫者ID
 @param   IN	nCallStatus			呼叫状态
 @param   IN	audioSessionId		语音请求序列号
 @param   IN	videoSessionId		视频请求序列号		
 @param   IN	nTimeout			超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_ModifyVtCallStatus(int32_t nPDLLHandle,
																 const char* szUserId,
																 dpsdk_call_status_e nCallStatus,
																 uint32_t audioSessionId,
																 uint32_t videoSessionId,
																 int32_t nTimeout);

/** 获取语音发送函数指针
 @param   IN	nPDLLHandle		SDK句柄
 @param   OUT	pCallBackFun	回调函数
 @param   OUT	pUserParam   	回调函数用户参数
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_GetAudioSendFunCallBack(	int32_t nPDLLHandle,
																		void** pCallBackFun,
																		AudioUserParam_t** pUserParam);
																		
/** 查询服务列表，建立服务连接（不用加载组织结构也可以控制云台、接收报警、接收设备状态上报）
@param   IN    nPDLLHandle     SDK句柄
@return  函数返回错误类型，参考dpsdk_retval_e
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryServerList(int32_t nPDLLHandle);

//可视对讲接口 end

/** 连接SCS 
 @param		IN	nPDLLHandle		SDK句柄
 @param		IN	szScsIp			服务IP地址
 @param		IN	nScsPort		服务端口号.
 @return	函数返回错误类型，参考dpsdk_retval_e
 @remark
*/
int32_t DPSDK_CALL_METHOD DPSDK_ConnectToSCS( int32_t nPDLLHandle, const char* szScsIp, int32_t nScsPort, int32_t nTimeout);

//人数统计 begin

/** 查询统计总数.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szCameraId		通道ID
 @param   OUT	nQuerySeq		码流请求序号,可作为后续操作标识 
 @param   OUT	totalCount		统计总数
 @param   IN	nStartTime		开始时间 
 @param   IN    nEndTime		结束时间				
 @param   IN    nGranularity	查询粒度，0:分钟,1:小时,2:日,3:周,4:月,5:季,6:年;
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryPersonCount(int32_t nPDLLHandle, const char* szCameraId, uint32_t* nQuerySeq, uint32_t* totalCount, uint32_t nStartTime, uint32_t nEndTime, int nGranularity, int32_t nTimeout);

/** 分页查询统计结果.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szCameraId		通道ID
 @param   IN	nQuerySeq		码流请求序号,可作为后续操作标识 
 @param   IN	nIndex			此次查询的开始值
 @param   IN    nCount			此次查询的数量		
 @param   OUT	nPersonInfo		详细的人数统计信息，new一个nCount大小的数组
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_QueryPersonCountBypage(int32_t nPDLLHandle, const char* szCameraId, uint32_t nQuerySeq, uint32_t nIndex, uint32_t nCount, Person_Count_Info_t* nPersonInfo, int32_t nTimeout);

/** 结束查询.
 @param   IN	nPDLLHandle		SDK句柄
 @param   IN	szCameraId		通道ID
 @param   IN	nQuerySeq		码流请求序号,可作为后续操作标识 			
 @param   IN	nTimeout		超时时长，单位毫秒
 @return  函数返回错误类型，参考dpsdk_retval_e
 @remark		
*/
int32_t DPSDK_CALL_METHOD DPSDK_StopQueryPersonCount(int32_t nPDLLHandle, const char* szCameraId, uint32_t nQuerySeq, int32_t nTimeout);

//人数统计 end
#endif
