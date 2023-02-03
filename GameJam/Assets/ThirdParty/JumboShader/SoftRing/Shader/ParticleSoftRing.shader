/*
[TEXCOORD1]
x=內圓大小
y=內圓模糊區
z=外圓大小
w=外圓模糊區
*/

Shader "Yile/Particle/SoftRing"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

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
                float4 basedata : TEXCOORD1;
                float4 colordata : TEXCOORD2;
				float4 color    : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float4 basedata : TEXCOORD1;
                float4 colordata : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;


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
                o.basedata = v.basedata;
                o.colordata = v.colordata;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 center = float2(0.5,0.5);
                float4 _Setting = i.basedata;

                fixed4 col = tex2D(_MainTex, i.uv) * i.colordata;

                float distance = sqrt(pow(i.uv.x - center.x, 2) + pow(i.uv.y - center.y, 2));

                //外圈開始淡入點
                float outSoftStartDistance = _Setting.w;
                //外圈淡入結束的點
                float outSoftEndDistance = _Setting.z;
                
                //內圈開始淡入的點
                float inSoftStartDistance = _Setting.y;
                //內圈淡入結束的點
                float inSoftEndDistance = _Setting.x;

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
