Shader "Jumbo/Effect/SimpleDistortion"
{
	Properties
	{
		_MainTex("MainTexture", 2D) = "white" {}
		_DistortTex("Distort Texture", 2D) = "white" {}
		_XDistort("X Distort", Range(-1,1)) = 1
		_YDistort("Y Distort", Range(-1,1)) = 1
		_Speed("Speed", Range(0,500)) = 1
		[MaterialToggle] USEMAIN("Use MainTex", Float) = 0
	}
		SubShader
		{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }

			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha // additive blending

			Pass
		{
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#pragma multi_compile _ DISTORTMAIN_ON
	#pragma multi_compile _ USEMAIN_ON

	#include "UnityCG.cginc"

			struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD1;
			float2 uv2 : TEXCOORD2;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex, _DistortTex;
		float4 _MainTex_ST, _DistortTex_ST;
		float  _Speed, _XDistort, _YDistort;
		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			o.uv2 = TRANSFORM_TEX(v.uv, _DistortTex);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 maintex = tex2D(_MainTex, i.uv); // first texture
			fixed distort = tex2D(_DistortTex, i.uv2 - (_Time.x*_Speed*float2(_XDistort, _YDistort))).r;// distortion
			fixed4 distortTex = tex2D(_MainTex, i.uv2 + (distort * float2(_XDistort, _YDistort)));//distortion Ttxture
#ifdef USEMAIN_ON
			maintex *= distortTex;
#else
			maintex = distortTex;
#endif
			return maintex;
		}
			ENDCG
		}
		}
}