#ifndef BLOOM_FOG_CG_INCLUDED
#define BLOOM_FOG_CG_INCLUDED

#if ENABLE_BLOOM_FOG

uniform float _StereoCameraEyeOffset;
uniform float2 _CustomFogTextureToScreenRatio;
uniform float _CustomFogAttenuation;
uniform float _CustomFogOffset;
uniform sampler2D _BloomPrePassTexture;

inline float4 GetFogCoord(float4 clipPos) {
  float eyeOffset = (unity_StereoEyeIndex * (_StereoCameraEyeOffset + _StereoCameraEyeOffset)) + -_StereoCameraEyeOffset;
  float4 screenPos;
  screenPos.xyw = clipPos.yxw * 0.5f;
  screenPos.z = screenPos.x * _ProjectionParams.x;
  screenPos.yz = screenPos.ww + screenPos.yz;
  screenPos.x = (clipPos.w * eyeOffset) + screenPos.y;
  return float4(((-screenPos.ww + screenPos.xz) * _CustomFogTextureToScreenRatio) + screenPos.ww, clipPos.zw);
}

#define BLOOM_FOG_COORDS(X, Y) float4 fogCoord : TEXCOORD##X; \
  float3 worldPos : TEXCOORD##Y;

#define BLOOM_FOG_TRANSFER(TO_FRAG, OUTPUT_VERTEX, INPUT_VERTEX) TO_FRAG.worldPos = mul(unity_ObjectToWorld, INPUT_VERTEX); \
  TO_FRAG.fogCoord = GetFogCoord(OUTPUT_VERTEX)

#define BLOOM_FOG_APPLY(TO_FRAG, COLOR, FOG_START_OFFSET, FOG_SCALE) float3 distance = TO_FRAG.worldPos + -_WorldSpaceCameraPos; \
  float fogIntensity = max(dot(distance, distance) + -FOG_START_OFFSET, 0); \
  fogIntensity = max((fogIntensity * FOG_SCALE) + -_CustomFogOffset, 0); \
  fogIntensity = 1 / ((fogIntensity * _CustomFogAttenuation) + 1); \
  fogIntensity = -fogIntensity + 1; \
  float4 fogCol = -float4(COLOR.rgb, 1) + tex2D(_BloomPrePassTexture, TO_FRAG.fogCoord.xy / TO_FRAG.fogCoord.ww); \
  fogCol.a = -COLOR.a; \
  COLOR = COLOR + (fogIntensity * fogCol)

#else

#define BLOOM_FOG_COORDS(X, Y)
#define BLOOM_FOG_TRANSFER(TO_FRAG, OUTPUT_VERTEX, INPUT_VERTEX)
#define BLOOM_FOG_APPLY(TO_FRAG, COLOR, FOG_START_OFFSET, FOG_SCALE)

#endif

#endif // BLOOM_FOG_CG_INCLUDED