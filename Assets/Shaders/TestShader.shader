Shader "Custom/TestShader"
{
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1) //阴影投bug
		_MainTex ("Main Tex", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
	}
	SubShader {
        Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
 
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Off

            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            //Diffuse
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Cutoff;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD0;
                float3 nDirWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert (a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                //准备向量
                float3 nDirWS = normalize(i.nDirWS);
                float3 lDirWS = normalize(UnityWorldSpaceLightDir(i.posWS));

                float4 texCol = tex2D(_MainTex, i.uv);
                clip(texCol.a - _Cutoff);

                //计算光照
                float3 albedo = texCol.rgb * _Color.rgb;
                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(lDirWS, nDirWS));
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //UNITY_LIGHT_ATTENUATION(atten, i, i.posWS);
                return fixed4(ambient + diffuse * 1.0, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Transparent/Cutout/VertexLit"
}

// {
//     Properties {
//             _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
//         [Header(Diffuse)][Space(5)]
//             _MainTex     ("基础纹理", 2D)             = "white" {}
//             _DiffCol     ("漫反颜色", Color)          = (1, 1, 1, 1)
//     }

//     SubShader
//     {
//         Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
//         /**
//          * Base Pass
//          */
//         Pass
//         {
//             Tags { "LightMode" = "ForwardBase" }

//             Cull Off

//             CGPROGRAM
//             #pragma multi_compile_fwdbase
//             #pragma vertex vert
//             #pragma fragment frag
//             #include "Lighting.cginc"
//             #include "AutoLight.cginc"
            
//             //Diffuse
//             sampler2D _MainTex;
//             float4 _MainTex_ST;
//             float4 _DiffCol;
//             float _Cutoff;

//             struct a2v {
//                 float4 vertex : POSITION;
//                 float3 normal : NORMAL;
//                 float4 texcoord : TEXCOORD0;
//             };

//             struct v2f {
//                 float4 pos : SV_POSITION;
//                 float3 posWS : TEXCOORD0;
//                 float3 nDirWS : TEXCOORD1;
//                 float2 uv : TEXCOORD2;
//                 SHADOW_COORDS(3)
//             };

//             v2f vert (a2v v) {
//                 v2f o;
//                 o.pos = UnityObjectToClipPos(v.vertex);
//                 o.posWS = mul(unity_ObjectToWorld, v.vertex);
//                 o.nDirWS = UnityObjectToWorldNormal(v.normal);
//                 o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
//                 TRANSFER_SHADOW(o);
//                 return o;
//             }

//             fixed4 frag (v2f i) : SV_Target {
//                 //准备向量
//                 float3 nDirWS = normalize(i.nDirWS);
//                 float3 lDirWS = normalize(UnityWorldSpaceLightDir(i.posWS));

//                 float4 texCol = tex2D(_MainTex, i.uv);
//                 clip(texCol.a - _Cutoff);

//                 //计算光照
//                 float3 albedo = texCol.rgb * _DiffCol.rgb;
//                 float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(lDirWS, nDirWS));
//                 float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
//                 UNITY_LIGHT_ATTENUATION(atten, i, i.posWS);
//                 return fixed4(ambient + diffuse * atten, 1.0);
//             }
//             ENDCG
//         }
//     }
//     FallBack "Transparent/Cutout/VertexLit"
// }
// {  
//     Properties {
//         _MainTex ("Main Tex", 2D) = "white" {}
//         _Color ("Main Tint", Color) = (1,1,1,1)
//         _AlphaScale ("Alpha Scale", Range(0, 1.0)) = 1
//     }
//     SubShader {
//         Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
//         Pass {
//             Tags { "LightMode" = "ForwardBase" }

//             Cull Front
//             ZWrite Off
//             Blend SrcAlpha OneMinusSrcAlpha
            
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
//             #include "Lighting.cginc"

//             float3 _Color;
//             sampler2D _MainTex; float4 _MainTex_ST;
//             float _AlphaScale;

//             struct a2v {
//                 float4 vertex : POSITION;
//                 float3 normal : NORMAL;
//                 float4 texcoord : TEXCOORD0;
//             };

//             struct v2f {
//                 float4 posCS : SV_POSITION;
//                 float3 posWS : TEXCOORD0;
//                 float2 uv : TEXCOORD1;
//                 float3 nDirWS : TEXCOORD2;
//             };

//             v2f vert (a2v v) {
//                 v2f o;
//                 o.posCS = UnityObjectToClipPos(v.vertex);
//                 o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
//                 o.posWS = mul(unity_ObjectToWorld, v.vertex);
//                 o.nDirWS = UnityObjectToWorldNormal(v.normal);
//                 return o;
//             }

//             fixed4 frag (v2f i) : SV_Target {
//                 float3 nDirWS = normalize(i.nDirWS);
//                 float3 lDirWS = normalize(UnityWorldSpaceLightDir(i.posWS));
//                 float4 texCol = tex2D(_MainTex,  i.uv);
//                 float3 albedo = texCol.rgb * _Color.rgb;
//                 float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(lDirWS, nDirWS));
//                 float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
//                 return fixed4(ambient + diffuse, texCol.a * _AlphaScale);
//             }

//             ENDCG
//         }
//         Pass {
//             Tags { "LightMode" = "ForwardBase" }

//             Cull Back
//             ZWrite Off
//             Blend SrcAlpha OneMinusSrcAlpha
            
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
//             #include "Lighting.cginc"

//             float3 _Color;
//             sampler2D _MainTex; float4 _MainTex_ST;
//             float _AlphaScale;

//             struct a2v {
//                 float4 vertex : POSITION;
//                 float3 normal : NORMAL;
//                 float4 texcoord : TEXCOORD0;
//             };

//             struct v2f {
//                 float4 posCS : SV_POSITION;
//                 float3 posWS : TEXCOORD0;
//                 float2 uv : TEXCOORD1;
//                 float3 nDirWS : TEXCOORD2;
//             };

//             v2f vert (a2v v) {
//                 v2f o;
//                 o.posCS = UnityObjectToClipPos(v.vertex);
//                 o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
//                 o.posWS = mul(unity_ObjectToWorld, v.vertex);
//                 o.nDirWS = UnityObjectToWorldNormal(v.normal);
//                 return o;
//             }

//             fixed4 frag (v2f i) : SV_Target {
//                 float3 nDirWS = normalize(i.nDirWS);
//                 float3 lDirWS = normalize(UnityWorldSpaceLightDir(i.posWS));
//                 float4 texCol = tex2D(_MainTex,  i.uv);
//                 float3 albedo = texCol.rgb * _Color.rgb;
//                 float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(lDirWS, nDirWS));
//                 float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
//                 return fixed4(ambient + diffuse, texCol.a * _AlphaScale);
//             }
            
//             ENDCG
//         }
//     }
//     Fallback "Transparent/VertexLit"
// }
// {
//     Properties {
//         [Header(Diffuse)][Space(5)]
//             _MainTex     ("基础纹理", 2D)             = "white" {}
//             _DiffCol     ("漫反颜色", Color)          = (1.0, 1.0, 1.0, 1.0)
//         [Header(Normal)][Space(5)]
//             _NormTex     ("法线贴图", 2D)             = "bump" {}
//             _NormScale   ("凹凸程度", Range(-1, 1))   = 1.0
//         [Header(Specular)][Space(5)]
//             _SpecMaskTex ("高光遮罩", 2D)             = "white" {}
//             _SpecCol     ("高光颜色", Color)          = (1.0, 1.0, 1.0, 1.0)
//             _SpecPow     ("高光次幂", Range(10, 100)) = 20
//             _SpecScale   ("高光强度", Range(1, 10))   = 1.0
//     }
//     SubShader
//     {
//         Pass
//         {
//             Tags { "LightMode" = "ForwardBase" }

//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
//             #include "Lighting.cginc"

//             //Diffuse
//             sampler2D _MainTex; float4 _MainTex_ST;
//             float4 _DiffCol;
//             //Normal
//             sampler2D _NormTex;
//             float _NormScale;
//             //Specular
//             sampler2D _SpecMaskTex;
//             float4 _SpecCol;
//             float _SpecPow;
//             float _SpecScale;

//             struct a2v {
//                 float4 vertex : POSITION;
//                 float3 normal : NORMAL;
//                 float4 tangent : TANGENT;
//                 float4 texcoord : TEXCOORD0;
//             };

//             struct v2f {
//                 float4 posCS : SV_POSITION;
//                 float3 posWS : TEXCOORD0;
//                 float2 uv : TEXCOORD1;
//                 float3 nDirWS : TEXCOORD2;
//                 float3 tDirWS : TEXCOORD3;
//                 float3 bDirWS : TEXCOORD4;
//             };

//             v2f vert (a2v v) {
//                 v2f o;
//                 o.posCS = UnityObjectToClipPos(v.vertex);
//                 o.posWS = mul(unity_ObjectToWorld, v.vertex);
//                 o.nDirWS = UnityObjectToWorldNormal(v.normal);
//                 o.tDirWS = UnityObjectToWorldDir(v.tangent.xyz);
//                 o.bDirWS = cross(o.nDirWS, o.tDirWS) * v.tangent.w;
//                 o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
//                 return o;
//             }

//             fixed4 frag (v2f i) : SV_Target {
//                 //准备向量
//                 float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
//                 float3 nDirTS = UnpackNormal(tex2D(_NormTex, i.uv)).rgb;
//                 nDirTS.xy *= _NormScale;
//                 nDirTS.z = sqrt(1.0 - saturate(dot(nDirTS.xy, nDirTS.xy)));
//                 float3 nDirWS = normalize(mul(nDirTS, TBN));
//                 float3 lDirWS = normalize(UnityWorldSpaceLightDir(i.posWS));
//                 float3 vDirWS = normalize(UnityWorldSpaceViewDir(i.posWS));
//                 float3 hDirWS = normalize(lDirWS + vDirWS);
                
//                 //计算光照
//                 float3 albedo = tex2D(_MainTex,  i.uv).rgb;
//                 float3 diffuse = _LightColor0.rgb * albedo * _DiffCol.rgb * max(0, dot(lDirWS, nDirWS));
//                 float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
//                 float specScale = tex2D(_SpecMaskTex, i.uv).r * _SpecScale;
//                 float3 specular = _LightColor0.rgb * _SpecCol.rgb * pow(max(0, dot(nDirWS, hDirWS)), _SpecPow) * specScale;
                
//                 //返回结果
//                 return fixed4(diffuse + specular, 1.0);
//             }
//             ENDCG
//         }
//     }
//     Fallback "Specular"
// }