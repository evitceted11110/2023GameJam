// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Simplified Alpha Blended Particle shader. Differences from regular Alpha Blended Particle one:
// - no Tint color
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "Jumbo/Light Sweep" {
Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
	_BlendTex("Alpha Blended(RGBA)",2D)="white"{}

}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off Lighting Off ZWrite Off 
	ColorMask RGB
	
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	SubShader {
		Pass {
		

			SetTexture [_BlendTex] {
				combine texture * primary
			}

			SetTexture [_MainTex] {
                combine previous * texture
            }
			
		}
	}
}
}
