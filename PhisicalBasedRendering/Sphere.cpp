#include "pch.h"
#include "Sphere.h"

using namespace PhisicalBasedRendering;

constexpr float PI = 3.1415927f;

PhisicalBasedRendering::Sphere::Sphere(DirectX::XMFLOAT3 center, float radius, unsigned int rings, unsigned int sectors)
{
	const auto RingsRecip = 1.0f / (float)(rings - 1);
	const auto SectorsRecip = 1.0f / (float)(sectors - 1);
	unsigned int countRings, countSectors;

	vertices.resize(rings* sectors);

	auto v = vertices.begin();

	// Calculate vertices' position
	for (countRings = 0; countRings < rings; countRings++) {
		const auto y = static_cast<float>(sin(-PI / 2 + PI * countRings * RingsRecip) * radius);

		for (countSectors = 0; countSectors < sectors; countSectors++) {
			const auto x = static_cast<float>(cos(2 * PI * countSectors * SectorsRecip) * sin(PI * countRings * RingsRecip));
			const auto z = static_cast<float>(sin(2 * PI * countSectors * SectorsRecip) * sin(PI * countRings * RingsRecip));
			DirectX::XMFLOAT3 point{ x * radius + center.x, y + center.y, z * radius + center.z };
			DirectX::XMFLOAT3 normal{ x * radius, y, z * radius };
			*v++ = { point, normal };
		}
	}

	// Calculate indices 
	indices.resize(rings * sectors * 6);
	auto i = indices.begin();
	for (countRings = 0; countRings < rings - 1; countRings++) {
		for (countSectors = 0; countSectors < sectors - 1; countSectors++) {

			*i++ = (countRings + 0) * sectors + countSectors;				// added for half-symmetry
			*i++ = (countRings + 0) * sectors + (countSectors + 1);
			*i++ = (countRings + 1) * sectors + (countSectors + 1);

			*i++ = (countRings + 0) * sectors + countSectors;
			*i++ = (countRings + 1) * sectors + (countSectors + 1);
			*i++ = (countRings + 1) * sectors + countSectors;
		}
	}
}