#ifndef GT_UBER_FUNCS_INCLUDE
#define GT_UBER_FUNCS_INCLUDE

#include "GTUberShader.Globals.hlsl"
#include "GTUberShader.Common.hlsl"
#include "GTUberShader.BlendFuncs.hlsl"
#include "MathUtils.Map.hlsl"

uint seed(float3 p)
{
	return 19u * p.x + 47u * p.y + 101u * p.z + 131u;
}

uint seed(float4 p)
{
	return 19u * p.x + 47u * p.y + 101u * p.z + 131u * p.w + 173u;
}

uint fmix(uint h)
{
	h ^= h >> 16;
	h *= 0x85ebca6bu;
	h ^= h >> 13;
	h *= 0xc2b2ae35u;
	h ^= h >> 16;
	return h;
}

inline float remap(float value, float min1, float max1, float min2, float max2)
{
	float range0 = max1 - min1;
	float range1 = max2 - min2;
	return min2 + (value - min1) * range1 / range0;
}

float pulse(float k, float x)
{
	float h = k * x;
	return h * exp(1.0 - h);
}

float2 hash(float2 p)
{
	p = float2(dot(p,float2(127.1,311.7)), dot(p,float2(269.5,183.3)));
	return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

float noise(in float2 p)
{
	const float K1 = 0.366025404; // ( sqrt(3) - 1 ) / 2;
	const float K2 = 0.211324865; // ( 3 - sqrt(3) ) / 6;
	const float3 S = float3(70.0, 70.0, 70.0);
                
	float2 i = floor(p + (p.x + p.y) * K1);	
	float2 a = p - i + (i.x + i.y) * K2;
	float2 o = a.x > a.y ? float2(1.0, 0.0) : float2(0.0, 1.0); //float2 of = 0.5 + 0.5*float2(sign(a.x-a.y), sign(a.y-a.x));
	float2 b = a - o + K2;
	float2 c = a - 1.0 + 2.0 * K2;
	
	float3 h = max(0.5 - float3(dot(a,a), dot(b,b), dot(c,c)), 0.0);
	h = h * h * h * h;

	float x = dot(a, hash(i        ));
	float y = dot(b, hash(i +   o));
	float z = dot(c, hash(i + 1.0));
	
	float3 n = h * float3(x, y, z);
	
	return dot(n, S);	
}

// 4th order approximation
float atanFast(float x)
{
	return x * (-0.1784f * abs(x) - 0.0663f * x * x + 1.0301f);
}

float smoothsq(float d, float x)
{
	return (1.0 - d) * 2.0 * atanFast(sin(x) / d) / PI;
}

float3 luma(float3 color)
{
	return dot(float3(0.299, 0.587, 0.114), color);
}

float bias(float x, float b)
{
	b = -log2(1.0 - b);
	return 1.0 - pow(1.0 - pow(x, 1.0 / b), b);
}

float InvEaseDual(float x, float k)
{
	k = clamp(k, 0.0001, 10000.0);
	x = 0.5 - x;
	float s = sign(x);
	x = clamp(abs(x) * 2.0, 0.0, 1.0);
	return 0.5 + 0.5 * s * x / (x * (k - 1.0) - k);
}

/**
 * \brief Explicitly branch-less version of a ternary conditional, for when platform behavior is unknown
 * \param predicate Value of 0 or 1
 * \param a Return value if predicate is 1 / true
 * \param b Output value if predicate is 0 / false
 */
inline float opt(float predicate, float a, float b)
{
	return lerp(a, b, step(predicate, 0.5f));
}

// For each component in a vector, returns -1 if negative or zero, +1 if positive
float  msign(float  x) { return (sign(x) + 1.0) * 0.5 * 2.0 - 1.0; }
float2 msign(float2 v) { return (sign(v) + 1.0) * 0.5 * 2.0 - 1.0; }
float3 msign(float3 v) { return (sign(v) + 1.0) * 0.5 * 2.0 - 1.0; }
float4 msign(float4 v) { return (sign(v) + 1.0) * 0.5 * 2.0 - 1.0; }

half  msign(half  x) { return (sign(x) + 1.0) * 0.5 * 2.0 - 1.0; }
half2 msign(half2 v) { return (sign(v) + 1.0) * 0.5 * 2.0 - 1.0; }
half3 msign(half3 v) { return (sign(v) + 1.0) * 0.5 * 2.0 - 1.0; }
half4 msign(half4 v) { return (sign(v) + 1.0) * 0.5 * 2.0 - 1.0; }

/**
 * Computes the progress with a softened transition edge.
 * 
 * This function is useful for generating effects like progress bars with a faded transition between the filled and
 * empty states. When progress is 0, the bar is completely empty; and when progress is 1, the bar is completely filled.
 * 
 * @param progress     The current progress value, expected to be between 0-1.
 * @param progressMap  The current progress map value, expected to be between 0-1.
 * @param edgeSize     The size of the transition zone. Should be greater than epsilon (not zero).
 * @return             The computed progress taking into account the transition band.
 */
half Progress(half progressMap, half edgeSize, half progress)
{
	// return (0.0 + ((edgeSize + (progressMap - 0.0) * (1.0 - edgeSize) / (1.0 - 0.0)) - ( progress + edgeSize )) * (1.0 - 0.0) / (progress - ( progress + edgeSize )));
	// return (progressMap * (1.0 - edgeSize) + edgeSize - (progress + edgeSize)) / (progress - (progress + edgeSize));
	return -(progressMap * (1.0 - edgeSize) - progress) / edgeSize;
}

float DistanceSq(float3 a, float3 b)
{
	const float3 diff = a - b;
	return dot(diff, diff);
}

float DistanceSq(float2 a, float2 b)
{
	const float2 diff = a - b;
	return dot(diff, diff);
}

float DistanceSq(float3 a)
{
	return dot(a, a);
}

float DistanceSq(float2 a)
{
	return dot(a, a);
}

// On lowest quality settings, lightmaps are packed differently on mobile vs. PC
half3 UnpackLightmap(half4 packedValue)
{
	#if UNITY_LIGHTMAP_RGBM_ENCODING
		return packedValue.rgb * pow(abs(packedValue.a), 2.2) * 34.493242;
	#elif UNITY_LIGHTMAP_DLDR_ENCODING
		return packedValue.rgb * 4.59;
	#else
		return packedValue.rgb;
	#endif
}

// Gorilla Tag's classic look, a uniform light cast by the default skybox
half GetGTClassicRimLight(float3 viewDirection, float3 normal, float smoothness)
{
	half nv = 1.0 - saturate(-dot(normal, viewDirection));
	nv = nv * nv * nv * nv * nv;
	half spec = lerp(0.01, 0.49 * smoothness, nv) + 0.01 * smoothness;
	return pow(max(spec,0.0), 1.1) * 0.86;
}

half3 GetGTClassicRimLightMetallic(float3 viewDirection, float3 normal, half3 albedo, float smoothness, float metallic)
{
	half nv = 1.0 - saturate(-dot(normal, viewDirection));
	nv = nv * nv * nv * nv * nv;
	half specularMultiplier = lerp(0.01, 0.49 * smoothness, nv) + 0.01 * smoothness;

	half3 defaultReflectionColor = half3(0.314, 0.396, 0.533); //Default skybox blue
	half3 reflectionColor = lerp(defaultReflectionColor, albedo, metallic);

	return specularMultiplier * reflectionColor;
}

inline float3 Posterize(float3 value, float3 steps)
{
	return floor(value / (1 / steps)) * (1 / steps);
}

inline float2 GetFragmentDelta(float2 uv, float4 texelSize)
{
	//
	// Glossary:
	//
	//   UV  - Texture Space
	//   ST  - Fragment Space
	//   XYZ - World Space
	//
	
	// Get ST derivatives
	float2 dS = ddx(uv);
	float2 dT = ddy(uv);

	// Calculate UV delta to nearest texel center
	float2 centerUV = floor(uv * texelSize.zw) / texelSize.zw + (texelSize.xy / 2.0);
	float2 dUV = (centerUV - uv);

	// Build UV inversion matrix using ST delta
	float2x2 dST_dUV =
		float2x2( dT[1], -dT[0], -dS[1], dS[0] ) * ( 1.0f / (dS[0] * dT[1] - dT[0] * dS[1]) );
 
	// Convert UV delta to ST delta
	float2 dST = mul(dST_dUV , dUV);
	return dST;
}

inline float3 TexelSnap(float3 posWS, float2 dST)
{ 
	// Get XYZ derivatives in ST space
	float3 dXYZ_dS = ddx(posWS);
	float3 dXYZ_dT = ddy(posWS);
 
	// Convert ST delta to XYZ delta
	float3 dXYZ = dXYZ_dS * dST[0] + dXYZ_dT * dST[1];

	// Clamp in case derivative value exploded
	// [-1, 1] should be magnitudes greater than any texel size
	dXYZ = clamp(dXYZ, -1, 1);
 
	// Transform snapped UV back to world space
	return posWS + dXYZ;
}

inline float2 GetAntiAliasUV(float2 uv, float4 texelSize, float bias = 0.5)
{
	float2 texel_c = uv * texelSize.zw;
	float2 half_w = 0.5 * fwidth(texel_c);
	float2 floor_c = floor(texel_c - bias) + bias;
	float2 term = smoothstep(bias - half_w, bias + half_w, texel_c - floor_c);
	return (floor_c + term) * texelSize.xy;
}

inline float4 qmul(float4 q1, float4 q2)
{
    return float4
	(
        q2.xyz * q1.w + q1.xyz * q2.w + cross(q1.xyz, q2.xyz),
        q1.w * q2.w - dot(q1.xyz, q2.xyz)
    );
}

// Euler angles rotation matrix
float3x3 Euler3x3(float3 v)
{
	float sx, cx;
	float sy, cy;
	float sz, cz;

	sincos(v.x, sx, cx);
	sincos(v.y, sy, cy);
	sincos(v.z, sz, cz);

	float3 row1 = float3(sx*sy*sz + cy*cz, sx*sy*cz - cy*sz, cx*sy);
	float3 row3 = float3(sx*cy*sz - sy*cz, sx*cy*cz + sy*sz, cx*cy);
	float3 row2 = float3(cx*sz, cx*cz, -sx);

	return float3x3(row1, row2, row3);
}

//
// Rotate vector by Euler angles (degrees)
//
inline float3 RotateByEuler(float3 v, float3 euler)
{
	return mul(Euler3x3(euler), v);
}
   
// Vector rotation with a quaternion
// http://mathworld.wolfram.com/Quaternion.html
inline float3 RotateVector(float3 v, float4 q)
{
    float4 q_c = q * float4(-1, -1, -1, 1);
    return qmul(q, qmul(float4(v, 0), q_c)).xyz;
}

inline float3 RotateByQuat(float3 v, float4 q)
{
	float3 uv  = cross(q.xyz,  v);
	float3 uuv = cross(q.xyz, uv);

	uv  *= 2.0f * q.w;
	uuv *= 2.0f;
	
	return v - uv + uuv;
}

inline float3 EulerToDir(float x, float y)
{
	return float3
	(
		cos(x) * sin(y),
		sin(x),
		cos(x) * cos(y)
	);
}

inline float3 BoxProject(float3 refDirWS, float3 posWS, float3 cubeCenter, float3 boxMin, float3 boxMax)
{
    refDirWS = normalize(refDirWS);

    #if 0
	
        float3 _max = (boxMax.xyz - posWS) / refDirWS;
        float3 _min = (boxMin.xyz - posWS) / refDirWS;

        float3 _minMax = (refDirWS > 0.0f) ? _max : _min;
	
    #else // Optimized version
	
        float3 _max = (boxMax.xyz - posWS);
        float3 _min = (boxMin.xyz - posWS);

        float3 select = step (float3(0,0,0), refDirWS);
        float3 _minMax = lerp (_max, _min, select);
	
        _minMax /= refDirWS;
	
    #endif

    float fa = min(min(_minMax.x, _minMax.y), _minMax.z);

    posWS -= cubeCenter.xyz;
    refDirWS = posWS + refDirWS * fa;
                
    return refDirWS;
}

// https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Rotate-About-Axis-Node.html
inline float3 RotateAboutAxis(float3 v, float3 axis, float degrees)
{
    degrees = radians(degrees);

    float s = sin(degrees);
    float c = cos(degrees);
    float omc = 1.0 - c;

    axis = normalize(axis);
                
    float3x3 rot = 
    {   omc * axis.x * axis.x + c, omc * axis.x * axis.y - axis.z * s, omc * axis.z * axis.x + axis.y * s,
        omc * axis.x * axis.y + axis.z * s, omc * axis.y * axis.y + c, omc * axis.y * axis.z - axis.x * s,
        omc * axis.z * axis.x - axis.y * s, omc * axis.y * axis.z + axis.x * s, omc * axis.z * axis.z + c
    };
                
    return mul(rot,  v);
}

inline float2 RotateUV_Degrees(float2 uv, float2 pivot, float speed, float animate)
{
    float rot = radians(speed * -1.0);
                
    if (animate == 1.)
    	rot *= _Time.y;

    float sinX = sin(rot);
    float cosX = cos(rot);
    float sinY = sin(rot);

    float2x2 m = float2x2(cosX, -sinX, sinY, cosX);
                    
    uv -= pivot;
    uv = mul(uv, m);
    uv += pivot;

    return uv;
}

inline float2 WaveWarpUV(float2 uv, float amplitude, float frequency, float scale)
{
    float aspect = _ScreenParams.y / _ScreenParams.x;
    float2 amp = float2(aspect * amplitude, amplitude) / scale;
                    
    float2 uv2  = (uv - 0.5) * (1.0 - abs(amp) * 2.0) + 0.5;
    float2 warp = (float2((uv2.y - 0.5) * aspect, uv2.x - 0.5) * scale + _Time.y * frequency) * PI;
                    
    uv2 += float2(sin(warp.x), sin(warp.y)) * amp;                    
    return uv2;
}

inline float2 ToRadialCoords(float3 coords)
{
    coords = normalize(coords);

    #if 0
        float lon = atan2(coords.z, coords.x) * INV_TWO_PI;
    #else

        // Fix mipmap seam by using small bias to select UV set
        // Slightly more expensive
    
        float lon_A = atan2(coords.z, coords.x) * INV_TWO_PI; // -0.5 to 0.5 range (default)
        float lon_B = frac(lon_A);                            //  0.0 to 1.0 range
    
        float lon = fwidth(lon_A) < fwidth(lon_B) - 0.001 ? lon_A : lon_B;
    #endif
                
    float lat = acos(coords.y) / PI;
                
    return -float2( lon , lat );
}

inline float3 RotateAroundY_Degrees(float3 vertex, float degrees)
{
    float alpha = degrees * PI / 180.0;
    float sina, cosa;

    sincos(alpha, sina, cosa);
    float2x2 m = float2x2(cosa, -sina, sina, cosa);
    
    return float3(mul(m, vertex.xz), vertex.y).xzy;
}

inline float RemapValue(float value, float2 inMinMax, float2 outMinMax)
{
    float inRange = inMinMax.y - inMinMax.x;
    float outRange = outMinMax.y - outMinMax.x;
    return outMinMax.x + (value - inMinMax.x) * outRange / inRange;
}

//
// Required for ParallaxOcclusionMapping:
//
inline float ComputePerPixelHeightDisplacement(float2 texOffsetCurrent, float lod, float2 uv, TEXTURE2D_PARAM(heightTexture, heightSampler))
{
	return SAMPLE_TEXTURE2D_LOD(heightTexture, heightSampler, uv + texOffsetCurrent, lod).r;
}

inline float2 ParallaxOcclusionMapping(float lod, float lodThreshold, int numSteps, float3 viewDirTS, float2 uv, out float outHeight, TEXTURE2D_PARAM(heightTexture, samplerState))
{
	float3 clipCoords = 0;

	//
    // Convention is:
    //     1.0 = top
    //     0.0 = bottom
	//
    // POM always calculates inward, no extrusion
	//
    float stepSize = 1.0 / (float) numSteps;

	//
    // View direction is defined as: [point  -> camera]
	// To raymarch, we want:         [camera ->  point]
	//
	// So we reverse the sign.
	//
    // The length of viewDirTS determines the furthest amount of displacement:
	//
	// float parallaxLimit = -length(viewDirTS.xy) / viewDirTS.z;
    // float2 parallaxDir = normalize(viewDirTS.xy);
    // float2 parallaxMaxOffsetTS = parallaxDir * parallaxLimit;
	//
	// The above simplifies to:
    float2 parallaxMaxOffsetTS = (viewDirTS.xy / -viewDirTS.z);
    float2 texOffsetPerStep = stepSize * parallaxMaxOffsetTS;

    // Manually calculate first step to init all values correctly
    float2 texOffsetCurrent = float2(0.0, 0.0);
    float prevHeight = ComputePerPixelHeightDisplacement(texOffsetCurrent, lod, uv, TEXTURE2D_ARGS(heightTexture, samplerState));
    texOffsetCurrent += texOffsetPerStep;
	
    float currHeight = ComputePerPixelHeightDisplacement(texOffsetCurrent, lod, uv, TEXTURE2D_ARGS(heightTexture, samplerState));
    float rayHeight = 1.0 - stepSize; // Start at top less one sample

    // Linear search
    for (int stepIndex = 0; stepIndex < numSteps; ++stepIndex)
    {				    	
        // Found a height below current ray height?
        // Then it's an intersection, stop search
        if (currHeight > rayHeight) break;

        prevHeight = currHeight;
        rayHeight -= stepSize;
        texOffsetCurrent += texOffsetPerStep;

        // Sample height/depth map
        currHeight = ComputePerPixelHeightDisplacement(texOffsetCurrent, lod, uv , TEXTURE2D_ARGS(heightTexture, samplerState)) * ( 1 - clipCoords.z );
    }

	//
    // Found below and above points, now perform line (ray)
    // intersection with piecewise linear height field approximation
	//

	//
	// Method 1: Secant method to refine the search
	// Ref: Faster Relief Mapping Using the Secant Method - Eric Risser
	//
	#if 1 

	    float pt0 = rayHeight + stepSize;
	    float pt1 = rayHeight;
	
	    float delta0 = pt0 - prevHeight;
	    float delta1 = pt1 - currHeight;

	    float delta;
	    float2 offset;
	
	    for (int i = 0; i < 3; ++i)
	    {
	        // The height [0..1] for the intersection between view ray and height field line
	        float intersectionHeight = (pt0 * delta1 - pt1 * delta0) / (delta1 - delta0);
	    	
	        // Retrieve offset required to find this intersectionHeight
		    offset = (1 - intersectionHeight) * texOffsetPerStep * numSteps;

	        currHeight = ComputePerPixelHeightDisplacement(offset, lod, uv, TEXTURE2D_ARGS(heightTexture, samplerState));

	        delta = intersectionHeight - currHeight;

	        if (abs(delta) <= 0.01) break;

	        // intersectionHeight < currHeight => new lower bounds
	        if (delta < 0.0)
	        {
	            delta1 = delta;
	            pt1 = intersectionHeight;
	        }
	        else
	        {
	            delta0 = delta;
	            pt0 = intersectionHeight;
	        }
	    }

	//
	// Method 2: Regular POM intersection
	//
	#else

		#if 0
	
		    float pt0 = rayHeight + stepSize;
		    float pt1 = rayHeight;
	
		    float delta0 = pt0 - prevHeight;
		    float delta1 = pt1 - currHeight;
	
		    float intersectionHeight = (pt0 * delta1 - pt1 * delta0) / (delta1 - delta0);
		    float2 offset = (1 - intersectionHeight) * texOffsetPerStep * numSteps;
	
		#else // A bit more optimized
		    
		    float delta0 = currHeight - rayHeight;
		    float delta1 = (rayHeight + stepSize) - prevHeight;
	
		    float ratio = delta0 / (delta0 + delta1);
		    float2 offset = texOffsetCurrent - ratio * texOffsetPerStep;
	
		#endif

	    currHeight = ComputePerPixelHeightDisplacement(offset, lod, uv, TEXTURE2D_ARGS(heightTexture, samplerState));

	#endif

    outHeight = currHeight;
	
    // Fade the effect with lod (avoids pop when switching to a discrete LOD mesh)
    offset *= (1.0 - saturate(lod - lodThreshold));

    return offset;
}

inline float2 ToPlanarParallaxUVs(float2 uv, float3 viewDirTS, float amplitude)
{
	return uv + viewDirTS.xy / -viewDirTS.z * amplitude * 0.01;
}

inline float2 GetParallaxUVs(float2 uv, float3 viewDirTS, int steps, float amplitude, TEXTURE2D_PARAM(heightMap, samplerState))
{
	float3 viewDir = viewDirTS; /* GetDisplacementObjectScale().xzy; */ // Optionally scale by object
	float maxHeight = amplitude * 0.01;
	float outHeight; // Unused for now, intended as out variable

	// Transform view vector to UV space
	float3 viewDirUV = normalize(float3(viewDir.xy * maxHeight, viewDir.z)); // TODO: skip normalize	
	float2 parallaxUV = uv + ParallaxOcclusionMapping(0, 0, steps, viewDirUV, uv, outHeight, TEXTURE2D_ARGS(heightMap, samplerState));
	
	return parallaxUV;
}

inline float3 GetFlatNormal(float3 position)
{
	float3 dx = ddx(position);
	float3 dy = ddy(position);
	return normalize(cross(dy, dx));
}

inline half3 GetGTClassicSpecularFaceted(float3 viewDir, float3 pos, float smoothness)
{
	float3 normal = GetFlatNormal(pos);
	
	half nv = 1.0 - saturate(-dot(normal, viewDir));
	nv = nv * nv * nv * nv * nv;
	half specularMultiplier = lerp(0.01, 0.49 * smoothness, nv) + 0.01 * smoothness;
	return specularMultiplier * half3(0.314, 0.396, 0.533); //Default skybox blue
}

inline float3 LavaBlobEffect(float3 baseColor, float speed, float2 uv, TEXTURE2D_PARAM(maskMap, maskSampler), TEXTURE2D_PARAM(gradMap, gradSampler))
{	
	float lvT = _Time.y * speed;
                
	float2 lUV1 = uv + float2( -0.02,  0.16) * lvT;
	float2 lUV2 = uv + float2(  0.00, -0.12) * lvT;
	float2 lUV3 = uv + float2( -0.04,  0.08) * lvT;
	float2 lUV4 = uv + float2(  0.06,  0.00) * lvT;

	float lvR = SAMPLE_TEXTURE2D(maskMap, maskSampler, lUV1).r;
	float lvG = SAMPLE_TEXTURE2D(maskMap, maskSampler, lUV2).g;
	float lvB = SAMPLE_TEXTURE2D(maskMap, maskSampler, lUV3).b;
	float lvA = SAMPLE_TEXTURE2D(maskMap, maskSampler, lUV4).a;

	float lvM = saturate(lvR + lvG + lvB + lvA);

	float shadow = Blend_Screen(lvR, lvG);
	shadow = Blend_Screen(shadow, lvB);
	shadow = max(shadow, lvA);

	lvM = lerp(lvM + shadow, lvM * shadow, 0.5);

	float bw = baseColor.r + baseColor.g + baseColor.b / 3.;
	
	lvM = RemapValue(lvM, float2(0.52, 1.0), float2(0.0, 1));
	lvM = max(bw, lvM * 1);
	
	float3 col = SAMPLE_TEXTURE2D(gradMap, gradSampler, float2(lvM, 0.)).rgb;
	return col;
}

// Approximate version from
// http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
inline half3 GammaToLinear(half3 sRGB)
{
	return sRGB * (sRGB * (sRGB * 0.305306011h + 0.682171111h) + 0.012522878h);
}

// Almost-perfect approximation from
// http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
inline half3 LinearToGamma(half3 linRGB)
{
	linRGB = max(linRGB, half3(0.h, 0.h, 0.h));
	return max(1.055h * pow(linRGB, 0.416666667h) - 0.055h, 0.h);
}

inline float NoiseWhite(float3 p3)
{
	const float HSCALE = 443.8975;
	p3  = frac(p3 * HSCALE);
	p3 += dot(p3, p3.yzx + 19.19);
	return frac((p3.x + p3.y) * p3.z);
}

inline float DitherBlue(float2 screenUV, float alpha, float time = 0)
{
	float2 uv = screenUV.xy / _GT_BlueNoiseTex_WH.w * _ScreenParams.xy; // Tiling
	float4 tex = SAMPLE_TEXTURE2D(_GT_BlueNoiseTex, sampler_GT_BlueNoiseTex, uv);
	
	float blue = LinearToGamma(tex.rgb).r;
	blue = frac(blue + time);
	
	float dither = step(1 - alpha, blue);
	return dither;
}

inline float2 TileAndOffset(float2 uv, float2 tiling, float2 offset)
{
	return uv * tiling + offset;
}

inline float2 CalcWorldSpaceUV(float3 posWS, float3 normalWS)
{
	float3 n = normalWS;

	// Pick dir for vertical "v" axis, z-up default
	float3 v_dir = float3(0, 0, 1);

	// For non-horizontal planes, choose closest vector to world up
	if(abs(n.y) < 1.0f)
	{
		v_dir = normalize(float3(0, 1, 0) - n.y * n);
	}

	// Get perpendicular vector to use as "u" dir
	float3 u_dir = normalize(cross(n, v_dir));

	// Project WS pos into texture plane
	return float2(dot(posWS, u_dir), dot(posWS, v_dir));
}

float2 FilterNiceUV(float2 uv, float2 texelSize, float resFactor = 1.0f)
{
	float res = float(texelSize.x);
	uv = uv * res + 0.5;
	
	float2 iuv = floor(uv);
	float2 fuv = frac(uv);
	
	uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
	uv = (uv - 0.5) / res * resFactor;
	
	return uv;
}

inline half3 BoxBlur(float2 uv, half samples, half radius)
{
	half3 sum = 0.0h;
		
	for (int i = -samples; i < samples; i++)
	{
		for (int j = -samples; j < samples; j++)
		{
			float2 box_uv = uv + half2(i, j) * (radius/samples);			
			half3 box = _SAMPLE_CAMERA_TEX(box_uv).xyz;
			sum += box / pow(samples * 2.0h, 2.0h);
		}
	}

	return sum;
}

inline float2 QuantizeUV(float2 uv, float2 size, float2 step)
{
	const float2 factor = size / step;
	return floor(uv * factor) / factor;
}

inline half3 GridEffect(float2 uv, float t, float2 res, float3 fgCol, float3 bgCol)
{
	uv *= res;
	float3 col = 1.;
	float term = (1. - distance(fmod(uv, float2(1, 1)), float2(0.5, 0.5))) * 1; 
	col *= term;
	// col *= 1. - distance(fmod(uv, float2(0.5, 0.5)), float2(0.5, 0.5));
	// col *= lerp(float3(0.01, 0.01, 0.01), float3(0,1,0), t * pow(term, 2));
	col *= lerp(bgCol, fgCol / 0.125, t * pow(term, 3));
	return col;
}

inline float3 RadialUVToRayDir(float2 uv)
{
	float2 v = PI * ( float2(1.5, 1.0) - float2(2.,1.) * uv );
	return float3
	(
		sin(v.y) * cos(v.x),
		cos(v.y),
		sin(v.y) * sin(v.x)
	);
}

inline float VertexWaveMask(float3 pos, float3 dir_mask, float4 sphere_mask, float scale, out float dir_pos, float offset = 0, float2 smooth_step = float2(0,1))
{
	float vw_mask = dot(normalize(dir_mask.xyz), pos);
	float vw_scale = 1.0 / scale;
	dir_pos = vw_mask;
	
	vw_mask = ((vw_mask + 0.5 + offset) * vw_scale) + (1.0 - vw_scale * 0.5) - 0.5;
	// vw_mask = saturate(vw_mask) * step(vw_mask, 1);
	vw_mask = smoothstep(smooth_step.x, smooth_step.y, vw_mask);

	float sph_mask = distance(pos, sphere_mask.xyz) - sphere_mask.w;
	sph_mask = Smootherstep(0.5, 0.66, saturate(sph_mask * sph_mask));
	vw_mask = sphere_mask.w == 0 ? vw_mask : Blend_Darken(vw_mask, (1.0 - sph_mask));
	
	return vw_mask;
}

// Simplified Blinn-Phong, limited to just the highlight itself, no Lambert/Fresnel term
inline float SpecularHighlight(float3 lightDir, float3 normal, float3 viewDir, float power = 16, float intensity = 1)
{
	float3 halfDir = normalize(lightDir + viewDir);
	float term = dot(normal, halfDir);
	float spec = pow(max(term, 0.0), power) * intensity;
	return spec;
}

float sdf_box_round(float3 pos, float3 size, float radius)
{
	float3 q = abs(pos) - size + radius;

	float outside = length(max(q,0.0));
	float inside = min(max(q.x,max(q.y,q.z)),0.0);
	
	return outside + inside - radius;
}


#endif // GT_UBER_FUNCS_INCLUDE