Shader "Yile/SpriteSheet"
{
	Properties
	{
		[Header(Texture Sheet)]
		_MainTex("Texture", 2D) = "white" {}
		[Header(Settings)]
		_ColumnsX("Columns (X)", int) = 1
		_RowsY("Rows (Y)", int) = 1
		_TotalFrame("TotalFrame",int) = 1

		[Space(20)]
		[Header(Loop Option)]
		[MaterialToggle] AUTOPLAY("自動輪播",Float) = 0
		[MaterialToggle] PINGPONG("Ping pong輪播",Float) = 0
		[MaterialToggle] REVERSE("反轉輪播",Float) = 0
		_TimerOffset("時間偏差",Float) = 0
		_AnimationSpeed("Frames Per Seconds (FPS)", float) = 10

		[Space(20)]
		[Header(Manual Option)]
		_Progress("Progress",Range(0,1))=0
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IGNOREPROJECTOR" = "true" "RenderType" = "Transparent" }

		LOD 100
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{	
			CGPROGRAM
			#pragma multi_compile _ AUTOPLAY_ON
			#pragma multi_compile _ PINGPONG_ON
			#pragma multi_compile _ REVERSE_ON
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			uint _ColumnsX;
			uint _RowsY;
			uint _TotalFrame;
			float _TimerOffset;
			float _AnimationSpeed;
			float _Progress;

			float Unity_Remap_float4(float In, float2 InMinMax, float2 OutMinMax)
			{
				return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//取得一格動畫的大小
				float2 size = float2(1.0f / _ColumnsX, 1.0f / _RowsY);

				uint totalFrames = _ColumnsX * _RowsY;


				//啟用自動撥放
#ifdef AUTOPLAY_ON
				float timer = _Time.y + _TimerOffset;
				uint index = timer *_AnimationSpeed % _TotalFrame;

#ifdef PINGPONG_ON
				int forward = floor((_Time.y*_AnimationSpeed) / _TotalFrame) % 2;
				//0 = forward, 1=reverse

				index += forward * (_TotalFrame-(index*2)-1);
#endif

#ifdef REVERSE_ON
				//反轉
				index = _TotalFrame-1 - index;
#endif


#else
				uint index = (floor(_Progress*totalFrames)-1) % _TotalFrame;
#endif
				

				//計算X/Y的Index位置
				uint indexX = index % _ColumnsX;
				uint indexY = floor((index % totalFrames) / _ColumnsX);

				//取得SpriteOffset
				float2 offset = float2(size.x*indexX,-size.y*indexY);

				//取得當前Index的UV
				float2 newUV = v.uv*size;

				//反轉Y軸 (動畫從左上開始)
				newUV.y = newUV.y + size.y*(_RowsY - 1);

				o.uv = newUV + offset;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				return col;
			}
		ENDCG
		}
	}
}
