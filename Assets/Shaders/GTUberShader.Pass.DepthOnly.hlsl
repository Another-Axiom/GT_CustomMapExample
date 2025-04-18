#pragma target 3.0

#pragma vertex depthVert
#pragma fragment depthFrag

#pragma shader_feature _ALPHATEST_ON
#pragma shader_feature _USE_TEXTURE
#pragma multi_compile_instancing

#include "GTUberShader.Common.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

struct DepthAttributes 
{
    float3 positionOS : POSITION;

    #if (_ALPHATEST_ON && _USE_TEXTURE)
        float2 uv : TEXCOORD0;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};


struct DepthVaryings 
{
    float4 positionCS : SV_POSITION;

    #if (_ALPHATEST_ON && _USE_TEXTURE)
        float2 uv : TEXCOORD0;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


DepthVaryings depthVert(DepthAttributes input)
{
    DepthVaryings output = (DepthVaryings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    
    #if (_ALPHATEST_ON && _USE_TEXTURE)
        output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    #endif
    
    output.positionCS = TransformObjectToHClip(input.positionOS);
    return output;
}

half4 depthFrag(DepthVaryings input) : SV_TARGET 
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #if (_ALPHATEST_ON  && _USE_TEXTURE)
        float alpha = _BaseColor.a;
        alpha *= SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a;
        clip(alpha - _Cutoff);
    #endif

    return input.positionCS.z;
}