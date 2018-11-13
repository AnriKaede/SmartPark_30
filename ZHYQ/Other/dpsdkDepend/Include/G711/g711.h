/********************************************************************
*	Funcname:           g711.h	    	
*	Author:				nie wuyang
*	Copyright 1992-2008, ZheJiang Dahua Technology Stock Co.Ltd.
* 						All Rights Reserved
*	Description:		G711������㷨ͷ�ļ�
*	Created:	        %2013%:%08%:%14%   %10%:%20%
*	Rivision Record:    2013.08.14:nie wuyang create
* 
*********************************************************************/

#ifndef __G711_H__
#define __G711_H__

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */
    


/*----------------------------------------*/
#ifdef _WIN32
	#define CALLMETHOD __stdcall
    #ifndef G711_LIB_EXPORTS
        #ifdef G711_DLL_EXPORTS
        #define G711_API    __declspec(dllexport)
        #else
        #define G711_API    __declspec(dllimport)
        #endif
    #else
    #define G711_API
    #endif

#else

#define G711_API
#define CALLMETHOD 

#endif
/*----------------------------------------*/

#include "audio_typedef.h"

/* The type of API parameters */
#undef  IN
#undef  INOUT
#undef  OUT
#define IN
#define INOUT
#define OUT


/********************************************************************
*	Funcname: 			g711a_Encode    	
*	Purpose:			G711a����ӿں���
*   InputParam:   		IN  unsigned char *src      :������������
*                 		IN           int  srclen    :�������ݳ���(����Ϊż��)����λ���ֽ�
*   OutputParam:  		OUT unsigned char *dest     :����������� 
*                 		OUT          int  *dstlen   :����������ȣ���λ���ֽ�
*   Return:             int
*   Created:	        2013.08.14:nie wuyang create
*   Rivision Record:    
*********************************************************************/
G711_API int CALLMETHOD g711a_Encode( IN  unsigned char *src,  OUT unsigned char *dest,
                                      IN           int  srclen,OUT          int  *dstlen);

/********************************************************************
*	Funcname: 			g711u_Encode    	
*	Purpose:			G711u����ӿں���
*   InputParam:   		IN  unsigned char *src      :������������
*                 		IN           int  srclen    :�������ݳ���(����Ϊż��)����λ���ֽ�
*   OutputParam:  		OUT unsigned char *dest     :����������� 
*                 		OUT          int  *dstlen   :����������ȣ���λ���ֽ�
*   Return:             int
*   Created:	        2013.08.14:nie wuyang create
*   Rivision Record:    
*********************************************************************/
G711_API int CALLMETHOD g711u_Encode( IN  unsigned char *src,  OUT unsigned char *dest,
                                      IN           int  srclen,OUT          int  *dstlen);

/********************************************************************
*	Funcname: 			g711a_Decode    	
*	Purpose:			G711a����ӿں���
*   InputParam:   		IN  unsigned char *src      :������������
*                 		IN           int  srclen    :�������ݳ��ȣ���λ���ֽ�
*   OutputParam:  		OUT unsigned char *dest     :����������� 
*                 		OUT          int  *dstlen   :����������ȣ���λ���ֽ�
*   Return:             int
*   Created:	        2013.08.14:nie wuyang create
*   Rivision Record:    
*********************************************************************/
G711_API int CALLMETHOD g711a_Decode( IN  unsigned char *src,  OUT unsigned char *dest,
                                      IN           int  srclen,OUT          int  *dstlen);

/********************************************************************
*	Funcname: 			g711u_Decode    	
*	Purpose:			G711u����ӿں���
*   InputParam:   		IN  unsigned char *src      :������������
*                 		IN           int  srclen    :�������ݳ��ȣ���λ���ֽ�
*   OutputParam:  		OUT unsigned char *dest     :����������� 
*                 		OUT          int  *dstlen   :����������ȣ���λ���ֽ�
*   Return:             int
*   Created:	        2013.08.14:nie wuyang create
*   Rivision Record:    
*********************************************************************/
G711_API int CALLMETHOD g711u_Decode( IN  unsigned char *src,  OUT unsigned char *dest,
                                      IN           int  srclen,OUT          int  *dstlen);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif //++#ifndef __G711_H__
