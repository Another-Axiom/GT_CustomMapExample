#ifndef MATH_UTILS_MAP_INCLUDE
#define MATH_UTILS_MAP_INCLUDE

#define DECLARE_MAP_FUNC(var_t) \
var_t map(var_t value, var_t src_min, var_t src_max, var_t dst_min, var_t dst_max)     \
    { return dst_min + (value - src_min) * (dst_max - dst_min) / (src_max - src_min); } \

DECLARE_MAP_FUNC(float)
DECLARE_MAP_FUNC(float2)
DECLARE_MAP_FUNC(float3)
DECLARE_MAP_FUNC(float4)

DECLARE_MAP_FUNC(half)
DECLARE_MAP_FUNC(half2)
DECLARE_MAP_FUNC(half3)
DECLARE_MAP_FUNC(half4)

#undef DECLARE_MAP_FUNC

#endif