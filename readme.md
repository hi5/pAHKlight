# pAHKlight - v0.1

pAHKlight - Your Lightweight Guide to [AutoHotkey](http://ahkscript.org/) libraries, classes, functions and tools.

Questions or suggestions? Post it here <http://ahkscript.org/boards/viewtopic.php?f=6&t=1241> or 
file [an issue](https://github.com/hi5/pAHKlight/issues) here on GitHub. To contribute, read
the info about the format below, and either post new entries for the database on the forum or
[create a pull request](https://help.github.com/articles/creating-a-pull-request).

## Introduction

**A package or module: a software component for accomplishing a particular thing.** (wikipedia)

Many programming languages have so called package managers to easily manage the installation of
libraries. AutoHotkey lacks such a standard solution (December '13). See the [discussions](#other-resources) 
below for some background info.

pAHKlight is a *possible* intermediate solution until a more competent system is setup, it is
not meant as a real package manager, but its purpose is to help find libraries, classes, functions
and tools quickly, especially for those unfamiliar with AutoHotkey.

The pAHKlight script is fairly short and the format for the "package database" is kept very simple so even
a novice user should be able to maintain (both the script and) the database. This will hopefully ensure
that is kept up to date by posting new additions for the database on the forum or pull requests on Github.

Once you have found a "package" of interest visit the source or discussion page for more detailed
information and (usually) instructions how install and apply the "package". 

As a reminder (for yourself) you can tick the checkbox in front of a package if you use it. It will
remember that for the next time you start pAHKlight so you can quickly see which package(s) you are
already using.

![pAHKlight user interface](https://raw.github.com/hi5/_resources/master/pahklight.png)

Things pAHKlight **can and should not** do:

* download, install or update libraries, classes, functions and tools
* check which (versions of) libraries, classes, functions and tools are currently installed

Things pAHKlight **should not** do:

* replicate the content of a forum by including all posted scripts. It should include packages only.

## INI Format

The INI format used in pahklightDB.ini has the following structure

   ```ini
   [Sequential number]
   name=short
   fullname=full
   author=
   type=lib|class|function|tool
   source=URL
   forum=URL
   category=
   description=
   ```

|Section/Key  |Description|
|-------------------|-----------|
|[Sequential number]|Used as section names in the INI, they have to be unique|
|name=              |Short names, usually the name of the Prefix in case of a library or class|
|fullname=          |Full name used in the Gui (texts) and Browse list (listview)|
|author=            |(Main) Author of the script - you can include an URL: name @ URL although not mandatory|
|type=              |Lib, class, function or tool - only one allowed see comments below|
|source=            |URL - can be same as forum URL below in case source is posted on a forum for example|
|forum=             |URL - forum link|
|category=          |CSV list (see categories.txt)|
|description=       |Purpose of the lib, class, function or tool. The entire text should be on one line due to the limitation of the INI format. Use `n if you want to display a new line just like you would in AutoHotkey|

**name, fullname, author, type, source and description are mandatory fields.**

## type

There are four types, you can only select one. The following brief definitions apply:

* lib: So called Standard and/or User Libraries (stdlib) as described briefly here <http://l.autohotkey.net/docs/Functions.htm#lib>. 
* class: A class is an extensible template for creating objects, see <http://l.autohotkey.net/docs/Objects.htm#Custom_Classes>
* function: Standalone function for a specific task
* tool: Helper programs to generate code (gui for example) or extend the capability of AutoHotkey. "Normal" scripts should not be included in pAHKlight.

## category

The category field is a comma separated value list. These can be found in categories.txt - if not present in that list the category is not accepted. Suggestions for the categories are of course welcome.

## Other Resources

Attempts for defining so called Standard libraries have been made before and discussed a number of times,
you can find some below:

* Alternative: <https://github.com/Library-Distribution> Not completed, no plans for further development
* Alternative: <http://www.autohotkey.com/board/topic/50834-ahk-standard-library-collection-2010-sep-gui-libs-100/> Last update in 2010
* Discussion: <http://www.autohotkey.com/board/topic/49921-stdlib-call-for-information/>
* Discussion: <http://www.autohotkey.com/board/topic/63827-libraries-in-default-ahk-installation-ahk-l/>
