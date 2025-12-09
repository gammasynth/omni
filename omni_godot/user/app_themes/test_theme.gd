extends AppTheme

func setup() -> void: _setup()

## Override this function in an extended class to set settings and textures for an AppTheme.
func _setup() -> void:
	theme_name = "test_theme"
	theme = ResourceLoader.load("user://themes/test_theme.theme")
	set_default_icon_textures()

