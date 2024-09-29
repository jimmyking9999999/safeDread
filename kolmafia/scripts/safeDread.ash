void main(){
	boolean isScriptEnabled = get_property("betweenBattleScript") == "safeDreadPreAdventure.ash";

	set_property("betweenBattleScript", isScriptEnabled ? "" : "safeDreadPreAdventure.ash");
	print(isScriptEnabled ? "Pre-Adventure Script Disabled." : "Pre-Adventure Script Enabled!", "teal");
}
