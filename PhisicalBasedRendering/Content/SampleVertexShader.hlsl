cbuffer ModelViewProjectionConstantBuffer : register(b0)
{
	matrix model;
	matrix view;
	matrix projection;
};

struct VertexShaderInput
{
	float3 pos : POSITION;
	float3 normal : NORMAL;
};

struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float3 usablePos : POSITION;
	float3 lightPos : POSITION1;
	float3 view : VIEW;
	float3 normal : NORMAL;
};

PixelShaderInput main(VertexShaderInput input)
{
	PixelShaderInput output;
	float4 pos = float4(input.pos, 1.0f);

	pos = mul(pos, model);
	pos = mul(pos, view);
	pos = mul(pos, projection);
	output.pos = pos;
	output.usablePos = pos.xyz;

	float4 normal = float4(input.normal, 1.0f);

	normal = mul(normal, model);
	normal = mul(normal, view);
	normal = mul(normal, projection);
	output.normal = normal.xyz;

	output.lightPos = float3(0.2f, 0.75f, 1.25f);
	output.view = float3(0.0f, 0.7f, 1.5f);

	return output;
}
