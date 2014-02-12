/*
Name          : pAHKlight - v0.1.1
Purpose       : Your Lightweight Guid to AutoHotkey libraries, classes, functions and tools
Source        : https://github.com/hi5/pAHKlight
AHKScript     : http://www.ahkscript.org/boards/viewtopic.php?f=6&t=1241
License       : MIT - see COPYING.txt
*/

#NoEnv
#SingleInstance, force
SetBatchLines, -1

; ini
Version:="v0.1.1"
AppWindow:="pAHKlight " Version " [ AutoHotkey libraries, classes, functions and tools ]"
dbf:="pahklightDB.ini"
use:="personal.ini"
Keys:="name,fullname,author,type,source,forum,category,ahkversion,description"
o:=[]
errorlog:=""
SaveInstalled:=""

; files we want to download in case of an update
pAHKlightfiles=
(join`n
pahklight.ahk
pahklightDB.ini
categories.txt
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
	 if !InStr("|lib|class|function|tool|", "|" o[Idx].type "|") or InStr(o[Idx].type,"|")
 		errorlog .= "[" Idx "] " o[Idx].name ": type error`n" 
 	 checkcategories:=o[Idx].category
	 Loop, parse, checkcategories, CSV 
	 	if !InStr( "|" categories "|", "|" Trim(A_LoopField) "|")
	 		{
	 		 errorlog .= "[" Idx "] " o[Idx].name ": category error`n" 
	 		 break
	 		} 
	 if !InStr(o[Idx].source, "http")
	 	errorlog .= "[" Idx "] " o[Idx].name ": source URL error`n" 
	 if (o[Idx].forum <> "") and !InStr(o[Idx].forum, "http")
	 	errorlog .= "[" Idx "] " o[Idx].name ": forum URL error`n" 
	}

Idx:=""

if (errorlog <> "")
	{
	 FileDelete, errorlog.txt
	 FileAppend, %errorlog%, errorlog.txt
	 errorlog:=" - please consult errorlog.txt!"
	 MsgBox, 48, Possible errors, Possible errors detected while loading the database.`nPlease consult errorlog.txt and report the errors.`nThank you!
	}

; build gui

Gui, +Resize +MinSize
Gui, Add, Text, x10 y10 w40 h20 vSearchLbl, Search:
Gui, Add, Edit, xp+50 yp-5 w200 h20 gSearch vSearch, 
Gui, Add, Text, xp+210 yp+5 w30 h20 vCategoryLbl, Cat:
Gui, Add, DropDownList, xp+30 yp-5 w150 h25 r10 vCategory gCategory, |%categories%
Gui, Add, Button, xp+160 yp-1 w50 h23 gReset vReset, &Reset
Gui, Add, Button, xp+140 yp w110 h23 gTryGoogle vGoogle, Try &Google
Gui, Add, Listview, vList x10 yp+30 w700 h200 grid checked gMyListView vList altsubmit, Name|Type|Full name|Author|Idx
Gosub, UpdateLV

Gui, Font, bold s12
Gui, Add, Link, x10 yp+210 w700 h25 cNavy vFound, ..
Gui, Font, normal s8

Gui, Add, text, x10 yP+25 w700 vDescriptionLbl, Description:
Gui, Add, Edit, xp yP+20  w700 h150 vDescription, 
 
Gui, Add, Link, xp yP+160 w700 vSource,
Gui, Add, Link, xp yP+20  w700 vForum,
Gui, Add, Link, xp yp+20  w350 vGithubLink, Help build the pAHKlight database at <a href="https://github.com/hi5/pAHKlight">Github.com</a>
Gui, Add, Button, xp+490 yp w100 gCheckUpdate vCheckUpdate, Check for updates
Gui, Add, Button, xp+110 yp w100 gGuiClose vExit, E&xit

Gui, Add, StatusBar, vStatusBar, 
SB_SetText("   There are " o.MaxIndex() " packages in this " AppWindow " database" errorlog)

LV_ModifyCol(1), LV_ModifyCol(2), LV_ModifyCol(3,370)
LV_ModifyCol(4), LV_ModifyCol(5,0) 
; we hide the last column (5) which holds the index we use to keep 
; track of which entry we are looking at while browsing the list
; with the UP & DOWN keys or a mouse click so we can update the Gui 
; and save any changes to the personal INI

Gui, Show, w720 h540, %AppWindow%
TrayTip
UpdateData()
Return

; Allow Resizing via Anchor:
GuiSize:
Anchor("Search", "w0.5")
Anchor("CategoryLbl", "x0.5")
Anchor("Category", "x0.5 w0.5")
Anchor("Reset", "x")
Anchor("Google", "x")
Anchor("List", "w h0.8")
Anchor("Found", "y0.8 w")
Anchor("DescriptionLbl", "y0.8")
Anchor("Description", "y0.8 w h0.2")
Anchor("Source", "w y")
Anchor("Forum", "w y")
Anchor("GithubLink", "w y")
Anchor("CheckUpdate", "x y")
Anchor("Exit", "x y")
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
	 ; Using ternary logic below to determine if we have an ahkversion
	 ; if so, display in [ .. ] (part before the :) if not simply show the descripton (part after the :)
	 GuiControl, , description, % o[Idx].ahkversion ? "[" o[Idx].ahkversion "] - " NewLines(o[Idx].description) : NewLines(o[Idx].description)
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

/*
	Function: Anchor
		Defines how controls should be automatically positioned relative to the new dimensions of a window when resized.

	Parameters:
		cl - a control HWND, associated variable name or ClassNN to operate on
		a - (optional) one or more of the anchors: 'x', 'y', 'w' (width) and 'h' (height),
			optionally followed by a relative factor, e.g. "x h0.5"
		r - (optional) true to redraw controls, recommended for GroupBox and Button types

	Examples:
> "xy" ; bounds a control to the bottom-left edge of the window
> "w0.5" ; any change in the width of the window will resize the width of the control on a 2:1 ratio
> "h" ; similar to above but directrly proportional to height

	Remarks:
		To assume the current window size for the new bounds of a control (i.e. resetting) simply omit the second and third parameters.
		However if the control had been created with DllCall() and has its own parent window,
			the container AutoHotkey created GUI must be made default with the +LastFound option prior to the call.
		For a complete example see anchor-example.ahk.

	License:
		- Version 4.60a <http://www.autohotkey.net/~polyethene/#anchor>
		- Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
*/

; Revised version for 64-bit/unicode - author unknown
; http://www.autohotkey.com/board/topic/91997-gui-anchor-for-current-version-of-ahk/?p=580170

Anchor(i, a := "", r := false) {
	static c, cs := 12, cx := 255, cl := 0, g, gs := 8, gl := 0, gpi, gw, gh, z := 0, k := 0xffff, ptr
	if z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), ptr := A_PtrSize ? "Ptr" : "UInt", z := true
	if !WinExist("ahk_id" . i) {
		GuiControlGet t, Hwnd, %i%
		if ErrorLevel = 0
			i := t
		else ControlGet i, Hwnd,, %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), ptr, &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	if (gp != gpi) {
		gpi := gp
		loop %gl%
			if NumGet(g, cb := gs * (A_Index - 1), "UInt") == gp {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				break
			}
		if !gf
			NumPut(gp, g, gl, "UInt"), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos dx, dy, dw, dh,, ahk_id %i%
	loop %cl%
		if NumGet(c, cb := cs * (A_Index - 1), "UInt") == i {
			if (a = "") {
				cf := 1
				break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			loop Parse, a, xywh
				if A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "UInt", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			if r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			return
		}
	if cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48, "UInt"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "UInt")
	if cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb, "UInt"), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	return true
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