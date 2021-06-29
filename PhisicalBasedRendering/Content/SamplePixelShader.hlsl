struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float3 usablePos : POSITION;
	float3 lightPos : POSITION1;
	float3 view : VIEW;
	float3 normal : NORMAL;
};

#define PI 3.1415926538

float heaviside(float x) {
	if (x > 0.0f) {
		return x;
	}
	return 0.0f;
}

float TrowbridgeReitz(float roughness2, float NdotH) {
	float NHR = NdotH * NdotH * (roughness2 - 1) + 1;
	float denom = PI * NHR * NHR;
	return roughness2 * heaviside(NdotH) / denom;
}

float innerVis(float roughness2, float3 normal, float3 halfway, float3 VorL) {
	float nDot = dot(normal, VorL);
	float RNsqrt = sqrt(roughness2 + (1 - roughness2) * nDot * nDot);
	return heaviside(dot(halfway, VorL)) / (abs(nDot) + RNsqrt);
}

float visibility(float roughness2, float3 normal, float3 halfway, float3 view, float3 light) {
	return innerVis(roughness2, normal, halfway, light) * innerVis(roughness2, normal, halfway, view);
}

float specular_brdf(float roughness2, float3 normal, float3 halfway, float3 view, float3 light) {
	return visibility(roughness2, normal, halfway, view, light) * TrowbridgeReitz(roughness2, dot(normal, halfway));
}

float3 diffuse_brdf(float3 color) {
	return 1/PI * color;
}

float4 main(PixelShaderInput input) : SV_TARGET
{
	float roughness = 0.25f;

	float3 normal = normalize(input.normal);
	float3 lightDir = normalize(input.lightPos - input.usablePos);
	float3 viewDir = normalize(input.view - input.usablePos);	
	float3 halfway = normalize(lightDir + viewDir);

	float specular = specular_brdf(roughness * roughness, normal, halfway, viewDir, lightDir);
	float3 specular3 = { specular , specular , specular };
	float3 diffuse = 0.5f * diffuse_brdf(float3 (1.0f, 0.18f, 0.68f)) / roughness;
	float3 dielectric_brdf = lerp(diffuse, specular3, 1 - roughness);

	return float4 (dielectric_brdf, 1.0f);
}
