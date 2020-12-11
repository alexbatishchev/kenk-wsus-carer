#####################################################
# settings.ps1
# edit this variables to customize main script
#####################################################

##################################################################
# PATHS and adresses
##################################################################

# Log path related settings
$sLogFileNameTemplate = "yyyy-MM-dd" #"yyyy-MM-dd-HH-mm-ss"
$sLogFilePathTemplate = "yyyy-MM"


##################################################################
# script options
##################################################################

$bDoMoveComputers = $true
$sTargetGroupToMoveName = 'Рабочие станции Обычные'
$sSearchStringsInHostnamesPath = ".\comp-names-to-move.txt"

$bDoDeclineUpdatesBySearchStrings = $true
$sSearchStringsInUpdatesPath = ".\update-captions-to-decline.txt"

$bDoApproveTestedUpdates  = $true
$sGroupNameToTest = 'Компьютеры для проверки обновлений'
$iDaysToWaitBeforeApproveToAll = 7


$sReporterMail =  "wsusserver@domain.com"
$sReportReceiver = "admin@domain.com"
$smtpServer =  "smtp.domain.com"