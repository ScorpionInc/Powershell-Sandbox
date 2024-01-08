#Add a ll function that includes hidden and ads
function ll(){
 return(Get-ChildItem -Force | ForEach-Object {
  Get-Item $_.FullName -Force
  Get-Item $_.FullName -Force -Stream * | Select -ExpandProperty PSPath
 })
}
