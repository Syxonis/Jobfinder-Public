extends Resource
class_name JOBLISTING

# Attributes with Defaults
@export var beruf: String = "KEIN BERUF"
@export var titel: String = "KEIN TITEL"
@export var refnr: String = "KEINE REFNR"
@export var plz: String = "KEINE PLZ"
@export var ort: String = "KEIN ORT"
@export var strasse: String = "KEINE STRASSE"
@export var region: String = "KEINE REGION"
@export var land: String = "KEIN LAND"
@export var entfernung: String = "KEINE ENTFERTNUNG"
@export var koordinaten: Vector2 = Vector2(0.0, 0.0)
@export var ortsteil: String = "KEIN ORTSTEIL"
@export var arbeitgeber: String = "KEIN ARBEITGEBER"
@export var aktuelleVeroeffentlichungsdatum: String = "KEIN AKTUELLES VERÖFFENTLICHKEITSDATUM"
@export var modifikationsTimestamp: String = "KEIN MODIFICATION TIMESTAMP"
@export var eintritsdatum: String = "KEIN EINTRITSDATUM"
@export var kundennummerHash: String = "KEINE KUNDENNUMMER HASH"

@export var attribute_dict: Dictionary = {}
@export var attribute_list: Array = []

# Favorite Attributes
@export var fav_status: String = "Nicht bearbeitet"
@export var link: String = ""
@export var notes: String = ""


func set_resource_name_from_fields() -> void:
	var clean_title: String = titel.strip_edges().replace(",", "").replace("\n", " ")
	var clean_arbeitgeber: String = arbeitgeber.strip_edges().replace(",", "").replace("\n", " ")
	var clean_ref: String = refnr.strip_edges()
	resource_name = "%s_%s_%s" % [clean_title, clean_arbeitgeber, clean_ref]



func update_attribute_list() -> void:
	attribute_dict = {
		"beruf": beruf,
		"titel": titel,
		"refnr": refnr,
		"plz": plz,
		"ort": ort,
		"strasse": strasse,
		"region": region,
		"land": land,
		"entfernung": entfernung,
		"koordinaten": koordinaten,
		"ortsteil": ortsteil,
		"arbeitgeber": arbeitgeber,
		"aktuelleVeroeffentlichungsdatum": aktuelleVeroeffentlichungsdatum,
		"modifikationsTimestamp": modifikationsTimestamp,
		"eintritsdatum": eintritsdatum,
		"kundennummerHash": kundennummerHash,
	}
	link = str("https://www.arbeitsagentur.de/jobsuche/jobdetail/" + refnr)
	attribute_list = [beruf, titel, arbeitgeber, region, ort, plz, ortsteil, entfernung, strasse, eintritsdatum, link, fav_status, notes ,land, koordinaten, aktuelleVeroeffentlichungsdatum, refnr, kundennummerHash, modifikationsTimestamp]
	set_resource_name_from_fields()
