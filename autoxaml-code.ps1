# ============================================================================
#
# Auto XAML Music Playlist for vMix v 1.0.0 - by Abel Chirinos Jara
#
# @author Abel Chirinos Jara <jchirinosjara@gmail.com>
# @version 1.0.0
#
# Basado en el c�digo de @Speegs y @JAIRODJ
# https://forums.vmix.com/posts/t1177-Auto-update-NOW-PLAYING-graphic-overlay
# ============================================================================


param (
    [int]$type = 1,
    [int]$input_no = 2,
    [string]$overlay_no = "2",
    [string]$title_name = "Headline",
    [int]$xaml_time = 10,
    [string]$in_num = "1",
    [string]$artist_name = "Headline",
    [string]$song_name = "Description",
    [string]$artist = " ",
    [string]$song = " ",
    [string]$message = " "
)

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

# Set XAML type
$type = [Microsoft.VisualBasic.Interaction]::InputBox("Ingrese opci�n XAML | 1 = Artista y Canci�n | 2 = T�tulo Completo", "Tipo de XAML", $type)
# Set Playlist input number
$in_num = [Microsoft.VisualBasic.Interaction]::InputBox("Ingrese el n�mero de entrada del Playlist", "Ubicaci�n del Playlis", $in_num)
# Set XAML input number
$input_no = [Microsoft.VisualBasic.Interaction]::InputBox("Ingrese en n�mero de la entrada en del XAML", "N�mero/Nombre del XAML", $input_no)

#Validate XAML type
if ($type -eq 1) {
    # Set Artist XAML param
    $artist_name = [Microsoft.VisualBasic.Interaction]::InputBox("Ingrese el campo del artista en XAML a modificar", "T�tulo a modificar", $artist_name)  
    # Set Songt XAM param
    $song_name = [Microsoft.VisualBasic.Interaction]::InputBox("Ingrese el campo del tema en XAML a modificar", "T�tulo a modificar", $song_name)  
}
Else {
    # Set Title XAML param
    $title_name = [Microsoft.VisualBasic.Interaction]::InputBox("Ingrese el campo del t�tulo en XAML a modificar", "T�tulo a modificar", $title_name)  
}
# Set XMAL overlay input 
$overlay_no = [Microsoft.VisualBasic.Interaction]::InputBox("Ingrese el n�mero de overlay para XAML 1,2,3 o 4", "Overlay del XAML", $overlay_no)

# Set XAML time on overlay
$xaml_time = [Microsoft.VisualBasic.Interaction]::InputBox("Ingrese el tiempo del XAML en pantalla", "Tiempo en pantalla", $xaml_time)


while ($true) {
       
    write-host "Automatic XAML Music Playlist v 1.0.0 - by Abel Chirinos Jara <jchirinosjara@gmail.com>"

    # vMix API
    $xmlurl = "http://localhost:8088/API/"
    # Templates API 
    $apicallurl1 = "$($xmlurl)?Function=SetText&Input=$($input_no)&SelectedName=$($title_name)&Value="
    $songurl1 = "$($xmlurl)?Function=SetText&Input=$($input_no)&SelectedName=$($song_name)&Value="
    $artisturl1 = "$($xmlurl)?Function=SetText&Input=$($input_no)&SelectedName=$($artist_name)&Value="
    $transinurl = "$($xmlurl)?Function=OverlayInput$($overlay_no)In&Input=$($input_no)"
    $transouturl = "$($xmlurl)?Function=OverlayInput$($overlay_no)Out&Input=$($input_no)"
    
    # Open vmix API XML
    [xml]$data = (New-Object System.Net.WebClient).DownloadString($xmlurl)
        
    $node = $data.SelectNodes("/vmix/inputs/input[@number='$in_num']")
            
    # Get playlist values
    $title = ($node | Select-Object -ExpandProperty title | Out-String) 
    $playnow = ($node | Select-Object -ExpandProperty state | Out-String)
    $position = ($node | Select-Object -ExpandProperty position | Out-String)
    $duration = ($node | Select-Object -ExpandProperty duration | Out-String)

    # Translate status to spanish
    $playnow = $playnow.Replace("Running", "Reproduciendo");
    $playnow = $playnow.Replace("Paused", "Pausado");

    #Fix Spanish special characters        
    $title = $title.Replace("List - ", "")
    $title = $title.Replace("á", "�")
    $title = $title.Replace("é", "�")
    $title = $title.Replace("ó", "�")
    $title = $title.Replace("ú", "�")
    $title = $title.Replace("Ñ", "�")
    $title = $title.Replace("ñ", "�")
    $title = $title.Replace("�", "�")

    # Remove file format
    $title = $title.Replace(".mp4", "")
    $title = $title.Replace(".mov", "")
    $title = $title.Replace(".wmv", "")
    $title = $title.Replace(".mkv", "")
    $title = $title.Replace(".m4v", "")
    $title = $title.Replace(".m2ts", "")

    $title = $title.Replace(".m4p", "")    
    $title = $title.Replace(".webm", "")
    $title = $title.Replace(".flv", "")
    $title = $title.Replace(".avi", "")
    $title = $title.Replace(".MTS", "")
    $title = $title.Replace(".M2TS", "")
    $title = $title.Replace(".TS", "")
    $title = $title.Replace(".mts", "")
    $title = $title.Replace(".ts", "")
    $title = $title.Replace(".qt", "")
    $title = $title.Replace(".mpg", "")
    $title = $title.Replace(".mpeg", "")
    $title = $title.Replace(".m2v", "")
    $title = $title.Replace(".3gp", "")

    $pos = $title.IndexOf("-")

    $song = " ";
    $artist = " ";

    if (($pos -gt 0)) {
        $song = $title.Substring($pos + 2)
        $artist = $title.Substring(0, $pos)
    }

    $apicallurl = $apicallurl1 + $title

    $songurl = $songurl1 + $song
    $artisturl = $artisturl1 + $artist

    $tremain = $duration - $position
    
    $position1 = [timespan]::fromseconds(($position / 1000))
    $tremain1 = [timespan]::fromseconds(($tremain / 1000))
    $ttotal = [timespan]::fromseconds(($duration / 1000))
    
    $message = (New-Object System.Net.WebClient).DownloadString("$songurl")
    $message = (New-Object System.Net.WebClient).DownloadString("$artisturl")

    if (($pos -le 0)) {
        $message = (New-Object System.Net.WebClient).DownloadString("$apicallurl")
    }
    
    # Script log
    write-host ""
    write-host "AL AIRE : $title" -ForegroundColor Green
    write-host "ARTISTA : $artist"
    write-host "TEMA    : $song"

    write-host "ESTADO  : $playnow"

    write-host "TIEMPO TOTAL        : "("{0:hh\:mm\:ss}" -f $ttotal)
    write-host "TIEMPO TRASCURRIDO  : "("{0:hh\:mm\:ss}" -f $position1)
    if ($tremain -le 10000){
    write-host "TIEMPO RESTANTE     : "("{0:hh\:mm\:ss}" -f $tremain1) -ForegroundColor red
} else{
    write-host "TIEMPO RESTANTE     : "("{0:hh\:mm\:ss}" -f $tremain1)
}
    $xamlintime = 10000;
    $ftimetoenter = $xamlintime;
    $ftimetoexit = ($xaml_time*1000)+$xamlintime
    $ltimetoenter = $duration-$xamlintime-($xaml_time*1000)
    $ltimetoexit = $duration-($xaml_time*1000)

    if (([int]$position -gt 10000) -and ([int]$position -lt $ftimetoexit)) {

        write-host "---------------------------"
        write-host "El XAML se ingres� en el overlay $($overlay_no)"
        write-host "---------------------------"
        $message = (New-Object System.Net.WebClient).DownloadString("$transinurl")
        Start-Sleep -Seconds $xaml_time

        write-host "---------------------------"
        write-host "El XAML se sal�o en el overlay $($overlay_no)"
        write-host "---------------------------"
        $message = (New-Object System.Net.WebClient).DownloadString("$transouturl")
    } Elseif (([int]$position -gt $ltimetoenter) -and ([int]$position -lt $ltimetoexit)) {
        
        write-host "---------------------------"
        write-host "El XAML se ingres� en el overlay $($overlay_no)"
        write-host "---------------------------"
        $message = (New-Object System.Net.WebClient).DownloadString("$transinurl")
        Start-Sleep -Seconds $xaml_time
        
        write-host "---------------------------"
        write-host "El XAML se sal�o en el overlay $($overlay_no)"
        write-host "---------------------------"
        $message = (New-Object System.Net.WebClient).DownloadString("$transouturl")
    }
    # Clear prompt
    Start-Sleep -Seconds 1
    Get-Variable true | Out-Default; Clear-Host;

}