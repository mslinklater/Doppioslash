Shader "Custom/SpecularShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,0,0,1)
		_DiffuseTex ("Texture", 2D) = "white" {}
		_Ambient ("Ambient", Range(0,1)) = 0.25
		_SpecColor ("Specular Material Color", Color) = (1,1,1,1)
		_Shininess ("Shininess", Float) = 10
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			fixed4 _Color;
			sampler2D _DiffuseTex;
			float4 _DiffuseTex_ST;
			float _Ambient;
			float _Shininess;

			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 vertexWorld : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normalDirection = normalize(i.worldNormal);
				float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
				float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));

				// Diffuse term
				float nl = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
				float4 tex = tex2D(_DiffuseTex, i.uv);
				float4 diffuseTerm = nl * _Color * tex * _LightColor0;

				// Specular term
				float3 reflectionDirection = reflect(-lightDirection, normalDirection);
				float3 specularDot = max(0.0, dot(viewDirection, reflectionDirection));
				float3 specular = pow(specularDot, _Shininess);
				float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0;

				float4 finalColor = diffuseTerm + specularTerm;
				return finalColor;
			}
			ENDCG
		}
	}
}
