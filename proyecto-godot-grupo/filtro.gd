extends StaticBody3D

signal nivel_completado

@export var radio_entrega: float = 4.0
@export var tiempo_llenado: float = 2.0

@onready var agua: MeshInstance3D = $Agua

var completado: bool = false
var jugador: Player

func _ready() -> void:
	add_to_group("filtro")
	_llenar_agua(0.0)
	await get_tree().process_frame
	jugador = get_tree().get_first_node_in_group("jugador")

func _physics_process(_delta: float) -> void:
	if completado or jugador == null:
		return
	if jugador.basura_recogida < jugador.MAX_BASURA:
		return
	if global_position.distance_to(jugador.global_position) <= radio_entrega:
		_completar()

func _completar() -> void:
	completado = true
	jugador.basura_recogida = 0
	jugador.basura_cambiada.emit(0, jugador.MAX_BASURA)
	var tween := create_tween()
	tween.tween_method(_llenar_agua, 0.0, 1.0, tiempo_llenado)
	nivel_completado.emit()

func _llenar_agua(t: float) -> void:
	agua.scale.y = maxf(t, 0.02)
	agua.position.y = 2.0 + 0.5 * agua.scale.y
