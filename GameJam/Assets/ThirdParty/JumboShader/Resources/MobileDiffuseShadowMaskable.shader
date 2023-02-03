Shader "Yile/MobileDiffuseShadowMaskable"
{
	Properties
	{
		_MainTex ("Base {RGB}", 2D) = "white" {}
	}
		SubShader
	{
        Tags { "RenderType"="Opaque" "Queue" = "Transparent-1"}
		LOD 150

		CGPROGRAM
    #pragma surface surf Lambert fullforwardshadows
		sampler2D _MainTex;
	struct Input{
		float2 uv_MainTex;
	};
	void surf(Input IN, inout SurfaceOutput o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
		o.Albedo = c.rgb;
	}
	ENDCG
	}
	Fallback "Mobile/VertexLit"
}
