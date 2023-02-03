Shader "Yile/Effect/Flame"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color",COLOR) = (1,1,1,1)
		_ColorStrength("主色調強度(1.5)",Range(0,2)) = 1.5
		_Speed("速度",float) = 1
		_NoiseStrength("雜訊強度",float)=1
		_FlameY("Y軸位移",float) = 0
		_FlameHeight("高度偏移 (4)",float) = 4
		_FlameWidth("火焰寬度 (.25)",float) = .25
		[Header(DefaultColor Red)]
		[MaterialToggle]EXGREEN("主色調 綠",float) = 0
		[MaterialToggle]EXBLUE("主色調 藍",float) = 0
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		LOD 100
		Blend SrcAlpha One
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma multi_compile _ EXRED_ON
			#pragma multi_compile _ EXGREEN_ON
			#pragma multi_compile _ EXBLUE_ON
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _ColorStrength,_Speed,_NoiseStrength, _FlameY, _FlameHeight, _FlameWidth;
			fixed4 _Color;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			

			float2 hash(float2 p)
			{
				p = float2(dot(p, float2(127.1, 311.7)),
					dot(p, float2(269.5, 183.3)));
				return -1.0 + 2.0*frac(sin(p)*43758.5453123);
			}

			float noise(float2 p)
			{
				const float K1 = 0.366025404; // (sqrt(3)-1)/2;
				const float K2 = 0.211324865; // (3-sqrt(3))/6;

				float2 i = floor(p + (p.x + p.y)*K1);

				float2 a = p - i + (i.x + i.y)*K2;
				float2 o = (a.x > a.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
				float2 b = a - o + K2;
				float2 c = a - 1.0 + 2.0*K2;

				float3 h = max(0.5 - float3(dot(a, a), dot(b, b), dot(c, c)), 0.0);

				float3 n = h * h*h*h*float3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));

				return dot(n, 70.0);
			}

			float fbm(float2 uv)
			{
				float f;
				fixed4 m = fixed4(1.6, 1.2, -1.2, 1.6);
				f = 0.5000*noise(uv); uv = m * uv;
				f += 0.2500*noise(uv); uv = m * uv;
				f += 0.1250*noise(uv); uv = m * uv;
				f += 0.0625*noise(uv); uv = m * uv;
				f = 0.5 + 0.5*f;
				return f;
			}

			fixed4 mainImage(float2 fragCoord)
			{
				float2 uv = fragCoord.xy ;
				float2 q = uv;

				float strength = floor(q.x + 1.)*_NoiseStrength;
				float T3 = max(3., 1.25*strength)*_Time.y*_Speed;
				q.x = fmod(q.x, 1.) - 0.5;
				q.y -= _FlameY;
				float n = fbm(strength*q - float2(0, T3));
				float c = 1. - 16. * pow(max(0., length(q*float2(1.8 + q.y*_FlameHeight, .75)) - n * max(0., q.y + _FlameWidth)), 1.2);
				float c1 = n * c * (1.5-pow(uv.y, 4.));

				c1 = clamp(c1, 0., 1.);

				fixed4 col = fixed4(_ColorStrength*c1, _ColorStrength*c1*c1*c1, c1*c1*c1*c1*c1*c1, 0);

#ifdef EXGREEN_ON
				fixed4 tempCol = col;
				col.r = tempCol.g;
				col.g = tempCol.r;
#endif
#ifdef EXBLUE_ON
				fixed4 tempCol = col;
				col.b = tempCol.r;
				col.r = tempCol.b;
#endif
				float a = c * (1. - pow(uv.y, 3.));
				col.rgb = lerp(fixed3(0, 0, 0), col.rgb, a)*_Color;
				col.a = a;

				return  col;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 flame = mainImage(i.uv + float2(0,-.5));
				return flame;
			}
			ENDCG
		}
	}
}
