extends Node

# Sorting Arrays
var jobtitel_sort_list: Array = []
var arbeitgeber_sort_list: Array = []
var ort_sort_list: Array = []
var beruf_sort_list: Array = []

var fav_jobtitel_sort_list: Array = []
var fav_arbeitgeber_sort_list: Array = []
var fav_ort_sort_list: Array = []

# Query Params
var api_search_params: Dictionary = {}

# Constant Values
const AGENTUR_API_BASEURL: String = "https://rest.arbeitsagentur.de/jobboerse/jobsuche-service/pc/v4/"
const AGENTUR_API_KEY: String = "jobboerse-jobsuche"

# Nodes
# Http Request Nodes
@onready var agentur_api_http_request: HTTPRequest = $AgenturApiHTTPRequest
# Option Buttons
@onready var jobtitel_sort_menu_button: MultiSelectMenuButton = $"../UIMainControl/AusschreibungenSortControl/JobtitelSortMenuButton"
@onready var arbeitgeber_sort_menu_button: MultiSelectMenuButton = $"../UIMainControl/AusschreibungenSortControl/ArbeitgeberSortMenuButton"
@onready var ort_sort_menu_button: MultiSelectMenuButton = $"../UIMainControl/AusschreibungenSortControl/OrtSortMenuButton"
@onready var beruf_sort_menu_button: MultiSelectMenuButton = $"../UIMainControl/AusschreibungenSortControl/BerufSortMenuButton"

@onready var jobtitel_fav_sort_menu_button: MultiSelectMenuButton = $"../UIMainControl/FavoritenSortControl/JobtitelFavSortMenuButton"
@onready var arbeitgeber_fav_sort_menu_button: MultiSelectMenuButton = $"../UIMainControl/FavoritenSortControl/ArbeitgeberFavSortMenuButton"
@onready var ort_fav_sort_menu_button: MultiSelectMenuButton = $"../UIMainControl/FavoritenSortControl/OrtFavSortMenuButton"
# Buttons
@onready var jobs_neu_suchen_button: Button = $"../UIMainControl/JobsNeuSuchenButton"



func get_agentur_job_data(extra_params: Dictionary = api_search_params) -> void:
	# Construct the URL, Header and Request
	var base_url = AGENTUR_API_BASEURL + "jobs"
	var header = ["X-API-Key: " + AGENTUR_API_KEY]
	
	var query_params: Array[String] = []
	
	for key in extra_params.keys():
		if extra_params[key] != null:
			var value := str(extra_params[key]).uri_encode()
			query_params.append("%s=%s" % [key, value])
	
	var constructed_url = base_url + "?" + "&".join(query_params)
	
	# Send request
	if Global.DEBUGMODE:
		print("ArbeitsAPI URL: " + constructed_url)
	agentur_api_http_request.request(constructed_url, header, HTTPClient.METHOD_GET)


func _on_agentur_api_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	# Encode the Data
	Global.joblisting_refnr_map = {}
	var temp = JSON.parse_string(body.get_string_from_utf8())
	if !temp.has("stellenangebote"):
		if Global.DEBUGMODE:
			print(temp)
		return
	var encoded_result = temp["stellenangebote"]
	# Create job objects for every listing
	for job in encoded_result:
		var joblisting := JOBLISTING.new()
		joblisting.beruf = get_or_default(job, "beruf", "KEIN BERUF")
		joblisting.titel = get_or_default(job, "titel", "KEIN TITEL")
		joblisting.refnr = get_or_default(job, "refnr", "KEINE REFNR")
		joblisting.arbeitgeber = get_or_default(job, "arbeitgeber", "KEIN ARBEITGEBER")
		joblisting.aktuelleVeroeffentlichungsdatum = get_or_default(job, "aktuelleVeroeffentlichungsdatum", "KEIN AKTUELLES VERÖFFENTLICHKEITSDATUM")
		joblisting.modifikationsTimestamp = get_or_default(job, "modifikationsTimestamp", "KEIN MODIFICATION TIMESTAMP")
		joblisting.eintritsdatum = get_or_default(job, "eintritsdatum", "KEIN EINTRITSDATUM")
		joblisting.kundennummerHash = get_or_default(job, "kundennummerHash", "KEINE KUNDENNUMMER HASH")
		var arbeitsort: Dictionary = get_or_default(job, "arbeitsort", {})
		joblisting.plz = get_or_default(arbeitsort, "plz", "KEINE PLZ")
		joblisting.ort = get_or_default(arbeitsort, "ort", "KEIN ORT")
		joblisting.ortsteil = get_or_default(arbeitsort, "ortsteil", "KEIN ORTSTEIL")
		joblisting.strasse = get_or_default(arbeitsort, "strasse", "KEINE STRASSE")
		joblisting.region = get_or_default(arbeitsort, "region", "KEINE REGION")
		joblisting.land = get_or_default(arbeitsort, "land", "KEIN LAND")
		joblisting.entfernung = get_or_default(arbeitsort, "entfernung", "N/A ")
		var coords: Dictionary = get_or_default(arbeitsort, "koordinaten", {})
		if coords.has("lat") and coords.has("lon"):
			joblisting.koordinaten = Vector2(float(coords["lat"]), float(coords["lon"]))
		else:
			joblisting.koordinaten = Vector2()
		joblisting.update_attribute_list()
		Global.joblisting_refnr_map[joblisting.refnr] = joblisting
	Global.shown_jobs_refnr_map = Global.joblisting_refnr_map
	populate_sort_options()
	Global.jobAPIDataLoaded.emit()
	jobs_neu_suchen_button.text = "Jobs Neu Suchen"
	jobs_neu_suchen_button.disabled = false
	Global.favJobListUpdate.emit()


func get_or_default(dict: Dictionary, key: String, default):
	if dict.has(key):
		return dict[key]
	return default


func _on_fav_list_update() -> void:
	fav_populate_sort_options()


func fav_populate_sort_options() -> void:
	# Empty all the sort parameter list for the multi-option-buttons
	fav_jobtitel_sort_list = []
	fav_arbeitgeber_sort_list = []
	fav_arbeitgeber_sort_list = []
	# Check if a jobs param is already in the array, if not add it
	for job in Global.fav_joblisting_array:
		if !fav_jobtitel_sort_list.has(job.titel):
			fav_jobtitel_sort_list.append(job.titel)
		if !fav_arbeitgeber_sort_list.has(job.arbeitgeber):
			fav_arbeitgeber_sort_list.append(job.arbeitgeber)
		if job.arbeitsort.has("ort"):
			if !fav_ort_sort_list.has(job.arbeitsort["ort"]):
				fav_ort_sort_list.append(job.arbeitsort["ort"])
	# Set the job params to the multi-option-buttons
	jobtitel_sort_list.sort()
	arbeitgeber_sort_list.sort()
	ort_sort_list.sort()
	jobtitel_fav_sort_menu_button.set_items(jobtitel_sort_list)
	arbeitgeber_fav_sort_menu_button.set_items(arbeitgeber_sort_list)
	ort_fav_sort_menu_button.set_items(ort_sort_list)


func populate_sort_options() -> void:
	# Empty all the sort parameter list for the multi-option-buttons
	jobtitel_sort_list = []
	arbeitgeber_sort_list = []
	ort_sort_list = []
	beruf_sort_list = []
	# Check if a jobs param is already in the array, if not add it
	for key in Global.joblisting_refnr_map.keys():
		var job = Global.joblisting_refnr_map[key]
		if !jobtitel_sort_list.has(job.titel):
			jobtitel_sort_list.append(job.titel)
		if !arbeitgeber_sort_list.has(job.arbeitgeber):
			arbeitgeber_sort_list.append(job.arbeitgeber)
		if !ort_sort_list.has(job.ort):
			ort_sort_list.append(job.ort)
		if !beruf_sort_list.has(job.beruf):
			beruf_sort_list.append(job.beruf)
		# Set the job params to the multi-option-buttons
	jobtitel_sort_list.sort()
	arbeitgeber_sort_list.sort()
	ort_sort_list.sort()
	beruf_sort_list.sort()
	jobtitel_sort_menu_button.set_items(jobtitel_sort_list)
	arbeitgeber_sort_menu_button.set_items(arbeitgeber_sort_list)
	ort_sort_menu_button.set_items(ort_sort_list)
	beruf_sort_menu_button.set_items(beruf_sort_list)
