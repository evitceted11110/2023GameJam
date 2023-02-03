Shader "Yile/SpriteWipes"
{
	Properties
	{
		[PerRendererData]_MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 0
		[HideInInspector] _RendererColor("RendererColor", Color) = (1,1,1,1)
		[HideInInspector] _Flip("Flip", Vector) = (1,1,1,1)
		[PerRendererData] _AlphaTex("External Alpha", 2D) = "white" {}
		[PerRendererData] _EnableExternalAlpha("Enable External Alpha", Float) = 0
		_LineWidth("LineWidth",range(0,10)) = 5
		_LineColor("LineColor", Color) = (1,1,1,1)
		_LineMove("LineMove",range(-2.2,2.2)) = 0
		_LineRota("LineRota",range(0,1)) = 0
		[Toggle]_IgnoreAlpha("IgnoreAlpha",int) = 0
		_debugValue("debugValue",float) = 999

			[HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
			[HideInInspector]_Stencil("Stencil ID", Float) = 0
			[HideInInspector]_StencilOp("Stencil Operation", Float) = 0
			[HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
			[HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
	}
		SubShader
		{
			Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

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
			//Blend One OneMinusSrcAlpha
			Pass
		{
			CGPROGRAM
	#pragma vertex MySpriteVert
	#pragma fragment MySpriteFrag
	#pragma target 2.0
	#pragma multi_compile_instancing
	#pragma multi_compile _ PIXELSNAP_ON
	#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
	#include "UnityCG.cginc"
	#include "UnitySprites.cginc"

			struct MyV2f
		{
			float4 vertex   : SV_POSITION;
			fixed4 color : COLOR;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
			UNITY_VERTEX_OUTPUT_STEREO
		};


			float2 myUV;
			float _LineWidth;
			float4 _LineColor;
			float _LineMove;
			float _LineRota;
			int _IgnoreAlpha;
			float _debugValue;
		fixed4 MySampleSpriteTexture(float2 uv)
		{
			myUV = uv;
			fixed4 color = tex2D(_MainTex, uv);

	#if ETC1_EXTERNAL_ALPHA
			fixed4 alpha = tex2D(_AlphaTex, uv);
			color.a = lerp(color.a, alpha.r, _EnableExternalAlpha);
	#endif

			color = tex2D(_MainTex, uv);

			return color;
		}

		MyV2f MySpriteVert(appdata_t IN)
		{
			MyV2f OUT;

			UNITY_SETUP_INSTANCE_ID(IN);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

	#ifdef UNITY_INSTANCING_ENABLED
			IN.vertex.xy *= _Flip;
	#endif

			OUT.vertex = UnityObjectToClipPos(IN.vertex);
			OUT.texcoord = IN.texcoord;
			OUT.texcoord1 = IN.texcoord;
			OUT.color = IN.color * _Color * _RendererColor;

	#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap(OUT.vertex);
	#endif

			return OUT;
		}

		float Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax)
		{
			return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
		}


		fixed4 MySpriteFrag(MyV2f IN) : SV_Target
		{
			fixed4 c = MySampleSpriteTexture(IN.texcoord)* IN.color;
		c.rgb *= c.a;

		//return c;
		float linetV = myUV.x;

		linetV = lerp(linetV, myUV.y, _LineRota);
		linetV = Unity_Remap_float4(linetV.x, float2(0,1), float2(0, 3.14));
		linetV = linetV + _LineMove;
		linetV = pow(sin(linetV), exp(_LineWidth));
		linetV = clamp(linetV, 0.01, 1);
		float4 lineColor = mul(linetV, _LineColor);

		if (_IgnoreAlpha)
			c += lineColor;
		else
		c.rgb += lineColor;

		//return  float4(0, 0, 0,c.a); //0透明 1黑色 -1白色
		return c;
		}
			ENDCG
		}
		}
}