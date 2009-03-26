global rails_dir
global tab_index
set tab_index to 1

tell application "Terminal"
	activate
	
	-- Settings
	set projects_root to "~/Projects"
	set presets to {"CaLinker/Site", "konst-teknik.se"}
	
	-- Ask for predefined projects
	set rails_dir to ¬
		{choose from list presets ¬
			with title ¬
			"Choose Ruby on Rails project" OK button name ¬
			"Open Project" cancel button name ¬
			"Other Project..." default items ¬
			"CaLinker/Site" with prompt "Choose any predefined project (in \"" & projects_root & "/\")"}
	
	-- If no project selected (i.e. clicked on Cancel), ask user to manually enter a project's path
	if rails_dir = {false} then
		set rails_dir to the text returned of (display dialog ¬
			"Please Enter the Path to Your Rails Directory" default answer ¬
			"~/Projects/" as text)
	else
		set rails_dir to "~/Projects/" & rails_dir
	end if
	
	--if (count of windows) = 0 then make new window
	
	-- Open the window Group
	(*tell application ¬
		"System Events" to tell process "Terminal" to tell menu bar 1 to ¬
		tell menu bar item "Window" to tell menu "Window" to ¬
			tell menu item "Open Window Group" to tell menu ¬
				"Open Window Group" to click menu item "Rails"*)
	
	-- Run the command in each tab
	my open_tab("Server", " ./script/server")
	my open_tab("Console", "./script/console")
	my open_tab("Autotest", "autotest")
	my open_tab("Rails Directory", "mater")
end tell

--do shell script "sleep 3 && open http://localhost:3000"

on open_tab(title, the_command)
	tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
	delay 0.1
	tell application "Terminal" to ¬
		do script with command ("cd " & rails_dir & "&& unset PROMPT_COMMAND && title '" & title & "' && " & the_command) ¬
			in last tab of window 1
end open_tab