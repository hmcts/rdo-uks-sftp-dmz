

if (!($smtpserversetting.SmartHost -eq "smtp.gmail.com")) { 

    $ipblock= @(24,0,0,128,
    32,0,0,128,
    60,0,0,128,
    68,0,0,128,
    1,0,0,0,
    76,0,0,0,
    0,0,0,0,
    0,0,0,0,
    1,0,0,0,
    0,0,0,0,
    2,0,0,0,
    1,0,0,0,
    4,0,0,0,
    0,0,0,0,
    76,0,0,128,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    255,255,255,255)

    $ipList = @()
    $octet = @()
 
    $ipList = "127.0.0.1"
    $octet += $ipList.Split(".")


    $ipblock[36] +=2 
    $ipblock[44] +=2;

    $smtpserversetting = get-wmiobject -namespace root\MicrosoftIISv2 -computername localhost -Query "Select * from IIsSmtpServerSetting" -ErrorAction SilentlyContinue
    $ipblock += $octet
    write-host "Setting up SMTP"
    
 
    $smtpserversetting.AuthBasic=1
    $smtpserversetting.RelayIpList=$ipblock
    $smtpserversetting.AuthFlags=1
    $smtpserversetting.RelayForAuth=-1
    $smtpserversetting.RemoteSmtpPort=587
    $smtpserversetting.RouteAction=268
    $smtpserversetting.RoutePassword="2y2adm;n2018!!"
    $smtpserversetting.RouteUserName="eftsftp@gmail.com"
    $smtpserversetting.SmartHost="smtp.gmail.com"
    $smtpserversetting.SmartHostType=2
    $smtpserversetting.put() | Out-Null
    
}

