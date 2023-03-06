#ifndef CUSTOM_TONEMAPPING_CG_INCLUDED
#define CUSTOM_TONEMAPPING_CG_INCLUDED

// #pragma multi_compile __ ACES_TONE_MAPPING

#if ACES_TONE_MAPPING

// frag: ACES_TONE_MAPPING_APPLY(col);
#define ACES_TONE_MAPPING_APPLY(col) \
  float3 shoulderLinearCol = col.rgb * 2.50999999 + 0.0299999993; \
  shoulderLinearCol = col.rgb * shoulderLinearCol; \
  float3 linearToeCol = col.rgb * 2.43000007 + 0.589999974; \
  linearToeCol = col.rgb * linearToeCol + 0.140000001; \
  col.rgb = clamp(shoulderLinearCol / linearToeCol, 0, 1)

#else

#define ACES_TONE_MAPPING_APPLY(col)

#endif

#endif // CUSTOM_TONEMAPPING_CG_INCLUDED
