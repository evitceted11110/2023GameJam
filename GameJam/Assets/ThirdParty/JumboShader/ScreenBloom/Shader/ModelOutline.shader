Shader "Yile/ModelOutline"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Color (RGB) Alpha (A)", 2D) = "white"{}
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineWidth("Outline width", Range(0.0, 10.0)) = .005
	}
	SubShader
	{
			Tags
			{
				"RenderType" = "Transparent" "Queue" = "Transparent"
			}
		Pass
		{
			Tags
			{
				"RenderType" = "Transparent" "Queue" = "Transparent" 
			}
			
			Cull Off
			ZWrite Off
			ColorMask RGB
			//Blend SrcAlpha OneMinusSrcAlpha
			Blend SrcAlpha One
			CGPROGRAM
			#pragma vertex VertexProgram
			//#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
			uniform float _OutlineWidth;
			uniform float4 _OutlineColor;
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 orginaVertex : TEXCOORD1;
			};

			float4 VertexProgram(
				float4 position : POSITION,
				float3 normal : NORMAL) : SV_POSITION{

			float4 clipPosition = UnityObjectToClipPos(position);
			float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, normal));

			//clipPosition.xyz += normalize(clipNormal) * _OutlineWidth;
			//float2 offset = normalize(clipNormal.xy) * _OutlineWidth * clipPosition.w;
			float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * _OutlineWidth * clipPosition.w * 8;
			clipPosition.xy += offset;

			return clipPosition;

			}

			v2f vert(appdata v)
			{
				v2f o;

				float3 norm = normalize(v.normal);

				float4 tempVert = v.vertex *0.5;
				tempVert.xyz += v.normal ;
				o.orginaVertex = UnityObjectToClipPos(tempVert) ;

				v.vertex.xyz += v.normal * _OutlineWidth;

				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}

			sampler2D _MainTex;
			float2 _BlurSize;
			fixed4 _Color;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 s = _OutlineColor;
				//s.a = _Color.a*_Color.a*_Color.a;
				s.a *= step(1-_Color.a, 0.001);
				return s;
			}
			ENDCG			
		}
		Pass
		{
			Tags
			{
				"RenderType" = "Transparent" "Queue" = "Transparent"
			}
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				//o.normalDir = normalize(mul(half4(v.normal, 0), unity_WorldToObject).xyz);

				return o;
			}

			uniform sampler2D _MainTex;
			uniform half4 _LightColor0;
			//half _Alpha;
			fixed4 _Color;
			half4 frag(v2f i) : COLOR
			{
				half4 c = tex2D(_MainTex, i.uv) * _Color;
				//c.a = _Alpha;
				return c;
			}

			ENDCG


			/*SetTexture[_ModelTexture]
			{
					Combine Primary * Texture
			}*/
		}
	}

				FallBack "Mobile/VertexLit"
}
