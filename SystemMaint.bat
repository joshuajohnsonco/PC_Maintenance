REM Batch file to clean and repair Windows.  Also removes temp files from common temp locations.
REM Joshua Johnson 2/7/23

@echo off
:START
set disk=false
echo
echo [31m-------------------------------------------------------------------------------------[0m
echo [31m 1st procedure checks the disk and scheduled chkdisk on reboot if errors are found.  [0m
echo [31m      2nd procedure checks and repairs the Windows Component Files - 2 phases        [0m
echo [31m         3rd procedure checks and repairs the Windows image - 3 phases               [0m
echo [31m          4th procedure uses System file check to check system files                 [0m
echo [31m                 5th procedure deletes temp file and folders.                        [0m
echo [31m-------------------------------------------------------------------------------------[0m
timeout 5


:CHKDSK
echo [41m--------------------------------------------------------------------------------[0m
echo [41m              Checking the Windows partition - procedure 1 of 5                 [0m
echo [41m--------------------------------------------------------------------------------[0m
chkdsk c: /scan
IF "%ERRORLEVEL%"=="0" set disk=true
IF "%ERRORLEVEL%"=="1" set disk=true
IF %disk% == true ( GOTO CHKClean ) ELSE ( GOTO CHKDirty )


:CHKDirty
echo [41m--------------------------------------------------------------------------------[0m
echo [41m          Found disk issue, boo...  Scheduling checkdisk on reboot.             [0m
echo [41m--------------------------------------------------------------------------------[0m
echo y|chkdsk c: /f /r
echo PRESS ANY KEY TO CONTINUE.
timeout 5
GOTO DISM


:CHKClean
echo [41m--------------------------------------------------------------------------------[0m
echo [41m                         No disk issues found, yeay!                            [0m
echo [41m--------------------------------------------------------------------------------[0m
timeout 5
GOTO DISM


:DISM
echo [41m--------------------------------------------------------------------------------[0m
echo [41m            Windows component files check - procedure 2 of 5                    [0m
echo [41m--------------------------------------------------------------------------------[0m
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
echo [44m-------------------------------------[0m
echo [44mPhase 1 of 2 completed               [0m
echo [44m-------------------------------------[0m
Dism.exe /online /Cleanup-Image /SPSuperseded
echo [44m-------------------------------------[0m
echo [44mPhase 2 of 2 completed               [0m
echo [44m-------------------------------------[0m
echo PRESS ANY KEY TO CONTINUE.
timeout 5
GOTO DISM2


:DISM2
echo [41m--------------------------------------------------------------------------------[0m
echo [41m        Checking the integrity of the Windows image - procedure 3 of 5          [0m
echo [41m--------------------------------------------------------------------------------[0m
DISM /Online /Cleanup-Image /CheckHealth
echo [44m-------------------------------------[0m
echo [44mPhase 1 of 3 completed               [0m
echo [44m-------------------------------------[0m
DISM /Online /Cleanup-Image /ScanHealth
echo [44m-------------------------------------[0m
echo [44mPhase 2 of 3 completed               [0m
echo [44m-------------------------------------[0m
DISM /Online /Cleanup-Image /RestoreHealth
echo [44m-------------------------------------[0m
echo [44mPhase 3 of 3 completed               [0m
echo [44m-------------------------------------[0m
echo PRESS ANY KEY TO CONTINUE.
timeout 5
goto SFC


:SFC
echo [41m--------------------------------------------------------------------------------[0m
echo [41m                Running System file check - procedure 4 of 5                    [0m
echo [41m--------------------------------------------------------------------------------[0m
sfc /scannow
echo [44m--------------------------------------------------------------------------------[0m
echo [44mIf SFC found some errors and could not repair, re-run the script after a reboot.[0m
echo [44m--------------------------------------------------------------------------------[0m
timeout 5
goto CleanDisk


:CleanDisk
echo [41m--------------------------------------------------------------------------------[0m
echo [41m             Deleting temp files and folders - procedure 5 of 5                 [0m
echo [41m--------------------------------------------------------------------------------[0m
del /s /f /q C:\Windows\Prefetch\*.*
del /s /f /q C:\Windows\Temp\*.*
for /d %%F in (c:\users\*) do del "%%F\appdata\local\temp\*" /s /f /q
echo
echo
echo [42m--------------------------------------------------------------------------------[0m
echo [42m                Checks and repairs are complete, Cheers!                        [0m
echo [42m--------------------------------------------------------------------------------[0m
goto END
:END
