
# my ROT5/13/18/47 Functions
# Reference: https://en.wikipedia.org/wiki/ROT13
Set-Variable -Name NUMERICS -Value ((48..(48+9)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name ALPHA_UPPER -Value ((65..(65+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name ALPHA_LOWER -Value ((97..(97+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name ALPHA -Value ((65..(65+25)+97..(97+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
function Convert-CharacterBlockROL([char]$source_char, [int]$block_size = 0, [array]$characters = $Global:ALPHA) {
    $characters_count = $characters.Count;
    if($characters_count -le 0){
        # Nothing to search/map.
        return $source_char;
    }
    if($block_size -le 0){
        # Automatic block size(half-ish)
        $block_size = [Math]::Floor( $(($characters_count / 2)) )
    }
    $source_index = -1;
    for($i = 0; $i -lt $characters_count; $i++){
        if($characters[$i] -ceq $source_char){
            $source_index = $i;
            break;
        }
    }
    if($source_index -lt 0){
        # Could find the source character in the characters array.
        return $source_char;
    }
    $block_index = $(($source_index % $block_size));
    $source_block = [Math]::Floor($source_index / $block_size);
    $target_block = $(($source_block - 1));# Block-wise ROL
    return $characters[$(($target_block * $block_size + $block_index))];
}
function Convert-ROT5( [string[]]$Text ){
    foreach($line in $Text){
        $next_line = "";
        foreach($c in $line.ToCharArray()){
            $nc = $( Convert-CharacterBlockROL -source_char $c -characters $Global:NUMERICS )
            $next_line = ($next_line + $nc);
        }
        $next_line;
    }
}
function Convert-ROT13( [string[]]$Text ){
    foreach($line in $Text){
        $next_line = "";
        foreach($c in $line.ToCharArray()){
            $nc = $( Convert-CharacterBlockROL -source_char $c -characters $Global:ALPHA_UPPER )
            $nc = $( Convert-CharacterBlockROL -source_char $nc -characters $Global:ALPHA_LOWER )
            $next_line = ($next_line + $nc);
        }
        $next_line;
    }
}
function Convert-ROT18( [string[]]$Text ){
    foreach($l in $(Convert-ROT5 -Text $Text)){
        Convert-ROT13 -Text $l;
    }
}
# e.g. Convert-ROT18 '6 78 901 2345 Why did the chicken'
# Modified from: https://rot47.net/
function Convert-ROT47( [string[]]$Text ){
    $buff = $(Clone-Object $Text.ToCharArray());
    for($i = 0; $i -lt $buff.Count; $i++){
        if($buff[$i] -ge 33 -and $buff[$i] -le 126){
            $buff[$i] = [char]$((33 + $(($(([int]$buff[$i] + 14)) % 94))));
        }
    }
    return $(-Join $buff)
}
# e.g. Convert-ROT47 'Hello World!'
