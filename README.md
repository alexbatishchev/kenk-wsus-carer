# Kenk WSUS carer 
 
* moves unassinged computers to desired wsus group by hostname template
* declines previously auto-approved updates with words in caption to ignore not needed updates like "itanium","ARM64"
* founds updates approved to test group more than set days ago and approves it to all computers group
* sends reports (if there was something to tell to admin) and writes logs

You can switch off any of feature via settings.ps1 file

For using all features you should
* set templates for moving computers' names and target group
* set templates for declining updates names
* set name for testing group and enable auto-approving updates for this group in your WSUS's settings