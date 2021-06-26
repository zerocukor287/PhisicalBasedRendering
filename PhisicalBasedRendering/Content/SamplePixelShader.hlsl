struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float3 usablePos : POSITION;
	float3 lightPos : POSITION1;
	float3 view : VIEW;
	float3 normal : NORMAL;
};


float Heaviside(float x) {
	if (x > 0.0f) {
		return 1.0f;
	}
	return 0.0f;
}

float TrowbridgeReitz(float roughness2, float NdotH) {
	float PI = 3.14f;
	float top = roughness2 * Heaviside(NdotH);
	float bottom = PI * pow(pow(NdotH, 2) * (roughness2 - 1) + 1, 2);
	return top / bottom;
}

float innerVis(float roughness2, float3 normal, float3 halfway, float3 VorL) {
	float top = Heaviside(dot(halfway, VorL));
	float length = abs(dot(normal, VorL));
	float beforeSqrt = roughness2 + pow((1 - roughness2), 2) * pow(dot(normal, VorL), 2);
	float sqrted = sqrt(beforeSqrt);
	return top / (length + sqrted);
}

float Visibility(float roughness2, float3 normal, float3 halfway, float3 view, float3 light) {
	return innerVis(roughness2, normal, halfway, light) * innerVis(roughness2, normal, halfway, view);
}

float specular_brdf(float roughness2, float3 normal, float3 halfway, float3 view, float3 light) {
	float NdotH = dot(normal, halfway);
	return Visibility(roughness2, normal, halfway, view, light) * TrowbridgeReitz(roughness2, NdotH);
}

float3 diffuse_brdf(float3 color) {
	float PI = 3.14f;
	return 1/PI * color;
}

float4 main(PixelShaderInput input) : SV_TARGET
{
	float metalness = 0.5f;
	float roughness = 0.2f;

	float3 color = { 0.68f, 0.18f, 0.68f };
	
	float3 lightDir = normalize(input.lightPos - input.usablePos);
	float3 viewDir = normalize(input.view - input.usablePos);	
	float3 halfway = normalize(lightDir + viewDir);

	float3 VdotH = dot(viewDir, halfway);
	float specular = specular_brdf(pow(roughness, 2), input.normal, halfway, viewDir, lightDir);
	float3 specular3 = { specular , specular , specular };
	float3 diffuse = diffuse_brdf(color);
	float3 dielectric_brdf = lerp(diffuse, specular3, 0.04 + (1 - 0.04) * pow(1 - abs(VdotH), 5));

	return float4 (dielectric_brdf, 1.0f);
}
