/*
水波紋擾動 - 圖片本體擾動
最多同時支援4組水波設定
*/
Shader "Yile/Effect/Simple_RippleBlur_Perspective"
{
	Properties
	{
		_DistortionAmt("擾動程度", Range(0,3)) = 1
		[HideInInspector]_MainTex("MainTexture", 2D) = "white" {}
		_Scale("振幅規模", Range(0,2)) = .5
		_Speed("水波速度", float) = -3
		_Frequency("水波頻率", float) = 3
		_PerspectiveOffset("透視設定 (x偏移,y偏移,x矯正,y矯正)",vector) = (0,0,0,0)

		[MaterialToggle] USEBG("Multiply Background", Float) = 0
		[MaterialToggle] CLAMP_ALPHA("Clamp Alpha", Float) = 0


		[Space(15)]
		_OffsetX1("x 位置 1", float) = 0
		_OffsetY1("y 位置 1", float) = 0
		_WaveAmplitude1("波紋振幅1", Range(0,2)) = 0
		_Distance1("距離1", float) = 10

		[Space(15)]
		_OffsetX2("x 位置 2", float) = 0
		_OffsetY2("y 位置 2", float) = 0
		_WaveAmplitude2("波紋振幅", Range(0,2)) = 0
		_Distance2("距離2", float) = 10

		[Space(15)]
		_OffsetX3("x 位置 3", float) = 0
		_OffsetY3("y 位置 3", float) = 0
		_WaveAmplitude3("波紋振幅", Range(0,2)) = 0
		_Distance3("距離3", float) = 10

		[Space(15)]
		_OffsetX4("x 位置 4", float) = 0
		_OffsetY4("y 位置 4", float) = 0
		_WaveAmplitude4("波紋振幅", Range(0,2)) = 0
		_Distance4("距離4", float) = 10
		
	}

		Category{

			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
			Blend SrcAlpha OneMinusSrcAlpha
			SubShader{

			Pass{
			Tags{ "LightMode" = "Always" }


			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#pragma multi_compile _ USEBG_ON
#pragma multi_compile _ CLAMP_ALPHA_ON

	#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord: TEXCOORD0;

			};



		struct v2f {
			float4 vertex : POSITION;
			float4 uvgrab : TEXCOORD0;
			float2 uvbump : TEXCOORD1;
			float2 uvmain : TEXCOORD2;
			float3 tempVertex : NORMAL;
		};

		float _BumpAmt;
		float4 _BumpMap_ST;
		float4 _MainTex_ST;
		float4 _MainTex_TexelSize;
		float Unity_Remap_float4(float In, float2 InMinMax, float2 OutMinMax)
		{
			return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
		}



		v2f vert(appdata_t v) {
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);

#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
#else
			float scale = 1.0;
#endif
			o.uvgrab.xy = (float2(o.vertex.x*scale, o.vertex.y*scale) + o.vertex.w) * 0.5;
			o.uvgrab.zw = o.vertex.zw;
			o.uvmain = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uvbump = v.texcoord - 0.5;
			o.tempVertex = mul(unity_ObjectToWorld, v.vertex).xyz;


			return o;
		}


		sampler2D _MainTex;

		float _Scale, _Speed, _Frequency, _DistortionAmt;

		float _WaveAmplitude1, _WaveAmplitude2, _WaveAmplitude3, _WaveAmplitude4, _WaveAmplitude5, _WaveAmplitude6, _WaveAmplitude7, _WaveAmplitude8;

		float _OffsetX1, _OffsetY1, _OffsetX2, _OffsetY2, _OffsetX3, _OffsetY3, _OffsetX4, _OffsetY4,
			_OffsetX5, _OffsetY5, _OffsetX6, _OffsetY6, _OffsetX7, _OffsetY7, _OffsetX8, _OffsetY8;

		float _Distance1, _Distance2, _Distance3, _Distance4, _Distance5, _Distance6, _Distance7, _Distance8;

		float4 _PerspectiveOffset;

		float2 GenOffsetUV(
			v2f i,float3 worldPos,
			float _OffsetX, float _OffsetY,
			float _Distance,float _WaveAmplitude,
			float2 offset
			) {

			float2 result = float2(0, 0);

			if (sqrt(pow(worldPos.x - _OffsetX, 2) + pow(worldPos.y - _OffsetY, 2)) < _Distance)
			{

				half w = sqrt(pow(worldPos.x - _OffsetX, 2) + pow(worldPos.y - _OffsetY, 2));


				float2 impactDis = float2(abs(worldPos.x - _OffsetX), abs(worldPos.y - _OffsetY));


				//透視偏移
				w += i.uvmain.x * _PerspectiveOffset.x;
				w += i.uvmain.y * _PerspectiveOffset.y;

				//透視矯正
				float xOff = (impactDis.x) * _PerspectiveOffset.z;
				float yOff = (impactDis.y) * _PerspectiveOffset.w;

				w += sqrt(pow(xOff ,2) + pow(yOff,2));


				half value = _Scale * (Unity_Remap_float4(sin(w * _Frequency + _Time.w*_Speed), float2(-1, 1), float2(0, 1)));

				float2 tempUV = offset + lerp(0, i.uvmain*value*_DistortionAmt, _WaveAmplitude);

				result += tempUV * _WaveAmplitude;
			}
			return result;
		}


		half4 frag(v2f i) : COLOR{

			float2 offset = _MainTex_ST.xy;
			offset = float2(0, 0);
			//==================================RippleWave==================================
			float3 worldPos = i.tempVertex;

			offset -= GenOffsetUV(i, worldPos, _OffsetX1, _OffsetY1, _Distance1, _WaveAmplitude1, offset);
			offset -= GenOffsetUV(i, worldPos, _OffsetX2, _OffsetY2, _Distance2, _WaveAmplitude2, offset);
			offset -= GenOffsetUV(i, worldPos, _OffsetX3, _OffsetY3, _Distance3, _WaveAmplitude3, offset);
			offset -= GenOffsetUV(i, worldPos, _OffsetX4, _OffsetY4, _Distance4, _WaveAmplitude4, offset);
			/*offset -= GenOffsetUV(i, worldPos, _OffsetX5, _OffsetY5, _Distance5, _WaveAmplitude5, offset);
			offset -= GenOffsetUV(i, worldPos, _OffsetX6, _OffsetY6, _Distance6, _WaveAmplitude6, offset);
			offset -= GenOffsetUV(i, worldPos, _OffsetX7, _OffsetY7, _Distance7, _WaveAmplitude7, offset);
			offset -= GenOffsetUV(i, worldPos, _OffsetX8, _OffsetY8, _Distance8, _WaveAmplitude8, offset);*/
			//=====================================================================

			//i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;


			float2 tempUV = offset + i.uvmain;

			//float2 tempUV = offset + i.uvgrab.xy;

			fixed4 mainCol = tex2D(_MainTex, tempUV);

			half4 col = tex2D(_MainTex, i.uvmain);
			//half4 col = tex2Dproj(_MainTex, UNITY_PROJ_COORD(i.uvgrab));

#ifdef USEBG_ON

			//mainCol = (mainCol + col) / 2;
			mainCol *= col;
#endif

#ifdef CLAMP_ALPHA_ON
			mainCol.a = col.a;
#endif
			return mainCol;

			}
			ENDCG
			}
		}
		}
}
