# --
# OTRS.nsi - a script to generate the OTRS Windows installer
# Copyright (C) 2001-2013 OTRS AG, http://otrs.org/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

# ------------------------------------------------------------ #
# define general information
# ------------------------------------------------------------ #

!define Installer_Home            "D:\otrs4winNG"
!define Installer_Home_Nsis       "${Installer_Home}\otrs4win"
!define Installer_Version_Major   3
!define Installer_Version_Minor   0
!define Installer_Version_Patch   0
!define Installer_Version_Jointer "-"
!define Installer_Version_Postfix "beta2"
#!define Installer_Version_Jointer ""
#!define Installer_Version_Postfix ""

!define OTRS_Name            "OTRS"
!define OTRS_Version_Major   3
!define OTRS_Version_Minor   2
!define OTRS_Version_Patch   2
#!define OTRS_Version_Jointer "."
#!define OTRS_Version_Postfix "rc1"
!define OTRS_Version_Jointer ""
!define OTRS_Version_Postfix ""
!define OTRS_Company         "OTRS Group"
!define OTRS_Url             "www.otrs.com"
!define OTRS_Instance_Number 1

!define OTRS_Version         "${OTRS_Version_Major}.${OTRS_Version_Minor}.${OTRS_Version_Patch}"
!define OTRS_Instance        "Instance-${OTRS_Instance_Number}"
!define OTRS_RegKey          "SOFTWARE\${OTRS_Name}"
!define OTRS_RegKey_Instance "${OTRS_RegKey}\${OTRS_Instance}"

!define Installer_Version "${Installer_Version_Major}.${Installer_Version_Minor}.${Installer_Version_Patch}"
!define Win_RegKey_Uninstall "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${OTRS_Name}"

var ActiveStatePerl
var PerlEx
var PerlMajor
var PerlMinor
var PerlExe
var MySQLInstalled
var MyDirectory
var Installed_OTRS_Major
var Installed_OTRS_Minor
var Installed_OTRS_Patch
var Installed_OTRS_Postfix
var Installed_OTRS_Version
var InstallDirShort
var InstallMode
var Upgrade

# ------------------------------------------------------------ #
# define installer information
# ------------------------------------------------------------ #

RequestExecutionLevel admin
CRCCheck              on
XPStyle               on
#SetCompress           off
SetCompress           Auto
SetCompressor         /SOLID lzma
SetCompressorDictSize 4
SetDatablockOptimize  On

Name         "${OTRS_Name} ${OTRS_Version} ${OTRS_Version_Postfix}"
OutFile      "${Installer_Home}\otrs-${OTRS_Version}${OTRS_Version_Jointer}${OTRS_Version_Postfix}-win-installer-${Installer_Version}${Installer_Version_Jointer}${Installer_Version_Postfix}.exe"
BrandingText "otrs4win installer - version ${Installer_Version} ${Installer_Version_Postfix}"

InstallDir $PROGRAMFILES32\${OTRS_Name}
InstallDirRegKey HKLM "${OTRS_RegKey_Instance}" Path

# ------------------------------------------------------------ #
# define multi user information
# ------------------------------------------------------------ #

!define MULTIUSER_EXECUTIONLEVEL Admin
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${OTRS_RegKey_Instance}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME MultiUserInstallMode
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_INSTDIR "${OTRS_Name}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "${OTRS_RegKey_Instance}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUE "Path"

# ------------------------------------------------------------ #
# define mui information
# ------------------------------------------------------------ #

# global settings
!define MUI_ABORTWARNING

# gui icons
!define MUI_ICON   "${Installer_Home_Nsis}\Graphics\Icons\OTRS.ico"
!define MUI_UNICON "${Installer_Home_Nsis}\Graphics\Icons\OTRS.ico"

# gui header images
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP   "${Installer_Home_Nsis}\Graphics\Header\OTRS.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "${Installer_Home_Nsis}\Graphics\Header\OTRS.bmp"

# ------------------------------------------------------------ #
# load required modules
# ------------------------------------------------------------ #

!include EnvVarUpdate.nsh
!include FileFunc.nsh
!include LogicLib.nsh
!include MUI2.nsh
!include MultiUser.nsh
!include Ports.nsh
!include Sections.nsh
!include WordFunc.nsh
!include x64.nsh

!insertmacro "DirState"

# ------------------------------------------------------------ #
# installer pages
# ------------------------------------------------------------ #

# welcome page
!define MUI_WELCOMEFINISHPAGE_BITMAP "${Installer_Home_Nsis}\Graphics\Wizard\OTRS.bmp"
!insertmacro MUI_PAGE_WELCOME

# license page (AGPL)
!define MUI_LICENSEPAGE_RADIOBUTTONS
!insertmacro MUI_PAGE_LICENSE "${Installer_Home_Nsis}\Licenses\GNU_Affero_License.rtf"

# directory page
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE InstInstallationDirValidate
!define MUI_PAGE_CUSTOMFUNCTION_PRE DirectoryHide
!insertmacro MUI_PAGE_DIRECTORY

# start menu page
Var StartMenuGroup
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY       "${OTRS_RegKey_Instance}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER      "${OTRS_Name}"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup

# install page
ShowInstDetails Hide
!insertmacro MUI_PAGE_INSTFILES

# finish page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION  InstStartWeb
!define MUI_FINISHPAGE_RUN_TEXT      $(mui_finishpage_run_text)
!define MUI_FINISHPAGE_LINK          "powered by ${OTRS_Company}"
!define MUI_FINISHPAGE_LINK_LOCATION "http://${OTRS_Url}"
!insertmacro MUI_PAGE_FINISH

# ------------------------------------------------------------ #
# uninstaller pages
# ------------------------------------------------------------ #

# welcome page
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${Installer_Home_Nsis}\Graphics\Wizard\OTRS.bmp"
!insertmacro MUI_UNPAGE_WELCOME

# confirm page
!insertmacro MUI_UNPAGE_CONFIRM

# uninstall page
ShowUninstDetails NeverShow
!insertmacro MUI_UNPAGE_INSTFILES

# finish page
!define MUI_UNFINISHPAGE_LINK          "powered by ${OTRS_Company}"
!define MUI_UNFINISHPAGE_LINK_LOCATION "http://${OTRS_Url}"
!insertmacro MUI_UNPAGE_FINISH

# ------------------------------------------------------------ #
# load languages
# ------------------------------------------------------------ #

# english strings
!insertmacro MUI_LANGUAGE English
LangString mui_finishpage_run_text ${LANG_ENGLISH} "Continue with Web Installer"

# ------------------------------------------------------------ #
# install sections
# ------------------------------------------------------------ #

# install pre section
Section -InstPre

    # install the icon files
    SetOutPath $INSTDIR\otrs4win
    File /r "${Installer_Home_Nsis}\Graphics\Icons\OTRS.ico"
    File /r "${Installer_Home_Nsis}\Graphics\Icons\OTRSServices.ico"

    # install the helper scripts
    File /r "${Installer_Home_Nsis}\Scripts"

    # delete the CVS directory
    sleep 1000  # sleep one second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $INSTDIR\otrs4win\Scripts\CVS

    ${If} $Upgrade != 'no'
        DetailPrint "Stopping services"
        nsExec::Exec "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Scheduler4win.pl$\" -a stop"
        nsExec::Exec "NET STOP $\"Cron Service (CRONw)$\""
        nsExec::Exec "NET STOP Apache2.2"
        nsExec::Exec "NET STOP MySQL"
    ${EndIf}

SectionEnd

Section -InstPerl
    ${If} ${FileExists} "$ActiveStatePerl"
        # For ActiveState perl, we prefer to install any modules
        # via PPM. We'll also install MinGW so we can install 
        # whatever else via cpan.
        ExpandEnvStrings $0 %COMSPEC%
        DetailPrint "Configuring ActiveState Perl. Warning: this can take a very long time..."
        NSExec::ExecToLog '"$0" /C "ppm install DBD::mysql"'
        NSExec::ExecToLog '"$0" /C "ppm install DBD::Pg"'
        NSExec::ExecToLog '"$0" /C "ppm install Crypt::SSLeay"'
        NSExec::ExecToLog '"$0" /C "ppm install Date::Format"'
        NSExec::ExecToLog '"$0" /C "ppm install Date::Manip"'
        NSExec::ExecToLog '"$0" /C "ppm install JSON::XS"'
        NSExec::ExecToLog '"$0" /C "ppm install Log::Dispatch"'
        NSExec::ExecToLog '"$0" /C "ppm install Log::Dispatch::FileRotate"'
        NSExec::ExecToLog '"$0" /C "ppm install Log::Log4perl"'
        NSExec::ExecToLog '"$0" /C "ppm install Mail::IMAPClient"'
        NSExec::ExecToLog '"$0" /C "ppm install Net::DNS"'
        NSExec::ExecToLog '"$0" /C "ppm install Net::LDAP"'
        NSExec::ExecToLog '"$0" /C "ppm install PDF::API2"'
        NSExec::ExecToLog '"$0" /C "ppm install Win32::Console::ANSI"'        
        NSExec::ExecToLog '"$0" /C "ppm install Win32::Daemon"'        
        NSExec::ExecToLog '"$0" /C "ppm install MinGW"'
        NSExec::ExecToLog '"$0" /C "cpan Encode::HanExtra"'
        
        # set perlexe
        StrCpy $PerlExe $ActiveStatePerl
        DetailPrint "ActivePerl configured."
    ${Else}    
        # StrawberryPerl is pre-configured with all modules we need
        # we only need to copy the files
        DetailPrint "Installing Strawberry Perl"
        SetOutPath $INSTDIR
        File /r "${Installer_Home}\StrawberryPerl"
        
        # set perlexe
        StrCpy $PerlExe "$INSTDIR\StrawberryPerl\perl\bin\perl.exe"
        DetailPrint "StrawberryPerl installed."        
    ${EndIf}

SectionEnd

# install CRONw section
Section -InstCRONw

    # install CRONw files
    SetOutPath $INSTDIR
    File /r "${Installer_Home}\CRONw"

    # configure CRONw
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Cron4Win32.pl$\" $\"$InstallDirShort\CRONw\crontab.txt$\""

    # register CRONw as service
    NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\CRONw\cronHelper.pl$\" --install"

    # remove the helper script
    ${If} $InstallMode != "Unittest"
        sleep 1000  # sleep one second to give the OS time to unlock the file
        Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureCRONw.pl"
    ${EndIf}

SectionEnd

# install MySQL section
Section /o -InstMySQL InstMySQL

    ${If} $MySQLInstalled <> 1

        # install MySQL files
        SetOutPath $INSTDIR
        File /r "${Installer_Home}\MySQL"

        # configure the mysql server
        GetFullPathName /SHORT $InstallDirShort $INSTDIR
        NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureMySQL.pl$\" -d $\"$InstallDirShort$\""

        # register mysql as service
        NSExec::ExecToLog '"$INSTDIR\MySQL\bin\mysqld.exe" --install MySQL --defaults-file="$INSTDIR\MySQL\my.ini"'

        # remove the helper script
        sleep 1000  # sleep one second to give the OS time to unlock the file
        Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureMySQL.pl"

    ${EndIf}

SectionEnd

# install Apache section
Section /o -InstApache InstApache

   ${If} ${FileExists} "$INSTDIR\StrawberryPerl\perl\bin\perl.exe"

        DetailPrint "Installing/upgrading Apache" 
        nsExec::Exec "NET STOP Apache2.2"    
        # install Apache files
        SetOutPath $INSTDIR
        File /r "${Installer_Home}\Apache"

       # configure apache
       GetFullPathName /SHORT $InstallDirShort $INSTDIR
       NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureApache.pl$\" -d $\"$InstallDirShort$\""

       # register apache as service
       NSExec::ExecToLog '"$INSTDIR\Apache\bin\httpd.exe" -k install'

       # add the apache service to the firewall exeption list
       SimpleFC::AddApplication "Apache HTTP Server" "$INSTDIR\Apache\bin\httpd.exe" 0 2 "" 1
       Pop $0

       # remove the helper script
       ${If} $InstallMode != "Unittest"
           sleep 1000  # sleep one second to give the OS time to unlock the file
           Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureApache.pl"
       ${EndIf}
   ${Else}
       DetailPrint "Configuring Microsoft IIS"
       
       # locate PerlEx dll based on perl.exe
       ${WordReplace} $ActiveStatePerl 'perl.exe' 'PerlEx30.dll' "-1" $PerlEx
       ExpandEnvStrings $0 %COMSPEC%
       
       # first make sure Microsoft IIS is installed
       ${DisableX64FSRedirection}
       NSExec::ExecToLog '"$0" /c $WINDIR\system32\dism.exe /online /norestart /enable-feature /ignorecheck /featurename:$\"IIS-WebServerRole$\" /featurename:$\"IIS-ManagementConsole$\" /featurename:$\"IIS-ISAPIExtensions$\" /featurename:$\"IIS-ISAPIFilter$\"' 
       ${EnableX64FSRedirection}

       # now configure a web site, and setup perlex with its own application pool    
       NSExec::ExecToLog '"$0\system32\inetsrv\appcmd.exe" add apppool /name:$\"OTRS$\"'
       NSExec::ExecToLog '"$0\system32\inetsrv\appcmd.exe" set config /section:applicationPools -[name=$\'OTRS$\'].managedPipelineMode:Integrated'
       NSExec::ExecToLog '"$0\system32\inetsrv\appcmd.exe" set config /section:applicationPools -[name=$\'OTRS$\'].enable32BitAppOnWin64:$\"True$\" /commit:apphost'
       NSExec::ExecToLog '"$0\system32\inetsrv\appcmd.exe" set config /section:handlers /+[name=$\'PerlEx$\',path=$\'*.pl$\',verb=$\'*$\',modules=$\'IsapiModule$\',scriptProcessor=$\'c:\Perl\bin\PerlEx30.dll$\']'
       NSExec::ExecToLog '"$0\system32\inetsrv\appcmd.exe" set config /section:system.webServer/security/isapiCgiRestriction /+[path=$\'$PerlEx$\',allowed=$\'True$\'] /commit:apphost'
       NSExec::ExecToLog '"$0\system32\inetsrv\appcmd.exe" add vdir /app.name:$\"Default Web Site/$\" /path:/otrs-web /physicalPath:$INSTDIR\OTRS\var\httpd\htdocs'
       NSExec::ExecToLog '"$0\system32\inetsrv\appcmd.exe" add app /site.name:$\"Default Web Site$\" /path:/otrs /physicalPath:$INSTDIR\OTRS\bin\cgi-bin -applicationPool:OTRS'
       
   ${EndIf}

SectionEnd

# install OTRS section
Section -InstOTRS

    # install OTRS files
    SetOutPath $INSTDIR
    IfFileExists $INSTDIR\OTRS\ARCHIVE 0 +2
       CopyFiles $INSTDIR\OTRS\ARCHIVE $INSTDIR\OTRS\ARCHIVE_OLD
        
    File /r "${Installer_Home}\OTRS"

    ${If} $Upgrade == "no"

    # configure OTRS
        GetFullPathName /SHORT $InstallDirShort $INSTDIR
        NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureOTRS.pl$\" -d $\"$InstallDirShort$\""

        # register Scheduler service (just for 3.1 and later)
        IfFileExists $INSTDIR\OTRS\bin\otrs.Scheduler4winInstaller.pl 0 +2
            NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Scheduler4winInstaller.pl$\" -a install"
    ${EndIf}
        
    # add common otrs information
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Major   "${OTRS_Version_Major}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Minor   "${OTRS_Version_Minor}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Patch   "${OTRS_Version_Patch}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Postfix "${OTRS_Version_Postfix}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Instance_Number "${OTRS_Instance_Number}"

    # create start menu entries
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Agent Interface.lnk"     "http://localhost/otrs/index.pl"     "" "$INSTDIR\otrs4win\OTRS.ico"
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Customer Interface.lnk"  "http://localhost/otrs/customer.pl"  "" "$INSTDIR\otrs4win\OTRS.ico"
    SetOutPath $SMPROGRAMS\$StartMenuGroup\Tools
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Web Installer.lnk" "http://localhost/otrs/installer.pl" "" "$INSTDIR\otrs4win\OTRS.ico"
    !insertmacro MUI_STARTMENU_WRITE_END

    # create desktop shortcut
    createShortCut "$DESKTOP\${OTRS_Name} Agent Interface.lnk" "http://localhost/otrs/index.pl" "" "$INSTDIR\otrs4win\OTRS.ico"

    # remove the helper script
    ${If} $InstallMode != "Unittest"
        sleep 1000  # sleep one second to give the OS time to unlock the file
        Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureOTRS.pl"
    ${EndIf}

SectionEnd

# install post section
Section -InstPost

    ${If} ${FileExists} "$INSTDIR\StrawberryPerl\perl\bin\perl.exe"
        GetFullPathName /SHORT $InstallDirShort $INSTDIR
        # add paths
        ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$InstallDirShort\StrawberryPerl\site\bin"
        ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$InstallDirShort\StrawberryPerl\perl\bin"
        ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$InstallDirShort\StrawberryPerl\c\bin"
    ${EndIf}

    # add common instance information
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Path                      $INSTDIR
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version_Major   "${Installer_Version_Major}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version_Minor   "${Installer_Version_Minor}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version_Patch   "${Installer_Version_Patch}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version         "${Installer_Version}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version_Postfix "${Installer_Version_Postfix}"

    # add uninstaller
    WriteUninstaller $INSTDIR\uninstall.exe
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   DisplayName     "${OTRS_Name}"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   DisplayIcon     $INSTDIR\otrs4win\OTRS.ico
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   Publisher       "${OTRS_Company}"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   HelpTelephone   " +1 (415) 3660178"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   HelpLink        "http://doc.otrs.org/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   URLInfoAbout    "http://${OTRS_Url}/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   URLUpdateInfo   "http://www.otrs.org/download/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   Comments        "OTRS Help Desk"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "${Win_RegKey_Uninstall}" NoModify        1
    WriteRegDWORD HKLM "${Win_RegKey_Uninstall}" NoRepair        1

    # start the otrs services
    sleep 2000
    DetailPrint "Starting services"
    nsExec::Exec "NET START MySQL"
    nsExec::Exec "NET START $\"Cron Service (CRONw)$\""
    nsExec::Exec "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Scheduler4win.pl$\" -a start"
    nsExec::Exec "NET START Apache2.2"
    
    # refresh the windows desktop (required for Vista's desktop)
    System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'

SectionEnd

# ------------------------------------------------------------ #
# uninstall sections
# ------------------------------------------------------------ #

# uninstall pre section
Section -un.UninstPre

    # stop the otrs services
    DetailPrint "Stopping services"
    nsExec::Exec "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Scheduler4win.pl$\" -a stop"
    nsExec::Exec "NET STOP $\"Cron Service (CRONw)$\""
    nsExec::Exec "NET STOP Apache2.2"
    nsExec::Exec "NET STOP MySQL"

    sleep 2000

SectionEnd

# uninstall OTRS section
Section -un.UninstOTRS

    # remove start menu entries
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Agent Interface.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Customer Interface.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Web Installer.lnk"

    # remove desktop shortcut
    Delete /REBOOTOK "$DESKTOP\${OTRS_Name} Agent Interface.lnk"

    DeleteRegValue HKLM "${OTRS_RegKey_Instance}" StartMenuGroup
    DeleteRegKey HKLM "${OTRS_RegKey_Instance}"
    
    # remove items from Path
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$InstallDirShort\StrawberryPerl\site\bin"
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$InstallDirShort\StrawberryPerl\perl\bin"
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$InstallDirShort\StrawberryPerl\c\bin"

    # deregister Scheduler service (just for 3.1 and later)
    IfFileExists $INSTDIR\OTRS\bin\otrs.Scheduler4winInstaller.pl 0 +2
        NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Scheduler4winInstaller.pl$\" -a remove"
    
    # delete the OTRS files
    RmDir /r /REBOOTOK $INSTDIR\OTRS

SectionEnd

# uninstall CRONw section
Section -un.UninstCRONw

    # register CRONw as service
    NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\CRONw\cronHelper.pl$\" --remove"

    # delete the CRONw files
    RmDir /r /REBOOTOK $INSTDIR\CRONw

SectionEnd

# uninstall Apache section
Section /o -un.UninstApache UninstApache

    # deregister apache as service
    NSExec::ExecToLog '"$INSTDIR\Apache\bin\httpd.exe" -k uninstall'

    # remove the apache service from the firewall exeption list
    SimpleFC::RemoveApplication "$INSTDIR\Apache\bin\httpd.exe"
    Pop $0

    # delete the Apache files
    RmDir /r /REBOOTOK $INSTDIR\Apache

SectionEnd

# uninstall MySQL section
Section /o -un.UninstMySQL UninstMySQL

    # deregister mysql as service
    NSExec::ExecToLog '"$INSTDIR\MySQL\bin\mysqld"  --remove MySQL'

    # delete the MySQL files
    RmDir /r /REBOOTOK $INSTDIR\MySQL

SectionEnd

# uninstall StrawberryPerl section
Section -un.UninstStrawberryPerl

    # delete the StrawberryPerl files
    RmDir /r /REBOOTOK $INSTDIR\StrawberryPerl

SectionEnd

# uninstall post section
Section -un.UninstPost

    # remove start menu
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\Uninstall ${OTRS_Name}.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Start.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Stop.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Restart.lnk"
    sleep 1000  # sleep one second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $SMPROGRAMS\$StartMenuGroup\Tools
    sleep 2000  # sleep two second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $SMPROGRAMS\$StartMenuGroup

    # remove uninstaller
    DeleteRegKey HKLM "${Win_RegKey_Uninstall}"
    Delete /REBOOTOK $INSTDIR\uninstall.exe

    # remove common instance information
    DeleteRegValue HKLM "${OTRS_RegKey_Instance}" Path
    DeleteRegKey   HKLM "${OTRS_RegKey_Instance}"
    DeleteRegKey   HKLM "${OTRS_RegKey}"

    # delete install directory
    sleep 1000  # sleep one second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $INSTDIR

    # refresh the windows desktop (required for Vista's desktop)
    System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'

SectionEnd

# ------------------------------------------------------------ #
# install functions
# ------------------------------------------------------------ #

# installer init function
Function .onInit

    InitPluginsDir

    Call InstCheckAlreadyRunning
    Call InstCheckAlreadyInstalled
    Call InstCheckActiveStatePerl
    Call InstCheckMySQLAlreadyInstalled
    Call InstCheckWebServerAlreadyInstalled

    # insert plugins
    !insertmacro MULTIUSER_INIT

    # activate optional installer sections
    !insertmacro SelectSection ${InstMySQL}
    !insertmacro SelectSection ${InstApache}

    # investigate the install mode
    ClearErrors
    ${GetOptions} $CMDLINE "/U" $R0
    IfErrors 0 +3
        StrCpy $InstallMode "Normal"
        goto +2
        StrCpy $InstallMode "Unittest"

FunctionEnd

# to check if the installer is already running
Function InstCheckAlreadyRunning

    # prevent multiple instances of the installer
    System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
    Pop $R0
    StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONSTOP "The ${OTRS_Name} installer is already running."
    Abort

FunctionEnd

# to check if OTRS is already installed
Function InstCheckAlreadyInstalled

    ReadRegStr $R0 HKLM "${Win_RegKey_Uninstall}" "UninstallString"

    # if OTRS is already installed, make sure this is a newer version
    ${If} ${FileExists} $R0

        # read version from history
        ReadRegStr $Installed_OTRS_Major   HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Major   
        ReadRegStr $Installed_OTRS_Minor   HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Minor   
        ReadRegStr $Installed_OTRS_Patch   HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Patch   
        ReadRegStr $Installed_OTRS_Postfix HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Postfix

        # combine to one string
        StrCpy $Installed_OTRS_Version "$Installed_OTRS_Major.$Installed_OTRS_Minor.$Installed_OTRS_Patch.$Installed_OTRS_Postfix"

        # convert to numbers so 'beta' and 'rc' will be no problem    
        ${VersionConvert} $Installed_OTRS_Version "" $R0
        ${VersionConvert} ${OTRS_Version} "" $R1    

        # comparison: 0 = equal, 1 = installed is newer, 2 = we are newer
        ${VersionCompare} $R0 $R1 $R0

        ${If} $R0 = 0
                MessageBox MB_OK|MB_ICONSTOP "You have already installed OTRS $Installed_OTRS_Version."
                Abort
        ${EndIf}        

        ${If} $R0 = 1
                MessageBox MB_OK|MB_ICONSTOP "You have installed $Installed_OTRS_Version, which is newer than ${OTRS_Version}."
                Abort
        ${EndIf}        

        ${If} $R0 = 1
            # we can only do patch level upgrades or upgrades that differ one minor
            ${If} $Installed_OTRS_Major < ${OTRS_Version_Major}
                MessageBox MB_OK|MB_ICONSTOP "You have installed $Installed_OTRS_Version. Please don't skip minor levels when upgrading."
                Abort
            ${Else}
                # same major level
                ${If} $Installed_OTRS_Minor == 0
                   MessageBox MB_OK|MB_ICONSTOP "You have installed $Installed_OTRS_Version. Please don't skip minor levels when upgrading."
                   Abort
                ${EndIf}
                ${If} $Installed_OTRS_Minor == 1
                    StrCpy $Upgrade "minor" 
                ${EndIf}
                ${If} $Installed_OTRS_Minor == ${OTRS_Version_Minor}
                    StrCpy $Upgrade "patch" 
                ${EndIf}                
            ${EndIf}        
        ${EndIf}        
    ${Else}
        StrCpy $Upgrade "no"
    ${EndIf}

FunctionEnd

Function InstCheckActiveStatePerl

    # check if 64-bit Perl is installed, we need 32-bit because of PerlEx
    # we need to use SetRegView64 on 64-bit OS otherwise we can not find
    # the correct regkey because the installer is a 32-bit 
    # application itself
    ${If} ${FileExists} $WINDIR\SYSWOW64\*.*
        SetRegView 64
        ReadRegStr $ActiveStatePerl HKLM Software\Perl BinDir
        SetRegView 32
        ${If} ${FileExists} "$ActiveStatePerl"
                MessageBox MB_OK|MB_ICONSTOP "You have installed ActiveState Perl 64-bit. Please uninstall the 64-bit version and install the x86 version before continuing setup."
                ExecShell "open" "http://www.activestate.com/activeperl/downloads"            
                Abort
        ${EndIf}
    ${EndIf}
    
    # check if ActiveState is installed 
    ReadRegStr $ActiveStatePerl HKLM Software\Perl BinDir
        
    # if we have ActiveState, test its properties
    ${If} ${FileExists} "$ActiveStatePerl"
        
        # check if ActiveState Perl is correct version
        # we need 5.16 because of apache mod_perl libs
        nsExec::ExecToStack '"$ActiveStatePerl" -MConfig -e $\"print $Config{api_revision}$\"'
        Pop $0
        Pop $PerlMajor

        nsExec::ExecToStack '"$ActiveStatePerl" -MConfig -e $\"print $Config{api_version}$\"'
        Pop $0
        Pop $PerlMinor
        
        ${If} $PerlMajor = 5
            ${If} $PerlMinor <> 16
                MessageBox MB_OK|MB_ICONSTOP "Please install ActivePerl 5.16 for x86. I found version $perlmajor.$perlminor."
                ExecShell "open" "http://www.activestate.com/activeperl/downloads"            
                Abort
            ${EndIf}
        ${Else}
            # different major version than 5? Really?
            MessageBox MB_OK|MB_ICONSTOP "Please install ActivePerl 5.16 for x86. I found version $perlmajor.$perlminor."
            ExecShell "open" "http://www.activestate.com/activeperl/downloads"            
            Abort
        ${EndIf}        


    ${Else}
           DetailPrint "No ActiveState perl found"
    ${EndIf}

FunctionEnd

# to check if MySQL is already installed
Function InstCheckMySQLAlreadyInstalled

    ${If} ${TCPPortOpen} 3306
        StrCpy $MySQLInstalled 1
    ${EndIf}

FunctionEnd

# to check if port 80 is available - non-fatal
Function InstCheckWebServerAlreadyInstalled

    ${If} ${TCPPortOpen} 80
#    MessageBox MB_OK "Port 80 is already in use. You probably already have a web server installed. OTRS brings it's own Apache instance and can only run on ports 80 or 443 (HTTPS). Make sure you configure your server so this causes no issues."
    ${EndIf}

FunctionEnd

Function DirectoryHide

    ${If} $Upgrade != "no"
         # set install dir from registry
         ReadRegStr $INSTDIR HKLM "${OTRS_RegKey_Instance}" "Path"
         Abort
    ${EndIf}
 
FunctionEnd 

# to check if install directory is empty
Function InstInstallationDirValidate

    ${If} $Upgrade == "no"
        #make sure $INSTDIR path is either empty or does not exist.
        Push $0
        ${DirState} "$INSTDIR" $0

        ${If} $0 == 1   #folder is full.  (other values: 0: empty, -1: not found)
            MessageBox MB_OK|MB_ICONEXCLAMATION "Directory not empty! Please select another directory."
            Abort
        ${EndIf}

        Pop $0
    ${EndIf}

FunctionEnd


Function InstStartWeb
# after completion launch the web installer for a new install
# or the agent interface for upgrade (possibly even package manager?)    

    ${If} $Upgrade == "no"

        # write a .json file to indicate we already had the License page
        FileOpen $9 var\tmp\installer.json w ;Opens a Empty File an fills it
        FileWrite $9 "{\"SkipLicense\":1}$\n"
        FileClose $9 ;Closes the filled file
        
        # now open web installer
        ExecShell "open" "http://localhost/otrs/installer.pl"
    ${Else}
        ExecShell "open" "http://localhost/otrs/index.pl"
    ${EndIf}

FunctionEnd

Function CancelAndLaunchSite

    # Cancel was pressed, the user wants to go to ActiveState to download ActivePerl
    # this opens http://www.activestate.com/activeperl/downloads but I can change the URL if needed
    ExecShell "open" "http://j.mp/12g32nt"

FunctionEnd

# ------------------------------------------------------------ #
# uninstall functions
# ------------------------------------------------------------ #

# uninstaller init function
Function un.onInit

    InitPluginsDir

    Call un.UninstCheckAlreadyRunning

    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro MULTIUSER_UNINIT

    ReadRegStr $INSTDIR HKLM "${OTRS_RegKey_Instance}" Path

    # activate optional uninstaller sections
    !insertmacro SelectSection ${UninstApache}
    !insertmacro SelectSection ${UninstMySQL}

FunctionEnd

# to check if the uninstaller is already running
Function un.UninstCheckAlreadyRunning

    # prevent multiple instances of the uninstaller
    System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
    Pop $R0
    StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONSTOP "The ${OTRS_Name} uninstaller is already running."
    Abort

FunctionEnd
