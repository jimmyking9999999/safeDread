// Globals

// number of monsters to leave alive in a zone
int protecc = 10;
// whether to ignore the above clobber-protection (currently unimplemented)
// boolean rundown = false;
// sanity check counter to make sure the number of monsters remaining matches what we expect it to be
// int[string] left = {"Forest": 1000, "Village": 1000, "Castle": 1000};
string abortMessage = "";
// set_property("_safeDread_clan","ASS");

//function to initialize our preferences
void initPrefs() {
	set_property("_safeDread_clan",get_clan_name());
	set_property("_safeDread_Forest",1337);
	set_property("_safeDread_Village",1337);
	set_property("_safeDread_Castle",1337);
	set_property("_safeDread_clear","none");
}

// Function to clear us to proceed
boolean safeToContinue(string snarf) {
	// Check the dungeon logs, parse out the monsters left in this zone and also see how many skills are left in The Machine
	string raidLog = visit_url("clan_raidlogs.php");
	matcher checkLeft = create_matcher("has defeated <b>(\\d+)</b> monster\\(s\\) in the " + snarf,raidLog);
	matcher checkSkills = create_matcher("used The Machine",raidLog);
	int skillsLeft = 3;
	if(checkSkills.find()){
		skillsLeft -= group_count(checkSkills);
	}

	//print("skills left: " + to_string(skillsLeft));

	if (checkLeft.find()) {
		int remaining = 1000 - to_int(checkLeft.group(1));
		// print("There are " + remaining + " monsters left in the " + snarf,"green");
		int safetyCheck = remaining - 1;

		if (safetyCheck < protecc){
			if (snarf == "Castle" && skillsLeft > 0) {
				abortMessage = "Your next adventure would bring " + get_clan_name() + " down below " + to_string(protecc) + " monsters in the " + snarf + " and there are still " + to_string(skillsLeft) + " skills left in The Machine! Aborting!";
			}
			else {
				abortMessage = "Your next adventure would bring " + get_clan_name() + " down below " + to_string(protecc) + " monsters in the " + snarf + "! Aborting!";
			}
			return false;
		}

		// logic to make sure we're not adventuring at the same time as anyone else

		switch (snarf) {
			case "Forest":
				switch {
					case get_property("_safeDread_Forest") == 1337 || get_property("_safeDread_Forest") < remaining:
						//either the initial run or we lost a fight; set with the number we just pulled from logs
						set_property("_safeDread_Forest",remaining);
					case get_property("_safeDread_Forest") > remaining:
						//more monsters have been killed than we expect; abort!
						print("snarf: " + snarf + "remaining: " + remaining + " _safeDread_Forest" + get_property(" _safeDread_Forest")); //DEBUG
						abortMessage = "More monsters have been killed in the forest than we can account for. Check with your clan to make sure you're the only one in this zone, then run `set _safeDread_Forest = 1337` in the cli";
						//return false;
					default:
						//no issues; decrement our counter
						set_property("_safeDread_Forest",safetyCheck);
				}
			case "Village":
				switch {
					case get_property("_safeDread_Village") == 1337 || get_property("_safeDread_Village") < remaining:
						//either the initial run or we lost a fight; set with the number we just pulled from logs
						set_property("_safeDread_Village",remaining);
					case get_property("_safeDread_Village") > remaining:
						//more monsters have been killed than we expect; abort!
						print("snarf: " + snarf + "remaining: " + remaining + " _safeDread_Village" + get_property(" _safeDread_Village")); //DEBUG
						abortMessage = "More monsters have been killed in the Village than we can account for. Check with your clan to make sure you're the only one in this zone, then run `set _safeDread_Village = 1337` in the cli";
						//return false;
					default:
						//no issues; decrement our counter
						set_property("_safeDread_Village",safetyCheck);

				}
			case "Castle":
				switch {
					case get_property("_safeDread_Castle") == 1337 || get_property("_safeDread_Castle") < remaining:
						//either the initial run or we lost a fight; set with the number we just pulled from logs
						set_property("_safeDread_Castle",remaining);
					case get_property("_safeDread_Castle") > remaining:
						//more monsters have been killed than we expect; abort!
						print("snarf: " + snarf + "remaining: " + remaining + " _safeDread_Castle" + get_property(" _safeDread_Castle")); //DEBUG
						abortMessage = "More monsters have been killed in the Castle than we can account for. Check with your clan to make sure you're the only one in this zone, then run `set _safeDread_Castle = 1337` in the cli";
						//return false;
					default:
						//no issues; decrement our counter
						set_property("_safeDread_Castle",safetyCheck);
				}

		}
		return true;
	}

	else {
		// this might mean that it's a brand-new instance
		matcher checkDreadOpen = create_matcher("div id..Dread",raidLog);
		if (!checkDreadOpen.find()) {
			abortMessage = "It doesn't look like dreadsylania is open in " + get_clan_name();
			return false;
		}
		else{
			//Dread's open, we just haven't killed anything in this zone yet. Proceed!
			return true;
		}
	}
	return false;
}


void main() {
	// print(to_string(my_location()));
	matcher zoneParse = create_matcher("Dreadsylvanian (\\w+)",my_location());
		
	if (zoneParse.find()){

		if(get_property("_safeDread_clan") != get_clan_name()){
			//we've changed clans; refresh everything
			initPrefs();
		}

		string zone = to_string(zoneParse.group(1));

		boolean proceed = True;
		if (zone == "Woods"){
			proceed = safeToContinue("Forest");
		}
		else {
			proceed = safeToContinue(zone);
		}

		if (!proceed && get_property("_safeDread_clear") != zone){
			abort(abortMessage);
		}	
	}

	
}