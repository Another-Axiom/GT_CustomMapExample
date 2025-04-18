#pragma target 3.0

#pragma vertex shadowVert
#pragma fragment shadowFrag

#pragma shader_feature _ALPHATEST_ON
#pragma shader_feature _USE_TEXTURE
#pragma multi_compile_instancing

#include "GTUberShader.Common.hlsl"

DECLARE_ATLASABLE_TEX2D(_BaseMap);            
DECLARE_ATLASABLE_SAMPLER(sampler_BaseMap);

struct ShadowAttributes 
{
    float3 positionOS : POSITION;

    #if (_ALPHATEST_ON && _USE_TEXTURE)
        float2 uv : TEXCOORD0;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct ShadowVaryings 
{
    float4 positionCS : SV_POSITION;
    
    #if (_ALPHATEST_ON && _USE_TEXTURE)
        float2 uv: TEXCOORD0;
    #endif
};

ShadowVaryings shadowVert(ShadowAttributes input) 
{
    ShadowVaryings output = (ShadowVaryings)0;
    UNITY_SETUP_INSTANCE_ID(input);

    #if (_ALPHATEST_ON && _USE_TEXTURE)
        output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    #endif

    output.positionCS = TransformObjectToHClip(input.positionOS);
    return output;
}

half4 shadowFrag(ShadowVaryings input) : SV_TARGET 
{
    #if (_ALPHATEST_ON  && _USE_TEXTURE)
        float alpha = _BaseColor.a;
        alpha *= SAMPLE_ATLASABLE_TEX2D(_BaseMap, sampler_BaseMap, input.uv, 0.0).a;
        clip(alpha - _Cutoff);
    #endif

    return 0;
}