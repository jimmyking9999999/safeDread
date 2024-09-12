// Globals

// number of monsters to leave alive in a zone
int protecc = 600;
// whether to ignore the above clobber-protection (currently unimplemented)
boolean rundown = false;
// sanity check counter to make sure the number of monsters remaining matches what we expect it to be
// int[string] left = {"Forest": 1000, "Village": 1000, "Castle": 1000};
string abortMessage = "";

// Function to check monsters left in a given location
boolean safeToContinue(string snarf) {
	// Check the dungeon logs, parse out the monsters left in this zone and also see how many skills are left in The Machine
	string raidLog = visit_url("clan_raidlogs.php");
	matcher checkLeft = create_matcher("has defeated <b>(\\d+)</b> monster\\(s\\) in the " + snarf,raidLog);
	matcher checkSkills = create_matcher("used The Machine",raidLog);
	int skillsLeft = 3 - group_count(checkSkills);

	if (checkLeft.find()) {
		int remaining = 1000 - to_int(checkLeft.group(1));
		print("There are " + remaining + " monsters left in the " + snarf,"green");
		int safetyCheck = remaining - 1;

		if (safetyCheck < protecc){
			if (snarf == "Dreadsylvanian Castle" && skillsLeft > 0) {
				abortMessage = "Your next adventure would bring " + get_clan_name() + " down below " + to_string(protecc) + " monsters in the " + snarf + " and there are still " + to_string(skillsLeft) + " skills left in The Machine! Aborting!";
			}
			else {
				abortMessage = "Your next adventure would bring " + get_clan_name() + " down below " + to_string(protecc) + " monsters in the " + snarf + "! Aborting!";
			}
			return false;
		}

		// add logic to check against left for the zone. To get this working in a preadv I'll need to use a preference

		// switch {
		// 	case left[snarf] != remaining && (left[snarf] == 1000 || remaining >= 300):
		// 		//initial run
		// 		print("Expected to find " + left[snarf] + " monsters left in the " + snarf + ", but found " + remaining);
		// 		left[snarf] = remaining;
		// 		return remaining;
		// 	case left[snarf] != remaining && remaining < 300:
		// 		//mismatch, so someone else is adventuring, and there are few enough monsters left that we want to be careful
		// 		left[snarf] = remaining;
		// 		print("Expected to find " + left[snarf] + " monsters left in the " + snarf + ", but found " + remaining + ", which is less than 300", "red");
		// 		return remaining;
		// 	default:
		// 		return remaining;
		// }
		return true;
	}

	else {
		// this might mean that it's a brand-new instance
		matcher checkDreadOpen = create_matcher("div id..Dread",raidLog);
		if (!checkDreadOpen.find()) {
			abortMessage = "It doesn't look like dreadsylania is open in " + get_clan_name();
			return false;
		}
	}
	return false;
}


void main() {
	// print(to_string(my_location()));
	matcher zoneParse = create_matcher("Dreadsylvanian (\\w+)",my_location());
		
	if (zoneParse.find()){
		string zone = to_string(zoneParse.group(1));

		boolean proceed = True;
		if (zone == "Woods"){
			proceed = safeToContinue("Forest");
		}
		else {
			proceed = safeToContinue(zone);
		}

		if (!proceed){
			abort(abortMessage);
		}	
	}

	
}