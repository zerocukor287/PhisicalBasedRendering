struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float3 usablePos : POSITION;
	float3 lightPos : POSITION1;
	float3 normal : NORMAL;
};

float3 calcSpecular() {
	return float3 (0.0f, 0.0f, 0.0f);
}

float3 calcDiffuse(float3 inputColor) {
	return inputColor;
}

float4 main(PixelShaderInput input) : SV_TARGET
{
	float metalness = 0.5f;
	float roughtness = 0.2f;

	float3 color = { 0.68f, 0.18f, 0.68f };
	
	float3 lightPos = input.lightPos;
	float3 lightDir = normalize(lightPos - input.usablePos);

	float3 diffuse = dot(lightDir, input.normal);
	float3 finColor = calcDiffuse(diffuse * color) + calcSpecular();
	return float4 (finColor, 1.0f);
}
