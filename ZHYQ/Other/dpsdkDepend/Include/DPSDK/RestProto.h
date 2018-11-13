#ifndef _REST_API_PROTO_H_
#define _REST_API_PROTO_H_

#include "basedef.h"
#include "FreeBuffer.h"
#include "ConstString.h"


// ����ṹ�����
typedef struct PSDKRequest
{
	CSTR content;
	const char* (*toJson)(struct PSDKRequest *p);
	int (*parseFromJson)(struct PSDKRequest *p, const char* strJson);
	void (*copy)(struct PSDKRequest *p, struct PSDKRequest *src);
	void (*destroy)(struct PSDKRequest *p);
} PSDKRequest;

// ��Ӧ�ṹ�����
typedef struct PSDKResponse
{
	CSTR content;
	const char* (*toJson)(struct PSDKResponse *p);
	int (*parseFromJson)(struct PSDKResponse *p, const char* strJson);
	void (*copy)(struct PSDKResponse *p, struct PSDKResponse *src);
	void (*destroy)(struct PSDKResponse *p);
} PSDKResponse;


// ����ʹ�����к�
#define PSDKAPI_INIT(name)		psdk_api_init_##name()
#define PSDKAPI_COPY(dst, src)	(dst)->base.copy(&(dst)->base, &(src)->base)
#define PSDKAPI_DESTROY(ptr)		(ptr)->base.destroy(&(ptr)->base)
#define PSDKAPI_TOJSON(ptr)		(ptr)->base.toJson(&(ptr)->base)
#define PSDKAPI_PARSEFROMJSON(ptr, strJson)		(ptr)->base.parseFromJson(&(ptr)->base, strJson)

#endif
