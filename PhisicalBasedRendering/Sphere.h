#pragma once

#include <vector>
#include "Content/ShaderStructures.h"
#include <DirectXMath.h>

namespace PhisicalBasedRendering {
	class Sphere {
	public:
		Sphere(DirectX::XMFLOAT3 center,
			float radius,
			unsigned int rings,
			unsigned int sectors);
		virtual ~Sphere() = default;

		std::vector<VertexPositionColor>& getVertices() {
			return vertices;
		};
		std::vector<unsigned int>& getIndices() {
			return indices;
		};
	private:
		std::vector<VertexPositionColor> vertices;
		std::vector<unsigned int> indices;
	};
}