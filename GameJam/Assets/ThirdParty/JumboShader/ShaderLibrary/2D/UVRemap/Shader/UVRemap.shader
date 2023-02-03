Shader "Yile/Effect/UVRemap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RT("RightTop",vector)=(1,1,0,0)
        _RB("RightButtom",vector)=(1,0,0,0)
        _LT("LeftTop",vector)=(0,1,0,0)
        _LB("LeftButtom",vector)=(0,0,0,0)
    }
    SubShader
    {
        Tags{ "Queue" = "Transparent" "IGNOREPROJECTOR" = "true" "RenderType" = "Transparent" }

		LOD 100
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _RT,_RB,_LT,_LB;
            float4 _UVClamp;

            float remap(float value, float2 IN,float2 OUT)
            {
                return (value - IN.x) / (IN.y - IN.x) * (OUT.y - OUT.x) + OUT.x;
            }

            float alphaMultiplier(float origin,float2 range){
                //step(a,b)   if a>b then return 0 else return 1

                return  step(origin,range.y) * step(range.x,origin);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

                float maxX = lerp( _RB.x , _RT.x , i.uv.y);
                float minX = lerp( _LB.x , _LT.x , i.uv.y);

                float shapeFixUVX = remap(i.uv.x,float2(minX,maxX),float2(0,1));

                float maxY = lerp( _LT.y , _RT.y , i.uv.x);
                float minY = lerp( _LB.y , _RB.y , i.uv.x);

                float shapeFixUVY = remap(i.uv.y,float2(minY,maxY),float2(0,1));


                float fixUV_x = remap(i.uv.x,float2(_LT.x,_RT.x),float2(0,1));

                float fixUV_Y = remap(i.uv.y,float2(_LB.y,_LT.y),float2(0,1));

                float2 fixUV = float2(shapeFixUVX,shapeFixUVY);

                fixed4 col = tex2D(_MainTex, fixUV);


                float finalAlpha = col.a;

                finalAlpha *= alphaMultiplier(i.uv.x,float2(minX,maxX));
                finalAlpha *= alphaMultiplier(i.uv.y,float2(minY,maxY));

                col.a = finalAlpha;


                //return i.vertex.y;

                return col;
            }
            ENDCG
        }
    }
}
