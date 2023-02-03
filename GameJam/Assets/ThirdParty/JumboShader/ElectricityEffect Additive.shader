Shader "Yile/Effect/ElectricityEffect Additive"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TintColor("Color",Color) = (1,1,1,1)
		_ElectricitySpeed("電流速度(x/y)",vector) = (0,0,0,0)
		_NoiseSpeed("雜訊速度(x/y)",vector) = (0,0,0,0)
		_ElectricityScale("電流規模",float) = 1
		_ElectricityThickness("線條寬度",Range(-1,1)) = 1
		_ElectricityAmount("電流數量",Range(1,50)) = 1
		_MaskSize("遮罩範圍",Range(0,2)) = 1
		_MaskFade("遮罩淡出",Range(0,2)) = 1
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		LOD 100
		Blend SrcAlpha One
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
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			inline float unity_noise_randomValue(float2 uv)
			{
				return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
			}

			inline float unity_noise_interpolate(float a, float b, float t)
			{
				return (1.0 - t)*a + (t*b);
			}

			inline float unity_valueNoise(float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac(uv);
				f = f * f * (3.0 - 2.0 * f);

				uv = abs(frac(uv) - 0.5);
				float2 c0 = i + float2(0.0, 0.0);
				float2 c1 = i + float2(1.0, 0.0);
				float2 c2 = i + float2(0.0, 1.0);
				float2 c3 = i + float2(1.0, 1.0);
				float r0 = unity_noise_randomValue(c0);
				float r1 = unity_noise_randomValue(c1);
				float r2 = unity_noise_randomValue(c2);
				float r3 = unity_noise_randomValue(c3);

				float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
				float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
				float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
				return t;
			}

			float Unity_SimpleNoise_float(float2 UV, float Scale)
			{
				float t = 0.0;

				float freq = pow(2.0, float(0));
				float amp = pow(0.5, float(3 - 0));
				t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3 - 1));
				t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3 - 2));
				t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

				return t;
			}

			float Unity_Remap_float4(float In, float2 InMinMax, float2 OutMinMax)
			{
				return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}

			float Unity_Rectangle_float(float2 UV, float Width, float Height)
			{
				float2 d = abs(UV * 2 - 1) - float2(Width, Height);
				d = 1 - d / fwidth(d);
				return saturate(min(d.x, d.y));
			}


			float2 Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale)
			{
				float2 delta = UV - Center;
				float radius = length(delta) * 2 * RadialScale;
				float angle = atan2(delta.x, delta.y) * 1.0 / 6.28 * LengthScale;
				return float2(radius, angle);
			}

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _ElectricityScale;
			float _ElectricityThickness;
			float4 _ElectricitySpeed, _NoiseSpeed;
			float _ElectricityAmount;
			fixed4 _TintColor;
			float _MaskSize;
			float _MaskFade;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				//First Noise
				float2 uv1 = i.uv + _ElectricitySpeed.xy * _Time.y;
				float n1 = Unity_SimpleNoise_float(uv1, _ElectricityScale);

				//Second Noise
				float2 uv2 = i.uv + _NoiseSpeed.xy * _Time.y;
				float n2 = Unity_SimpleNoise_float(uv2, _ElectricityScale);

				//Mask
				float2 polarUV = Unity_PolarCoordinates_float(i.uv, float2(0.5, 0.5), _MaskSize, 1);
				float mask = clamp(1- pow(polarUV.x, _MaskFade),0,1);

				float finalNoise = pow((n1 + n2), _ElectricityAmount);
				finalNoise = Unity_Remap_float4(finalNoise, float2(0, 1), float2(-10, 10));
				finalNoise = Unity_Rectangle_float(finalNoise, 1, _ElectricityThickness);

				finalNoise *= mask;


				fixed4 result = i.color * finalNoise*_TintColor;

				col.rgb = result.rgb;
				col.a *= result.a*_TintColor.a;
				return col;
			}
			ENDCG
		}
	}
}
