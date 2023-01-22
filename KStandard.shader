Shader "Custom/KStandard" {
  Properties {
    _Color ("Color", Color) = (1,1,1,1)
    _MainTex ("Albedo (RGB)", 2D) = "white" {}
    _FakeLightDir ("Fake Light Direction", Vector) = (0,0,0,1)
    _FakeLightColor ("Fake Light Color", Color) = (1,1,1,1)
    _FakeLightAtten ("Fake Light Attenuation", float) = 1
    _FogHeightOffset ("Fog Height Offset", float) = 0
    _FogHeightScale ("Fog Height Scale", float) = 1
    _FogStartOffset ("Fog Start Offset", float) = 0
    _FogScale ("Fog Scale", float) = 1
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 200

    CGPROGRAM
    #pragma surface surf SimpleSpecular vertex:vert finalcolor:fogcolor nofog keepalpha
    #pragma multi_compile __ ENABLE_BLOOM_FOG

    #include "BloomFog.cginc"

    fixed4 _Color;
    sampler2D _MainTex;
    fixed4 _FakeLightDir;
    fixed4 _FakeLightColor;
    float _FakeLightAtten;
    float _FogHeightOffset;
    float _FogHeightScale;
    float _FogStartOffset;
    float _FogScale;

    half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
      half3 h = normalize(_FakeLightDir.xyz + viewDir);
      half diff = max(0, dot(s.Normal, _FakeLightDir.xyz));
      float nh = max(0, dot(s.Normal, h));
      float spec = pow(nh, 10);

      half4 c;
      c.rgb = (s.Albedo * _FakeLightColor.rgb * diff + _FakeLightColor.rgb * spec) * _FakeLightAtten;
      c.a = s.Alpha;
      return c;
    }

    struct Input {
      float2 uv_MainTex;
      BLOOM_FOG_SURFACE_INPUT
    };

    void vert (inout appdata_full v, out Input data) {
      UNITY_INITIALIZE_OUTPUT(Input, data);
      BLOOM_FOG_TRANSFER(data, v.vertex);
    }

    void fogcolor (Input IN, SurfaceOutput o, inout fixed4 color) {
      BLOOM_HEIGHT_FOG_APPLY(IN, color, _FogStartOffset, _FogScale, _FogHeightOffset, _FogHeightScale);
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
