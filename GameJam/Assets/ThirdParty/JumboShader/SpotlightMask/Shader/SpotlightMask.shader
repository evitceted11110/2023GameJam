Shader "Yile/Effect/SpotlightMask"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
        [HideInInspector]_OffsetX1("x Offset 1", float) = 0
		[HideInInspector]_OffsetY1("y Offset 1", float) = 0
        [HideInInspector]_Radius1("Radius1", float) = 0
        [HideInInspector]_OffsetX2("x Offset 2", float) = 0
		[HideInInspector]_OffsetY2("y Offset 2", float) = 0
        [HideInInspector]_Radius2("Radius2", float) = 0
        [HideInInspector]_OffsetX3("x Offset 3", float) = 0
		[HideInInspector]_OffsetY3("y Offset 3", float) = 0
        [HideInInspector]_Radius3("Radius3", float) = 0
        [HideInInspector]_OffsetX4("x Offset 4", float) = 0
		[HideInInspector]_OffsetY4("y Offset 4", float) = 0
        [HideInInspector]_Radius4("Radius4", float) = 0
        [HideInInspector]_OffsetX5("x Offset 5", float) = 0
		[HideInInspector]_OffsetY5("y Offset 5", float) = 0
        [HideInInspector]_Radius5("Radius5", float) = 0
        [HideInInspector]_OffsetX6("x Offset 6", float) = 0
		[HideInInspector]_OffsetY6("y Offset 6", float) = 0
        [HideInInspector]_Radius6("Radius6", float) = 0


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
				float4 color    : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float4 vertex : POSITION;
                float3 tempVertex : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _OffsetX1,_OffsetY1,_OffsetX2,_OffsetY2,_OffsetX3,_OffsetY3,
                _OffsetX4,_OffsetY4,_OffsetX5,_OffsetY5,_OffsetX6,_OffsetY6;
            float _Radius1,_Radius2,_Radius3,_Radius4,_Radius5,_Radius6;

            float GenSpotlight(v2f i, float3 worldPos, float _OffsetX, float _OffsetY, float _Radius) 
            {
                float distance = sqrt(pow(worldPos.x - _OffsetX, 2) + pow(worldPos.y - _OffsetY, 2));

                return step(distance,_Radius);
			}

            v2f vert (appdata v)
            {
                v2f o;

				o.color = v.color;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.tempVertex = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                float3 worldPos = i.tempVertex;

                float value1 = GenSpotlight(i,worldPos,_OffsetX1,_OffsetY1,_Radius1);
                float value2 = GenSpotlight(i,worldPos,_OffsetX2,_OffsetY2,_Radius2);
                float value3 = GenSpotlight(i,worldPos,_OffsetX3,_OffsetY3,_Radius3);
                float value4 = GenSpotlight(i,worldPos,_OffsetX4,_OffsetY4,_Radius4);
                float value5 = GenSpotlight(i,worldPos,_OffsetX5,_OffsetY5,_Radius5);
                float value6 = GenSpotlight(i,worldPos,_OffsetX6,_OffsetY6,_Radius6);

                float mixValue = clamp(value1+value2+value3+value4+value5+value6,0,1);

                col.a = col.a * step(mixValue,.99);
 
                return col;
            }
            ENDCG
        }
    }
}
