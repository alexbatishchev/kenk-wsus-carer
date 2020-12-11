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
$sTargetGroupToMoveName = '������� ������� �������'
$sSearchStringsInHostnamesPath = ".\comp-names-to-move.txt"

$bDoDeclineUpdatesBySearchStrings = $true
$sSearchStringsInUpdatesPath = ".\update-captions-to-decline.txt"

$bDoApproveTestedUpdates  = $true
$sGroupNameToTest = '���������� ��� �������� ����������'
$iDaysToWaitBeforeApproveToAll = 7


$sReporterMail =  "wsusserver@domain.com"
$sReportReceiver = "admin@domain.com"
$smtpServer =  "smtp.domain.com"