function initASCIITextTable(){
	#TODO
	# Target Size is 6 lines and <= 12 wide.
	# Uppercase initialized as empty strings.
	$letters_data = @{};
	foreach($l in 65..90){
		$letters_data[ [char]$l ] = "";
	}
	$letters_data["A"] += "     /\`n";
	$letters_data["A"] += "    /  \`n";
	$letters_data["A"] += "   / /\ \`n";
	$letters_data["A"] += "  / /--\ \`n";
	$letters_data["A"] += " / /----\ \`n";
	$letters_data["A"] += "/_/      \_\";
	$letters_data["B"] += "+----\`n";
	$letters_data["B"] += "| +-\ \`n";
	$letters_data["B"] += "| |-/ /`n";
	$letters_data["B"] += "| |-\ \`n";
	$letters_data["B"] += "| +-/ /`n";
	$letters_data["B"] += "+----/";
	$letters_data["C"] += "+------\`n";
	$letters_data["C"] += "| +----/`n";
	$letters_data["C"] += "| |`n";
	$letters_data["C"] += "| |`n";
	$letters_data["C"] += "| +----\`n";
	$letters_data["C"] += "|------/";
	$letters_data["D"] += "|----\`n";
	$letters_data["D"] += "| +-= \`n";
	$letters_data["D"] += "| |  \ \`n";
	$letters_data["D"] += "| |  / /`n";
	$letters_data["D"] += "| +-= /`n";
	$letters_data["D"] += "|----/";
	$letters_data["E"] += "+-----\`n";
	$letters_data["E"] += "| +---/`n";
	$letters_data["E"] += "| +---\`n";
	$letters_data["E"] += "| +---/`n";
	$letters_data["E"] += "| +---\`n";
	$letters_data["E"] += "|-----/";
	$letters_data["F"] += "+-----\`n";
	$letters_data["F"] += "| +---/`n";
	$letters_data["F"] += "| +---\`n";
	$letters_data["F"] += "| +---/`n";
	$letters_data["F"] += "| |`n";
	$letters_data["F"] += "|-|";
	$letters_data["G"] += "+------\`n";
	$letters_data["G"] += "| +----/`n";
	$letters_data["G"] += "| |/--\`n";
	$letters_data["G"] += "| |\--+|`n";
	$letters_data["G"] += "| |---||`n";
	$letters_data["G"] += "|------/";
	$letters_data["H"] += "+-+   +-+`n";
	$letters_data["H"] += "| |   | |`n";
	$letters_data["H"] += "| |---| |`n";
	$letters_data["H"] += "| |---| |`n";
	$letters_data["H"] += "| |   | |`n";
	$letters_data["H"] += "+-+   +-+";
	$letters_data["I"] += "/-----\`n";
	$letters_data["I"] += "\-+ +-/`n";
	$letters_data["I"] += "  | |  `n";
	$letters_data["I"] += "  | |  `n";
	$letters_data["I"] += "/-+ +-\`n";
	$letters_data["I"] += "\-----/";
	$letters_data["J"] += "+-----+`n";
	$letters_data["J"] += "+-+ +-+`n";
	$letters_data["J"] += "  | |  `n";
	$letters_data["J"] += "  | |  `n";
	$letters_data["J"] += "+-+ +`n";
	$letters_data["J"] += "\---/`n";
	$letters_data["K"] += "+-+ --+`n";
	$letters_data["K"] += "| |/ /`n";
	$letters_data["K"] += "| | /`n";
	$letters_data["K"] += "| |/\`n";
	$letters_data["K"] += "| |\ \`n";
	$letters_data["K"] += "+-+ +-+";
	$letters_data["L"] += "+-+`n";
	$letters_data["L"] += "| |`n";
	$letters_data["L"] += "| |`n";
	$letters_data["L"] += "| |`n";
	$letters_data["L"] += "| +--\`n";
	$letters_data["L"] += "+----/";
	$letters_data["M"] += "    /\ /\`n";
	$letters_data["M"] += "   /  v  \`n";
	$letters_data["M"] += "  / /\ /\ \`n";
	$letters_data["M"] += " / /  v  \ \`n";
	$letters_data["M"] += "/_/       \_\";
	$letters_data["N"] += "+-+  +-+`n";
	$letters_data["N"] += "| |\ | |`n";
	$letters_data["N"] += "| | \| |`n";
	$letters_data["N"] += "| |\ | |`n";
	$letters_data["N"] += "| | \| |`n";
	$letters_data["N"] += "+-+  +-+";
	$letters_data["O"] += "/------\`n";
	$letters_data["O"] += "| /--\ |`n";
	$letters_data["O"] += "| |  | |`n";
	$letters_data["O"] += "| |  | |`n";
	$letters_data["O"] += "| \--/ |`n";
	$letters_data["O"] += "\------/";
	$letters_data["P"] += "/------\`n";
	$letters_data["P"] += "| /--\ |`n";
	$letters_data["P"] += "| |--/ |`n";
	$letters_data["P"] += "| |----/`n";
	$letters_data["P"] += "| |`n";
	$letters_data["P"] += "+-+";
	$letters_data["Q"] += "/------\`n";
	$letters_data["Q"] += "| /--\ |`n";
	$letters_data["Q"] += "| | _| |`n";
	$letters_data["Q"] += "| \\ \ |`n";
	$letters_data["Q"] += "+---\ \/`n";
	$letters_data["Q"] += "     \_|";
	$letters_data["R"] += "/------\`n";
	$letters_data["R"] += "| /--\ |`n";
	$letters_data["R"] += "| | _| |`n";
	$letters_data["R"] += "| |\ \/`n";
	$letters_data["R"] += "| | \ \`n";
	$letters_data["R"] += "+-+  \_|";
	$letters_data["S"] += "/------\`n";
	$letters_data["S"] += "| /----/`n";
	$letters_data["S"] += "| \---\`n";
	$letters_data["S"] += "\----\ \`n";
	$letters_data["S"] += "/----/ |`n";
	$letters_data["S"] += "\------/";
	$letters_data["T"] += "/-------\`n";
	$letters_data["T"] += "\--\ /--/`n";
	$letters_data["T"] += "   | |`n";
	$letters_data["T"] += "   | |`n";
	$letters_data["T"] += "   | |`n";
	$letters_data["T"] += "   \-/";
	$letters_data["U"] += "/-\   /-\`n";
	$letters_data["U"] += "| |   | |`n";
	$letters_data["U"] += "| |   | |`n";
	$letters_data["U"] += "| |   | |`n";
	$letters_data["U"] += "\ \___/ /`n";
	$letters_data["U"] += " \-----/";
	$letters_data["V"] += "/\        /\`n";
	$letters_data["V"] += "\ \      / /`n";
	$letters_data["V"] += " \ \    / /`n";
	$letters_data["V"] += "  \ \  / /`n";
	$letters_data["V"] += "   \ \/ /`n";
	$letters_data["V"] += "    \--/";
	$letters_data["W"] += "/-\      /-\`n";
	$letters_data["W"] += "| |      | |`n";
	$letters_data["W"] += "| |      | |`n";
	$letters_data["W"] += "\ \  /\  / /`n";
	$letters_data["W"] += " \ \/  \/ /`n";
	$letters_data["W"] += "  \--/\--/";
	$letters_data["X"] += "/\    /\`n";
	$letters_data["X"] += "\ \  / /`n";
	$letters_data["X"] += " \ \/ /`n";
	$letters_data["X"] += " / /\ \`n";
	$letters_data["X"] += "/ /  \ \`n";
	$letters_data["X"] += "|/    \|";
	$letters_data["Y"] += "/\   /\`n";
	$letters_data["Y"] += "\ \ / /`n";
	$letters_data["Y"] += " \ v /`n";
	$letters_data["Y"] += "  | |`n";
	$letters_data["Y"] += "  | |`n";
	$letters_data["Y"] += "  |-|";
	# Lowercase Initialized as Uppercase
	foreach($l in 97..122){
		$letters_data[ [char]$l ] = $letters_data[ [char]$(($l - 32)) ];
	}
	$letters_data["w"] += "/\        /\`n";
	$letters_data["w"] += "\ \  /\  / /`n";
	$letters_data["w"] += " \ \/  \/ /`n";
	$letters_data["w"] += "  \--/\--/";
	return($letters_data);
}
# Returns the height of a specific character in by line breaks
function Get-ASCIIArtCharHeight([char]$Character, [array]$ASCIIArtSet = @()){
}
# Returns the max and min width of the ascii characters rows.
function Get-ASCIIArtCharWidth([char]$Character, [array]$ASCIIArtSet = @()){
}
$ASCIIARTTEXT = (initASCIITextTable);
# Generates ASCII Art to represent string input value.
function Generate-ASCIIArtText([String]$Text){
	$buffer = "";
	$lineCount = 0;
	$cWidths = @();
	foreach($c in $Text.ToCharArray()){
		$nextArt = $ASCIIARTTEXT["$($c)"];
		$nextArtLines = $nextArt.Split("`n");
		$nextLineCount = $nextArtLines.Count;
		if($lineCount -lt $nextLineCount){
			$lineCount = $nextLineCount;
		}
		$widestLine = 0;
		foreach($artLine in $nextArtLines){
			if($artLine.Length -gt $widestLine){
				$widestLine = $artLine.Length;
			}
		}
		$cWidths+=$widestLine;
	}
	for($i = 0; $i -lt $lineCount; $i++){
		$cArray = $Text.ToCharArray();
		for($ii = 0; $ii -lt $cArray.Count; $ii++){
			$nextArt = $ASCIIARTTEXT["$($cArray[$ii])"];
			$nextArtLines = $nextArt.Split("`n");
			$nextLineCount = $nextArtLines.Count;
			if(($lineCount - $i) -gt $nextLineCount){
				for($iii = -1; $iii -lt $cWidths[$ii]; $iii++){
					$buffer += " ";
				}
				continue;
			}
			$nextArtLine = $nextArtLines[$i - ($lineCount - $nextLineCount)];
			$buffer += $nextArtLine;
			for($iii = $nextArtLine.Length - 1; $iii -lt $cWidths[$ii]; $iii++){
				$buffer += " ";
			}
		}
		if(($i + 1) -lt $lineCount){
			$buffer += "`n";
		}
	}
	return $buffer;
}
echo "$(Generate-ASCIIArtText "HANGMAN")";
