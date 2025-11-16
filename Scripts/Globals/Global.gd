extends Node

# Debugmode for Testing
const DEBUGMODE = true

var conf_data_loaded: bool = false

## Variables
# Normal Joblistings mapped to their reference-number
var joblisting_refnr_map: Dictionary = {}
var shown_jobs_refnr_map: Dictionary = {}
# Favorited Joblistings mapped to their reference-number
var fav_joblisting_refnr_map: Dictionary = {}
var fav_shown_jobs_refnr_map: Dictionary = {}
# Default Savepath for the favorited joblistings
var default_joblisting_savepath: String = "user://saved_joblistings"
# Default Conf filepath
var config = ConfigFile.new()
const SETTINGS_FILE_PATH: String = "user://settings.ini"


## Global Signals
signal jobAPIDataLoaded
signal angebotFilterUpdate
signal favJobListUpdate


func _ready() -> void:
	# Check if the custom dirs exist, if not, create them
	var dir = DirAccess.open(default_joblisting_savepath)
	if !dir:
		var userpath = DirAccess.open("user://")
		userpath.make_dir("saved_joblistings")
	# Check if the settings.ini exists
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		create_config_file()
	else:
		config.load(SETTINGS_FILE_PATH)
	
	## Load all Jobs
	# Get all the Job Folders
	dir = DirAccess.open(default_joblisting_savepath)
	if dir:
		# Iterate thorugh all the folders
		for folder in dir.get_directories():
			# Construct subdir and filepath
			var subdir = default_joblisting_savepath + "/" + folder
			var files = ResourceLoader.list_directory(subdir)
			# Check all Files in the folder
			for file in files:
				# Check if they are tres
				if file.substr(file.length() - 5, 5) == ".tres":
					# Load the job and add it to the refnr_map
					var loaded_job = load_job(subdir + "/" + file)
					if !Global.fav_joblisting_refnr_map.has(loaded_job.refnr):
						Global.fav_joblisting_refnr_map[loaded_job.refnr] = loaded_job
	conf_data_loaded = true


### Config File
# Helper function to create the config File
func create_config_file() -> void:
	# Set Initial Values
	config.set_value("initial_params", "jobtitel", "")
	config.set_value("initial_params", "berufsfeld", "")
	config.set_value("initial_params", "angebotsart", 0)
	config.set_value("initial_params", "ort", "")
	config.set_value("initial_params", "umkreis", 25)
	config.set_value("initial_params", "suchergebnisse", 50)
	
	config.save(SETTINGS_FILE_PATH)




### Save and Load Jobs
# Save a single Job to a specific Path
func save_job(job: JOBLISTING) -> void:
	# Check if the Folder for the Joblisting exists
	var folderpathtemp = get_job_folderpath(job)
	var dir = DirAccess.open(folderpathtemp)
	# If it doesnt, create it: refnr__beruf__arbeitgeber
	if !dir:
		var userpath = DirAccess.open(default_joblisting_savepath)
		userpath.make_dir(folderpathtemp)
	# Actually Save the job into the folder as a tres: refnr.tres
	ResourceSaver.save(job, get_job_filepath(job))


# Load a single Job from a specific Path
func load_job(path: String) -> Resource:
	var res = ResourceLoader.load(path)
	#if res == null:
		#push_error("Failed to load job: " + path)
	return res



### CSV Export Helper
func export_favorite_joblistings_to_csv(output_path: String) -> void:
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write CSV to: " + output_path)
		return

	# CSV HEADER
	var headers := [
		"beruf","titel","arbeitgeber","region","ort","plz","ortsteil","entfernung","strasse",
		"eintritsdatum","link","fav_status","notes","land",
		"koordinaten","aktuelleVeroeffentlichungsdatum","refnr",
		"kundennummerHash","modifikationsTimestamp"
	]
	file.store_csv_line(headers)

	# Get your map from the global singleton
	var global := get_node("/root/Global")
	var map: Dictionary = global.fav_joblisting_refnr_map

	for refnr in map.keys():
		var job: JOBLISTING = map[refnr]
		if job == null: 
			continue

		job.update_attribute_list()  # ensure fields are up to date

		var row := [
			job.beruf,
			job.titel,
			job.arbeitgeber,
			job.region,
			job.ort,
			job.plz,
			job.ortsteil,
			job.entfernung,
			job.strasse,
			job.eintritsdatum,
			job.link,
			job.fav_status,
			job.notes,
			job.land,
			str(job.koordinaten),
			job.aktuelleVeroeffentlichungsdatum,
			job.refnr,
			job.kundennummerHash,
			job.modifikationsTimestamp
		]

		file.store_csv_line(row)

	file.close()
	print("CSV exported →", output_path)



### Helper Functions
# PURGE THE EVILS LETTERS FOR THE MACHINE GOD
func sanitize_for_windows_filename(namee: String) -> String:
	# Remove invalid characters
	var invalid_chars = ['<', '>', ':', '"', '/', '\\', '|', '?', '*']
	for c in invalid_chars:
		namee = namee.replace(c, "_")  # Replace with underscore
	# Trim trailing spaces or dots
	namee = namee.strip_edges()
	while namee.ends_with(".") or namee.ends_with(" "):
		namee = namee.substr(0, namee.length() - 1)
	return namee

# Get the folder path for a joblisting
func get_job_folderpath(joblisting: JOBLISTING, customuserpath: bool = false) -> String:
	var raw_name = "%s__%s__%s" % [joblisting.refnr, joblisting.beruf, joblisting.arbeitgeber]
	var safe_name = sanitize_for_windows_filename(raw_name)
	if customuserpath:
		return safe_name
	return default_joblisting_savepath + "/" + safe_name

# Get the actual filepath for the tres
func get_job_filepath(joblistng: JOBLISTING) -> String:
	return get_job_folderpath(joblistng) + "/" + joblistng.refnr + ".tres"
