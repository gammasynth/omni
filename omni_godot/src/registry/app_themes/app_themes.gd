extends Registry

func _gather_subregistry_paths() -> Error:
	#subregistry_paths.append("res://src/registry/entities/items.gd")
	#check_library_for_registries("res://", true, "theme")
	return OK

func _boot_registry():
	# override this function to set name and what directories to load files from for this registry
	#registry_name = "entities"
	#element_is_folder = true
	#multiple_elements_in_folder = true
	#uses_entry_groups = false
	#entry_class = RegistryEntry.new()
	directories_to_load = [
		"res://src/class/app_themes/"
		#"res://resource/theme/"
	]
	#search_for_loadable_content_by_name("res://", "themes")
	return OK
