Shader "Unlit/KGlow" {
  Properties {
    _Color ("Color", Color) = (1,1,1,1)
    _MainTex ("Texture", 2D) = "white" {}
    _ColorAlpha ("Color Alpha", float) = 1
    _FogStartOffset ("Fog Start Offset", float) = 0
    _FogScale ("Fog Scale", float) = 1
    _Glow ("Deprecated", Range(1,1)) = 1
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 100

    Pass {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile __ ENABLE_BLOOM_FOG
      
      #include "UnityCG.cginc"
      #include "BloomFog.cginc"

      struct appdata {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct v2f {
        float2 uv : TEXCOORD0;
        BLOOM_FOG_COORDS(1, 2)
        float4 vertex : SV_POSITION;
      };

      fixed4 _Color;
      sampler2D _MainTex;
      float4 _MainTex_ST;
      float _ColorAlpha;
      float _FogStartOffset;
      float _FogScale;
      
      v2f vert (appdata v) {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        BLOOM_FOG_INITIALIZE(o, v.vertex);
        return o;
      }
      
      fixed4 frag (v2f i) : SV_Target {
        fixed4 col = tex2D(_MainTex, i.uv) * float4(_Color.rgb, _ColorAlpha);
        BLOOM_FOG_APPLY(i, col, _FogStartOffset, _FogScale);
        return col;
      }
      ENDCG
    }
  }
}
