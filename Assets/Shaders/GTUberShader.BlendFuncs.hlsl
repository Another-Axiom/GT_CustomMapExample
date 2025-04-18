#ifndef GT_UBER_BLEND_FUNCS_INCLUDE
#define GT_UBER_BLEND_FUNCS_INCLUDE

#define DECLARE_Blend_ColorBurn(var_t, _nt, lrp_t) \
var_t Blend_ColorBurn (var_t a, var_t b) { return _nt(1.0) - (_nt(1.0) - b)/a; } \
var_t Blend_ColorBurn (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_ColorBurn(a, b), blend); }

#define DECLARE_Blend_Darken(var_t, _nt, lrp_t) \
var_t Blend_Darken (var_t a, var_t b) { return min(b, a); } \
var_t Blend_Darken (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Darken(a, b), blend); }

#define DECLARE_Blend_Difference(var_t, _nt, lrp_t) \
var_t Blend_Difference (var_t a, var_t b) { return abs(b - a); } \
var_t Blend_Difference (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Difference(a, b), blend); }

#define DECLARE_Blend_Dodge(var_t, _nt, lrp_t) \
var_t Blend_Dodge (var_t a, var_t b) { return a / (_nt(1.0) - b); } \
var_t Blend_Dodge (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Dodge(a, b), blend); }

#define DECLARE_Blend_Divide(var_t, _nt, lrp_t) \
var_t Blend_Divide (var_t a, var_t b) { return a / (b + _nt(0.000000000001)); } \
var_t Blend_Divide (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Dodge(a, b), blend); }

#define DECLARE_Blend_Exclusion(var_t, _nt, lrp_t) \
var_t Blend_Exclusion (var_t a, var_t b) { return b + a - (_nt(2.0) * b * a); } \
var_t Blend_Exclusion (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Exclusion(a, b), blend); }

#define DECLARE_Blend_HardMix(var_t, _nt, lrp_t) \
var_t Blend_HardMix (var_t a, var_t b) { return step(_nt(1.0) - a, b); } \
var_t Blend_HardMix (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_HardMix(a, b), blend); }

#define DECLARE_Blend_Lighten(var_t, _nt, lrp_t) \
var_t Blend_Lighten (var_t a, var_t b) { return max(b, a); } \
var_t Blend_Lighten (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Lighten(a, b), blend); }

#define DECLARE_Blend_LinearBurn(var_t, _nt, lrp_t) \
var_t Blend_LinearBurn (var_t a, var_t b) { return a + b - _nt(1.0); } \
var_t Blend_LinearBurn (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_LinearBurn(a, b), blend); }

#define DECLARE_Blend_LinearDodge(var_t, _nt, lrp_t) \
var_t Blend_LinearDodge (var_t a, var_t b) { return a + b; } \
var_t Blend_LinearDodge (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_LinearDodge(a, b), blend); }

#define DECLARE_Blend_LinearLight(var_t, _nt, lrp_t) \
var_t Blend_LinearLight (var_t a, var_t b) { return b < _nt(0.5) ? max(a + (_nt(2.0) * b) - _nt(1.0), _nt(0.0)) : min(a + _nt(2.0) * (b - _nt(0.5)), _nt(1.0)); } \
var_t Blend_LinearLight (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_LinearLight(a, b), blend); }

#define DECLARE_Blend_LinearLightAddSub(var_t, _nt, lrp_t) \
var_t Blend_LinearLightAddSub (var_t a, var_t b) { return b + _nt(2.0) * a - _nt(1.0); } \
var_t Blend_LinearLightAddSub (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_LinearLightAddSub(a, b), blend); }

#define DECLARE_Blend_Multiply(var_t, _nt, lrp_t) \
var_t Blend_Multiply (var_t a, var_t b) { return a * b; } \
var_t Blend_Multiply (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Multiply(a, b), blend); }

#define DECLARE_Blend_Negation(var_t, _nt, lrp_t) \
var_t Blend_Negation (var_t a, var_t b) { return _nt(1.0) - abs(_nt(1.0) - b - a); } \
var_t Blend_Negation (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Negation(a, b), blend); }

#define DECLARE_Blend_Subtract(var_t, _nt, lrp_t) \
var_t Blend_Subtract (var_t a, var_t b) { return a - b; } \
var_t Blend_Subtract (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Subtract(a, b), blend); }

#define DECLARE_Blend_Screen(var_t, _nt, lrp_t) \
var_t Blend_Screen (var_t a, var_t b) { return _nt(1.0) - (_nt(1.0) - b) * (_nt(1.0) - a); } \
var_t Blend_Screen (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Screen(a, b), blend); }

#define DECLARE_Blend_Overwrite(var_t, _nt, lrp_t) \
var_t Blend_Overwrite (var_t a, var_t b, lrp_t blend) { return lerp(a, b, blend); }

#define DECLARE_Blend_HardLight(var_t, _nt, lrp_t) \
var_t Blend_HardLight (var_t a, var_t b)                                   \
{                                                                          \
    var_t result1 = _nt(1.0) - _nt(2.0) * (_nt(1.0) - a) * (_nt(1.0) - b); \
    var_t result2 = _nt(2.0) * a * b;                                      \
    var_t zeroOrOne = step(b, _nt(0.5));                                   \
    return result2 * zeroOrOne + (_nt(1.0) - zeroOrOne) * result1;         \
}                                                                          \
var_t Blend_HardLight (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_HardLight(a, b), blend); }

#define DECLARE_Blend_Overlay(var_t, _nt, lrp_t) \
var_t Blend_Overlay (var_t a, var_t b)                                     \
{                                                                          \
    var_t result1 = _nt(1.0) - _nt(2.0) * (_nt(1.0) - a) * (_nt(1.0) - b); \
    var_t result2 = _nt(2.0) * a * b;                                      \
    var_t zeroOrOne = step(a, _nt(0.5));                                   \
    return result2 * zeroOrOne + (_nt(1.0) - zeroOrOne) * result1;         \
}                                                                          \
var_t Blend_Overlay (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_Overlay(a, b), blend); }

#define DECLARE_Blend_PinLight(var_t, _nt, lrp_t) \
var_t Blend_PinLight (var_t a, var_t b)                         \
{                                                               \
    var_t check = step (_nt(0.5), b);                           \
    var_t result1 = check * max(_nt(2.0) * (a - _nt(0.5)), b);  \
    return result1 + (_nt(1.0) - check) * min(_nt(2.0) * a, b); \
}                                                               \
var_t Blend_PinLight (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_PinLight(a, b), blend); }

#define DECLARE_Blend_SoftLight(var_t, _nt, lrp_t) \
var_t Blend_SoftLight (var_t a, var_t b)                                                 \
{                                                                                        \
    var_t result1 = _nt(2.0) * a * b + a * a * (_nt(1.0) - _nt(2.0) * b);                \
    var_t result2 = sqrt(a) * (_nt(2.0) * b - _nt(1.0)) + _nt(2.0) * a * (_nt(1.0) - b); \
    var_t zeroOrOne = step(_nt(0.5), b);                                                 \
    return result2 * zeroOrOne + (_nt(1.0) - zeroOrOne) * result1;                       \
}                                                                                        \
var_t Blend_SoftLight (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_SoftLight(a, b), blend); }

#define DECLARE_Blend_VividLight(var_t, _nt, lrp_t) \
var_t Blend_VividLight (var_t a, var_t b)                          \
{                                                                  \
    var_t result1 = _nt(1.0) - (_nt(1.0) - b) / (_nt(2.0) * a);    \
    var_t result2 = b / (_nt(2.0) * (_nt(1.0) - a));               \
    var_t zeroOrOne = step(_nt(0.5), a);                           \
    return result2 * zeroOrOne + (_nt(1.0) - zeroOrOne) * result1; \
}                                                                  \
var_t Blend_VividLight (var_t a, var_t b, lrp_t blend) { return lerp(a, Blend_VividLight(a, b), blend); }

// Glossary:
//
//      var_t = Input/output variable type
//      _nt   = Precision suffix macro
//      lrp_t = Blend variable type for lerped overloads
//
#define DECLARE_BLEND_FUNCS_FOR(var_t, _nt, lrp_t) \
    DECLARE_Blend_ColorBurn         (var_t, _nt, lrp_t) \
    DECLARE_Blend_Darken            (var_t, _nt, lrp_t) \
    DECLARE_Blend_Difference        (var_t, _nt, lrp_t) \
    DECLARE_Blend_Dodge             (var_t, _nt, lrp_t) \
    DECLARE_Blend_Divide            (var_t, _nt, lrp_t) \
    DECLARE_Blend_Exclusion         (var_t, _nt, lrp_t) \
    DECLARE_Blend_HardMix           (var_t, _nt, lrp_t) \
    DECLARE_Blend_Lighten           (var_t, _nt, lrp_t) \
    DECLARE_Blend_LinearBurn        (var_t, _nt, lrp_t) \
    DECLARE_Blend_LinearDodge       (var_t, _nt, lrp_t) \
    DECLARE_Blend_LinearLight       (var_t, _nt, lrp_t) \
    DECLARE_Blend_LinearLightAddSub (var_t, _nt, lrp_t) \
    DECLARE_Blend_Multiply          (var_t, _nt, lrp_t) \
    DECLARE_Blend_Negation          (var_t, _nt, lrp_t) \
    DECLARE_Blend_Subtract          (var_t, _nt, lrp_t) \
    DECLARE_Blend_Screen            (var_t, _nt, lrp_t) \
    DECLARE_Blend_Overwrite         (var_t, _nt, lrp_t) \
    DECLARE_Blend_HardLight         (var_t, _nt, lrp_t) \
    DECLARE_Blend_Overlay           (var_t, _nt, lrp_t) \
    DECLARE_Blend_PinLight          (var_t, _nt, lrp_t) \
    DECLARE_Blend_SoftLight         (var_t, _nt, lrp_t) \
    DECLARE_Blend_VividLight        (var_t, _nt, lrp_t) 

// Explicit precision specifier for numeric literal n
#define f(n) n##f
#define h(n) n##h

DECLARE_BLEND_FUNCS_FOR(float , f, float)
DECLARE_BLEND_FUNCS_FOR(float2, f, float)
DECLARE_BLEND_FUNCS_FOR(float3, f, float)
DECLARE_BLEND_FUNCS_FOR(float4, f, float)

DECLARE_BLEND_FUNCS_FOR(half , h, half)
DECLARE_BLEND_FUNCS_FOR(half2, h, half)
DECLARE_BLEND_FUNCS_FOR(half3, h, half)
DECLARE_BLEND_FUNCS_FOR(half4, h, half)

// Undefines, avoid polluting global scope
#undef f
#undef h
#undef DECLARE_BLEND_FUNCS_FOR

#undef DECLARE_Blend_ColorBurn              
#undef DECLARE_Blend_Darken            
#undef DECLARE_Blend_Difference        
#undef DECLARE_Blend_Dodge             
#undef DECLARE_Blend_Divide            
#undef DECLARE_Blend_Exclusion         
#undef DECLARE_Blend_HardMix           
#undef DECLARE_Blend_Lighten           
#undef DECLARE_Blend_LinearBurn        
#undef DECLARE_Blend_LinearDodge       
#undef DECLARE_Blend_LinearLight       
#undef DECLARE_Blend_LinearLightAddSub 
#undef DECLARE_Blend_Multiply          
#undef DECLARE_Blend_Negation          
#undef DECLARE_Blend_Subtract          
#undef DECLARE_Blend_Screen            
#undef DECLARE_Blend_Overwrite         
#undef DECLARE_Blend_HardLight         
#undef DECLARE_Blend_Overlay           
#undef DECLARE_Blend_PinLight          
#undef DECLARE_Blend_SoftLight         
#undef DECLARE_Blend_VividLight

#endif // GT_UBER_BLEND_FUNCS_INCLUDE