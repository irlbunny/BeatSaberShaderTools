# Beat Saber Shader Tools
Various tools for helping create shaders that work *properly* inside Beat Saber. If you have any issues, please report them in this repo or DM me on Discord: `kaitlyn~#3777`

## BloomFog.cginc
Allows for easily mixing in the Bloom Fog from Beat Saber with the output of your shader, allowing objects to cleanly fade in without popping in (e.g. custom notes). Properly handles fog attenuation/offset, works on PC and should work on Quest as well.

Notes:
- Height Fog is experimental and may have issues, use at your own risk!

Unlit Shader Usage:
- Include the CGINC in your shader, example: `#include "BloomFog.cginc"`
- Add `#pragma multi_compile __ ENABLE_BLOOM_FOG` in your shader to also build for `ENABLE_BLOOM_FOG`.
- In your `v2f`, add `BLOOM_FOG_COORDS(1, 2)`. (change `1` and `2` to an empty TEXCOORD number if TEXCOORD1/2 is populated)
- In your vertex function, at the end of it, add `BLOOM_FOG_TRANSFER(o, v.vertex);` right before the return.
- In your fragment function, at the end of it, add `BLOOM_FOG_APPLY(i, col, 0.0, 5.0);` right before the return.
- Done, your shader should now handle Beat Saber's Bloom Fog correctly!

Shader Examples:
- Unlit Texture (`KTexture.shader`)
- Unlit Glow (`KGlow.shader`)
- Surface Specular Fake Lighting (`KStandard.shader`)

## CustomLighting.cginc
Allows you to use Beat Saber's custom directional lighting (max of 5 directional lights), useful if you want to make your objects reactive with the environment lighting.

Notes:
- This is experimental, and is not 100% finished yet.
- Only works on surface shaders, not unlit shaders.

Shader Examples:
- Bloom Fog + Surface Specular Custom Lighting (`KStandardLighting.shader`)
