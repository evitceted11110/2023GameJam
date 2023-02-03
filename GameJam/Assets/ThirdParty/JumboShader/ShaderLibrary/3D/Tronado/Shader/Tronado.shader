Shader "Yile/3D/Tronado"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
        _NoiseStrength("NoiseStrength",float) = 5
        _NoiseSpeed("NoiseSpeed",vector) = (1,1,0,0)
        _NoiseScale("NoiseScale",float) = 1
        _ExtraNoiseValue("ExtraNoiseValue",Range(0,5)) = 1
        _DissolveValue("DissolveValue",Range(0,1)) = 0

        _TwirlCenter("TwirlCenter",vector)=(0.5,0.5,0,0)
        _TwirlAmount("TwirlAmount",float) = 1
        _TwirlSpeed("TwirlSpeed",vector) = (1,1,0,0)

        [Header(Blending)]
    	[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5
    	[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10

		// stencil for (UI) Masking
		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255
		_ColorMask("Color Mask", Float) = 15
    }
    SubShader
    {

       Tags { "Queue"="Transparent" "IgnoreProjector"="true" "RenderType"="Transparent" }
		// stencil for (UI) Masking
		//Stencil
		//{
		//	Ref[_Stencil]
		//	Comp[_StencilComp]
		//	Pass[_StencilOp]
		//	ReadMask[_StencilReadMask]
		//	WriteMask[_StencilWriteMask]
		//}
		Cull Off
		Lighting Off
		ZWrite Off
        Blend [_BlendSrc] [_BlendDst]
  
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float4 color    : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float4 vertex : SV_POSITION;
            };


             float unity_noise_randomValue (float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
            }

            float unity_noise_interpolate (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }

            float unity_valueNoise (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);

                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = unity_noise_randomValue(c0);
                float r1 = unity_noise_randomValue(c1);
                float r2 = unity_noise_randomValue(c2);
                float r3 = unity_noise_randomValue(c3);

                float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
                float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
                float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
                return t;
            }

            float Unity_SimpleNoise_float(float2 UV, float Scale)
            {
                float t = 0.0;

                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                return t;
            }

            float2 Unity_RadialShear_UV(float2 UV, float2 Center, float Strength, float2 Offset)
            {
                float2 delta = UV - Center;
                float delta2 = dot(delta.xy, delta.xy);
                float2 delta_offset = delta2 * Strength;
                return UV + float2(delta.y, -delta.x) * delta_offset + Offset;
            }

            float2 Unity_Twirl_UV(float2 UV, float2 Center, float Strength, float2 Offset)
            {
                float2 delta = UV - Center;
                float angle = Strength * length(delta);
                float x = cos(angle) * delta.x - sin(angle) * delta.y;
                float y = sin(angle) * delta.x + cos(angle) * delta.y;
               return float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _NoiseScale;
            fixed4 _NoiseSpeed;
            float _DissolveValue;
            float4 _Color;
            float _NoiseStrength;
            float _ExtraNoiseValue;
            float2 _TwirlCenter;
            float _TwirlAmount;
            float2 _TwirlSpeed;

            v2f vert (appdata v)
            {
                v2f o;

				o.color = v.color;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                

              //  return fixed4(i.uv.x,i.uv.y,0,1);

                float2 noiseUV = Unity_RadialShear_UV(i.uv,float2(0.5,0.5),_NoiseStrength, float2( _Time.x*_NoiseSpeed.x, _Time.x*_NoiseSpeed.y));
               
                
                float noise = Unity_SimpleNoise_float(noiseUV,_NoiseScale);
               

                float2 twirlUV = Unity_Twirl_UV(i.uv,_TwirlCenter,_TwirlAmount,_Time.x*_TwirlSpeed.xy);
                float twirlNoise = Unity_SimpleNoise_float(twirlUV,30);

                noise *= twirlNoise;

                noise  = noise + _ExtraNoiseValue*noise;

                fixed4 col = tex2D(_MainTex, i.uv) * _Color * noise;

                clip(noise-_DissolveValue);

                return col;
            }
            ENDCG
        }
    }
}
