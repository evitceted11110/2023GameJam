Shader "Jumbo/Effect/ScaledRadialBlur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Samples("Samples", Range(1, 32)) = 16
		_NoiseTex("Texture",2D) = "white"{}
		_NoiseStrength("Noise Strength",Range(0,1)) = 0.5
		_NoiseSpeed("Noise Speed",Vector) = (0,1,0,0)
		_Scale("Scale Size", Range(1, 30)) = 1
		_EffectAmount("Effect amount", Range(0, 2)) = 1
		_AdditionalColor("AdditionalColor", Color) = (1,1,1,1)
		_Brightness("Brightness",Range(0,1)) = 0
		_Transparency("Transparency",Range(0,1)) = 0
		_Radius("Radius", Range(0,1.5)) = 0.1
	}
		SubShader
		{
			Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				float _Scale;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex*_Scale);
					o.uv = v.uv;
					return o;
				}

				sampler2D _MainTex;
				sampler2D _NoiseTex;
				float _Samples;
				float _EffectAmount;
				float _Radius;
				float _Brightness;
				float _Transparency;
				float _NoiseStrength;
				fixed4 _AdditionalColor;
				float4 _NoiseSpeed;

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = fixed4(0, 0, 0, 0);
					float2 dist = i.uv - float2(.5, .5);
					for (int x = 0; x < _Samples; x++) {
						float sampleScale = 1 - _EffectAmount * (x / _Samples)* (saturate(length(dist) / _Radius));
						float2 sampleScaleUV = dist * sampleScale * _Scale;

						fixed4 effect = tex2D(_MainTex, dist * sampleScale* _Scale + float2(.5, .5));
						fixed4 noise = tex2D(_NoiseTex, dist * sampleScale*_Scale + (_NoiseSpeed.xy*_Time.x));
						fixed4 extraColor = _AdditionalColor * (1 + _Brightness + (noise.r *(_NoiseStrength)));

						effect *= fixed4(extraColor.r, extraColor.g, extraColor.b, 1);
						effect.a *= (1 - _Transparency);
						col += effect;
				}
				col /= _Samples;
				return col;
			}
			ENDCG
		}
		}
}