#####################################################
# uszfunctions.ps1
# common functions for our scripts
#####################################################

##### preparing logs path once when importing this template ###########
	$oTempDate = Get-Date
	$sLogSubFolder = ""
	if ($sLogFilePathTemplate -ne "") {
		$sLogSubFolder = $oTempDate.ToString($sLogFilePathTemplate) + "\"
	}
	$sLocalLogPath = $PSScriptRoot + "\logs\" + $sLogSubFolder
	if (-not (Test-Path $sLocalLogPath)) {
		new-item -type directory -path $sLocalLogPath -Force
	}
	$sLocalLogName = $sLocalLogPath + $oTempDate.ToString($sLogFileNameTemplate) +".txt"

#####################################################
function Wlog( $sText ) {
	$sOut = "[" + (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss") + "]: " + $sText
	$sOut | Out-File -FilePath $sLocalLogName -Encoding "UTF8" -Append
	write-host $sOut
}
#####################################################
function tr64($tStr) {
	if ( $tStr -eq $null) {
		return ""
	}
	if ($tStr -ne "") {
		if ($tStr.length -gt 64) {
			$tStr = $tStr.Substring(0,64)
		}
		$tStr = $tStr.Trim()
	}
	return $tStr
}
#####################################################

function log ($tStr,[ref]$rStrReport = [ref]($script:strReport)) {
	$rStrReport.Value += ('<p>' + $tStr +'</p>')
	Wlog ($tStr)
}
#####################################################

function logH3 ($tStr,[ref]$rStrReport = [ref]($script:strReport)) {
	$rStrReport.Value += ('<h3>' + $tStr +'</h3>')
	Wlog ($tStr)
}
#####################################################

function logH2 ($tStr,[ref]$rStrReport = [ref]($script:strReport)) {
	$rStrReport.Value += ('<h2>' + $tStr +'</h2>')
	Wlog ($tStr)
}
#####################################################

function logred ($tStr,[ref]$rStrReport = [ref]($script:strReport)) {
	Wlog ($tStr)
	$rStrReport.Value += ('<p class="red">' + $tStr +'</p>')
}
#####################################################

function loggreen ($tStr,[ref]$rStrReport = [ref]($script:strReport)) {
	Wlog ($tStr)
	$rStrReport.Value += ('<p class="green">' + $tStr +'</p>')
}
#####################################################

function loggray ($tStr,[ref]$rStrReport = [ref]($script:strReport)) {
	$rStrReport.Value += ('<p class="gray">' + $tStr +'</p>')
	Wlog ($tStr)
}

#####################################################

function logtable ($List,[ref]$rStrReport = [ref]($script:strReport)) {
	$tStrTable = "<table><tr>"
	$varList = $List | Get-Member -membertype properties | select -expand Name
	$List | Get-Member -membertype properties | %{
		$tStrTable = $tStrTable + ("<th>" + $_.Name + "</th>")
	}
	$bDoSecond = $false
	foreach ($tListElement in $List) {
		if ($bDoSecond) {
			$tStrTable = $tStrTable + ('<tr>')
		} else {
			$tStrTable = $tStrTable + ('<tr class="second">')
		}	
		
		$bDoSecond = (-not $bDoSecond)
		foreach ($var in $varList) {
			$tStrTable = $tStrTable + (("<td>") + $tListElement.$var)
		}
	}
	$tStrTable = $tStrTable + ("</table>")
	$rStrReport.Value += $tStrTable
	return $tStrTable
}
#####################################################

function logtablecsv ($Caption,$List,[ref]$rStrReport = [ref]($script:strReport)) {
	$tStrTable = "<table><tr>"
	$varList = $List | Get-Member -membertype properties | select -expand Name
	$List | Get-Member -membertype properties | %{
		$tStrTable = $tStrTable + ("<th>" + $_.Name + "</th>")
	}
	$bDoSecond = $false
	foreach ($tListElement in $List) {
		if ($bDoSecond) {
			$tStrTable = $tStrTable + ('<tr>')
		} else {
			$tStrTable = $tStrTable + ('<tr class="second">')
		}	
		
		$bDoSecond = (-not $bDoSecond)
		foreach ($var in $varList) {
			$tStrTable = $tStrTable + (("<td>") + $tListElement.$var)
		}
	}
	$tStrTable = $tStrTable + ("</table>")
	$rStrReport.Value += $tStrTable
	$List | Export-Csv ".\$Caption.csv"
	return $tStrTable
}
#####################################################

function loglist ($tList,[ref]$rStrReport = [ref]$script:strReport) {
	$tStrTable = "<table><tr>"
	$bDoSecond = $false
	foreach ($tListElement in $tList) {
		if ($bDoSecond) {
			$tStrTable = $tStrTable + ('<tr>')
		} else {
			$tStrTable = $tStrTable + ('<tr class="second">')
		}	
		$bDoSecond = (-not $bDoSecond)
		$tStrTable = $tStrTable + (("<td>") + $tListElement)
	}
	$tStrTable = $tStrTable + ("</table>")
	$rStrReport.Value += $tStrTable
	return $tStrTable
}
#####################################################

function global:TranslitToLAT
{
 	param([string]$inString)
	$Translit_To_LAT = @{ 
	[char]'�' = "a"
	[char]'�' = "a"
	[char]'�' = "b"
	[char]'�' = "b"
	[char]'�' = "v"
	[char]'�' = "v"
	[char]'�' = "g"
	[char]'�' = "g"
	[char]'�' = "d"
	[char]'�' = "d"
	[char]'�' = "e"
	[char]'�' = "e"
	[char]'�' = "�"
	[char]'�' = "�"
	[char]'�' = "zh"
	[char]'�' = "zh"
	[char]'�' = "z"
	[char]'�' = "z"
	[char]'�' = "i"
	[char]'�' = "i"
	[char]'�' = "i"
	[char]'�' = "i"
	[char]'�' = "k"
	[char]'�' = "k"
	[char]'�' = "l"
	[char]'�' = "l"
	[char]'�' = "m"
	[char]'�' = "m"
	[char]'�' = "n"
	[char]'�' = "n"
	[char]'�' = "o"
	[char]'�' = "o"
	[char]'�' = "p"
	[char]'�' = "p"
	[char]'�' = "r"
	[char]'�' = "r"
	[char]'�' = "s"
	[char]'�' = "s"
	[char]'�' = "t"
	[char]'�' = "t"
	[char]'�' = "u"
	[char]'�' = "u"
	[char]'�' = "f"
	[char]'�' = "f"
	[char]'�' = "kh"
	[char]'�' = "kh"
	[char]'�' = "ts"
	[char]'�' = "ts"
	[char]'�' = "ch"
	[char]'�' = "ch"
	[char]'�' = "sh"
	[char]'�' = "sh"
	[char]'�' = "shch"
	[char]'�' = "shch"
	[char]'�' = "ie"		# "``"
	[char]'�' = "ie"		# "``"
	[char]'�' = "y"		# "y`"
	[char]'�' = "y"		# "Y`"
	[char]'�' = ""		# "`"
	[char]'�' = ""		# "`"
	[char]'�' = "e"		# "e`"
	[char]'�' = "e"		# "E`"
	[char]'�' = "iu"
	[char]'�' = "iu"
	[char]'�' = "ia"
	[char]'�' = "ia"
	}
	$outChars=""
	foreach ($c in $inChars = $inString.ToCharArray())
		{
		if ($Translit_To_LAT[$c] -cne $Null ) 
			{$outChars += $Translit_To_LAT[$c]}
		else
			{$outChars += $c}
		}
	Write-Output $outChars
 }
##############################################################################################
function generateHtmlHeader() {
	$cssStyle = "<style>body {
	font-family:Calibri;
	 font-size:12pt;
	}
	th { 
	background-color:#007F0E;
	color:white;
	}
	tr {
	 background-color:#DDDDDD;
	color:black;}
	tr.second {
	 background-color:#FFFFFF;
	color:black;
	}
	td {border:1px solid #DDDDDD;}
	p.red {
	color:red;
	}
	p.green{
	color:green;
	}
	p.gray{
	color:gray;
	}
	</style>"
	$sHeaderText = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="content-type" content="text/html; charset=windows-1251">' + $cssStyle  + "</head><body>"
	
	return $sHeaderText
}
#####################################################
function placeRepFile($strRep,$strName) {
	$sPath = $env:temp + "\$strName.html"
	$strRep | Out-File $sPath
	return $sPath 
}
