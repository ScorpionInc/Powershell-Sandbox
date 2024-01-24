class BruteForceItem {
    # Properties
    [string]$CharacterSet=""
    [int]$Index=0
    # Constructor(s)
    BruteForceItem() {
        $this.Init(@{})
    }
    BruteForceItem([hashtable]$Properties) {
        $this.Init($Properties)
    }
    BruteForceItem([string]$CharacterSet, [int]$InitialIndex = 0) {
        $this.Init(@{CharacterSet = $CharacterSet; Index = $InitialIndex})
    }
    # Function(s)
    [int] GetCharactersLength() {
        return $this.CharacterSet.Length;
    }
    [bool] IsValid() {
        return ($this.Index -ge 0) -and ($this.Index -lt $this.CharacterSet.Length);
    }
    [bool] IsInvalid() {
        return -not $this.IsValid();
    }
    [bool] CanStep(){
        if($this.IsInvalid()){
            return $true;
        }
        return $this.Index -ne $(($this.CharacterSet.Length - 1));
    }
    [string] ToString() {
        if($this.IsInvalid()){
            return "";
        }
        return "$($this.CharacterSet.ToCharArray()[$this.Index])";
    }
    [string] DoStep(){
        if($this.canStep()){
            $this.Index = $(($this.Index + 1));
        } else {
            $this.Index = 0;
        }
        return $this.ToString();
    }
    # Method(s)
    [void] Init([hashtable]$Properties){
        foreach($Property in $Properties.Keys){
            $this.$Property = $Properties.$Property
        }
    }
}

class BruteForceArray {
    # Properties
    [BruteForceItem[]] $BruteForceItems = @()
    # Constructor(s)
    BruteForcer(){}
    # Function(s)
    [int] Count(){
        return $this.BruteForceItems.Count
    }
    [bool] CanStep(){
        if($this.BruteForceItems.Count -le 0){
            return $false
        }
        foreach($item in $this.BruteForceItems){
            if($item.CanStep()){
                return $true
            }
        }
        return $false
    }
    [string] ToString(){
        $rsa = "";
        foreach($item in $this.BruteForceItems){
            $rsa = ($rsa + $item.ToString())
        }
        return "$($rsa)";
    }
    [string] DoStep(){
        $stepOccured = $false
        for($i = 0; $i -lt $this.BruteForceItems.Count; $i++){
            $stepUpHere = $true
            for($ii = $(($i + 1)); $ii -lt $this.BruteForceItems.Count; $ii++){
                if($this.BruteForceItems[$ii].CanStep()){
                    $stepUpHere = $false
                    break
                }
            }
            if($stepUpHere){
                $stepOccured = $true
                $this.BruteForceItems[$i].DoStep()
                for($ii = $(($i + 1)); $ii -lt $this.BruteForceItems.Count; $ii++){
                    $this.BruteForceItems[$ii].DoStep()
                }
                break
            }
        }
        if(-not $stepOccured){
            $this.ResetIndexes()
        }
        return $this.ToString();
    }
    # Method(s)
    [void] Init([string]$CharacterSet, [int]$Count, [string]$InitialValue=""){
        $this.BruteForceItems.Clear();
        for($i = 0; $i -lt $Count; $i++){
            $initialIndex = 0;
            if($i -lt $InitialValue.Length){
                $initialChar = $InitialValue.ToCharArray()[$i];
                $initialIndex = $CharacterSet.IndexOf($initialChar);
                if($initialIndex -lt 0){
                    $initialIndex = 0;
                }
            }
            $this.BruteForceItems += [BruteForceItem]::new($CharacterSet, $initialIndex);
        }
    }
    [void] SetAllIndexes([int]$NewIndex){
        foreach($item in $this.BruteForceItems){
            $item.Index = $NewIndex
        }
    }
    [void] ResetIndexes(){
        $this.SetAllIndexes(0);
    }
    [void] RunWith([scriptblock]$FunctionToCall){
        $FunctionToCall.Invoke($this.ToString())
        while($this.CanStep()){
            $FunctionToCall.Invoke($this.DoStep())
        }
    }
}

class BruteForcer{
}

function Write-HostA($p){ Write-Host -sep '' "start" $p; }
$forcer = [BruteForceArray]::new();
$forcer.Init("0123456789", 4, "");
$forcer.RunWith(${function:Write-HostA})
