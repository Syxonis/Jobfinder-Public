extends Control

# Variables
var assigned_job: JOBLISTING

# Empty Vars on ready:
var label_map: Dictionary = {}
var refnr: String = ""

# Nodes
# Labels
@onready var beruf_label: RichTextLabel = $ActualContainer/LeftLabelControl/BerufLabel
@onready var titel_label: RichTextLabel = $ActualContainer/LeftLabelControl/TitelLabel
@onready var arbeitgeber_label: RichTextLabel = $ActualContainer/LeftLabelControl/ArbeitgeberLabel
@onready var region_label: RichTextLabel = $ActualContainer/OrtControl/RegionLabel
@onready var ort_label: RichTextLabel = $ActualContainer/OrtControl/OrtLabel
@onready var ortsteil_label: RichTextLabel = $ActualContainer/OrtControl/OrtsteilLabel
@onready var strasse_label: RichTextLabel = $ActualContainer/OrtControl/StrasseLabel
@onready var entfernung_label: RichTextLabel = $ActualContainer/OrtControl/EntfernungLabel
# Buttons
@onready var status_option_button: OptionButton = $ActualContainer/InteractiveControl/StatusControl/StatusOptionButton
@onready var note_text_edit: TextEdit = $ActualContainer/InteractiveControl/StatusControl/NoteTextEdit


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
