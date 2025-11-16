extends Control

# Variables
var assigned_job: JOBLISTING

# Empty Vars on ready:
var label_map: Dictionary = {}
var refnr: String = ""

# Nodes
# Labels
@onready var beruf_label: Label = $ActualControl/beruf_label
@onready var titel_label: Label = $ActualControl/titel_label
@onready var ort_label: Label = $ActualControl/ort_label
@onready var arbeitgeber_label: Label = $ActualControl/arbeitgeber_label
@onready var datum_label: Label = $ActualControl/datum_label
@onready var entfernung_label: Label = $"ActualControl/entfernung label"



func _ready() -> void:
	init_display()


func init_display():
	# Init Map
	## Layout: Label: [Prefix, Value, Suffix]
	label_map = {
		beruf_label: ["Beruf: ", assigned_job.beruf, ""],
		titel_label: ["Titel: ", assigned_job.titel, ""],
		arbeitgeber_label: ["Arbeitgeber: ", assigned_job.arbeitgeber, ""],
		datum_label: ["Veröffentlicht: ", assigned_job.aktuelleVeroeffentlichungsdatum, ""],
		ort_label: ["Ort: ", assigned_job.ort, ""],
		entfernung_label: ["Entfernung: ", assigned_job.entfernung, "km"]
	}
	# Init other Vars
	refnr = assigned_job.refnr
	
	init_labels()


func init_labels() -> void:
	for label in label_map.keys():
		label.text = str(label_map[label][0]) + str(label_map[label][1]) + str(label_map[label][2])


func _on_open_link_button_pressed() -> void:
	OS.shell_open("https://www.arbeitsagentur.de/jobsuche/jobdetail/" + refnr)


func _on_favorite_button_pressed() -> void:
	if !Global.fav_joblisting_refnr_map.has(assigned_job.refnr):
		Global.fav_joblisting_refnr_map[assigned_job.refnr] = assigned_job
		Global.favJobListUpdate.emit()
		Global.save_job(assigned_job)
