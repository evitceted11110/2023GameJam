Shader "Yile/PostProcess/GaussianBlur"
{ 
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        [Header(Blending)]
    	[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5
    	[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10

        radius ("Radius", Range(0,30)) = 15
        resolution ("Resolution", float) = 800  
        hstep("HorizontalStep", Range(0,5)) = 0.5
        vstep("VerticalStep", Range(0,5)) = 0.5 

        repeat("Repeat", Range(5,20)) = 5 

        mainTexValue("mainTexValue", Range(0,1)) = 1
        blurTexValue("blurTexValue", Range(0,1)) = 2 

    }

    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="true" "RenderType"="Transparent"}
        ZWrite Off 

        Blend [_BlendSrc] [_BlendDst]
        Cull Off
        GrabPass { }
        Pass
        {    
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };    
            struct v2f
            {
                half2 texcoord  : TEXCOORD0;
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 bguv : TEXCOORD1;

            };

            sampler2D _MainTex;
            float radius;
            float resolution;

            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            float hstep;
            float vstep;
            float mainTexValue,blurTexValue;
            fixed4 _Color;
            int repeat;
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color;
                OUT.bguv = ComputeGrabScreenPos(OUT.vertex);

                return OUT;
            }

            float4 frag(v2f i) : COLOR
            {    
                float2 uv = i.bguv;
                float4 sum = float4(0.0, 0.0, 0.0, 0.0);
                float2 tc = uv;
                float4 mainCol = tex2D(_GrabTexture,tc);
                //blur radius in pixels
                float blur = radius/resolution/4;     

                int repeatValue = ceil(repeat);

                for(int a=0;a<repeatValue;a++){
                    sum += tex2D(_GrabTexture, float2(tc.x - (a+1)*blur*hstep, tc.y - (a+1)*blur*vstep)) *( 0.1945945946 / (a+1));

                }

                for(int b=0;b<repeatValue;b++){
                    sum += tex2D(_GrabTexture, float2(tc.x + (b+1)*blur*-hstep, tc.y + (b+1)*blur*vstep)) *( 0.1945945946 / (b+1));
                }

                sum += tex2D(_GrabTexture, float2(tc.x, tc.y)) * 0.2270270270;

                for(int c=0;c<repeatValue;c++){
                    sum += tex2D(_GrabTexture, float2(tc.x + (c+1)*blur*hstep, tc.y + (c+1)*blur*vstep)) * (0.1945945946/ (c+1));
                }

                for(int d=0;d<repeatValue;d++){
                    sum += tex2D(_GrabTexture, float2(tc.x + (d+1)*blur*hstep, tc.y + (d+1)*blur*-vstep)) * (0.1945945946/ (d+1));
                }

                fixed4 blurValue = float4(  sum.rgb, 1)*_Color;

                return blurValue * blurTexValue;
            }    
            ENDCG
        }
    }
    Fallback "Sprites/Default"    
}