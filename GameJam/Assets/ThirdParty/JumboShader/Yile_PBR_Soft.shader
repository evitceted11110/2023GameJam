Shader "Yile/Model/Lit/PBR_Soft"
{
	Properties
	{
		_Color("Tint", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		[Toggle]_UseCutoff("Use Cutoff", Float) = 1

		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BumpScale("Normal Intensity", Range( -2 , 2)) = 1
		_BumpMap("Normal", 2D) = "bump" {}

		[Header(Rim Setting)]
		[Toggle]_UseRim("Use Rim", Float) = 1
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimSize("Rim Size", Range( -8 , 1.5)) = -3

		[Header(R_Specular G_Gloss B_EmissionMask)]
		_PBRTex("PBRTex", 2D) = "white" {}

		[Header(Specular Setting)]
		_SpecularStrength("SpecularStrength", Range( 0.01 , 1)) = 0.5
		_SpecColor("Specular Color",Color)=(1,1,1,1)

		[Header(Gloss Setting)]
		_GlossStrength("GlossStrength", Range( 0.01 , 1)) = 0.5

		[Header(Emission Setting)]
		_EmissionColor("EmissionColor", Color) = (1,1,1,1)
		_EmissionTex("EmissionTex", 2D) = "white" {}
		_EmissionStrength("EmissionStrength", Range( 0 , 5)) = 0.5

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
		uniform float _SpecularStrength;
		uniform float _GlossStrength;
		uniform float _UseCutoff;

		uniform float _Cutoff = 0.5;
		uniform sampler2D _EmissionTex;
		uniform float4 _EmissionTex_ST;
		uniform float4 _EmissionColor;
		uniform float _EmissionStrength;

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float3 normalLerp = lerp( float3(0,0,1) , UnpackNormal( tex2D( _BumpMap, uv_BumpMap ) ) , _BumpScale);
			o.Normal = normalLerp;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode16 = tex2D( _MainTex, uv_MainTex );
			o.Albedo = ( _Color * tex2DNode16 ).rgb;
			float4 temp_cast_1 = (0.0).xxxx;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV23 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode23 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV23, ( 1.0 - _RimSize ) ) );


			//PBR UV
			float2 uv_PBRTex = i.uv_texcoord * _PBRTex_ST.xy + _PBRTex_ST.zw;

			//PBR 圖片
			float4 PBRCol = tex2D( _PBRTex, uv_PBRTex );

			//R通道給Specular
			o.Specular = _SpecularStrength*PBRCol.r;

			//G通道給_Gloss
			o.Gloss = _GlossStrength*PBRCol.g;

			//Emission UV
			float2 uv_EmissionTex = i.uv_texcoord * _EmissionTex_ST.xy + _EmissionTex_ST.zw;

			float4 emissionTex = tex2D( _EmissionTex, uv_EmissionTex )*_EmissionColor * _EmissionStrength;

			//B通道給EmissionMask
			float emissionMask = PBRCol.b;

			emissionTex *= emissionMask;

			o.Emission = lerp(temp_cast_1,( fresnelNode23 * _RimColor ),_UseRim).rgb + emissionTex;


			o.Alpha = _Color.a * tex2DNode16.a;
			clip( tex2DNode16.a - (_Cutoff * _UseCutoff) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf BlinnPhong keepalpha fullforwardshadows 

		ENDCG
		//Pass
		//{
		//	Name "ShadowCaster"
		//	Tags{ "LightMode" = "ShadowCaster" }
		//	ZWrite On
		//	CGPROGRAM
		//	#pragma vertex vert
		//	#pragma fragment frag
		//	#pragma target 2.0
		//	#pragma multi_compile_shadowcaster
		//	#pragma multi_compile UNITY_PASS_SHADOWCASTER
		//	#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
		//	#include "HLSLSupport.cginc"
		//	#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
		//		#define CAN_SKIP_VPOS
		//	#endif
		//	#include "UnityCG.cginc"
		//	#include "Lighting.cginc"
		//	#include "UnityPBSLighting.cginc"
		//	struct v2f
		//	{
		//		V2F_SHADOW_CASTER;
		//		float2 customPack1 : TEXCOORD1;
		//		float4 tSpace0 : TEXCOORD2;
		//		float4 tSpace1 : TEXCOORD3;
		//		float4 tSpace2 : TEXCOORD4;
		//		UNITY_VERTEX_INPUT_INSTANCE_ID
		//	};
		//	v2f vert( appdata_full v )
		//	{
		//		v2f o;
		//		UNITY_SETUP_INSTANCE_ID( v );
		//		UNITY_INITIALIZE_OUTPUT( v2f, o );
		//		UNITY_TRANSFER_INSTANCE_ID( v, o );
		//		Input customInputData;
		//		float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
		//		half3 worldNormal = UnityObjectToWorldNormal( v.normal );
		//		half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
		//		half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
		//		half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
		//		o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
		//		o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
		//		o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
		//		o.customPack1.xy = customInputData.uv_texcoord;
		//		o.customPack1.xy = v.texcoord;
		//		TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
		//		return o;
		//	}
		//	half4 frag( v2f IN
		//	#if !defined( CAN_SKIP_VPOS )
		//	, UNITY_VPOS_TYPE vpos : VPOS
		//	#endif
		//	) : SV_Target
		//	{
		//		UNITY_SETUP_INSTANCE_ID( IN );
		//		Input surfIN;
		//		UNITY_INITIALIZE_OUTPUT( Input, surfIN );
		//		surfIN.uv_texcoord = IN.customPack1.xy;
		//		float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
		//		half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
		//		surfIN.worldPos = worldPos;
		//		surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
		//		surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
		//		surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
		//		surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
		//		SurfaceOutput o;
		//		UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
		//		surf( surfIN, o );
		//		#if defined( CAN_SKIP_VPOS )
		//		float2 vpos = IN.pos;
		//		#endif
		//		SHADOW_CASTER_FRAGMENT( IN )
		//	}
		//	ENDCG
		//}
	}
	Fallback "Diffuse"
}