Shader "Unlit/CardMask"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	    _MaskTex("Mask", 2D) = "white" {}
		_ReplaceColor("ReplaceColor",Color) = (1,1,1,1)	

		[Toggle(FILL_WITH_RED)]
		_EnableMask("EnableMask", Float) = 0
		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 150

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog			

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
			sampler2D _MaskTex;
			float4 _MainTex_ST;
			fixed4 _ReplaceColor;
			float _EnableMask;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);			

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				fixed4 maskColor = tex2D(_MaskTex, i.uv);
				
			fixed4 col;
			
			if (maskColor.r <=0.9)
				col = _ReplaceColor;
			else
				col = tex2D(_MainTex, i.uv);

			if(_EnableMask==0)
				col = tex2D(_MainTex, i.uv);

		//	col = maskColor;

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
