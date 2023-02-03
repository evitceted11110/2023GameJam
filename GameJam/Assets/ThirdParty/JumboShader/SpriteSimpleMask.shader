Shader "Yile/SpriteSimpleMask"
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

		_ColorMask("Color Mask", Float) = 15
		_Filter_Height("Filter_Height",Range(0,1)) = 0
		[Toggle(UNITY_UI_ALPHACLIP)]_InvertHeightMove("InvertHeightMove",float) = 0

		_Filter_Width("Filter_Width",Range(0,1)) = 0
		[Toggle(UNITY_UI_ALPHACLIP)]_InvertWidthMove("InvertWidthMove",float) = 0

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
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
		Blend One OneMinusSrcAlpha
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
		UNITY_VERTEX_OUTPUT_STEREO
	};

	float _Filter_Height;
	float _InvertHeightMove;
	float _Filter_Width;
	float _InvertWidthMove;

	fixed4 MySampleSpriteTexture(float2 uv)
	{
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
		OUT.color = IN.color * _Color * _RendererColor;

#ifdef PIXELSNAP_ON
		OUT.vertex = UnityPixelSnap(OUT.vertex);
#endif

		return OUT;
	}

	fixed4 MySpriteFrag(MyV2f IN) : SV_Target
	{
		fixed4 c = MySampleSpriteTexture(IN.texcoord) * IN.color;
	c.rgb *= c.a;
	

	if (_InvertHeightMove)
	{
		if (IN.texcoord.y < _Filter_Height)
			c = float4(0, 0, 0, 0);
	}
	else
	{
		if (IN.texcoord.y > _Filter_Height)
			c = float4(0, 0, 0, 0);
	}

	if (_InvertWidthMove)
	{
		if (IN.texcoord.x < _Filter_Width)
			c = float4(0, 0, 0, 0);
	}
	else
	{
		if (IN.texcoord.x > _Filter_Width)
			c = float4(0, 0, 0, 0);
	}
	return c ;	
	}
		ENDCG
	}
	}
}