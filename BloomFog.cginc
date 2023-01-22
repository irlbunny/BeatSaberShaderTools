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
  float eyeOffset = (unity_StereoEyeIndex * (_StereoCameraEyeOffset * 2)) + -_StereoCameraEyeOffset;
  float4 screenPos;
  screenPos.xyw = clipPos.yxw * 0.5f;
  screenPos.z = screenPos.x * _ProjectionParams.x;
  screenPos.yz = screenPos.ww + screenPos.yz;
  screenPos.x = (clipPos.w * eyeOffset) + screenPos.y;
  return float4(((-screenPos.ww + screenPos.xz) * _CustomFogTextureToScreenRatio) + screenPos.ww, clipPos.zw);
}

inline float GetHeightFogIntensity(float3 worldPos, float fogHeightOffset, float fogHeightScale) {
  float heightFogIntensity = _CustomFogHeightFogHeight + _CustomFogHeightFogStartY;
  heightFogIntensity = ((worldPos.y * fogHeightScale) + fogHeightOffset) + -heightFogIntensity;
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
#define BLOOM_FOG_COORDS(fogCoordIndex, worldPosIndex) \
  float4 fogCoord : TEXCOORD##fogCoordIndex; \
  float3 worldPos : TEXCOORD##worldPosIndex;

#define BLOOM_FOG_SURFACE_INPUT \
  float4 fogCoord; \
  float3 worldPos;

// vert: BLOOM_FOG_TRANSFER(o, v.vertex);
#define BLOOM_FOG_TRANSFER(outputStruct, inputVertex) \
  outputStruct.worldPos = mul(unity_ObjectToWorld, inputVertex); \
  outputStruct.fogCoord = GetFogCoord(UnityObjectToClipPos(inputVertex))

// frag: BLOOM_FOG_APPLY(i, col, _FogStartOffset, _FogScale);
#define BLOOM_FOG_APPLY(fogData, col, fogStartOffset, fogScale) \
  float3 fogDistance = fogData.worldPos + -_WorldSpaceCameraPos; \
  float4 fogCol = -float4(col.rgb, 1) + tex2D(_BloomPrePassTexture, fogData.fogCoord.xy / fogData.fogCoord.ww); \
  fogCol.a = -col.a; \
  col = col + ((GetFogIntensity(fogDistance, fogStartOffset, fogScale) + 1) * fogCol)

// frag: BLOOM_HEIGHT_FOG_APPLY(i, col, _FogStartOffset, _FogScale, _FogHeightOffset, _FogHeightScale);
#define BLOOM_HEIGHT_FOG_APPLY(fogData, col, fogStartOffset, fogScale, fogHeightOffset, fogHeightScale) \
  float3 fogDistance = fogData.worldPos + -_WorldSpaceCameraPos; \
  float4 fogCol = -float4(col.rgb, 1) + tex2D(_BloomPrePassTexture, fogData.fogCoord.xy / fogData.fogCoord.ww); \
  fogCol.a = -col.a; \
  col = col + (((GetHeightFogIntensity(fogData.worldPos, fogHeightOffset, fogHeightScale) * GetFogIntensity(fogDistance, fogStartOffset, fogScale)) + 1) * fogCol)

#else

#define BLOOM_FOG_COORDS(fogCoordIndex, worldPosIndex)
#define BLOOM_FOG_SURFACE_INPUT
#define BLOOM_FOG_TRANSFER(outputStruct, inputVertex)
#define BLOOM_FOG_APPLY(fogData, col, fogStartOffset, fogScale)
#define BLOOM_HEIGHT_FOG_APPLY(fogData, col, fogStartOffset, fogScale, fogHeightOffset, fogHeightScale)

#endif

#endif // BLOOM_FOG_CG_INCLUDED
