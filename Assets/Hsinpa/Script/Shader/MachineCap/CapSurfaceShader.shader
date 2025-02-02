﻿Shader "Hsinpa/MachineCatCap"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _EmisisonStrength("EmissionStr", Range(0,1)) = 0.0
        _EmissionMaskTex("Albedo (RGB)", 2D) = "white" {}
        _EmissionNoiseTex("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _EmissionMaskTex;
        sampler2D _EmissionNoiseTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        half _EmisisonStrength;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed normalizeSinTime = (_SinTime.w + 2.0 * 0.5) * 2;

            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 emissionMask = tex2D(_EmissionMaskTex, IN.uv_MainTex);

            fixed emissionSize = 2.0;
            fixed2 emissionUV = fixed2(IN.uv_MainTex.x * emissionSize + _SinTime.x, (IN.uv_MainTex.y + _Time.y) * emissionSize);
            fixed4 emissionNoise = tex2D(_EmissionNoiseTex, emissionUV).r;
            emissionNoise = emissionNoise * normalizeSinTime;

            fixed4 emission = c * (1 - emissionMask.x) * _EmisisonStrength * emissionNoise;

            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Emission = emission.rgb;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
