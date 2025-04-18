#ifndef GT_UBER_COMMON_INCLUDE
#define GT_UBER_COMMON_INCLUDE

// Some defines for JetBrains Rider syntax highlighting.
#if __RESHARPER__
#define _USE_TEX_ARRAY_ATLAS 1
#endif // __RESHARPER__


#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#define THREE_HALFS_PI 4.71238898038469

#define _DECLARE_TEX2D(texture_name) TEXTURE2D(texture_name); SAMPLER(sampler##texture_name);
#define _SAMPLE_TEX2D(texture_name, uv) SAMPLE_TEXTURE2D(texture_name, sampler##texture_name, uv);

SAMPLER(sampler_linear_repeat);

#if _USE_TEX_ARRAY_ATLAS

    // The equivalent of `_BaseMap_AtlasSlice` still needs to be declared independently in the CBUFFER block.
    #define DECLARE_ATLASABLE_TEX2D(texName) \
        TEXTURE2D_ARRAY(texName##_Atlas)

    #define DECLARE_ATLASABLE_SAMPLER(samplerName) \
        SAMPLER(samplerName##_Atlas)

    #define SAMPLE_ATLASABLE_TEX2D(texName, samplerName, coord2, mipBias) \
        SAMPLE_TEXTURE2D_ARRAY_BIAS(texName##_Atlas, samplerName##_Atlas, coord2, texName##_AtlasSlice, mipBias)

    // Sampler name has to be set explicitly... really intended for samplers defined above in "GlobalSamplers.hlsl".
    #define SAMPLE_ATLASABLE_TEX2D_LOD(texName, samplerName, coord2, mipLODLevel) \
        SAMPLE_TEXTURE2D_ARRAY_LOD(texName##_Atlas, samplerName, coord2, texName##_AtlasSlice, mipLODLevel)

#else

    #define DECLARE_ATLASABLE_TEX2D(texName) \
        TEXTURE2D(texName)

    #define DECLARE_ATLASABLE_SAMPLER(samplerName) \
        SAMPLER(samplerName)

    #define SAMPLE_ATLASABLE_TEX2D(texName, samplerName, coord2, mipBias) \
        SAMPLE_TEXTURE2D_BIAS(texName, samplerName, coord2, mipBias)

    #define SAMPLE_ATLASABLE_TEX2D_LOD(texName, samplerName, coord2, mipLODLevel) \
        SAMPLE_TEXTURE2D_LOD(texName, samplerName, coord2, mipLODLevel)

#endif // _USE_TEX_ARRAY_ATLAS

#if _USE_TEX_ARRAY_ATLAS && _TEX_ARRAY_SLICE_SOURCE__TWO_IN_ALPHA

/**
 * Unpacks the alpha, base map slice, and emission map slice.
 *
 * Slices are returned as floats to avoid an extra conversion, because when sampling in fragment shader it will be
 * combined with uv coordinates as float3.
 * 
 * @param packedValue  The vertex color alpha before unpacking.
 * @param alpha        Output of unpacked alpha value as half because that is the vertex color precision.
 * @param slice1       Output of unpacked base map slice index.
 * @param slice2       Output of unpacked emission map slice index.
 */
inline void Unpack2TexArraySlicesFromAlpha(float packedValue, out half alpha, out float slice1, out float slice2) {
    uint intVal = asuint(packedValue);
    const uint mask10Bits = 0x3FF; // 10 bits set to 1
    const uint mask11Bits = 0x7FF; // 11 bits set to 1

    alpha = (half)(intVal & mask10Bits) / 1023.0h;
    slice1 = (float)((intVal >> 10) & mask11Bits);
    slice2 = (float)((intVal >> 21) & mask11Bits);
}

#endif // _TEX_ARRAY_SLICE_SOURCE__TWO_IN_ALPHA

#endif // GT_UBER_COMMON_INCLUDE