Shader "Unlit/KTexture" {
  Properties {
    _MainTex ("Texture", 2D) = "white" {}
    _FogStartOffset ("Fog Start Offset", float) = 0
    _FogScale ("Fog Scale", float) = 1
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
        float4 vertex : SV_POSITION;
        BLOOM_FOG_COORDS(1, 2)
        float2 uv : TEXCOORD3;
      };

      sampler2D _MainTex;
      float4 _MainTex_ST;
      float _FogStartOffset;
      float _FogScale;
      
      v2f vert (appdata v) {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        BLOOM_FOG_TRANSFER(o, o.vertex, v.vertex);
        return o;
      }
      
      fixed4 frag (v2f i) : SV_Target {
        float4 col = tex2D(_MainTex, i.uv);
        col.a = 0;
        BLOOM_FOG_APPLY(i, col, _FogStartOffset, _FogScale);
        return col;
      }
      ENDCG
    }
  }
}
