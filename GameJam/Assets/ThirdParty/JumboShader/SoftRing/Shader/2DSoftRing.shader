Shader "Yile/Effect/2DSoftRing"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

        _InsideRingSize("內圓大小",Range(0,1)) = 0
        _InsideRingSoft("內圓模糊範圍",Range(0,1)) = 0
        _OutsideRingSize("外圓大小",Range(0,1)) = 0
        _OutsideRingSoft("外圓模糊範圍",Range(0,1)) = 0

        [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5
    	[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10

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
		Cull Off
		Lighting Off
		ZWrite Off
		//Blend SrcAlpha OneMinusSrcAlpha
        Blend [_BlendSrc] [_BlendDst]


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
          //  float4 _Setting;
            float _InsideRingSize,_OutsideRingSize;
            float _InsideRingSoft,_OutsideRingSoft;

            float remap(float value, float2 IN,float2 OUT)
            {
                return (value - IN.x) / (IN.y - IN.x) * (OUT.y - OUT.x) + OUT.x;
            }

            v2f vert (appdata v)
            {
                v2f o;

				o.color = v.color;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 center = float2(0.5,0.5);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;

                float distance = sqrt(pow(i.uv.x - center.x, 2) + pow(i.uv.y - center.y, 2));


                //外圈開始淡入點
                float outSoftStartDistance = _OutsideRingSoft;
                //外圈淡入結束的點
                float outSoftEndDistance = _OutsideRingSize;
                
                //內圈開始淡入的點
                float inSoftStartDistance = _InsideRingSoft;
                //內圈淡入結束的點
                float inSoftEndDistance = _InsideRingSize;

                //兩邊Start柔邊以外的都要剃除
                float outOffRingAlpha = step(distance,outSoftStartDistance) * step(inSoftStartDistance,distance);

                float inCircleAlpha = step(distance,outSoftEndDistance) * step(inSoftStartDistance,distance);

                //內圈淡入效果
                float inSoftLerpValue = step(distance,inSoftStartDistance) * step(inSoftEndDistance,distance);
                inSoftLerpValue *= remap(distance, float2(inSoftEndDistance,inSoftStartDistance), float2(0,1));

                //外圈淡入效果
                float outSoftLerpValue = step(distance,outSoftStartDistance) * step(outSoftEndDistance,distance);
                outSoftLerpValue *= remap(distance, float2(outSoftStartDistance,outSoftEndDistance), float2(0,1));

                //最外圍Alpha * 外圈淡入值 + 內圈淡入Alpha + 中心Alpha
                float alpha = outOffRingAlpha * outSoftLerpValue + inSoftLerpValue + inCircleAlpha;

                col.a = alpha*i.color.a;

                return col;
            }
            ENDCG
        }
    }
}
