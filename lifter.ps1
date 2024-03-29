param( 
    [int]$keep = 50  # By default, keep only 50 latest images
)

$interfaceLiftUrl = "http://interfacelift.com"
$imageFolderPath = $PSScriptRoot + "\InterfaceLift"

if (!(Test-Path $imageFolderPath)) {
    New-Item $imageFolderPath -ItemType directory
}


$agilityPath = [string]::Format("{0}\HtmlAgilityPack.dll", $PSScriptRoot)
[Reflection.Assembly]::LoadFile($agilityPath)

$userAgent = "User-Agent"
$userAgentValue = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)"

$client = New-Object System.Net.WebClient
$client.Headers.Add($userAgent, $userAgentValue)
$downloads = $client.DownloadString($interfaceLiftUrl + "/wallpaper/downloads/date/widescreen/1920x1080/")

$htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
$htmlDoc.Loadhtml($downloads)

$htmlDoc.DocumentNode.SelectNodes("//div[@class='download']") | foreach {  
    $download = $_.SelectSingleNode(".//a")
    $url = New-Object System.Uri([string]::Format("{0}{1}", $interfaceLiftUrl, $download.Attributes["href"].Value)) 
    $image = $url.Segments[-1]

    $imagePath = [string]::Format("{0}\{1}", $imageFolderPath, $image)
    if (!(Test-Path $imagePath)) {
        $client.Headers.Add($userAgent, $userAgentValue)
        $client.DownloadFile($url, $imagePath)
    }
}

# keep only recent images
Get-ChildItem $imageFolderPath -Filter "*.jpg" | 
    Sort-Object -Property Name -Descending |
    Select-Object -Skip $keep |
    Remove-Item -Force