-- RailsTerm 0.3.2
-- 
-- martin.strom at gmail dot com
-- 
-- HISTORY
-- 
-- 0.3.2 Support for Rails 3
-- 0.3.1 Updated to work with 10.6 Terminal
-- 0.3 Use passenger/mod_rails and auto detect vhosts added by Passenger.prefpane
-- 0.2 Use 10.5 Terminal instead
-- 0.1 Initial version
--

-- Settings --
set visor_enabled to false -- if you use Visor (http://docs.blacktree.com/visor/visor), set this to true

-- Run it
global rails_dir, min_window_count, visor_enabled
main()

-- Main start function
on main()
	my set_minimum_window_count()
	
	tell application "Terminal"
		activate
		
		set rails_dir to my ask_for_rails_project_directory()
		
		if not my rails_dir_exists() then
			display alert ¬
				"Project is not a valid Rails directory" message ¬
				"The directory doesn't seem to contain some folders a Rails project usually do. Please check your path." as warning
		else
			my open_rails_tabs()
		end if
	end tell
end main

on set_minimum_window_count()
	if visor_enabled then
		set min_window_count to 2 -- Visor SIMBL seems to use 2 windows for itself
	else
		set min_window_count to 0
	end if
end set_minimum_window_count

on get_rails_projects()
	return my projects_from_passenger_vhosts()
end get_rails_projects

on projects_from_passenger_vhosts()
	set cmd to "for file in /etc/apache2/passenger_pane_vhosts/*.vhost.conf; do grep DocumentRoot $file | awk '{print $2}' | sed 's/\"//g' | sed 's/\\/public$//g' ; done | sort -ubf"
	do shell script cmd
	set output to the result as text
	
	set original_delimiters to AppleScript's text item delimiters
	
	set AppleScript's text item delimiters to {return}
	set the_projects to text items of output
	set AppleScript's text item delimiters to original_delimiters
	
	return the_projects
end projects_from_passenger_vhosts

on ask_for_rails_project_directory()
	activate
	
	set presets to {"first_project", "another_project", "one_more_project"} -- sub directories to “project_root'”
	
	set projects to my get_rails_projects()
	set project_directory to ¬
		{choose from list projects ¬
			with title ¬
			"Choose Ruby on Rails project" OK button name ¬
			"Open Project" cancel button name ¬
			"Other Project..." default items ¬
			(first item of projects) with prompt "Please select which Rails project you want to open.
If it's not in the list, click \"Other Project\" to enter its path."}
	
	-- If no project selected (i.e. clicked on Cancel), ask user to manually enter a project's path
	if project_directory = {false} then
		set project_directory to the text returned of (display dialog ¬
			"Please Enter the Path to Your Rails Directory" default answer ¬
			"~" as text)
	end if
	
	return project_directory
end ask_for_rails_project_directory

on rails_dir_exists()
	set dir_exists to false
	
	try
		do shell script "cd " & rails_dir & " && [[ -x app ]] && [[ -x config ]] && echo exists"
		if text of result is "exists" then
			set dir_exists to true
		else
			set dir_exists to false
		end if
	on error
		set dir_exists to false
	end try
	
	return dir_exists as boolean
end rails_dir_exists

on open_rails_tabs()
	my open_tab("Log", "tail -f log/development.log")
	my open_tab("Console", "[[ -x script/console ]] && script/console || rails c")
	my open_tab("Autotest", "[[ -d spec ]] && autospec || autotest")
	
	tell application "TextMate" to activate
	my open_tab("Rails Directory", "mater") -- I use `mater` @ http://pastie.textmate.org/221354 instead of `mate .` for rails apps
end open_rails_tabs

on open_tab(title, the_command)
	tell application "Terminal" to activate
	
	my create_new_window_or_tabs()
	
	tell application "Terminal" to ¬
		do script with command ("cd " & rails_dir & "&& unset PROMPT_COMMAND && echo -n -e \"\\033]0;" & title & "\\007\" && " & the_command) ¬
			in last tab of window 1
end open_tab

on create_new_window_or_tabs()
	if (count of windows of application "Terminal") ≤ min_window_count then
		tell application "Terminal" to do script "" -- create a new window
	else
		tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
	end if
end create_new_window_or_tabs