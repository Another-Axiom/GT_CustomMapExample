Shader "GorillaTag/WindTunnelRibbons" {
    Properties {
        _WindColor ("WindColor", Color) = (0.5778747,0.7084448,0.8113208,1)
    }

    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    ENDHLSL



    SubShader {

        Pass {
            Name "Unlit"
            Tags {
                "RenderPipeline"="UniversalPipeline"
            }

            Tags {
                "LightMode" = "UniversalForward"
            }
            Cull Off
            CGPROGRAM
            #include "UnityShaderVariables.cginc"

 		#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
                //only defining to not throw compilation error over Unity 5.5
                #define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
        #endif

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            // Instancing pragmas
            #pragma multi_compile_instancing
            #pragma instancing_options nolodfade
            #pragma instancing_options nolightprobe
            #pragma instancing_options nolightmap


            // Includes
            #include "UnityCG.cginc"

            // Shader Feature Keywords
            #pragma shader_feature_local _ _VERTEX_COLOR__ON

            float4 _WindColor;

            struct appdata {
                float4 vertex : POSITION;
                //#if _VERTEX_COLOR__ON
                float4 color : COLOR;
                //#endif
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                //#if _VERTEX_COLOR__ON
                float4 color : COLOR;
                //#endif
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.uv = v.uv;
                float3 ase_vertex3Pos = v.vertex.xyz;
                float clampResult53 = clamp(
                    (0.0 + (fmod((_Time.y + v.uv.xy.x), 2.0) - 0.3) * (1.0 - 0.0) / (0.4 - 0.3)), 0.7, 1.0);
                float3 lerpResult5 = lerp(ase_vertex3Pos, (v.color).rgb, clampResult53);
                float mulTime52 = _Time.y * -1.0;
                float cos67 = cos(mulTime52);
                float sin67 = sin(mulTime52);
                float2 rotator67 = mul((lerpResult5).xz - float2(0, 0), float2x2(cos67, -sin67, sin67, cos67)) +
                float2(0, 0);
                float2 break71 = rotator67;
                float3 appendResult70 = (float3(break71.x, lerpResult5.y, break71.y));

                v.vertex.xyz = appendResult70;
                v.vertex.w = 1;


                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;

                // Compute fog amount from clip space position.
                UNITY_TRANSFER_FOG(o, o.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                // Handle instancing data transfer.
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                const float emissiveAmount = 0; //UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _EmissiveAmount);
                float4 color49 = IsGammaSpace()
                                     ? float4(0.5778747, 0.7084448, 0.8113208, 1)
                                     : float4(0.2933302, 0.4601087, 0.6231937, 1);
                fixed4 finalColor = _WindColor; //color49;//float4(texColor + emissiveColor, 1.0);
                UNITY_APPLY_FOG(i.fogCoord, finalColor);

                return finalColor;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}