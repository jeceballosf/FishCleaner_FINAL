extends CanvasLayer

const TIEMPO_AVISO := 4.0

@onready var label: Label = $ContadorLabel
var _aviso: Label

func _ready() -> void:
	_crear_aviso()
	await get_tree().process_frame
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		push_error("No se encontró al jugador en el grupo 'jugador'")
		return
	jugador.basura_cambiada.connect(_actualizar)
	_actualizar(jugador.basura_recogida, jugador.MAX_BASURA)
	var filtro = get_tree().get_first_node_in_group("filtro")
	if filtro:
		filtro.nivel_completado.connect(mostrar_nivel_completado)

func _actualizar(cantidad: int, maximo: int) -> void:
	label.text = "Basura: %d / %d" % [cantidad, maximo]
	if cantidad >= maximo:
		label.text += "  ¡LLENO!"

func _crear_aviso() -> void:
	_aviso = Label.new()
	_aviso.text = "¡NIVEL COMPLETADO!"
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_aviso.add_theme_font_size_override("font_size", 96)
	_aviso.add_theme_color_override("font_color", Color.WHITE)
	_aviso.add_theme_color_override("font_outline_color", Color.BLACK)
	_aviso.add_theme_constant_override("outline_size", 16)
	_aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aviso.visible = false
	add_child(_aviso)
	_aviso.anchor_left = 0.0
	_aviso.anchor_top = 0.0
	_aviso.anchor_right = 1.0
	_aviso.anchor_bottom = 1.0
	_aviso.offset_left = 0.0
	_aviso.offset_top = 0.0
	_aviso.offset_right = 0.0
	_aviso.offset_bottom = 0.0

func mostrar_nivel_completado() -> void:
	_aviso.visible = true
	_aviso.modulate.a = 0.0
	_aviso.scale = Vector2(0.3, 0.3)
	_aviso.pivot_offset = get_viewport().get_visible_rect().size / 2.0
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(_aviso, "modulate:a", 1.0, 0.4)
	t.tween_property(_aviso, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.chain().tween_interval(TIEMPO_AVISO)
	t.chain().tween_property(_aviso, "modulate:a", 0.0, 0.6)
	t.chain().tween_callback(func(): _aviso.visible = false)
