Shader "Yile/Shadow/SpriteColorBlend"
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
		[MaterialToggle] HitBool("Hit Bool", Float) = 0
		_HitColor("HitColor", Color) = (1,1,1,1)
		_blendPower("BlendPower",Range(0,1)) = 0.2
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
		"Shadowable" = "True"
	}
		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		Pass
	{
		CGPROGRAM
#pragma vertex SpriteVert
#pragma fragment MySpriteFrag
#pragma target 2.0
#pragma multi_compile_instancing
#pragma multi_compile _ PIXELSNAP_ON
#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
#include "UnityCG.cginc"
#include "UnitySprites.cginc"

		float _blendPower;
		float HitBool;
		fixed4 _HitColor;

		fixed4 MySampleSpriteTexture(float2 uv)
	{
		fixed4 color = tex2D(_MainTex, uv);


#if ETC1_EXTERNAL_ALPHA
		fixed4 alpha = tex2D(_AlphaTex, uv);
		color.a = lerp(color.a, alpha.r, _EnableExternalAlpha);
#endif
		if (HitBool == 0)
			color = tex2D(_MainTex, uv);
		else		
			color = fixed4(color.r*_blendPower + _HitColor.r, color.g*_blendPower + _HitColor.g, color.b*_blendPower + _HitColor.b, color.a);		



		return color;
	}
	fixed4 MySpriteFrag(v2f IN) : SV_Target
	{
		fixed4 c = MySampleSpriteTexture(IN.texcoord) * IN.color;
	c.rgb *= c.a;
	return c;
	}
		ENDCG
	}
	}
}