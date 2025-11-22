extends Node
class_name ProceduralMeshes

# Procedural Mesh Generator for Royal Rush 3D
# Creates custom geometry using SurfaceTool

static func create_rounded_box(width: float, height: float, depth: float, corner_radius: float, segments: int = 8) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var hw = width / 2.0
	var hh = height / 2.0
	var hd = depth / 2.0
	var r = min(corner_radius, min(hw, hh))

	# Create front and back faces with rounded corners
	for z_sign in [-1, 1]:
		var z = hd * z_sign
		var normal = Vector3(0, 0, z_sign)

		# Center rectangle
		_add_quad(st,
			Vector3(-hw + r, -hh + r, z),
			Vector3(hw - r, -hh + r, z),
			Vector3(hw - r, hh - r, z),
			Vector3(-hw + r, hh - r, z),
			normal)

		# Edge rectangles
		_add_quad(st,
			Vector3(-hw + r, hh - r, z),
			Vector3(hw - r, hh - r, z),
			Vector3(hw - r, hh, z),
			Vector3(-hw + r, hh, z),
			normal)

		_add_quad(st,
			Vector3(-hw + r, -hh, z),
			Vector3(hw - r, -hh, z),
			Vector3(hw - r, -hh + r, z),
			Vector3(-hw + r, -hh + r, z),
			normal)

		_add_quad(st,
			Vector3(-hw, -hh + r, z),
			Vector3(-hw + r, -hh + r, z),
			Vector3(-hw + r, hh - r, z),
			Vector3(-hw, hh - r, z),
			normal)

		_add_quad(st,
			Vector3(hw - r, -hh + r, z),
			Vector3(hw, -hh + r, z),
			Vector3(hw, hh - r, z),
			Vector3(hw - r, hh - r, z),
			normal)

		# Corner arcs
		for corner in [
			Vector2(-hw + r, hh - r),
			Vector2(hw - r, hh - r),
			Vector2(hw - r, -hh + r),
			Vector2(-hw + r, -hh + r)
		]:
			var start_angle = 0.0
			if corner.x < 0 and corner.y > 0:
				start_angle = PI / 2
			elif corner.x < 0 and corner.y < 0:
				start_angle = PI
			elif corner.x > 0 and corner.y < 0:
				start_angle = 3 * PI / 2

			for i in range(segments):
				var a1 = start_angle + (i * PI / 2 / segments)
				var a2 = start_angle + ((i + 1) * PI / 2 / segments)

				var p1 = Vector3(corner.x, corner.y, z)
				var p2 = Vector3(corner.x + cos(a1) * r, corner.y + sin(a1) * r, z)
				var p3 = Vector3(corner.x + cos(a2) * r, corner.y + sin(a2) * r, z)

				st.set_normal(normal)
				st.add_vertex(p1)
				st.add_vertex(p2 if z_sign > 0 else p3)
				st.add_vertex(p3 if z_sign > 0 else p2)

	# Side faces
	_add_quad(st,
		Vector3(-hw, -hh + r, -hd),
		Vector3(-hw, -hh + r, hd),
		Vector3(-hw, hh - r, hd),
		Vector3(-hw, hh - r, -hd),
		Vector3(-1, 0, 0))

	_add_quad(st,
		Vector3(hw, -hh + r, hd),
		Vector3(hw, -hh + r, -hd),
		Vector3(hw, hh - r, -hd),
		Vector3(hw, hh - r, hd),
		Vector3(1, 0, 0))

	_add_quad(st,
		Vector3(-hw + r, hh, -hd),
		Vector3(-hw + r, hh, hd),
		Vector3(hw - r, hh, hd),
		Vector3(hw - r, hh, -hd),
		Vector3(0, 1, 0))

	_add_quad(st,
		Vector3(-hw + r, -hh, hd),
		Vector3(-hw + r, -hh, -hd),
		Vector3(hw - r, -hh, -hd),
		Vector3(hw - r, -hh, hd),
		Vector3(0, -1, 0))

	st.generate_tangents()
	return st.commit()

static func _add_quad(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3, normal: Vector3) -> void:
	st.set_normal(normal)
	st.add_vertex(p1)
	st.add_vertex(p2)
	st.add_vertex(p3)

	st.set_normal(normal)
	st.add_vertex(p1)
	st.add_vertex(p3)
	st.add_vertex(p4)

static func create_playing_card(width: float = 0.8, height: float = 1.2, thickness: float = 0.02) -> ArrayMesh:
	# Create a card with slightly rounded corners
	return create_rounded_box(width, height, thickness, 0.05, 6)

static func create_chip(radius: float = 0.15, height: float = 0.05, segments: int = 16) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half_h = height / 2.0

	# Top and bottom faces
	for y_sign in [-1, 1]:
		var y = half_h * y_sign
		var normal = Vector3(0, y_sign, 0)

		for i in range(segments):
			var a1 = i * TAU / segments
			var a2 = (i + 1) * TAU / segments

			var center = Vector3(0, y, 0)
			var p1 = Vector3(cos(a1) * radius, y, sin(a1) * radius)
			var p2 = Vector3(cos(a2) * radius, y, sin(a2) * radius)

			st.set_normal(normal)
			st.add_vertex(center)
			st.add_vertex(p1 if y_sign > 0 else p2)
			st.add_vertex(p2 if y_sign > 0 else p1)

	# Side face
	for i in range(segments):
		var a1 = i * TAU / segments
		var a2 = (i + 1) * TAU / segments

		var p1 = Vector3(cos(a1) * radius, -half_h, sin(a1) * radius)
		var p2 = Vector3(cos(a2) * radius, -half_h, sin(a2) * radius)
		var p3 = Vector3(cos(a2) * radius, half_h, sin(a2) * radius)
		var p4 = Vector3(cos(a1) * radius, half_h, sin(a1) * radius)

		var normal = Vector3(cos((a1 + a2) / 2), 0, sin((a1 + a2) / 2))
		_add_quad(st, p1, p2, p3, p4, normal)

	st.generate_tangents()
	return st.commit()
