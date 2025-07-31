extends Node2D

@export var turns := 6
@export var spacing := 35.0
@export var resolution := 100
@export var rotation_speed := -30.0  # Radians per second

func _draw():
	var points = []
	for i in range(resolution * turns):
		var angle = i * TAU / resolution
		var radius = i * spacing / resolution
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.DARK_RED, 12.0)

func _process(delta):
	rotation += rotation_speed * delta
