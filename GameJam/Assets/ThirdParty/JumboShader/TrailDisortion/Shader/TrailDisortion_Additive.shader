Shader "Yile/Particle/TrailDisortion_Additive"
{
    Properties
    {
        [Header(Main)]
        _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
        _UVSpeed("UV Speed",Vector) = (0,0,0,0)
        _ExtraBrightness("ExtraBrightness",Range(0,5)) = 0

        [Header(Disortion)]
        _DisortionMap("Disortion Texture", 2D) = "white" {}
        _XDistort("Distort_X",Float) = 0
        _YDistort("Distort_Y",Float) = 0
        _DisortSpeed("DisortSpeed",Float) = 0
        _DistortAmount("DistortAmount",Range(0,5))=0

        [Header(Mask)]
        _MaskTex("Mask Texture", 2D) = "white" {}
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
				float4 color    : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex,_DisortionMap,_MaskTex;
            float4 _MainTex_ST,_DisortionMap_ST,_MaskTex_ST;
            float4 _UVSpeed,_Color;
            float _XDistort,_YDistort,_DistortAmount,_DisortSpeed;
            float _ExtraBrightness;
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

                fixed distort = tex2D(_DisortionMap, i.uv - (_Time.x*_DisortSpeed*float2(_XDistort, _YDistort))).r;// distortion
			    
                // sample the texture
                float2 moveUV = float2(_UVSpeed.x*_Time.y, _UVSpeed.y*_Time.y);

                fixed4 distortTex = tex2D(_MainTex, i.uv + moveUV + (_DistortAmount*(distort * float2(_XDistort, _YDistort))));//distortion Ttxture

                fixed4 maskTex = tex2D(_MaskTex,i.uv);

                fixed4 col = (distortTex * i.color +(_ExtraBrightness*distortTex.a))*i.color.a*maskTex.r* _Color;

                return col;
            }
            ENDCG
        }
    }
}
