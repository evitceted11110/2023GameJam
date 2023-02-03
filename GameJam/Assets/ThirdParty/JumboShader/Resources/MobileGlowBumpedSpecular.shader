Shader "Yile/MobileGlowBumpedSpecular" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		[PowerSlider(5.0)] _Shininess("Shininess", Range(0.03, 1)) = 0.078125
		_MainTex("Color (RGB) Alpha (A)", 2D) = "white"
		[NoScaleOffset] _NormalMap("Normalmap", 2D) = "bump" {}
		_NormalStrength("NormalStrength",float) = 1
		_SpecularMap("SpecularMap",2D) = "white"{}
		_GlowMap("GlowMap",2D) = "white"{}
		_GlowStrength("GlwoStrength",Range(0,5)) = 0
	}
	SubShader{
		Tags {"RenderType" = "Opaque"}
		LOD 100

		CGPROGRAM
		#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview interpolateview
		float _NormalStrength;
		inline fixed4 LightingMobileBlinnPhong(SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
		{
			fixed diff = max(0, dot(s.Normal, lightDir));
			fixed nh = max(0, dot(s.Normal, halfDir));
			fixed spec = pow(nh, s.Specular * 128) * s.Gloss;

			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
			UNITY_OPAQUE_ALPHA(c.a);
			return c;
		}

		sampler2D _MainTex;
		sampler2D _NormalMap;
		sampler2D _GlowMap;
		sampler2D _SpecularMap;
		half _Shininess;
		float _GlowStrength;
		fixed4 _Color;
		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex)*_Color;
			fixed4 glow = tex2D(_GlowMap, IN.uv_MainTex)*_GlowStrength;
			fixed4 specular = tex2D(_SpecularMap, IN.uv_MainTex);
			
			o.Emission = glow;
			o.Albedo = tex.rgb;
			o.Gloss = tex.a;
			o.Alpha = tex.a;
			o.Specular = _Shininess;

			fixed3 normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
			normal.z = normal.z*_NormalStrength;
			o.Normal = normalize(normal)*specular.r;
		}
		ENDCG
	}
	FallBack "Mobile/VertexLit"
}
