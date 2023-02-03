Shader "Yile/MobileGlowMap_Unlit_NoAlpha" {
	Properties{
		_Color("Color", Color) = (.5,.5,.5,1)
		_MainTex("Color (RGB) Alpha (A)", 2D) = "white"
		_GlowMap("GlowMap",2D) = "white"{}
		_GlowStrength("GlowStrength",Range(0,5)) = 0
	}
	SubShader{
		Tags {"RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 200

		CGPROGRAM
		#pragma surface surf NoLight

		inline fixed4 LightingNoLight(SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
		{

			fixed4 c;
			c.rgb = s.Albedo;
			c.a = 0;
			return c;
		}

		sampler2D _MainTex;

		sampler2D _GlowMap;


		float _GlowStrength;

		fixed4 _Color;
		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex)*_Color;
			fixed4 glow = tex2D(_GlowMap, IN.uv_MainTex)*_GlowStrength;


			o.Emission = glow;
			o.Albedo = tex.rgb;

		}
		ENDCG
		}
		FallBack "Mobile/VertexLit"
}
