void main(){
	boolean isScriptEnabled = get_property("preAdventureScript") == "safeDreadPreAdventure.ash";

	set_property("preAdventureScript", isScriptEnabled ? "" : "safeDreadPreAdventure.ash");
	print(isScriptEnabled ? "Pre-Adventure Script Disabled." : "Pre-Adventure Script Enabled!", "teal");
}
