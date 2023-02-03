Shader "Jumbo/Effect/WaterDistortionWithLight"
{
	Properties
	{
		_MainTex("MainTexture", 2D) = "white" {}
		_DistortTex("Distort Texture", 2D) = "white" {}
		_DistortAmount("DistortAmount", Range(0,1)) = 1
		_XDistort("X Distort", Range(-1,1)) = 1
		_YDistort("Y Distort", Range(-1,1)) = 1
		_Speed("Speed", Range(0,500)) = 1
		_LightTex("Light Texture", 2D) = "white" {}
		_LightScroll("Lisht Scroll (xy/xy)",vector) = (0,0,0,0)
		_LightAmount("LightAmount", Range(0,1)) = 1
		[MaterialToggle] USECURVE("Use Curve", Float) = 0
		[MaterialToggle] USELIGHT("Use Light", Float) = 0
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
	#pragma multi_compile _ USELIGHT_ON
	#pragma multi_compile _ USECURVE_ON

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

		sampler2D _MainTex, _DistortTex, _LightTex;
		float4 _MainTex_ST, _DistortTex_ST, _LightTex_ST;
		float  _Speed, _XDistort, _YDistort;
		float4 _LightScroll;
		float _LightAmount;
		float _DistortAmount;
		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			o.uv2 = TRANSFORM_TEX(v.uv, _DistortTex);
			return o;
		}

		float2 GetWaveUV(float2 uv, float2 scroll) {
#ifdef USECURVE_ON
			return uv + float2(sin(_Time.x*scroll.x), sin(_Time.x*scroll.y));
#endif
			return uv + float2((_Time.x*scroll.x), (_Time.x*scroll.y));

		}

		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 maintex = tex2D(_MainTex, i.uv); // first texture
			fixed distort = tex2D(_DistortTex, i.uv2 - (_Time.x*_Speed*float2(_XDistort, _YDistort))).r;// distortion
			fixed4 distortTex = tex2D(_MainTex, i.uv2 + (_DistortAmount*(distort * float2(_XDistort, _YDistort))));//distortion Ttxture
			maintex = distortTex;

#ifdef USELIGHT_ON
			//maintex += maintex * lerp(0.3,0.5, distort)  * 0.2;
			fixed4 firstLight = tex2D(_LightTex, GetWaveUV(i.uv - float2(0.5, 0.5), _LightScroll.xy));
			fixed4 secondLight = tex2D(_LightTex, GetWaveUV(i.uv, _LightScroll.zw));
			fixed4 finalLight = pow(firstLight, 2) * pow(secondLight, 2);

			finalLight *= _LightAmount;
			maintex += finalLight;
#endif

			return maintex;
		}
			ENDCG
		}
		}
}