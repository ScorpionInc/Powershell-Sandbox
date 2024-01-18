
Set-Variable -Name ALPHA_UPPER -Value ((65..(65+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name ALPHA_LOWER -Value ((97..(97+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name ALPHA -Value ((97..(97+25) + 65..(65+25)).ForEach({ [char]$_ })) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
function Convert-ROT([int]$block_size, [char]$source_char, $characters = $Global:ALPHA) {
    $characters_count = $characters.Count;
    $source_index = -1;
    for($i = 0; $i -lt $characters_count; $i++){
        if($characters[$i] -eq $source_char){
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
    $target_block = $(($source_block - 1));
    return $characters[$target_block * $block_size];
}
Convert-ROT 13 'W'
