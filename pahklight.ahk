/*
Name          : pAHKlight - v0.1
Purpose       : Your Lightweight Guid to AutoHotkey libraries, classes, functions and tools
Source        : https://github.com/hi5/pAHKlight
AHKScript     : ...
License       : MIT - see COPYING.txt

Todo          : Check for updates on database (by checking sha of GH repository)

*/

#NoEnv
SetBatchLines, -1

; ini
Version:="0.1"
AppWindow:="pAHKlight - " Version
dbf:="pahklightDB.ini"
use:="personal.ini"
Keys:="name,author,type,source,forum,tags,description"
o:=[]

; read database
IniRead, Sections, %dbf%
IniRead, installed, %use%, settings, installed

StringReplace, Sections, Sections, `n, `n, UseErrorLevel
If (ErrorLevel > 200)
	TrayTip, Loading, pAHKlight database ..., 3, 1

Loop, parse, Sections, `n, `r
	{
	 Idx:=A_Index
	 IniRead, Section, %dbf%, %A_LoopField%
	 o[Idx,"shortname"]:=A_LoopField
	 if A_LoopField in %installed%
	 	o[Idx,"check"]:="check"
	 o[Idx,"searchthis"]:=A_LoopField " " section
	 Loop, parse, Keys, CSV
	 	{
		 RegExMatch(section "`n","isU)" A_LoopField "=(.*)\r?\n",keym)
		 o[Idx,A_LoopField]:=keym1
		}
	 Section:="",keym:="",keym1:=""
	}

; build gui

Gui, Add, Text, x10 y10 w40 h20, Search:
Gui, Add, Edit, xp+50 yp-5 w200 h20 gSearch vSearch, 
Gui, Add, link, xp+410 yp+5, Help build the pAHKlight database at <a href="GH">Github.com</a>

Gui, Add, Listview, x10 yp+20 w700 h250 grid checked gMyListView altsubmit, Name|Type|Full name|Author|Idx
Gosub, UpdateLV

Gui, Font, bold s12
Gui, Add, Text, x10 yp+260 w700 h25 cNavy vFound, % o[1].shortname " by " o[1].author
Gui, Font, normal s8

Gui, Add, text, x10 yP+25 w700, Description:
Gui, Add, Edit, xp yP+20  w700 h150 vDescription, 
 
Gui, Add, link, xp yP+160 w700 vSource,
Gui, Add, link, xp yP+20  w700 vForum,
Gui, Add, text, xp yp+30, pAHKlight - Your Lightweight Guide to AutoHotkey libraries, classes, functions and tools.
Gui, Add, Button, xp+500 yp-5 w100 gCheckUpdate, Check for updates
Gui, Add, Button, xp+100 yp w100 gGuiClose, Exit

Gui, Add, StatusBar,, Bar's starting text (omit to start off empty).
SB_SetText("   There are " o.MaxIndex() " packages in this " AppWindow " database")

LV_ModifyCol(1), LV_ModifyCol(2), LV_ModifyCol(3,380)
LV_ModifyCol(4), LV_ModifyCol(5,0)

Gui, Show,, %AppWindow%
TrayTip
UpdateData()
Return

; Respond to mouse clicks in Listview
MyListView:
Critical
if (A_GuiEvent == "I")
	{
	 LV_GetText(Idx, A_EventInfo, 5)
	 If (ErrorLevel == "C") ;  C (checkmark)
	 	o[Idx].check:="check"
     If (ErrorLevel == "c") ;  or c (uncheckmark). 	
	 	o[Idx].check:=""
	}
UpdateData()
Return

; Start searching
Search:
Critical
Gui, Submit, NoHide
If (StrLen(Search) <= 1)
	{
	 Gosub, UpdateLV
	 Return
	}
If (StrLen(Search) < 2)
	Return
LV_Delete()
GuiControl, , Edit2, %A_Space%
Loop % o.MaxIndex()
	{
	 StringReplace, re, Search, %A_Space%, .*, All ; this could be refined
	 if RegExMatch(o[A_Index].searchthis,"iUms)" re)
		LV_Add(o[A_Index].check, o[A_Index].shortname,o[A_Index].type,o[A_Index].name,o[A_Index].author,A_Index)
	}
UpdateData()
ControlSend, SysListview321, {Up}, %AppWindow%
ControlFocus, Edit1, %AppWindow%
Return

; clear and fill listview
UpdateLV:
LV_Delete()
Loop % o.MaxIndex()
	 LV_Add(o[A_Index].check, o[A_Index].shortname,o[A_Index].type,o[A_Index].name,o[A_Index].author,A_Index)
UpdateData()	
Return

; Update various texts in the Gui
UpdateData()
	{
	 global o
	 Gui, Submit, NoHide
	 SelItem := LV_GetNext()
	 If (SelItem = 0)
	    SelItem = 1
	 LV_GetText(Idx, SelItem, 5)
	 If (o[Idx].forum = "") or (o[Idx].forum ="~")
		forum:= "Forum  : not available..."
	 else
	 	forum:= "Forum  : <a href=""" o[Idx].forum """>" o[Idx].forum "</a>"
	 If (o[Idx].source = "") or (o[Idx].source ="~")
	 	source:= "Source : not available..."
	 else
		source:="Source : <a href=""" o[Idx].source """>" o[Idx].source "</a>"
	 found:=o[Idx].shortname " by " o[Idx].author
	 StringReplace,found,found,&,&&,all
	 StringReplace,forum,forum,&,&&,all
	 StringReplace,source,source,&,&&,all
	 GuiControl, , found, %found%
	 GuiControl, , source, %source%
	 GuiControl, , forum, %forum%
	 GuiControl, , description, % NewLines(o[Idx].description)
	}

; various hotkeys
#If ActiveControlIs("SysListView321")
~Up::
UpdateData()
Return
~Down::
UpdateData()
Return
#If

#If (WinActive(AppWindow) and ActiveControlIs("Edit1"))
Up::
PreviousPos:=LV_GetNext()
If (PreviousPos = 0) ; exeption, focus is not on listview this will allow you to jump to last item via UP key
	{
	 ControlSend, SysListview321, {End}, %AppWindow%
	 Return
	}
ControlSend, SysListview321, {Up}, %AppWindow%
ItemsInList:=LV_GetCount()
ChoicePos:=PreviousPos-1
If (ChoicePos <= 1)
	ChoicePos = 1
If (ChoicePos = PreviousPos)
	ControlSend, SysListview321, {End}, %AppWindow%
UpdateData()
Return

Down::
PreviousPos:=LV_GetNext()
ControlSend, SysListview321, {Down}, %AppWindow%
ItemsInList:=LV_GetCount()
ChoicePos:=PreviousPos+1
If (ChoicePos > ItemsInList)
	ChoicePos := ItemsInList
If (ChoicePos = PreviousPos)
	ControlSend, SysListview321, {Home}, %AppWindow%
UpdateData()
Return
#If

ActiveControlIs(Control)
	{
	 ControlGetFocus, FocusedControl, A
	 If (FocusedControl = Control)
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
MsgBox Currently not implemented (would simply check the sha of the GH repository)
; todo when on GitHub
Return

Esc::
GuiClose:
GuiEscape:
SaveSettings:
Loop % o.MaxIndex()
	If (o[A_Index].check = "check")
		SaveInstalled .= o[A_Index].shortname ","
IniWrite, %SaveInstalled%, %use%, settings, installed

ExitApp