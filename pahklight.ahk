/*
Name          : pAHKlight - v0.1
Purpose       : Your Lightweight Guid to AutoHotkey libraries, classes, functions and tools
Source        : https://github.com/hi5/pAHKlight
AHKScript     : http://www.ahkscript.org/boards/viewtopic.php?f=6&t=1241
License       : MIT - see COPYING.txt
*/

#NoEnv
#SingleInstance, force
SetBatchLines, -1

; ini
Version:="v0.1"
AppWindow:="pAHKlight " Version " [ AutoHotkey libraries, classes, functions and tools ]"
dbf:="pahklightDB.ini"
use:="personal.ini"
Keys:="name,fullname,author,type,source,forum,category,description"
o:=[]
errorlog:=""

; files we want to download in case of an update
pAHKlightfiles=
(join`n
pahklight.ahk
pahklightDB.ini
)

; read categories and prepare for DropDownList
FileRead, categories, categories.txt
categories:=RegExReplace(categories,"m)\r?\n","|")

; read database
IniRead, Sections, %dbf%
IniRead, installed, %use%, settings, installed
StringReplace, Sections, Sections, `n, `n, UseErrorLevel
if (ErrorLevel > 200)
	TrayTip, Loading, pAHKlight database ..., 3, 1

Loop, parse, Sections, `n, `r
	{
	 Idx:=A_Index
	 IniRead, Section, %dbf%, %A_LoopField%
	 o[Idx,"searchthis"]:=A_LoopField " " section
	 Loop, parse, Keys, CSV
		{
		 RegExMatch(section "`n","isU)" A_LoopField "=(.*)\r?\n",keym)
		 if ((A_LoopField = "author") and (InStr(keym1," @ ")))
		 	{
			 StringSplit, _auinfo, keym1, @
			 o[Idx,"author"]:=Trim(_auinfo1)
			 o[Idx,"authorlink"]:=Trim(_auinfo2)
			 Continue
		 	}
		 o[Idx,A_LoopField]:=Trim(keym1)
		}
 	 if InStr("," installed ",", "," o[Idx].name ",")
 		 o[Idx,"check"]:="check"
	 Section:="",keym:="",keym1:="",_auinfo1:="",_auinfo2:=""
	 ; basic error checking
	 if !InStr("|lib|class|function|tool|", "|" o[Idx].type "|")
 		errorlog .= "[" Idx "] " o[Idx].name ": type error`n" 
 	 checkcategories:=o[Idx].category
	 Loop, parse, checkcategories, CSV 
	 	if !InStr( "|" categories "|", "|" A_LoopField "|")
	 		{
	 		 errorlog .= "[" Idx "] " o[Idx].name ": category error`n" 
	 		 break
	 		} 
	 if !InStr(o[Idx].source, "http") or !InStr(o[Idx].forum, "http")
	 	errorlog .= "[" Idx "] " o[Idx].name ": source or forum error`n" 
	}

if (errorlog <> "")
	{
	 FileDelete, errorlog.txt
	 FileAppend, %errorlog%, errorlog.txt
	 errorlog:=" - please consult errorlog.txt!"
	}

; build gui

Gui, Add, Text, x10 y10 w40 h20, Search:
Gui, Add, Edit, xp+50 yp-5 w200 h20 gSearch vSearch, 
Gui, Add, Text, xp+210 yp+5 w30 h20, Cat:
Gui, Add, DropDownList, xp+30 yp-5 w150 h25 r10 vCategory gCategory, |%categories%
Gui, Add, Button, xp+160 yp-1 w50 h23 gReset, &Reset
Gui, Add, Button, xp+140 yp w110 h23 gTryGoogle, Try &Google
Gui, Add, Listview, x10 yp+30 w700 h200 grid checked gMyListView altsubmit, Name|Type|Full name|Author|Idx
Gosub, UpdateLV

Gui, Font, bold s12
Gui, Add, Link, x10 yp+210 w700 h25 cNavy vFound, ..
Gui, Font, normal s8

Gui, Add, text, x10 yP+25 w700, Description:
Gui, Add, Edit, xp yP+20  w700 h150 vDescription, 
 
Gui, Add, Link, xp yP+160 w700 vSource,
Gui, Add, Link, xp yP+20  w700 vForum,
Gui, Add, Link, xp yp+20, Help build the pAHKlight database at <a href="https://github.com/hi5/pAHKlight">Github.com</a>
Gui, Add, Button, xp+490 yp-5 w100 gCheckUpdate, Check for updates
Gui, Add, Button, xp+110 yp w100 gGuiClose, E&xit

Gui, Add, StatusBar,, 
SB_SetText("   There are " o.MaxIndex() " packages in this " AppWindow " database" errorlog)

LV_ModifyCol(1), LV_ModifyCol(2), LV_ModifyCol(3,380)
LV_ModifyCol(4), LV_ModifyCol(5,0) 
; we hide the last column (5) which holds the index we use to keep 
; track of which entry we are looking at while browsing the list
; with the UP & DOWN keys or a mouse click so we can update the Gui 
; and save any changes to the personal INI

Gui, Show, w720 h535, %AppWindow%
TrayTip
UpdateData()
Return

; Respond to mouse clicks in Listview
MyListView:
Critical
if (A_GuiEvent == "I")
	{
	 LV_GetText(Idx, A_EventInfo, 5)
	 if (ErrorLevel == "C") ;  C (checkmark)
	 	o[Idx].check:="check"
	 if (ErrorLevel == "c") ;  or c (uncheckmark). 	
	 	o[Idx].check:=""
	}
UpdateData()
Return

; Start searching
Search:
Critical
Gui, Submit, NoHide
if (StrLen(Search) <= 1)
	{
	 Gosub, UpdateLV
	 Return
	}
if (StrLen(Search) < 2)
	Return
LV_Delete()
GuiControl, , Edit2, %A_Space%
Loop % o.MaxIndex()
	{
	 ; if the category doesn't match we can skip this entry
	 if ((Category <> "") and !InStr("," o[A_Index].category ",", "," Category ","))
		Continue
	 re:="iUms)" Search
	 if InStr(Search,A_Space) ; prepare regular expression to ensure search is done independent on the position of the words
		re:="iUms)(?=.*" RegExReplace(Search,"iUms)(.*)\s","$1)(?=.*") ")"
	 if RegExMatch(o[A_Index].searchthis,re) 
	 	LV_Add(o[A_Index].check, o[A_Index].name,o[A_Index].type,o[A_Index].fullname,o[A_Index].author,A_Index)
	}
UpdateData()
ControlSend, SysListview321, {Up}, %AppWindow%
ControlFocus, Edit1, %AppWindow%
Return

; Reset (clear) GUI
Reset:
GuiControl, , Category, ||%categories%
GuiControl, , Search,
ControlFocus, search, A
Return

; Category filter
Category:
Gui, Submit, NoHide
Gosub, UpdateLV
Return

; clear and fill listview
UpdateLV:
LV_Delete()
Loop % o.MaxIndex()
	{
	 if (Category = "") ; show all results
	 	LV_Add(o[A_Index].check, o[A_Index].name,o[A_Index].type,o[A_Index].fullname,o[A_Index].author,A_Index)
	 else if InStr("," o[A_Index].category ",", "," Category ",") ; show only results matching the category
	 	LV_Add(o[A_Index].check, o[A_Index].name,o[A_Index].type,o[A_Index].fullname,o[A_Index].author,A_Index)
	}
UpdateData()	
Return

; Update various texts in the Gui
UpdateData()
	{
	 global o
	 Gui, Submit, NoHide
	 SelItem := LV_GetNext()
	 if (SelItem = 0)
	    SelItem = 1
	 LV_GetText(Idx, SelItem, 5)
	 if (o[Idx].forum = "") or (o[Idx].forum ="~")
		forum:= "Forum  : not available..."
	 else
	 	forum:= "Forum  : <a href=""" o[Idx].forum """>" o[Idx].forum "</a>"
	 if (o[Idx].source = "") or (o[Idx].source ="~")
	 	source:= "Source : not available..."
	 else
		source:="Source : <a href=""" o[Idx].source """>" o[Idx].source "</a>"
	 ; Using ternary logic below to determine if we have an authorlink
	 ; if so, create a link (part before the :) if not simply show text (part after the :)
	 found:=o[Idx].authorlink ? o[Idx].name " by <a href=""" o[Idx].authorlink """>" o[Idx].author "</a>" : o[Idx].name " by " o[Idx].author
	 if (found = " by ")
	 	found:=""
	 StringReplace,found,found,&,&&,all
	 StringReplace,forum,forum,&,&&,all
	 StringReplace,source,source,&,&&,all
	 GuiControl, , found, %found%
	 GuiControl, , source, %source%
	 GuiControl, , forum, %forum%
	 GuiControl, , description, % NewLines(o[Idx].description)
	}

; Google custom search
; http://ahkscript.org/boards/viewtopic.php?f=3&t=237
TryGoogle:
Gui, Submit, NoHide
; Should probably use a nice UrlEncode function here just to be safe(r)
; but replacing space will do for now
StringReplace, googleQ, search, %A_Space%, +, All
Run, http://www.google.com/cse?cref=https://www.google.com/cse/tools/makecse`%3Furl`%3Dwww.ahkscript.org`%252F&ie=UTF-8&hl=&cx=010629462602499112316:ywoq_rufgic&q=%googleQ%&sa=Search&siteurl=www.ahkscript.org/&ref=&ss=420j61434j4
Return

; Various hotkeys
#If ActiveControlIs("SysListView321")
~Up::
UpdateData()
Return
~Down::
UpdateData()
Return
#If

; Endless scrolling in a listview
; http://www.autohotkey.com/board/topic/41349-example-endless-scrolling-in-a-listview/
#If (WinActive(AppWindow) and ActiveControlIs("Edit1"))
Up::
PreviousPos:=LV_GetNext()
if (PreviousPos = 0) ; exeption, focus is not on listview this will allow you to jump to last item via UP key
	{
	 ControlSend, SysListview321, {End}, %AppWindow%
	 Return
	}
ControlSend, SysListview321, {Up}, %AppWindow%
ItemsInList:=LV_GetCount()
ChoicePos:=PreviousPos-1
if (ChoicePos <= 1)
	ChoicePos = 1
if (ChoicePos = PreviousPos)
	ControlSend, SysListview321, {End}, %AppWindow%
UpdateData()
Return

Down::
PreviousPos:=LV_GetNext()
ControlSend, SysListview321, {Down}, %AppWindow%
ItemsInList:=LV_GetCount()
ChoicePos:=PreviousPos+1
if (ChoicePos > ItemsInList)
	ChoicePos := ItemsInList
if (ChoicePos = PreviousPos)
	ControlSend, SysListview321, {Home}, %AppWindow%
UpdateData()
Return
#If

ActiveControlIs(Control)
	{
	 ControlGetFocus, FocusedControl, A
	 if (FocusedControl = Control)
		Return 1
	 else
		Return 0	
	}

NewLines(text)
	{
	 StringReplace, text, text, ``n, `n, All
	 Return text
	}

CheckUpdate:
; Each commit (update) of the GitHub (or any git) repository has its
; own sha key, we can use this to check if there are any updates
RegExMatch(UrlDownloadToVar("https://api.github.com/repos/hi5/pAHKlight/git/refs/heads/master"),"U)\x22sha\x22\x3A\x22\K\w{6}",GHsha)
IniRead, sha, %use%, settings, sha
if (GHsha = "") or (GHsha = sha)
	{
	 MsgBox, 64, No update available, Your pAHKlight seems to be up-to-date.
	 Return
	}
MsgBox, 36, Update?, Do you wish to download updates for pAHKlight?
IfMsgBox, No
	Return
Loop, parse, pAHKlightfiles, `n
	{
	 FileMove, %A_LoopField%, %A_LoopField%.backup, 1
	 URLDownloadToFile, https://raw.github.com/hi5/pAHKlight/master/%A_LoopField%, %A_LoopField%
	}
MsgBox, 64, Restart, The updates have been downloaded.`nThe previous version has been saved as .BACKUP`nClick OK to restart.
IniWrite, %GHsha%, %use%, settings, sha
Sleep 500
Reload
Return

UrlDownloadToVar(URL)
	{
	 WebRequest:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	 try WebRequest.Open("GET",URL)
	 catch error
		Return error.Message
	 WebRequest.Send()
	 Return WebRequest.ResponseText
	}

Esc::
GuiClose:
GuiEscape:
SaveSettings:
; Store all "checked" packages so we can show the checkbox next time
Loop % o.MaxIndex()
	if (o[A_Index].check = "check")
		SaveInstalled .= o[A_Index].name ","
IniWrite, %SaveInstalled%, %use%, settings, installed

ExitApp