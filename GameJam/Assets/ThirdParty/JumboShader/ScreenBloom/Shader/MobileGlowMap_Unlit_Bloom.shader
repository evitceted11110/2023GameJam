Shader "Yile/MobileGlowMap_Unlit_Bloom" {
	Properties
	{
		_Color("Color", Color) = (.5,.5,.5,1)
		_MainTex("Color (RGB) Alpha (A)", 2D) = "white"
		_GlowMap("GlowMap",2D) = "white"{}
		_GlowStrength("GlwoStrength",Range(0,5)) = 0
	}

	SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" "PerformanceChecks" = "False" "Glowable" = "True" }
		LOD 300

		CGPROGRAM
		#pragma surface surf NoLight

		inline fixed4 LightingNoLight(SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
		{

			fixed4 c;
			c.rgb = s.Albedo ;
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
			//o.Alpha = tex.a*_Color.a;

		}
		ENDCG
		}
			FallBack "Mobile/VertexLit"
}
