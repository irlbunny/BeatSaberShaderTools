# Beat Saber Shader Tools
Various tools for helping create shaders that work *properly* inside Beat Saber. If you have any issues, please report them in this repo or DM me on Discord: `kaitlyn~#3777`

## BloomFog.cginc
Allows for easily mixing in the Bloom Fog from Beat Saber with the output of your shader, allowing objects to cleanly fade in without popping in (e.g. custom notes). Properly handles fog attenuation/offset, works on PC and should work on Quest as well.

Usage:
- Include the CGINC in your shader, example: `#include "Assets/Shaders/BloomFog.cginc"`
- Add `#pragma multi_compile __ ENABLE_BLOOM_FOG` in your shader to also build for `ENABLE_BLOOM_FOG`.
- In your `v2f`, add `BLOOM_FOG_COORDS(1, 2)`. (change `1` and `2` to an empty TEXCOORD number if TEXCOORD1/2 is populated)
- In your vertex function, at the end of it, add `BLOOM_FOG_TRANSFER(o, o.vertex, v.vertex);` right before the return. (`o.vertex` must be the output of `UnityObjectToClipPos(v.vertex)`)
- In your fragment function, at the end of it, add `BLOOM_FOG_APPLY(i, col, 0, 5);` right before the return.
- Done, your shader should now handle Beat Saber's Bloom Fog correctly!

Example:
```
Shader "BeatSaber/BloomFog/Texture" {
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
      #include "Assets/Shaders/BloomFog.cginc"

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
```
