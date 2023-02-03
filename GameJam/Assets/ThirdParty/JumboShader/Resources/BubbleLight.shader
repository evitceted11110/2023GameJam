Shader "Jumbo/Effect/BubbleLight"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_ShapeMask("Mask",2D) = "white"{}
		_Color("Color", Color) = (1,1,1,1)
		[MaterialToggle] COLOR_MASK("Use ColorMask", Float) = 1
		_ColorMask("ColorMask",2D) = "white"{}
		_MaskGrid("Mask Grid", Vector) = (10,10,0,0)
		_Speed("Speed", Range(0.1, 10)) = 1
		_MaskSizeX("X Size", Range(1,500)) = 10
		_MaskSizeY("Y Size", Range(1,500)) = 10
		_MaxAlpha("Max Alpha", Range(0,1)) = 0.7
		_MinAlpha("Min Alpha", Range(0,1)) = 0.2
		[MaterialToggle] RANDOM("Use Random", Float) = 1

	}
		SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 100
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
	{
		CGPROGRAM
#pragma multi_compile _ COLOR_MASK_ON
#pragma multi_compile _ RANDOM_ON
#pragma vertex vert
#pragma fragment frag
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
		float2 uv2 : TEXCOORD1;
		float2 uv3 : TEXCOORD2;
		UNITY_FOG_COORDS(1)
			float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _ShapeMask;
	float4 _ShapeMask_ST;
	sampler2D _ColorMask;
	float4 _ColorMask_ST;

	float _MaskSizeX;
	float _MaskSizeY;

	float4 _MaskGrid;

	float _Speed;
	float _MaxAlpha;
	float _MinAlpha;
	float4 _Color;
	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.uv2 = TRANSFORM_TEX(v.uv, _ShapeMask);
		o.uv3 = TRANSFORM_TEX(v.uv, _ColorMask);
		UNITY_TRANSFER_FOG(o,o.vertex);
		return o;
	}

	float random(float2 p)
	{
		p = frac(p*0.3183099 + .1);
		p *= 17.0;
		return frac(p.x*p.y*(p.x + p.y));
	}

	fixed4 frag(v2f i) : SV_Target
	{

		float2 scale = float2(_MaskSizeX,_MaskSizeY);	//grid
		float timeSpeed = _Time.y*_Speed;
#ifdef RANDOM_ON
		timeSpeed *= random(floor(i.uv*scale));
#endif

		float tempStep = ceil(timeSpeed);				//Make sure step is integer

#ifdef COLOR_MASK_ON
		float2 step = float2(tempStep / _MaskGrid.x, 0);
		float2 nextStep = float2((tempStep + 1) / _MaskGrid.x, 0);
#else
		float2 step = float2(tempStep, 0);
		float2 nextStep = float2((tempStep + 1), 0);
#endif

		//Create Mask with scale
		float2 mask_uv = i.uv2*scale;
		fixed4 mask = tex2D(_ShapeMask, mask_uv);

#ifdef COLOR_MASK_ON
		float2 colorBlock_uv = i.uv3*scale / _MaskGrid;

		float2 firstColorBlockUV = step + colorBlock_uv;
		fixed4 colorBlock = tex2D(_ColorMask, firstColorBlockUV);

		float2 nextColorBlockUV = nextStep + colorBlock_uv;
		fixed4 nextColorBlock = tex2D(_ColorMask, nextColorBlockUV);
		//Apply Red intensity
		float colorBlockAvg = (colorBlock.r);
		float nextColorBlockAvg = (nextColorBlock.r);
#else
		float colorBlockAvg = random(step);
		float nextColorBlockAvg = random(nextStep);
#endif
		//Lerp from current color to next color
		mask.a *= lerp(colorBlockAvg, nextColorBlockAvg, fmod(timeSpeed, 1));
		mask.a = clamp(mask.a, _MinAlpha, _MaxAlpha);

		fixed4 col = tex2D(_MainTex, i.uv);
		col.rbg *= mask.a;
		return col * _Color;
	}
		ENDCG
	}
	}
}
