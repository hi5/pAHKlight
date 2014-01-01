# pAHKlight - v0.1

**Introduction**

pAHKlight - Your Lightweight Guide to AutoHotkey libraries, classes, functions and tools.

**A package or module: a software component for accomplishing a particular thing.** (wikipedia)

Many programming languages have so called package managers to easily manage the installation of
libraries. AutoHotkey lacks such a standard solution (December '13). See the [discussions](#other-resources) 
below for some background info.

pAHKlight is a *possible* intermediate solution until a more competent system is setup, it is
not meant as a real package manager, but its purpose is to help find libraries, classes, functions
and tools quickly, especially for those unfamiliar with AutoHotkey.

The pAHKlight script is short and the format for the "package database" is kept very simple so even
a novice user should be able to update (both the script and) the database. This will hopefully ensure
that is kept up to date by posting new additions for the database on the forum or pull requests on Github.

Once you have found a "package" of interest visit the source or discussion page for more detailed
information and (usually) instructions how install and apply the "package". 

As a reminder you can tick the checkbox in front of a package if you use it and it will remember
that for the next time so you can quickly see which packaged you are already using.

Things pAHKlight **can not** do:

* download, install or update libraries, classes, functions and tools
* check which (versions of) libraries, classes, functions and tools are currently installed

Things pAHKlight **should not** do:

* replicate the content of a forum by including all posted scripts. It should include packages only.

## INI Format

The INI format used in pahklightDB.ini has the following structure

   ```ini
   [Shortname]
   name=Full name
   author=
   type=lib|class|function|tool
   source=URL
   forum=URL
   tags=
   description=
   ```

|Section/Key  |Description|
|-------------|-----------|
|[Shortname]  |Section names have to be unique. If you add a new library and the name has been taken, simply add a (serial) number to the name, for example JSON2, JSON3 etc so it becomes unique|
|name=        |Full name used in the Gui and Browse list (listview)|
|author=      |Main author of the script|
|type=        |Lib, class, function or tool - only one allowed see comments below|
|source=      |URL - can be same as forum URL below in case source is posted on a forum for example|
|forum=       |URL - forum link|
|tags=        |CSV list - currently not used in the Gui yet but they are included in the search|
|description= |Purpose of the lib, class, function or tool. The entire text should be on one line due to the limitation of the INI format. Use `n if you want to display a new line|

### type

There are four types, you can only select one. The following brief definitions apply:

* lib: So called Standard and/or User Libraries (stdlib) as described briefly here <http://l.autohotkey.net/docs/Functions.htm#lib>. 
* class: A class is an extensible template for creating objects, see <http://l.autohotkey.net/docs/Objects.htm#Custom_Classes>
* function: Standalone function for a specific task
* tool: Helper programs to generate code (gui for example) or extend the capability of AutoHotkey. "Normal" scripts should not be included in pAHKlight.

## Other Resources

* Alternative: <https://github.com/Library-Distribution> Not completed, no plans for further development
* Alternative: <http://www.autohotkey.com/board/topic/50834-ahk-standard-library-collection-2010-sep-gui-libs-100/> Last updated in 2010
* Discussion: <http://www.autohotkey.com/board/topic/49921-stdlib-call-for-information/>
* Discussion: <http://www.autohotkey.com/board/topic/63827-libraries-in-default-ahk-installation-ahk-l/>
