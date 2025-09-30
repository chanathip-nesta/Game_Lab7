extends StaticBody3D

@onready var bottom_detector = $BottomDetector
@onready var mesh = $Mesh
@onready var particles = $Particles

var exploded = false

func _ready():
	bottom_detector.body_entered.connect(_on_bottom_hit)

func _on_bottom_hit(body: Node3D) -> void:
	if body.is_in_group("player") and !exploded:
		# ห้ามทำทันทีระหว่างสัญญาณ in/out
		call_deferred("_explode_safe")

func _explode_safe() -> void:
	if exploded:
		return
	exploded = true

	Audio.play("res://sounds/break.ogg")
	particles.restart()
	mesh.hide()

	# เปลี่ยนค่าที่เกี่ยวกับฟิสิกส์ด้วย set_deferred เสมอ
	$CollisionShape3D.set_deferred("disabled", true)
	bottom_detector.set_deferred("monitoring", false)
	# (ตัวเลือก) กันสัญญาณซ้ำ
	bottom_detector.set_deferred("monitorable", false)

	await get_tree().create_timer(1.0).timeout
	queue_free()
