#ifndef CUSTOM_LIGHTING_CG_INCLUDED
#define CUSTOM_LIGHTING_CG_INCLUDED

// Hardcoded to 5, thanks Beat Games.
uniform float4 _DirectionalLightDirections[5];
uniform float4 _DirectionalLightPositions[5]; // ?? No idea how to use this, ATM.
uniform float _DirectionalLightRadii[5];
uniform float4 _DirectionalLightColors[5];

half4 LightingCustomSpecular(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
  half4 c;

  for (int i = 0; i < 5; i++) {
    float4 directionalLightDirection = _DirectionalLightDirections[i];
    float directionalLightRadius = _DirectionalLightRadii[i];
    float4 directionalLightColor = _DirectionalLightColors[i];

    half3 h = normalize(directionalLightDirection.xyz + viewDir);
    half diff = max(0, dot(s.Normal, directionalLightDirection.xyz));
    float nh = max(0, dot(s.Normal, h));
    float spec = pow(nh, 48);

    c.rgb = c.rgb + ((s.Albedo * directionalLightColor.rgb * diff + directionalLightColor.rgb * spec * directionalLightRadius) * 0.005);
  }

  c.a = s.Alpha;
  return c;
}

#endif // CUSTOM_LIGHTING_CG_INCLUDED
