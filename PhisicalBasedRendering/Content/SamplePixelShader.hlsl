struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float3 usablePos : POSITION;
	float3 lightPos : POSITION1;
	float3 view : VIEW;
	float3 normal : NORMAL;
};

#define PI 3.1415926538

float Heaviside(float x) {
	if (x > 0.0f) {
		return x;
	}
	return 0.0f;
}

float TrowbridgeReitz(float roughness2, float NdotH) {
	float nom = roughness2 * Heaviside(NdotH);
	float denom = PI * pow(pow(NdotH, 2) * (roughness2 - 1) + 1, 2);
	return nom / denom;
}

float innerVis(float roughness2, float3 normal, float3 halfway, float3 VorL) {
	float nom = Heaviside(dot(halfway, VorL));
	float nDot = dot(normal, VorL);
	float beforeSqrt = roughness2 + (1 - roughness2) * pow(nDot, 2);
	float sqrted = sqrt(beforeSqrt);
	return nom / (abs(nDot) + sqrted);
}

float Visibility(float roughness2, float3 normal, float3 halfway, float3 view, float3 light) {
	return innerVis(roughness2, normal, halfway, light) * innerVis(roughness2, normal, halfway, view);
}

float specular_brdf(float roughness2, float3 normal, float3 halfway, float3 view, float3 light) {
	float NdotH = dot(normal, halfway);
	return Visibility(roughness2, normal, halfway, view, light) * TrowbridgeReitz(roughness2, NdotH);
}

float3 diffuse_brdf(float3 color) {
	return 1/PI * color;
}

float4 main(PixelShaderInput input) : SV_TARGET
{
	float roughness = 0.1f;

	float3 color = { 1.0f, 0.18f, 0.68f };
	
	float3 normal = normalize(input.normal);
	float3 lightDir = normalize(input.lightPos - input.usablePos);
	float3 viewDir = normalize(input.view - input.usablePos);	
	float3 halfway = normalize(lightDir + viewDir);

	float specular = specular_brdf(roughness * roughness, normal, halfway, viewDir, lightDir);
	float3 specular3 = { specular , specular , specular };
	float3 diffuse = 0.5f * diffuse_brdf(color) / roughness;
	float3 dielectric_brdf = lerp(diffuse, specular3, 1 - roughness);

	return float4 (dielectric_brdf, 1.0f);
}
