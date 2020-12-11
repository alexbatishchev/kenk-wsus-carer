. .\settings.ps1
. .\uszfunctions.ps1

wlog ("*******************************************")	
wlog ("Starting: " + $MyInvocation.MyCommand.Definition)	

################################################
# Contstants (default GUIDs)
#'Неназначенные компьютеры' aka 'Unassigned Computers'
$sUnassignedComputersGuid = "b73ca6ed-5727-47f3-84de-015e03f6a88a"
# 'Все компьютеры'  aka 'All Computers'
$sAllComputersGuid = "a0a08746-4dbe-4a37-9adf-9e7652c0b421" 

$strReport = generateHtmlHeader
$StartDate=(GET-DATE)

$bAlarmFlag = $false	

# reading Captions To Ignore
wlog ("reading templates for Captions To Ignore from $sSearchStringsInUpdatesPath")	
$aCaptionsToIgnore = @()
$aCaptionsToIgnore= Get-Content $sSearchStringsInUpdatesPath
$aCaptionsToIgnore = $aCaptionsToIgnore | ForEach-Object{$_.Trim()} | Where-Object { -not $_.StartsWith("#")} | Where-Object {$_ -ne ""} | Where-Object {$_ -ne $null}
$iCount = ($aCaptionsToIgnore | measure).count
wlog ("Got $iCount strings")	

wlog ("reading templates for Names To Move from $sSearchStringsInHostnamesPath")	
$aNamesToMove = @()
$aNamesToMove= Get-Content $sSearchStringsInHostnamesPath
$aNamesToMove = $aNamesToMove | ForEach-Object{$_.Trim()} | Where-Object { -not $_.StartsWith("#")} | Where-Object {$_ -ne ""} | Where-Object {$_ -ne $null}
$iCount = ($aNamesToMove | measure).count
wlog ("Got $iCount strings")	


wlog ("connecting to WSUS")	
$WSUSserver="localhost"
[Int32]$portNumber = 8530
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($WSUSserver,$false,$portNumber)
if ($wsus -eq $null) {
	wlog ("error connecting to WSUS")
	return	
}
wlog ("connected ok")


$aAllWSUSGroups = $wsus.GetComputerTargetGroups()
$aAllWSUSGroups | % {
	$sString = "got group :" + ( $_ |select Name, Id | ConvertTo-Json -compress)
	wlog ($sString)
}


#=====================================================
# part 1: moving unassigned computers
if ($bDoMoveComputers ) {
	wlog ("Part 1: now we try to move unassinged computers")	
	
	$oTargetGroupToMoveGuid = $null 
	$oTargetGroupToMoveGuid = $aAllWSUSGroups | Where Name -eq $sTargetGroupToMoveName 
	if ($oTargetGroupToMoveGuid -eq $null) {
		wlog ("can not find group to move to with Name [$sTargetGroupToMoveName], skipping part")
	} else {
		$sTargetGroupToMoveGuid = $oTargetGroupToMoveGuid.Id.Guid
		wlog ("found group with id [$sTargetGroupToMoveGuid] to move to for Name [$sTargetGroupToMoveName]")

		$bDoSendReport = $false
		$gNotSet 			= $wsus.GetComputerTargetGroup($sUnassignedComputersGuid)
		$oTargetGroupToMove = $wsus.GetComputerTargetGroup($sTargetGroupToMoveGuid)
		$sMovingReport = ""
		
		foreach ($sNameTemplate in $aNamesToMove) {
			wlog ("now we find and move um assined comps with [$sNameTemplate] in hostname")	

			foreach ($oComp in $gNotSet.GetComputerTargets()) {	
				if ($oComp.FullDomainName.Contains($sNameTemplate)) {
					log ("Moved to group [$sTargetGroupToMoveName] host " + $oComp.FullDomainName)([ref]$sMovingReport)
					$oTargetGroupToMove.AddComputerTarget($oComp)
					$bDoSendReport = $true
				}
			}
		}		
		if ($sMovingReport -ne "") {
			logh2 ("Перемещены компьютеры:")([ref]$strReport)
			log ($sMovingReport)([ref]$strReport)
		}
	}
	wlog ("done Part 1")	
}


#=====================================================
# part 2  find and decline not needed updates
if ($bDoDeclineUpdatesBySearchStrings) {
	wlog ("Part 2: now we find and decline not needed updates")	

	$sText = $aCaptionsToIgnore -join ']['
	$sText = "[" + $sText + "]"
	$sText = "Обновления отклоняются по признаку обнаружения в тексте описания любой из строк: " + $sText
	wlog ($sText)

	$sTDecliningReport = ""

	foreach ($sSearchString in $aCaptionsToIgnore) {
		wlog ("searching not declined updates with string [$sSearchString] in caption...")
		
		$updates = $wsus.SearchUpdates($sSearchString) | Where-Object{-not $_.IsDeclined }
		$iCount = $updates.Count
		wlog ("Got $iCount updates")

		If ($updates.Count -gt 0)
		{
			$bDoSendReport = $true
			logH2 ("Найдены и отклонены обновления для $sSearchString") ([ref]$sTDecliningReport)
			$updates | ForEach-Object{
				$_.Decline() 
			}	
			$updates = $updates | Select `
			@{Name="Title";Expression={[string]$_.Title}},`
			@{Name="KB Article";Expression={[string]$_.KnowledgebaseArticles}},`
			@{Name="Classification";Expression={[string]$_.UpdateClassificationTitle}},`
			@{Name="Product Title";Expression={[string]$_.ProductTitles}},`
			@{Name="Product Family";Expression={[string]$_.ProductFamilyTitles}},`
			@{Name="Creation Date";Expression={[string]$_.CreationDate}},`
			@{Name="Arrival Date";Expression={[string]$_.ArrivalDate}},`
			@{Name="Uninstallation Supported";Expression={[string]$_.UninstallationBehavior.IsSupported}}

			$tStrRep = logtable $updates ([ref]$sTDecliningReport)
		}
	}

	if ($sTDecliningReport -ne "") {
		$sText = $aCaptionsToIgnore -join ']['
		$sText = "[" + $sText + "]"
		$sText = "Обновления отклоняются по признаку обнаружения в тексте описания любой из строк: " + $sText
	
		loggray ($sText) ([ref]$sTDecliningReport)
		$strReport = $strReport + $sTDecliningReport
	}
	wlog ("End of Part 3")	
}

#====================================================
# Part 3: now we auto-approving already tested updates
if ($bDoApproveTestedUpdates) {
	wlog ("Part 3: now we auto-approving already tested updates")	


	$oGroupToTestGuid = $null 
	$oGroupToTestGuid = $aAllWSUSGroups | Where Name -eq $sGroupNameToTest 
	if ($oGroupToTestGuid -eq $null) {
		wlog ("can not find group of tested computers with Name $sGroupNameToTest, skipping part")
	} else {
		$sGroupToTestGuid = $oTargetGroupToMoveGuid.Id.Guid
		wlog ("found group of tested computers with id [$sGroupToTestGuid] for Name [$sGroupNameToTest]")

		$sAutoApprovalLog = ""
		$sAutoApprovalCount = 0
		$tPrintUpdate = @()
		
		$gAllComutersGroup = $wsus.GetComputerTargetGroup($sAllComputersGuid)

		$date_to = $StartDate.AddDays(-1 * $iDaysToWaitBeforeApproveToAll)
		$date_from = $StartDate.AddDays(-42)
		wlog ("Searching for nearly received and auto approved updates...")

		$updates = $wsus.GetUpdates('LatestRevisionApproved', $date_from, $date_to, $null, $null)
		$updates = $updates | Where IsApproved -eq $true
		$iCount = $updates.Count
		wlog ("Got $iCount updates")
		
		Foreach ($update in $updates) {
			wlog ("looking for approves for update " + $update.title)
			$approvals = $update.GetUpdateApprovals()
			$iCount = $approvals.Count
			$approvalsForTest = $approvals | Where ComputerTargetGroupId -eq $sGroupToTestGuid
			$iCount2 = $approvalsForTest.Count
			wlog ("Got $iCount approvals total and $iCount2 approves for test group directly")

			$bWasApproval = $false

			$approvalsForTest | %{  
				$sTMessage = "Removing approval for test group"
				wlog ($sTMessage)
				$_.Delete()
				$sAutoApprovalCount =$sAutoApprovalCount +1 
				$tPrintUpdate = $tPrintUpdate + $update
				$bWasApproval = $true
			}
			if ($bWasApproval) {
				$sTMessage = "Approving for all comuters default group"
				$update.Approve('Install', $gAllComutersGroup)
			}
		}
		if ($sAutoApprovalCount -ne 0) {
			$bDoSendReport = $true
			$tPrintUpdate = $tPrintUpdate	| Select `
				@{Name="Title";Expression={[string]$_.Title}},`
				@{Name="KB Article";Expression={[string]$_.KnowledgebaseArticles}},`
				@{Name="Classification";Expression={[string]$_.UpdateClassificationTitle}},`
				@{Name="Product Title";Expression={[string]$_.ProductTitles}},`
				@{Name="Product Family";Expression={[string]$_.ProductFamilyTitles}},`
				@{Name="Creation Date";Expression={[string]$_.CreationDate}},`
				@{Name="Arrival Date";Expression={[string]$_.ArrivalDate}},`
				@{Name="Uninstallation Supported";Expression={[string]$_.UninstallationBehavior.IsSupported}}

			$tStrRep = logtable $tPrintUpdate ([ref]$sAutoApprovalLog)
			$sDate_to = $date_to.ToString("yyyy-MM-dd HH:mm:ss")
			logh2 ("Автоматически одобрены на все группы обновления, которые одобрены для тестовой группы до даты $sDate_to" ) ([ref]$strReport)
			log ("Всего одобрено обновлений:$sAutoApprovalCount")([ref]$strReport)
			$strReport = $strReport + $sAutoApprovalLog
		}
	}
	wlog ("End of part 3")	
}

If (-not $bDoSendReport) {
	wlog ("nothing to send as report")	
} 
else
{
	wlog ("preparing and sening report")	

	$EndDate=(GET-DATE)
	$sTimediff = NEW-TIMESPAN –Start $StartDate –End $EndDate

	
	log ("#####################################################") ([ref]$strReport)
	log ("Время создания отчета: " + $EndDate ) ([ref]$strReport)
	log ("Длительность обработки: " + $sTimediff ) ([ref]$strReport)
	log ("Отчет сформирован скриптом  " + $MyInvocation.MyCommand.Definition + " на " + "$env:computername.$env:userdnsdomain" ) ([ref]$strReport)

	$strReport =  $strReport + "</body></html>"

	
	#Creating a Mail object
	$msg = new-object Net.Mail.MailMessage
	#Creating SMTP server object
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)

	#Email structure 
	$msg.From = $sReporterMail
	$msg.ReplyTo = $sReporterMail

	$sSubj = "Отчет о работе обслужатора WSUS"
	$msg.To.Add($sReportReceiver)

	$msg.subject = $sSubj
	$msg.body =   $strReport
	$msg.IsBodyHTML = $true
	$smtp.Send($msg)
}
wlog ("end of work: " + $MyInvocation.MyCommand.Definition)	
wlog ("*******************************************")	
