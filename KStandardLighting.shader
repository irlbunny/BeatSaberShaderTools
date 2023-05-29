Shader "Custom/KStandardLighting" {
  Properties {
    _Color ("Color", Color) = (1,1,1,1)
    _MainTex ("Albedo (RGB)", 2D) = "white" {}
    _FogStartOffset ("Fog Start Offset", float) = 0
    _FogScale ("Fog Scale", float) = 1
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 200

    CGPROGRAM
    #pragma surface surf CustomSpecular vertex:vert finalcolor:fogcolor nofog keepalpha
    #pragma multi_compile __ ENABLE_BLOOM_FOG
    #pragma target 3.0

    #include "BloomFog.cginc"
    #include "CustomLighting.cginc"

    fixed4 _Color;
    sampler2D _MainTex;
    float _FogStartOffset;
    float _FogScale;

    struct Input {
      float2 uv_MainTex;
      BLOOM_FOG_SURFACE_INPUT
    };

    void vert (inout appdata_full v, out Input data) {
      UNITY_INITIALIZE_OUTPUT(Input, data);
      BLOOM_FOG_INITIALIZE(data, v.vertex);
    }

    void fogcolor (Input IN, SurfaceOutput o, inout fixed4 color) {
      BLOOM_FOG_APPLY(IN, color, _FogStartOffset, _FogScale);
    }

    void surf (Input IN, inout SurfaceOutput o) {
      fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
      o.Albedo = c.rgb;
      o.Alpha = 0;
    }
    ENDCG
  }
  FallBack "Diffuse"
}
