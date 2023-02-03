// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Simplified Alpha Blended Particle shader. Differences from regular Alpha Blended Particle one:
// - no Tint color
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "Jumbo/LineShader" {
Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
	_BlendTex("Alpha Blended(RGBA)",2D)="white"{}
	_Stencil ("Stencil Ref", Float) = 0
	_StencilComp ("Stencil Comparison", Float) = 8
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	SubShader {
		Pass {
			Stencil
			{
				Ref [_Stencil]
				Comp [_StencilComp]
				Pass Keep
			}

			SetTexture [_MainTex] {
				combine texture * primary
			}

			SetTexture[_BlendTex]{
				combine texture lerp(texture) previous
			}
		}
	}
}
}
