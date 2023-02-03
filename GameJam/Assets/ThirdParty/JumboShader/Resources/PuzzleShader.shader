Shader "Yile/Effect/PuzzleShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MaskTex("Mask", 2D) = "white" {}
		_LightColor("LightColor", Color) = (1,1,1,1)
		_DarkColor("DarkColor", Color) = (0,0,0,1)
		_Border("Border", vector) = (0,0,0,0)
		_TOTALWIDTH("TotalWidth", float) = 0
		_TOTALHEIGH("TotalHeigh", float) = 0

	}
		SubShader
		{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha // additive blending
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
					float2 uv2 : TEXCOORD1;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float2 uv2: TEXCOORD1;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				sampler2D _MaskTex;
				float4 _MaskTex_ST;
				fixed4 _LightColor, _DarkColor;
				float _TOTALWIDTH, _TOTALHEIGH;
				float4 _Border;


				float Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax)
				{
					return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
				}

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.uv2 = v.uv2;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture

					/*float minX = _TOTALWIDTH / _Border.x;
					float maxX = _TOTALWIDTH / _Border.z;

					float minY = _TOTALHEIGH / _Border.y;
					float maxY = _TOTALHEIGH / _Border.w;
*/

					float minX = _Border.x / _TOTALWIDTH;
					float maxX = _Border.y / _TOTALWIDTH;

					float minY = _Border.z / _TOTALHEIGH;
					float maxY = _Border.w / _TOTALHEIGH;

					/*float maskUVX = i.uv.x / (maxX + minX);
					float maskUVY = i.uv.y / (maxY + minY);*/

					float maskUVX = Unity_Remap_float4(i.uv.x, float2(minX, maxX), float2(0, 1));
					float maskUVY = Unity_Remap_float4(i.uv.y, float2(minY, maxY), float2(0, 1));

					float2 maskUV = float2(maskUVX, maskUVY);

					

					//float2 maskUV = float2(i.uv2.x, i.uv2.y);
					fixed4 col = tex2D(_MainTex, i.uv);

					fixed4 mask = tex2D(_MaskTex, maskUV);

					col.a *= mask.a;
					col.rgb = col.rgb * mask.g + _LightColor * mask.r + _DarkColor * mask.b;

					//col = fixed4(maskUVY, maskUVY, maskUVY, 1);
					return col;
				}
				ENDCG
			}
		}
}
