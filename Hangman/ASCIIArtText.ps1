function New-ASCIITextTable(){
	# Returns hashtable of ASCII art for common English Letters using only ASCII.
	# Target Size is 6 lines and <= 12 wide.
	# Uppercase initialized as empty strings.
	#$letters_data = @{};# Case-Insensitive(Wrong)
	#$letters_data = [hashtable]::new();
	$letters_data = New-Object -TypeName hashtable
	foreach($l in 65..90){
		$letters_data[ $([char]$l) ] = "";
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
	$letters_data["F"] += "|_|";
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
	$letters_data["Z"] += "/-----\`n";
	$letters_data["Z"] += "\---/ /`n";
	$letters_data["Z"] += "   / /`n";
	$letters_data["Z"] += "  / /`n";
	$letters_data["Z"] += " / /--\`n";
	$letters_data["Z"] += "<-----/";
	# Lowercase Initialized as Uppercase
	foreach($l in 97..122){
		#Write-Host "Setting letters_data[$([char]$l)] to: '$($letters_data[ [char]$(($l - 32)) ])'." #Debugging
		$letters_data[ "$([char]$l)" ] = $letters_data[ "$([char]$(($l - 32)))" ];
	}
	$letters_data["a"]  = "/-----\`n";
	$letters_data["a"] += "| |-| |`n";
	$letters_data["a"] += "| |-| \`n";
	$letters_data["a"] += "\----\/";
	$letters_data["b"]  = "/-\`n";
	$letters_data["b"] += "| |`n"
	$letters_data["b"] += "| \---\`n";
	$letters_data["b"] += "| /-\ |`n"
	$letters_data["b"] += "| \-/ |`n";
	$letters_data["b"] += "\-----/";
	$letters_data["c"]  = "/---|`n";
	$letters_data["c"] += "| |-/`n";
	$letters_data["c"] += "| |-\`n";
	$letters_data["c"] += "\---|";
	$letters_data["d"]  = "    /-\`n";
	$letters_data["d"] += "    | |`n"
	$letters_data["d"] += "/---/ |`n";
	$letters_data["d"] += "| /-\ |`n"
	$letters_data["d"] += "| \-/ |`n";
	$letters_data["d"] += "\-----/";
	$letters_data["e"]  = "/----\`n";
	$letters_data["e"] += "| <> |`n";
	$letters_data["e"] += "| |--/`n";
	$letters_data["e"] += "| \--\`n";
	$letters_data["e"] += "\----/";
	$letters_data["f"]  = "   /---\`n";
	$letters_data["f"] += "  / /--/`n";
	$letters_data["f"] += "/-+ \-\`n";
	$letters_data["f"] += "\-+ +-/`n";
	$letters_data["f"] += "  | |`n";
	$letters_data["f"] += "  +-+";
	$letters_data["g"]  = "/----\`n";
	$letters_data["g"] += "| <> |`n";
	$letters_data["g"] += "\--| \`n";
	$letters_data["g"] += " /-/ /`n";
	$letters_data["g"] += " \--/";
	$letters_data["h"]  = "/-\`n";
	$letters_data["h"] += "| |`n";
	$letters_data["h"] += "| |--\`n";
	$letters_data["h"] += "| /-\ \`n";
	$letters_data["h"] += "| | | |`n";
	$letters_data["h"] += "+-+ +-+";
	$letters_data["i"] =  " /-\`n";
	$letters_data["i"] += " \-/`n";
	$letters_data["i"] += " /-\`n"
	$letters_data["i"] += " | |`n";
	$letters_data["i"] += " | |`n";
	$letters_data["i"] += "/---\";
	$letters_data["l"]  = "+-+`n";
	$letters_data["l"] += "| |`n";
	$letters_data["l"] += "| |`n";
	$letters_data["l"] += "| |`n";
	$letters_data["l"] += "| |`n";
	$letters_data["l"] += "+-+";
	$letters_data["m"] =  "  /\  /\`n";
	$letters_data["m"] += " /  \/  \`n";
	$letters_data["m"] += "/ /\  /\ \`n";
	$letters_data["m"] += "\/  \/  \/";
	$letters_data["n"]  = "|-|--\`n";
	$letters_data["n"] += "| /-\ \`n";
	$letters_data["n"] += "| | | |`n";
	$letters_data["n"] += "+-+ +-+";
	$letters_data["o"]  = "/-----\`n";
	$letters_data["o"] += "| |-| |`n";
	$letters_data["o"] += "| |-| |`n";
	$letters_data["o"] += "\-----/";
	$letters_data["p"]  = "/-----\`n";
	$letters_data["p"] += "| +-+ |`n";
	$letters_data["p"] += "| +-+ |`n";
	$letters_data["p"] += "| /--/`n";
	$letters_data["p"] += "| |`n";
	$letters_data["p"] += "\-/";
	$letters_data["q"]  = "/-----\`n";
	$letters_data["q"] += "| |-| |`n";
	$letters_data["q"] += "| |-| |`n";
	$letters_data["q"] += "\--\  |`n";
	$letters_data["q"] += "    | |`n";
	$letters_data["q"] += "    \-/";
	$letters_data["r"]  = "/-v--\`n";
	$letters_data["r"] += "| +--/`n";
	$letters_data["r"] += "| |`n";
	$letters_data["r"] += "+-+";
	$letters_data["s"]  = "//===>`n";
	$letters_data["s"] += "||`n";
	$letters_data["s"] += "L\==\\`n";
	$letters_data["s"] += "     ||`n";
	$letters_data["s"] += "<===//";
	$letters_data["t"]  = "  /-\`n";
	$letters_data["t"] += "/-+ +-\`n";
	$letters_data["t"] += "\-+ +-/`n";
	$letters_data["t"] += "  | |`n";
	$letters_data["t"] += "  | |`n";
	$letters_data["t"] += "  +-+";
	$letters_data["u"]  = "+-+   +-+`n";
	$letters_data["u"] += "| |   | |`n";
	$letters_data["u"] += " \ \-/ /`n";
	$letters_data["u"] += "  \---/";
	$letters_data["v"]  = "/\    /\`n";
	$letters_data["v"] += "\ \  / /`n";
	$letters_data["v"] += " \ \/ /`n";
	$letters_data["v"] += "  \--/";
	$letters_data["w"] =  "/\        /\`n";
	$letters_data["w"] += "\ \  /\  / /`n";
	$letters_data["w"] += " \ \/  \/ /`n";
	$letters_data["w"] += "  \--/\--/";
	$letters_data["x"]  = "/\  /\`n";
	$letters_data["x"] += "\ \/ /`n";
	$letters_data["x"] += "/ /\ \`n";
	$letters_data["x"] += "\/  \/";
	# Symbol(s)
	$letters_data[" "] =  "    ";
	$letters_data["."] =  "/-\`n";
	$letters_data["."] += "\-/";
	$letters_data[","] =  "/-\`n";
	$letters_data[","] +=  "\  |`n";
	$letters_data[","] += " |/";
	return($letters_data);
}
# Returns the height of a specific character in by line breaks
function Get-ASCIIArtCharHeight([char]$Character, [hashtable]$ASCIIArtSet = @()){
	if($ASCIIArtSet.ContainsKey($Character)){
		$art = $ASCIIArtSet["$($Character)"]
		$counter = 0
		ForEach($line in $($art -split "[\r\n]+")){
			$counter += 1
		}
		return $counter
	}
	return 0
}
# Returns the max and min width of the ascii characters rows.
function Get-ASCIIArtCharWidth([char]$Character, [hashtable]$ASCIIArtSet = @()){
	if($ASCIIArtSet.ContainsKey($Character)){
		$art = $ASCIIArtSet["$($Character)"]
		$counter = 0
		ForEach($line in $($art -split "[\r\n]+")){
			$LineLength = $line.Length
			if($LineLength -gt $counter){
				$counter = $LineLength
			}
		}
		return $counter
	}
	return 0
}

# Generates ASCII Art to represent string input value.
function New-ASCIIArtText([String]$Text, [hashtable]$ASCIIArtSet = @()){
	$buffer = "";
	$lineCount = 0;
	$cWidths = @();
	foreach($c in $Text.ToCharArray()){
		if(-not $ASCIIArtSet.ContainsKey("$($c)")){
			# No ASCII Art Defined for character.
			continue
		}
		$nextArt = $ASCIIArtSet["$($c)"];
		if([string]::IsNullOrEmpty($nextArt)){
			# Character's art is defined but is empty.
			continue;
		}
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
			$nextArt = $ASCIIArtSet["$($cArray[$ii])"];
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

# Example Usage:
#$ASCIIARTTEXT = (New-ASCIITextTable)
#Write-Host "$(New-ASCIIArtText -Text "Hello World." -ASCIIArtSet ($ASCIIARTTEXT))"
