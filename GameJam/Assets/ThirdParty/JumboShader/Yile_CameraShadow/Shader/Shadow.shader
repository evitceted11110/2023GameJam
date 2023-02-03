// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Yile/Camera/Shadow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Repeat("Repeat",int)=5
		_BlurValue("Blur",Range(0,5))=1
		_Shift("Shift",Vector)=(0,0,0,0)
		_LoopShift("LoopShift",float)=0.001
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest always
		Blend SrcAlpha OneMinusSrcAlpha

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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			int _Repeat;
			float _BlurValue;
			float4 _Shift;
			float _LoopShift;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//基底偏移
				float2 shiftUV = i.uv + _Shift.xy; 
				//每個Loop偏移量
				fixed blurValue = _LoopShift;
				float shiftValues = float2(blurValue,blurValue);
				fixed4 finalResult = fixed4(0,0,0,0);

				//偏移次數
				int count = _Repeat;
				for(int i=1;i<count;i++){

					float2 loopShiftValues = shiftValues*i;
					float devideValue = _BlurValue * (i) /count;

					finalResult += tex2D(_MainTex,shiftUV + (loopShiftValues * float2(1,0)))*devideValue;
					finalResult += tex2D(_MainTex,shiftUV + (loopShiftValues * float2(0,1)))*devideValue;
					finalResult += tex2D(_MainTex,shiftUV + (loopShiftValues * float2(-1,0)))*devideValue;
					finalResult += tex2D(_MainTex,shiftUV + (loopShiftValues * float2(0,-1)))*devideValue;

					finalResult += tex2D(_MainTex,shiftUV + (loopShiftValues * float2(0.5,0.5)))*devideValue;
					finalResult += tex2D(_MainTex,shiftUV + (loopShiftValues * float2(-0.5,0.5)))*devideValue;
					finalResult += tex2D(_MainTex,shiftUV + (loopShiftValues * float2(0.5,-0.5)))*devideValue;
					finalResult += tex2D(_MainTex,shiftUV + (loopShiftValues * float2(-0.5,-0.5)))*devideValue;
				}
				fixed4 result = tex2D(_MainTex,shiftUV);
				finalResult.r *= result.a;
				return finalResult.r;
			}
			ENDCG
		}
	}
}
