extends Control

# Variables
var assigned_job: JOBLISTING

# Empty Vars on ready:
var label_map: Dictionary = {}
var refnr: String = ""

# Nodes
# Labels
@onready var beruf_label: RichTextLabel = $ActualContainer/TopLabelControl/BerufLabel
@onready var titel_label: RichTextLabel = $ActualContainer/TopLabelControl/TitelLabel
@onready var arbeitgeber_label: RichTextLabel = $ActualContainer/TopLabelControl/ArbeitgeberLabel
@onready var region_label: RichTextLabel = $ActualContainer/OrtControl/RegionLabel
@onready var ort_label: RichTextLabel = $ActualContainer/OrtControl/OrtLabel
@onready var ortsteil_label: RichTextLabel = $ActualContainer/OrtControl/OrtsteilLabel
@onready var strasse_label: RichTextLabel = $ActualContainer/OrtControl/StrasseLabel
@onready var entfernung_label: RichTextLabel = $ActualContainer/OrtControl/EntfernungLabel
# Buttons
@onready var status_option_button: OptionButton = $ActualContainer/InteractiveControl/StatusControl/StatusOptionButton
@onready var note_text_edit: TextEdit = $ActualContainer/InteractiveControl/NoteTextEdit
@onready var bewerbung_auswählen_button: Button = $ActualContainer/InteractiveControl/BewerbungAuswählenButton
@onready var anschreiben_auswählen_button: Button = $ActualContainer/InteractiveControl/AnschreibenAuswählenButton
# Other
@onready var file_dialog: FileDialog = $ActualContainer/InteractiveControl/BewerbungAuswählenButton/FileDialog


var rtl_selectables: Array = []

## System Functions
func _ready() -> void:
	init_display()

func init_display():
	# Init Map
	## Layout: Label: [Prefix, Value, Suffix]
	label_map = {
		beruf_label: ["[color=#000000]Beruf: ", assigned_job.beruf, ""],
		titel_label: ["[color=#000000]Titel: ", assigned_job.titel, ""],
		arbeitgeber_label: ["[color=#000000]Arbeitgeber: ", assigned_job.arbeitgeber, ""],
		region_label: ["[color=#000000]", assigned_job.region, ""],
		ort_label: ["[color=#000000]", assigned_job.ort, ""],
		ortsteil_label: ["[color=#000000]", assigned_job.ortsteil, ""],
		strasse_label: ["[color=#000000]", assigned_job.strasse, ""],
		entfernung_label: ["[color=#000000]Entfernung: ", assigned_job.entfernung, "KM"]
	}
	# Init other Vars
	refnr = assigned_job.refnr
	# Make Labels Selectable
	rtl_selectables = [beruf_label, titel_label, arbeitgeber_label, region_label, ort_label, ortsteil_label, strasse_label, entfernung_label]
	for rtl in rtl_selectables:
		rtl.selection_enabled = true
	# Init Buttons etc
	select_option_by_text(status_option_button, assigned_job.fav_status)
	note_text_edit.text = assigned_job.notes
	init_labels()

func init_labels() -> void:
	for label in label_map.keys():
		label.text = str(label_map[label][0]) + str(label_map[label][1]) + str(label_map[label][2])



## Button Inputs
# UI
func _on_status_option_button_item_selected(index: int) -> void:
	assigned_job.fav_status = status_option_button.get_item_text(index)
	assigned_job.update_attribute_list()
	Global.save_job(assigned_job)


func _on_note_text_edit_text_changed() -> void:
	assigned_job.notes = note_text_edit.text
	assigned_job.update_attribute_list()
	Global.save_job(assigned_job)


# Other
func _on_open_link_button_pressed() -> void:
	OS.shell_open("https://www.arbeitsagentur.de/jobsuche/jobdetail/" + refnr)


func _on_un_favorite_button_pressed() -> void:
	if Global.fav_joblisting_refnr_map.has(assigned_job.refnr):
		Global.fav_joblisting_refnr_map.erase(assigned_job.refnr)
		# Delete the Saved Tres
		var dir = DirAccess.open(Global.get_job_folderpath(assigned_job))
		if dir:
			dir.remove(Global.get_job_filepath(assigned_job))
		Global.favJobListUpdate.emit()



## Helper Functions
func select_option_by_text(option_button: OptionButton, text_to_select: String) -> void:
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == text_to_select:
			option_button.selected = i
			return
	# Optional: If not found, you could select nothing
	option_button.selected = -1


func _on_open_path_button_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir() + "/saved_joblistings/" + Global.get_job_folderpath(assigned_job, true))


# Function Relevant Vars
var is_bewerbung_assigned: bool = false
var is_anschreiben_assigned: bool = false
var file_dialog_mode: String

# Bewerbung
var assigned_bewerbung_path: String
var assigned_bewerbung_filename: String
# Anschreiben
var assigned_anschreiben_path: String
var assigned_anschreiben_filename: String


func _on_bewerbung_auswählen_button_pressed() -> void:
	if !is_bewerbung_assigned:
		file_dialog_mode = "bewerbung"
		file_dialog.popup_centered()
	else:
		OS.shell_open(assigned_bewerbung_path)



func _on_anschreiben_auswählen_button_pressed() -> void:
	if !is_anschreiben_assigned:
		file_dialog_mode = "anschreiben"
		file_dialog.popup_centered()
	else:
		OS.shell_open(assigned_anschreiben_path)



func _on_file_dialog_file_selected(path: String) -> void:
	match file_dialog_mode:
		"bewerbung":
			assigned_bewerbung_path = path
			assigned_bewerbung_filename = path.get_file()
			bewerbung_auswählen_button.text = assigned_bewerbung_filename + " Öffnen"
			is_bewerbung_assigned = true
		"anschreiben":
			assigned_anschreiben_path = path
			assigned_anschreiben_filename = path.get_file()
			anschreiben_auswählen_button.text = assigned_anschreiben_filename + " Öffnen"
			is_anschreiben_assigned = true


func _on_bewerbung_unassign_button_pressed() -> void:
	assigned_bewerbung_path = ""
	assigned_bewerbung_filename = ""
	bewerbung_auswählen_button.text = "Bewerbung Auswählen:"
	is_bewerbung_assigned = false

func _on_anschreiben_unassign_button_pressed() -> void:
	assigned_anschreiben_path = ""
	assigned_anschreiben_filename = ""
	anschreiben_auswählen_button.text = "Anschreiben Auswählen:"
	is_anschreiben_assigned = false
