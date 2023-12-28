## Development environment setup
FM uses Metamod, AMX Mod X, and Orpheu to build and run plugins.

### Metamod
Download (pick the binary for your operating system): http://metamod.org/

Installation instructions: http://metamod.org/metamod.html

Summary of installation instructions:

	Copy metamod.dll to addons/metamod
	The folder structure should be Half-Life/tfc/addons/metamod, create any folders that don't exist
	In Half-Life/tfc, edit these lines liblist.gam to make tfc use the metamod dll for your operating system (gamedll for windows and gamedll_linux for linux):
		gamedll "dlls/mp.dll"
		gamedll_linux "dlls/cs_i386.so"
	to:
		gamedll "addons/metamod/dlls/metamod.dll"
		gamedll_linux "addons/metamod/dlls/metamod_i386.so"

### AMX Mod X 1.9 base and AMX Mod X 1.9 tfc
Download (pick your operating system and download BOTH the base and tfc versions): https://www.amxmodx.org/downloads-new.php?branch=1.9-dev&all=1

Installation instructions:

	You should be able to just copy the addons folder for both downloads into the tfc directory.
	The folder structure should be Half-Life/tfc/addons/amxmodx
	Copy base first and then tfc, replace all conflicting files.

### Orpheu 2.6.3
Download (orpheu-files-2.6.3.zip): https://github.com/Arkshine/Orpheu/releases
Installation instructions:
	Unzip contents into amxmodx directory, don't include the orpheu-files-2.6.3 folder

### Setting up compile tools:
Copy the contents of amxmodx/scripting from both the base and tfc versions and orpheu-files-2.6.3/scripting to a tools folder in the root of this repository.

The folder structure should be fm_base_plugins/tools/ with the contents of the scripting folder inside - the scripting folder itself should not be included.

Once all scripting folders have been copied, move the include folder from tools to the root of this repository.


## Configuring plugins to enable:
Edit Plugins.ini in addons/metamod folder (create if doesn't exist)

Lines can be commented (disabled) with // or #

	<platform> <filepath> [<description>]
	example:
		// linux    dlls/mybot.so
		# win32     dlls/mybot-old.dll         Mybot old
		win32       dlls/mybot.dll             Mybot current
		linux       /tmp/stub_mm_i386.so
		win32       /tmp/stub_mm_i386.dll
		linux       ../dlls/trace_mm_i386.so
		win32       ../dlls/trace_mm_i386.dll
		linux       dlls/admin_MM_i386.so
		win32       dlls/admin_MM_i386.dll
