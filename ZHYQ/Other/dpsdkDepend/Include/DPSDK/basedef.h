#ifndef _REST_API_PROTO_BASEDEF_H_
#define _REST_API_PROTO_BASEDEF_H_

#include <stdio.h>

#ifdef __cplusplus
#define C_API extern "C"
#else
#define C_API
#endif

#if 0
#else
#endif

// ������ BOOL
/*
	IOS_DH:				��ʶ�����.a��ΪIOS�汾,��Ҫ����BOOLΪsigned char(��IOSϵͳ����һ��)
	TARGET_OS_IPHONE��	��ʶĿǰ�ı��뻷��ΪIOS����ʵ����,��˲�Ҫ�ض���BOOL,�����ͻ
	����			��	linux or win,��Ҫ����BOOL����
*/
#ifdef IOS_DH
typedef signed char BOOL;
#elif TARGET_OS_IPHONE

#else


#endif

#endif
