#ifndef _REST_API_PROTO_CONST_STRING_H_
#define _REST_API_PROTO_CONST_STRING_H_

#include "basedef.h"

typedef struct
{
	char *cstr;
} const_string_t;

C_API const_string_t const_string_new(const char *str);
C_API const_string_t const_string_new_length(const char *str, int len);
C_API void const_string_clear(const_string_t cs);

#define CSTR				const_string_t
#define CS(str)				const_string_new(str)
#define CS_LENGTH(cs)		const_string_length(cs)
#define CS_CLEAR(cs)		const_string_clear(cs), (cs).cstr = NULL

C_API int const_string_length(CSTR cs);
C_API int const_string_start_with(CSTR cs, const char *str);
C_API int const_string_end_with(CSTR cs, const char *str);

C_API void const_string_appendn(CSTR *cs, const char *str, int len);
C_API void const_string_append(CSTR *cs, const char *str);
C_API void const_string_append_int(CSTR *cs, int n);
C_API void const_string_append_double(CSTR *cs, double n);

C_API CSTR const_string_sub(CSTR cs, int start_pos, int end_pos);
C_API CSTR const_string_sub_between(CSTR s, const char *begin_str, const char *end_str);
C_API CSTR const_string_cat(CSTR cs1, CSTR cs2);

C_API int const_string_indexof(CSTR cs, const char *str);
C_API int const_string_indexof_from(CSTR cs, const char *str, int from);

C_API CSTR const_string_replace(CSTR cs, const char *from, const char *to);

#endif
