extends Control


# Nodes
# Line Edits
@onready var job_titel_line_edit: LineEdit = $RightControl/JobTitelLineEdit
@onready var berufsfeld_line_edit: LineEdit = $RightControl/BerufsfeldLineEdit
@onready var ort_line_edit: LineEdit = $RightControl/OrtLineEdit
# Spin Boxes
@onready var umkreis_spin_button: SpinBox = $RightControl/UmkreisSpinButton
@onready var max_ergebnisse_spin_box: SpinBox = $RightControl/MaxErgebnisseSpinBox
# Option Buttons
@onready var angebotsart_options_button: OptionButton = $RightControl/AngebotsartOptionsButton
# Checkbuttons
@onready var vollzeit_check_button: CheckButton = $RightControl/CheckButtonControl/VollzeitCheckButton
@onready var teilzeit_check_button: CheckButton = $RightControl/CheckButtonControl/TeilzeitCheckButton
@onready var schicht_nacht_we_check_button_3: CheckButton = $RightControl/CheckButtonControl/SchichtNachtWECheckButton3
@onready var minijob_check_button: CheckButton = $RightControl/CheckButtonControl/MinijobCheckButton
@onready var work_from_home_check_button: CheckButton = $RightControl/CheckButtonControl/WorkFromHomeCheckButton
# Buttons
@onready var jobs_neu_suchen_button: Button = $JobsNeuSuchenButton
@onready var clear_folders_without_jobs_button: Button = $FolderDataControl/ClearFoldersWithoutJobsButton
# Menu Buttons
@onready var jobtitel_sort_menu_button: MenuButton = $AusschreibungenSortControl/JobtitelSortMenuButton
@onready var arbeitgeber_sort_menu_button: MenuButton = $AusschreibungenSortControl/ArbeitgeberSortMenuButton
@onready var ort_sort_menu_button: MenuButton = $AusschreibungenSortControl/OrtSortMenuButton
@onready var beruf_sort_menu_button: MultiSelectMenuButton = $AusschreibungenSortControl/BerufSortMenuButton
# V-Box Containers
@onready var v_box_container_jobs: VBoxContainer = $ScrollContainerJobs/VBoxContainerJobs
@onready var v_box_container_favorites: VBoxContainer = $ScrollContainerFavorites/VBoxContainerFavorites

# Controls
@onready var agentur_api_control: Control = $"../AgenturApiControl"

# Consts
const JOB_DISPLAY = preload("res://Scenes/Ui/JobDisplay.tscn")
const FAV_JOB_DISPLAY = preload("res://Scenes/Ui/FavJobDisplay.tscn")

var search_buttons: Array


func _ready() -> void:
	search_buttons = [job_titel_line_edit, berufsfeld_line_edit, ort_line_edit, umkreis_spin_button, max_ergebnisse_spin_box, angebotsart_options_button, jobs_neu_suchen_button]
	connect_signals()
	while !Global.conf_data_loaded:
		pass
	apply_conf_values()
	agentur_api_control.get_agentur_job_data()


func connect_signals() -> void:
	Global.jobAPIDataLoaded.connect(_job_api_data_loaded)
	Global.angebotFilterUpdate.connect(_angebot_filter_update)
	Global.favJobListUpdate.connect(_on_fav_list_update)


func apply_conf_values() -> void:
	var conf = Global.config
	if conf.get_value("initial_params", "jobtitel") != "":
		agentur_api_control.api_search_params["was"] = conf.get_value("initial_params", "jobtitel")
		job_titel_line_edit.text = conf.get_value("initial_params", "jobtitel")
	if conf.get_value("initial_params", "berufsfeld") != "":
		agentur_api_control.api_search_params["berufsfeld"] = conf.get_value("initial_params", "berufsfeld")
		berufsfeld_line_edit.text =conf.get_value("initial_params", "berufsfeld")
	if conf.get_value("initial_params", "ort") != "":
		agentur_api_control.api_search_params["wo"] = conf.get_value("initial_params", "ort")
		ort_line_edit.text = conf.get_value("initial_params", "ort")
	if int(conf.get_value("initial_params", "umkreis")) > 0 and int(conf.get_value("initial_params", "umkreis")) < 1000:
		agentur_api_control.api_search_params["umkreis"] = conf.get_value("initial_params", "umkreis")
		umkreis_spin_button.value = int(conf.get_value("initial_params", "umkreis"))
	if int(conf.get_value("initial_params", "suchergebnisse")) > 0 and int(conf.get_value("initial_params", "suchergebnisse")) < 251:
		agentur_api_control.api_search_params["size"] = conf.get_value("initial_params", "suchergebnisse")
		max_ergebnisse_spin_box.value = int(conf.get_value("initial_params", "suchergebnisse"))
	if int(conf.get_value("initial_params", "angebotsart")) == 1 or 2 or 4 or 34:
		match conf.get_value("initial_params", "angebotsart"):
			1: 
				agentur_api_control.api_search_params["angebotsart"] = "1"
			2: 
				agentur_api_control.api_search_params["angebotsart"] = "2"
			4: 
				agentur_api_control.api_search_params["angebotsart"] = "4"
			34: 
				agentur_api_control.api_search_params["angebotsart"] = "34"
		angebotsart_options_button.select(int(conf.get_value("initial_params", "angebotsart")))



## Called when the filters are changed, to refilter the results
func _angebot_filter_update() -> void:
	Global.shown_jobs_refnr_map = {}
	for key in Global.joblisting_refnr_map.keys():
		var job = Global.joblisting_refnr_map[key]
		if pass_job_filters(job):
			Global.shown_jobs_refnr_map[key] = job
	display_jobs(true, false)


## Helper Function to check if a job passes the job filters
func pass_job_filters(job: JOBLISTING) -> bool:
	var filter1: bool = false
	var filter2: bool = false
	var filter3: bool = false
	var filter4: bool = false
	if jobtitel_sort_menu_button.get_selected_items() == []:
		filter1 = true
	else:
		if job.titel in jobtitel_sort_menu_button.get_selected_items():
			filter1 = true
	if arbeitgeber_sort_menu_button.get_selected_items() == []:
		filter2 = true
	else:
		if job.arbeitgeber in arbeitgeber_sort_menu_button.get_selected_items():
			filter2 = true
	if ort_sort_menu_button.get_selected_items() == []:
		filter3 = true
	else:
		if job.ort in ort_sort_menu_button.get_selected_items():
			filter3 = true
	if beruf_sort_menu_button.get_selected_items() == []:
		filter4 = true
	else:
		if job.beruf in beruf_sort_menu_button.get_selected_items():
			filter4 = true
	if filter1 and filter2 and filter3 and filter4:
		return true
	else:
		return false


func _on_fav_list_update() -> void:
	Global.fav_shown_jobs_refnr_map = Global.fav_joblisting_refnr_map
	display_jobs(false, true)


func _job_api_data_loaded() -> void:
	display_jobs(true, false)


### UI Functions
# Clear Jobdata Completly
func clear_job_data(v_box: VBoxContainer, clear_array: bool = false, array: Dictionary = {}) -> void:
	for child in v_box.get_children():
		child.queue_free()
	if clear_array:
		array.clear()

# Display the jobs in the arrays
func display_jobs(normal: bool = false, favorites: bool = false) -> void:
	if normal:
		clear_job_data(v_box_container_jobs)
		for key in Global.shown_jobs_refnr_map.keys():
			var job = Global.shown_jobs_refnr_map[key]
			var job_display_temp = JOB_DISPLAY.instantiate()
			job_display_temp.assigned_job = job
			v_box_container_jobs.add_child(job_display_temp)
	if favorites:
		clear_job_data(v_box_container_favorites)
		for key in Global.fav_shown_jobs_refnr_map.keys():
			var job = Global.fav_shown_jobs_refnr_map[key] 
			var job_display_temp = FAV_JOB_DISPLAY.instantiate()
			job_display_temp.assigned_job = job
			v_box_container_favorites.add_child(job_display_temp)


### Search Params Inputs
# Jobtitel Param Lineedit Input
func _on_job_titel_line_edit_text_changed(new_text: String) -> void:
	if new_text != "":
		agentur_api_control.api_search_params["was"] = new_text
	else:
		agentur_api_control.api_search_params.erase("was")

# Berufsfeld Param Lineedit Input
func _on_berufsfeld_line_edit_text_changed(new_text: String) -> void:
	if new_text != "":
		agentur_api_control.api_search_params["berufsfeld"] = new_text
	else:
		agentur_api_control.api_search_params.erase("berufsfeld")

# Ort Param Lineedit Input
func _on_ort_line_edit_text_changed(new_text: String) -> void:
	if new_text != "":
		agentur_api_control.api_search_params["wo"] = new_text
	else:
		agentur_api_control.api_search_params.erase("wo")

# Angebotsart Param Options Button Input
func _on_angebotsart_options_button_item_selected(index: int) -> void:
	match index:
		1: agentur_api_control.api_search_params["angebotsart"] = "1"
		2: agentur_api_control.api_search_params["angebotsart"] = "2"
		3: agentur_api_control.api_search_params["angebotsart"] = "4"
		4: agentur_api_control.api_search_params["angebotsart"] = "34"
		5: agentur_api_control.api_search_params.erase("angebotsart")
	agentur_api_control.get_agentur_job_data()

# Umkreis Param Spinbox Input
func _on_umkreis_spin_button_value_changed(value: float) -> void:
	agentur_api_control.api_search_params["umkreis"] = str(int(value))
	agentur_api_control.get_agentur_job_data()

# Ergebnisse Param Spinbox Input
func _on_max_ergebnisse_spin_box_value_changed(value: float) -> void:
	agentur_api_control.api_search_params["size"] = str(int(value))
	agentur_api_control.get_agentur_job_data()



func _on_jobs_neu_suchen_button_pressed() -> void:
	clear_job_data(v_box_container_jobs, true, Global.fav_joblisting_refnr_map)
	jobs_neu_suchen_button.disabled = true
	jobs_neu_suchen_button.text = "Auf Serverantwort Warten..."
	await agentur_api_control.get_agentur_job_data()












### FOR TESTING
@onready var http_request222: HTTPRequest = $"../TestButton/TestHTTPRequest"

func _on_button_pressed() -> void:
	var job_hash_id = "12456-1435948-1-S"
	var api_url = "https://rest.arbeitsagentur.de/jobboerse/jobsuche-service/pc/v2/jobdetails/" + job_hash_id
	print(api_url)
	
	var headers = ["X-API-Key: jobboerse-jobsuche"]  # <-- Add your key here
	http_request222.request(api_url, headers)

func _on_http_request_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("cameback")
	print("Result code: ", result)
	print("HTTP code: ", response_code)
	if body.size() > 0:
		print(body.get_string_from_utf8())
	else:
		print("Empty body! Check API key or TLS.")


func _on_open_job_savingutton_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())


func _on_unlock_folder_clear_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		clear_folders_without_jobs_button.disabled = false
	else:
		clear_folders_without_jobs_button.disabled = true


func _on_clear_folders_without_jobs_button_pressed() -> void:
	var dir = DirAccess.open(Global.default_joblisting_savepath)
	if dir:
		# Iterate thorugh all the folders
		for folder in dir.get_directories():
			# Construct subdir and filepath
			var subdir = Global.default_joblisting_savepath + "/" + folder
			var files = ResourceLoader.list_directory(subdir)
			# Check all Files in the folder, and if it has a tres dont delete it
			var has_res: bool = false
			for file in files:
				if file.substr(file.length() - 5, 5) == ".tres":
					has_res = true
			if !has_res:
				dir.remove(subdir)


func _on_export_to_csv_button_pressed() -> void:
	var output_path := "user://favoriten_export.csv"
	Global.export_favorite_joblistings_to_csv(output_path)
	print("Export completed:", output_path)


func _on_save_search_params_button_pressed() -> void:
	if agentur_api_control.api_search_params.has("was"):
		Global.config.set_value("initial_params", "jobtitel", agentur_api_control.api_search_params["was"])
	if agentur_api_control.api_search_params.has("berufsfeld"):
		Global.config.set_value("initial_params", "berufsfeld", agentur_api_control.api_search_params["berufsfeld"])
	if agentur_api_control.api_search_params.has("wo"):
		Global.config.set_value("initial_params", "ort", agentur_api_control.api_search_params["wo"])
	if agentur_api_control.api_search_params.has("umkreis"):
		Global.config.set_value("initial_params", "umkreis", agentur_api_control.api_search_params["umkreis"])
	if agentur_api_control.api_search_params.has("size"):
		Global.config.set_value("initial_params", "suchergebnisse", agentur_api_control.api_search_params["size"])
	if agentur_api_control.api_search_params.has("angebotsart"):
		Global.config.set_value("initial_params", "angebotsart", agentur_api_control.api_search_params["angebotsart"])
	
	Global.config.save(Global.SETTINGS_FILE_PATH)


func _on_reset_optionen_button_pressed() -> void:
	Global.create_config_file()
	apply_conf_values()
	ort_line_edit.clear()
	job_titel_line_edit.clear()
	berufsfeld_line_edit.clear()


## Search after Entering Param
func _on_job_titel_line_edit_text_submitted(_new_text: String) -> void:
	agentur_api_control.get_agentur_job_data()

func _on_berufsfeld_line_edit_text_submitted(_new_text: String) -> void:
	agentur_api_control.get_agentur_job_data()

func _on_ort_line_edit_text_submitted(_new_text: String) -> void:
	agentur_api_control.get_agentur_job_data()
