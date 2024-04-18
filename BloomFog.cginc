#ifndef BLOOM_FOG_CG_INCLUDED
#define BLOOM_FOG_CG_INCLUDED

#if ENABLE_BLOOM_FOG

uniform float _CustomFogOffset;
uniform float _CustomFogAttenuation;
uniform float _CustomFogHeightFogStartY;
uniform float _CustomFogHeightFogHeight;
uniform sampler2D _BloomPrePassTexture;
uniform float2 _CustomFogTextureToScreenRatio;
uniform float _StereoCameraEyeOffset;

inline float4 GetFogCoord(float4 worldPos) {
  float4 u_xlat1;
  float4 u_xlat3;

  float eyeOffset = (unity_StereoEyeIndex * (_StereoCameraEyeOffset * 2)) + -_StereoCameraEyeOffset;
  u_xlat1 = mul(unity_MatrixVP, worldPos);
  u_xlat3.xyw = u_xlat1.yxw * float3(0.5, 0.5, 0.5);
  u_xlat3.z = u_xlat3.x * _ProjectionParams.x;
  u_xlat3.yz = u_xlat1.ww * float2(0.5, 0.5) + u_xlat3.yz;
  u_xlat3.x = u_xlat1.w * eyeOffset + u_xlat3.y;
  u_xlat3.xy = (-u_xlat1.ww) * float2(0.5, 0.5) + u_xlat3.xz;
  return float4(u_xlat3.xy * _CustomFogTextureToScreenRatio.xy + u_xlat3.ww, u_xlat1.zw);
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

#define BLOOM_FOG_COORDS(fogCoordIndex, worldPosIndex) \
  float4 fogCoord : TEXCOORD##fogCoordIndex; \
  float4 fogWorldPos : TEXCOORD##worldPosIndex;

#define BLOOM_FOG_SURFACE_INPUT \
  float4 fogCoord; \
  float4 fogWorldPos;

#define BLOOM_FOG_INITIALIZE(outputStruct, vertex) \
  outputStruct.fogWorldPos = mul(unity_ObjectToWorld, float4(vertex.xyz, 1)); \
  outputStruct.fogCoord = GetFogCoord(outputStruct.fogWorldPos)

#define BLOOM_FOG_SAMPLE(fogData) \
  tex2D(_BloomPrePassTexture, fogData.fogCoord.xy / fogData.fogCoord.w)

#define BLOOM_FOG_APPLY(fogData, col, fogStartOffset, fogScale) \
  float3 fogDistance = fogData.fogWorldPos.xyz + -_WorldSpaceCameraPos; \
  float4 fogCol = -float4(col.rgb, 1) + BLOOM_FOG_SAMPLE(fogData); \
  fogCol.a = -col.a; \
  col = col + ((GetFogIntensity(fogDistance, fogStartOffset, fogScale) + 1) * fogCol)

#define BLOOM_HEIGHT_FOG_APPLY(fogData, col, fogStartOffset, fogScale, fogHeightOffset, fogHeightScale) \
  float3 fogDistance = fogData.fogWorldPos.xyz + -_WorldSpaceCameraPos; \
  float4 fogCol = -float4(col.rgb, 1) + BLOOM_FOG_SAMPLE(fogData); \
  fogCol.a = -col.a; \
  col = col + (((GetHeightFogIntensity(fogData.fogWorldPos.xyz, fogHeightOffset, fogHeightScale) * GetFogIntensity(fogDistance, fogStartOffset, fogScale)) + 1) * fogCol)

#else

#define BLOOM_FOG_COORDS(fogCoordIndex, worldPosIndex)
#define BLOOM_FOG_SURFACE_INPUT

#define BLOOM_FOG_INITIALIZE(outputStruct, inputVertex)
#define BLOOM_FOG_APPLY(fogData, col, fogStartOffset, fogScale)

#define BLOOM_HEIGHT_FOG_APPLY(fogData, col, fogStartOffset, fogScale, fogHeightOffset, fogHeightScale)

#endif

#endif // BLOOM_FOG_CG_INCLUDED
