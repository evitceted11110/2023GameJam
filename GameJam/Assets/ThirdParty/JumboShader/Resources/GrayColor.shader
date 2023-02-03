Shader "Jumbo/GrayColor"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//_GrayColor("GrayColor",)=(1,1,1,1)
		_GrayPow("Gray Pow",Range (0,1))=1
		_ColorAdd("Color Add",Color)=(1,1,1,1)
		_RedPow("Red Pow",float)=1
		_GreenPow("Green Pow",float)=1
		_BluePow("Blue Pow",float)=1
		

	}
	SubShader
	{
		Tags { "Queue"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
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
			float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _GrayPow;
			float4 _ColorAdd;
			float _RedPow;
			float _GreenPow;
			float _BluePow;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{				
				fixed4 color = tex2D(_MainTex, i.uv);
				fixed lum=color.r*_GrayPow+color.g*_GrayPow+color.b*_GrayPow;
				fixed4 grayscale=fixed4(lum,lum,lum,color.a);
				fixed4 col=grayscale*_GrayPow+color*(1-_GrayPow);
				col.r=col.r*_ColorAdd.r*_RedPow;
				col.g=col.g*_ColorAdd.g*_GreenPow;
				col.b=col.b*_ColorAdd.b*_BluePow;
				

				return col;
			}
			ENDCG
		}
	}
}
