#ifndef BLOOM_FOG_CG_INCLUDED
#define BLOOM_FOG_CG_INCLUDED

// #pragma multi_compile __ ENABLE_BLOOM_FOG

#if ENABLE_BLOOM_FOG

uniform float _CustomFogOffset;
uniform float _CustomFogAttenuation;
uniform float _CustomFogHeightFogStartY;
uniform float _CustomFogHeightFogHeight;
uniform sampler2D _BloomPrePassTexture;
uniform float2 _CustomFogTextureToScreenRatio;
uniform float _StereoCameraEyeOffset;

inline float4 GetFogCoord(float4 clipPos) {
  float eyeOffset = (unity_StereoEyeIndex * (_StereoCameraEyeOffset + _StereoCameraEyeOffset)) + -_StereoCameraEyeOffset;
  float4 screenPos;
  screenPos.xyw = clipPos.yxw * 0.5f;
  screenPos.z = screenPos.x * _ProjectionParams.x;
  screenPos.yz = screenPos.ww + screenPos.yz;
  screenPos.x = (clipPos.w * eyeOffset) + screenPos.y;
  return float4(((-screenPos.ww + screenPos.xz) * _CustomFogTextureToScreenRatio) + screenPos.ww, clipPos.zw);
}

inline float GetHeightFogIntensity(float3 distance, float fogHeightOffset, float fogHeightScale) {
  float heightFogIntensity = _CustomFogHeightFogHeight + _CustomFogHeightFogStartY;
  heightFogIntensity = ((distance.y * fogHeightScale) + fogHeightOffset) + -heightFogIntensity;
  heightFogIntensity = heightFogIntensity / _CustomFogHeightFogHeight;
  heightFogIntensity = clamp(heightFogIntensity, 0, 1);
  return ((-heightFogIntensity * 2) + 3) * (heightFogIntensity * heightFogIntensity);
}

inline float GetFogIntensity(float3 distance, float fogStartOffset, float fogScale) {
  float fogIntensity = max(dot(distance, distance) + -fogStartOffset, 0);
  fogIntensity = max((fogIntensity * fogScale) + -_CustomFogOffset, 0);
  fogIntensity = 1 / ((fogIntensity * _CustomFogAttenuation) + 1);
  return -fogIntensity;
}

// v2f: BLOOM_FOG_COORDS(1, 2)
#define BLOOM_FOG_COORDS(X, Y) \
  float4 fogCoord : TEXCOORD##X; \
  float3 worldPos : TEXCOORD##Y;

// vert: BLOOM_FOG_TRANSFER(o, o.vertex, v.vertex);
#define BLOOM_FOG_TRANSFER(TO_FRAG, OUTPUT_VERTEX, INPUT_VERTEX) \
  TO_FRAG.worldPos = mul(unity_ObjectToWorld, INPUT_VERTEX); \
  TO_FRAG.fogCoord = GetFogCoord(OUTPUT_VERTEX)

// frag: BLOOM_FOG_APPLY(i, col, _FogStartOffset, _FogScale);
#define BLOOM_FOG_APPLY(TO_FRAG, COLOR, FOG_START_OFFSET, FOG_SCALE) \
  float3 distance = TO_FRAG.worldPos + -_WorldSpaceCameraPos; \
  float4 fogCol = -float4(COLOR.rgb, 1) + tex2D(_BloomPrePassTexture, TO_FRAG.fogCoord.xy / TO_FRAG.fogCoord.ww); \
  fogCol.a = -COLOR.a; \
  COLOR = COLOR + ((GetFogIntensity(distance, FOG_START_OFFSET, FOG_SCALE) + 1) * fogCol)

// frag: BLOOM_HEIGHT_FOG_APPLY(i, col, _FogStartOffset, _FogScale, _FogHeightOffset, _FogHeightScale);
#define BLOOM_HEIGHT_FOG_APPLY(TO_FRAG, COLOR, FOG_START_OFFSET, FOG_SCALE, FOG_HEIGHT_OFFET, FOG_HEIGHT_SCALE) \
  float3 distance = TO_FRAG.worldPos + -_WorldSpaceCameraPos; \
  float4 fogCol = -float4(COLOR.rgb, 1) + tex2D(_BloomPrePassTexture, TO_FRAG.fogCoord.xy / TO_FRAG.fogCoord.ww); \
  fogCol.a = -COLOR.a; \
  COLOR = COLOR + (((GetHeightFogIntensity(distance, FOG_HEIGHT_OFFET, FOG_HEIGHT_SCALE) * GetFogIntensity(distance, FOG_START_OFFSET, FOG_SCALE)) + 1) * fogCol)

#else

#define BLOOM_FOG_COORDS(X, Y)
#define BLOOM_FOG_TRANSFER(TO_FRAG, OUTPUT_VERTEX, INPUT_VERTEX)
#define BLOOM_FOG_APPLY(TO_FRAG, COLOR, FOG_START_OFFSET, FOG_SCALE)
#define BLOOM_HEIGHT_FOG_APPLY(TO_FRAG, COLOR, FOG_START_OFFSET, FOG_SCALE, FOG_HEIGHT_OFFET, FOG_HEIGHT_SCALE)

#endif

#endif // BLOOM_FOG_CG_INCLUDED