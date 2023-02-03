Shader "Yile/Model/Lit/MatCap_PBR"
{
	Properties
	{
		_Color("Tint", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		[Toggle]_UseCutoff("Use Cutoff", Float) = 1

		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BumpScale("Normal Intensity", Range( 0 , 5)) = 1
		_BumpMap("Normal", 2D) = "bump" {}

		[Header(Rim Setting)]
		[Toggle]_UseRim("Use Rim", Float) = 1
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimSize("Rim Size", Range( -8 , 1.5)) = -3

		[Header(R_Specular G_Gloss B_EmissionMask)]
		_PBRTex("PBRTex", 2D) = "white" {}

		[Header(Emission Setting)]
		_EmissionColor("EmissionColor", Color) = (1,1,1,1)
		_EmissionTex("EmissionTex", 2D) = "white" {}
		_EmissionStrength("EmissionStrength", Range( 0 , 5)) = 0.5


		[Header(Matcap Setting)]
		_MatCap("MatCap", 2D) = "white" {}
		_MatCapColor("MatCapColor", Color) = (1,1,1,1)

		_MatCapStrength("MatCap Strength", Range(0.0, 1.0)) = 0.5


		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ 
			"RenderType" = "TransparentCutout"  
			"Queue" = "Transparent+0" 
			"IgnoreProjector" = "True" 
			"IsEmissive" = "true"  
			"Shadowable" = "True"
		}
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 2.0

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif

		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			float4 screenPos;
			INTERNAL_DATA
		};

		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform sampler2D _PBRTex;
		uniform float4 _PBRTex_ST;
		uniform float _BumpScale;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _UseRim;
		uniform float _RimSize;
		uniform float4 _RimColor;
		uniform float _UseCutoff;

		uniform float _Cutoff = 0.5;
		uniform sampler2D _EmissionTex;
		uniform float4 _EmissionTex_ST;
		uniform float4 _EmissionColor;
		uniform float _EmissionStrength;

		sampler2D _MatCap;
		float _MatCapStrength;
		fixed4 _MatCapColor;

		void surf( Input i , inout SurfaceOutput o )
		{
			//MainTexture
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 col = tex2D( _MainTex, uv_MainTex );

			//PBR
			float2 uv_PBRTex = i.uv_texcoord * _PBRTex_ST.xy + _PBRTex_ST.zw;
			float4 PBRCol = tex2D( _PBRTex, uv_PBRTex );

			//Normal
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float3 normal = float3(0,0,0);
			normal.xy = tex2D(_BumpMap, uv_BumpMap).wy  * 2 - 1;
			normal.xy *= _BumpScale;
			normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
			normal = normal.xzy;
			normal = normalize(normal);

			

			//======================MapCap Variable========================
			//漫反射UV坐标准备：存储于TEXCOORD1的前两个坐标xy。
			float4 diffuseUVAndMatCapCoords = float4(0,0,0,0);
			diffuseUVAndMatCapCoords.xy = TRANSFORM_TEX(i.uv_texcoord, _MainTex);

			//MatCap坐标准备：将法线从模型空间转换到观察空间，存储于TEXCOORD1的后两个纹理坐标zw
			diffuseUVAndMatCapCoords.z = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(o.Normal));
			diffuseUVAndMatCapCoords.w = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(o.Normal));

			//归一化的法线值区间[-1,1]转换到适用于纹理的区间[0,1]
			diffuseUVAndMatCapCoords.zw = diffuseUVAndMatCapCoords.zw * 0.5 + 0.5;
			//座標轉換
			float4 position = UnityObjectToClipPos(i.worldPos);

			//世界空间位置
			float3 worldSpacePosition = mul(unity_ObjectToWorld, position).xyz;
			//世界空间法线
			float3 worldSpaceNormal = normalize(mul((float3x3)unity_ObjectToWorld, o.Normal));
			//世界空间反射向量
			float3 worldSpaceReflectionVector = reflect(worldSpacePosition - _WorldSpaceCameraPos.xyz, worldSpaceNormal);


			//=======================Color==============================
			//漫反射颜色
			float4 diffuseColor = tex2D(_MainTex, diffuseUVAndMatCapCoords.xy)*_Color;
			//主颜色
			float3 mainColor = lerp(_Color.rgb, diffuseColor.rgb, diffuseColor.a);
			//从提供的MatCap纹理中，提取出对应光照信息
			float3 matCapColor = tex2D(_MatCap, diffuseUVAndMatCapCoords.zw).rgb * _MatCapStrength * PBRCol.g;

			float4 finalColor = float4(mainColor*2.0*matCapColor,_Color.a);
			o.Albedo = matCapColor*col;


			float4 temp_cast_1 = (0.0).xxxx;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotRim = dot( o.Normal, ase_worldViewDir );
			float rimValue = ( 0.0 + 1.0 * pow( 1.0 - dotRim, (0- _RimSize ) ) );

			//Emission UV
			float2 uv_EmissionTex = i.uv_texcoord * _EmissionTex_ST.xy + _EmissionTex_ST.zw;
			//B通道給EmissionMask
			float4 emissionTex = tex2D( _EmissionTex, uv_EmissionTex )*_EmissionColor * _EmissionStrength*PBRCol.b;
			emissionTex.rgb += normal.r*normal.b;

			o.Emission = lerp(temp_cast_1,( rimValue * _RimColor ),_UseRim).rgb + emissionTex;
			
			o.Alpha = _Color.a * col.a;
			clip( col.a - (_Cutoff * _UseCutoff) );
		}

		ENDCG
		CGPROGRAM

		#pragma surface surf NoLight keepalpha fullforwardshadows 

		inline fixed4 LightingNoLight(SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
		{

			fixed4 c;
			c.rgb = s.Albedo;
			c.a = s.Alpha;
			return c;
		}

		ENDCG
		
	}
	Fallback "Diffuse"
}