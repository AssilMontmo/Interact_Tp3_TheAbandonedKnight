extends Control

@onready var title_label = $CenterContainer/MenuContainer/TitleLabel
@onready var menu_buttons = $CenterContainer/MenuContainer/ButtonContainer
@onready var options_panel = $OptionsPanel
@onready var fade_overlay = $FadeOverlay
@onready var volume_slider = $OptionsPanel/MarginContainer/VBoxContainer/VolumeControl/VolumeSlider
@onready var volume_label = $OptionsPanel/MarginContainer/VBoxContainer/VolumeControl/VolumeValue

var intro_complete := false

func _ready():
	title_label.modulate.a = 0
	for button in menu_buttons.get_children():
		button.modulate.a = 0
	options_panel.visible = false
	fade_overlay.modulate.a = 1.0
	volume_slider.value = 10
	update_volume_label()
	$CenterContainer/MenuContainer/ButtonContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/MenuContainer/ButtonContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$CenterContainer/MenuContainer/ButtonContainer/ExitButton.pressed.connect(_on_exit_pressed)
	$OptionsPanel/MarginContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	
	
# Intro
	play_intro_sequence()
func play_intro_sequence():
	var fade_in = create_tween()
	fade_in.tween_property(fade_overlay, "modulate:a", 0.0, 1.5)
	await fade_in.finished
	await get_tree().create_timer(0.5).timeout
	title_label.scale = Vector2(1.2, 1.2)
	var title_tween = create_tween()
	title_tween.set_parallel(true)
	title_tween.set_ease(Tween.EASE_OUT)
	title_tween.set_trans(Tween.TRANS_CUBIC)
	title_tween.tween_property(title_label, "modulate:a", 1.0, 2.0)
	title_tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 1.5)
	await title_tween.finished
	await get_tree().create_timer(0.5).timeout
	var buttons = menu_buttons.get_children()
	for button in buttons:
		if button is Button:
			var button_tween = create_tween()
			button_tween.set_ease(Tween.EASE_OUT)
			button_tween.tween_property(button, "modulate:a", 1.0, 0.5)
			await get_tree().create_timer(0.2).timeout
	intro_complete = true
	print("Intro complete!")
	
#Parametre boutons
	
func _on_start_pressed():
	if not intro_complete:
		return
	set_buttons_disabled(true)

	var fade_out = create_tween()
	fade_out.set_parallel(true)
	fade_out.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	fade_out.tween_property(title_label, "modulate:a", 0.0, 0.8)
	for button in menu_buttons.get_children():
		fade_out.tween_property(button, "modulate:a", 0.0, 0.8)
	await fade_out.finished
	get_tree().change_scene_to_file("res://Scenes/Tutorial_Level.tscn")
	
	
func _on_options_pressed():
	if not intro_complete:
		return
	var fade_menu = create_tween()
	fade_menu.set_parallel(true)
	for button in menu_buttons.get_children():
		fade_menu.tween_property(button, "modulate:a", 0.0, 0.3)
	fade_menu.tween_property(title_label, "modulate:a", 0.3, 0.3)
	await fade_menu.finished
	options_panel.modulate.a = 0
	options_panel.visible = true
	var fade_options = create_tween()
	fade_options.tween_property(options_panel, "modulate:a", 1.0, 0.3)
	
	
func _on_back_pressed():
	var fade_options = create_tween()
	fade_options.tween_property(options_panel, "modulate:a", 0.0, 0.3)
	await fade_options.finished
	options_panel.visible = false
	var fade_menu = create_tween()
	fade_menu.set_parallel(true)
	for button in menu_buttons.get_children():
		fade_menu.tween_property(button, "modulate:a", 1.0, 0.3)
	fade_menu.tween_property(title_label, "modulate:a", 1.0, 0.3)
	
	
func _on_exit_pressed():
	if not intro_complete:
		return
	var fade_out = create_tween()
	fade_out.tween_property(fade_overlay, "modulate:a", 1.0, 0.8)
	await fade_out.finished
	get_tree().quit()
func _on_volume_changed(value: float):
	update_volume_label()
	
	
	# Option de volume
	var volume_db = lerp(-80.0, 0.0, value / 10.0)
	var audio_players = get_tree().get_nodes_in_group("game_audio")
	for player in audio_players:
		if player is AudioStreamPlayer or player is AudioStreamPlayer2D:
			player.volume_db = volume_db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)
func update_volume_label():
	volume_label.text = str(int(volume_slider.value))
func set_buttons_disabled(disabled: bool):
	for button in menu_buttons.get_children():
		if button is Button:
			button.disabled = disabled
