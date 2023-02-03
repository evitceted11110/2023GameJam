Shader "Jumbo/SliderLight" {
Properties {
	_Color("Main Color",Color)=(1,1,1,1)
	_MainTex ("Base (RGBA)", 2D) = "white" {}
	_MaskTex ("Alpha (RGBA)", 2D) = "black" {}
	_Light("Light",Float)=1
}

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 250
	Lighting off
	
CGPROGRAM
#pragma surface surf Lambert alpha


sampler2D _MainTex;
sampler2D _MaskTex;
float _Light;
fixed4 _Color;


struct Input {
	float2 uv_MainTex;
	float2 uv_MaskTex;
	
};

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
	half4 decal = tex2D(_MaskTex, IN.uv_MaskTex);
	c*=_Color*_Light;
	o.Emission = c.rgb;
	o.Alpha = decal.a*c.a;
}
ENDCG
}

Fallback "Diffuse"
}
