extends Camera2D

var shake_amount = 0.0
var shake_decay = 5.0
var rng = RandomNumberGenerator.new()

func _process(delta):
	if shake_amount > 0:
		offset = Vector2(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-1.0, 1.0)
		) * shake_amount
		shake_amount = lerp(shake_amount, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

func shake(amount: float):
	shake_amount = amount
