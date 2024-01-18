
Set-Variable -Name NUMERICS -Value ((48..(48+9)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name ALPHA_UPPER -Value ((65..(65+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name ALPHA_LOWER -Value ((97..(97+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name ALPHA -Value ((65..(65+25)+97..(97+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
function Convert-CharacterBlockROL([int]$block_size, [char]$source_char, [array]$characters = $Global:ALPHA) {
    $characters_count = $characters.Count;
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
function Convert-ROT13([string[]]$Text ){
    foreach($line in $Text){
        $next_line = "";
        foreach($c in $line.ToCharArray()){
            $nc = $( Convert-CharacterBlockROL -block_size 13 -source_char $c -characters $Global:ALPHA_UPPER )
            $nc = $( Convert-CharacterBlockROL -block_size 13 -source_char $nc -characters $Global:ALPHA_LOWER )
            $next_line = ($next_line + $nc);
        }
        $next_line;
    }
}
Convert-ROT13 'Why did the chicken'
