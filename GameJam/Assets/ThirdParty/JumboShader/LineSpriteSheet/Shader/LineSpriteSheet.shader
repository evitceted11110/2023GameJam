Shader "Yile/Effect/LineSpriteSheet"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)


		[Header(Settings)]
		_ColumnsX("Columns (X)", int) = 1
		[MaterialToggle] FLOWX("X軸滑動",Float) = 0
		_RowsY("Rows (Y)", int) = 1
		[MaterialToggle] FLOWY("Y軸滑動",Float) = 0
		_TotalFrame("TotalFrame",int) = 1
		_TimeSpeed("TimeSpeed",Float) = 1
		_TimerOffset("時間偏差",Float) = 0
		_AnimationSpeed("Frames Per Seconds (FPS)", float) = 10
		// stencil for (UI) Masking
		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255
		_ColorMask("Color Mask", Float) = 15
    }
    SubShader
    {

       Tags { "Queue"="Transparent" "IgnoreProjector"="true" "RenderType"="Transparent" }
		// stencil for (UI) Masking
		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}
		LOD 100
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha


        Pass
        {
            CGPROGRAM
            #pragma multi_compile _ FLOWX_ON
			#pragma multi_compile _ FLOWY_ON

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float4 color    : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			uint _ColumnsX;
			uint _RowsY;
			uint _TotalFrame;
			float _AnimationSpeed;
			float _TimeSpeed;
			float _TimerOffset;
            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				//取得一格動畫的大小
				float2 size = float2(1.0f / _ColumnsX, 1.0f / _RowsY);
				uint totalFrames = _ColumnsX * _RowsY;

#ifdef FLOWX_ON
				totalFrames = _RowsY;
				size = float2(1, 1.0f / _RowsY);
#endif

#ifdef FLOWY_ON
				totalFrames = _ColumnsX;
				size = float2(1.0f / _ColumnsX, 1);
#endif

				//啟用自動撥放

				float timer = _Time.y * _TimeSpeed + _TimerOffset;
				uint index = abs(timer) *_AnimationSpeed % _TotalFrame;

				//計算X/Y的Index位置
				uint indexX = index % _ColumnsX;
				uint indexY = floor((index % totalFrames) / _ColumnsX);

				float2 offset = float2(size.x*indexX,-size.y*indexY);
#ifdef FLOWX_ON
				offset = float2(timer,-size.y*indexY);
#endif
#ifdef FLOWY_ON
				offset = float2(size.x*indexX,-timer);
#endif

				//取得SpriteOffset
				

				//取得當前Index的UV
				float2 newUV = v.uv*size;

				//反轉Y軸 (動畫從左上開始)
				newUV.y = newUV.y + size.y*(_RowsY - 1);

				o.uv = newUV + offset;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
				//return fixed4 (1,1,1,1);
                return col;
            }
            ENDCG
        }
    }
}
