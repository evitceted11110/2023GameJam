/*
ShapMask Ver2.2
Fix Nvidia Rectangle Error
*/
Shader "Yile/UI/Image_ShapeMask"
{
	Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
		[Enum(Circle, 0,Ellipse,1 , Rectangle, 2, Polygon, 3, CustomRectangle, 4)] _Shape("Shape",float)=0
		_Width("Width",Range(0,1)) = 0
		_Height("Height",Range(0,1)) = 0
		_Radius("Radius",Range(0,1)) = 0
		[IntRange]_Sides("Sides",Range(3,16)) = 4
		_CustomRectangle("CustomRect",vector)=(0,0,0,0)
		[Enum(Average, 0,Width,1 , Height, 2)] _RectDefine("RectDefine",float)=0
		_Size("Size",vector)=(0,0,0,0)
		_Inverse ("Inverse", Float) = 0

		_StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
		_ColorMask ("Color Mask", Float) = 15
		 [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
        
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_ALPHACLIP
           // #pragma multi_compile _ INVERSE_ON
            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                half2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
            };
            
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
			float4 _CustomRectangle;
			float _Width,_Height,_Radius,_Sides;
			float _Inverse;
			float _Shape;
			float _RectDefine;
			float4 _Size;
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.worldPosition = IN.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = IN.texcoord ;
                
                #ifdef UNITY_HALF_TEXEL_OFFSET
                OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1) * OUT.vertex.w;
                #endif
                
                OUT.color = IN.color * _Color;
                return OUT;
            }

            sampler2D _MainTex;

			float is_Equal(float x, float y){
				return 1.0 - abs(sign(x-y));
			}

			float Remap(float x, float2 t,float2 s)
			{
				return (x - t.x) / (t.y - t.x) * (s.y - s.x) + s.x;
			}

			float DistanceFromCenter(float2 uv){
				float distance = sqrt(pow(uv.x - 0.5, 2) + pow(uv.y - 0.5, 2));
				return distance;
			}

			float4 Unity_Ellipse_float(float2 UV, float Width, float Height)
			{
				float d = length((UV * 2 - 1) / float2(Width, Height));
				return saturate((1 - d) / fwidth(d));
			}	

			float CalculateRectUV(float uv,float bigSide, float smallSide){
			
				float sideLength =  (bigSide - (bigSide-smallSide)) /2 ;
				float minUV = sideLength/ bigSide;
				float maxUV = 1-minUV;

				float finalResult = 0.5f;

				finalResult += step(uv,minUV) * (-finalResult + Remap(uv, float2(0,minUV), float2(0,0.5) ));
				finalResult += step(maxUV,uv) * (-finalResult + Remap(uv, float2(maxUV,1), float2(0.5,1) ));

				return finalResult;

			}

			float Unity_RoundedRectangle_float(float2 UV, float Width, float Height, float Radius)
			{

				float2 tempUV = UV;

				//寬為主
				tempUV.x += is_Equal(_RectDefine,1) * (-tempUV.x + CalculateRectUV(tempUV.x,_Size.x,_Size.y));
				//高為主
				tempUV.y += is_Equal(_RectDefine,2) * (-tempUV.y + CalculateRectUV(tempUV.y,_Size.y,_Size.x));


				Radius = max(min(min(abs(Radius * 2), abs(Width)), abs(Height)), 1e-5);
				float2 uv = abs(tempUV * 2 - 1) - float2(Width, Height) + Radius;
				float d = length(max(0, uv)) / Radius;
				return step(0.0001f,(1-d));
				//return saturate((1 - d) / fwidth(d));
			}

			

			float Unity_Polygon_float(float2 UV, float Sides, float Width, float Height)
			{
				float pi = 3.14159265359;
				float aWidth = Width * cos(pi / Sides);
				float aHeight = Height * cos(pi / Sides);
				float2 uv = (UV * 2 - 1) / float2(aWidth, aHeight);
				uv.y *= -1;
				float pCoord = atan2(uv.x, uv.y);
				float r = 2 * pi / Sides;
				float distance = cos(floor(0.5 + pCoord / r) * r - pCoord) * length(uv);
				return saturate((1 - distance) / fwidth(distance));
			}

			

			float Custom_Rectangle(float2 UV, float Width, float Height, float4 customVector){
				float top_right = step(0.5,UV.x) * step(0.5,UV.y) * customVector.x;
				float top_left = step(UV.x,0.5) * step(0.5,UV.y)* customVector.y;
				float buttom_left = step(UV.x,0.5) * step(UV.y,0.5)* customVector.z;
				float buttom_right = step(0.5,UV.x) * step(UV.y,0.5)* customVector.w;

				float center = is_Equal(0.5,UV.x) + is_Equal(0.5,UV.y);

				float result = top_right + top_left + buttom_right + buttom_left + center;

				return Unity_RoundedRectangle_float(UV,Width,Height,result);
			}


            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				//Circle
				float circleMask = is_Equal(_Shape,0) * (1-step(_Radius,DistanceFromCenter(IN.texcoord)));

				//Ellipse
				float ellipseMask = is_Equal(_Shape,1) * Unity_Ellipse_float(IN.texcoord,_Width,_Height);
				
				//Rectangle
				float rectangleMask = is_Equal(_Shape,2) * Unity_RoundedRectangle_float(IN.texcoord,_Width,_Height,_Radius);
				
				//Polygon
				float polygonMask = is_Equal(_Shape,3) * Unity_Polygon_float(IN.texcoord,_Sides,_Width,_Height);

				//CustomRectangle
				float customRectMask = is_Equal(_Shape,4) * Custom_Rectangle(IN.texcoord,_Width,_Height,_CustomRectangle);

				float maskValue = circleMask + ellipseMask + rectangleMask + polygonMask+customRectMask;
				maskValue = ((1-maskValue)*_Inverse) + ((1-_Inverse) * maskValue);

                color.a = maskValue;
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                
                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }
        ENDCG
        }
    }
}
