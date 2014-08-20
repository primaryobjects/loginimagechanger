#!/bin/bash
appPath=/usr/share/login-image-changer
settingsPath=$appPath/settings.conf
rcLocalPath="/etc/rc.local"
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
runCommand="sudo bash \"$scriptPath/loginimage.sh\" -r"

settingsExists=0
install=0
uninstall=0
run=0
sourcePath="none"
destPath="none"

echo "Login Image Changer v1.0 (http://github.com/primaryobjects/loginimagechanger)"
echo ""

# Check command-line arguments.
if [ $1 ]
then
	if [ $1 = "--install" ] || [ $1 = "-i" ]
	then
		install=1
	elif [ $1 = "--uninstall" ] || [ $1 = "-u" ]
	then
		uninstall=1
	elif [ $1 = "--run" ] || [ $1 = "-r" ]
	then
		run=1
	else
		echo "-h, --help       Help"
		echo "-r, --run        Run login image changer and change background image"
		echo "-i, --install    Install or change existing settings"
		echo "-u, --uninstall  Uninstall"
		exit
	fi
fi

# Ensure running as root.
if [ "$EUID" -ne 0 ]
then
  echo "Please run as root: sudo bash loginimage.sh"
else
	# Check if the settings file exists.
	if [ -f "$settingsPath" ]
	then
		settingsExists=1

		# Read settings from config file.
		exec 6< "$settingsPath"
		read sourcePath <&6
		read destPath <&6
		exec 6<&-
	fi

	if [ $uninstall = 1 ]
	then
		if [ "$sourcePath" = "none" ] || [ "$destPath" = "none" ]
		then
			echo "Nothing to uninstall."
		else
			echo "Uninstalling"
		
			backupFile=$(basename "$destPath")
			echo "Restoring backup of $appPath/$backupFile to $destPath"
			mv -f "$appPath"/"$backupFile" "$destPath"

			echo "Removing run command from $rcLocalPath"
			sed -i '/loginimage\.sh/d' "$rcLocalPath"

			echo "Removing folder $appPath"
			rm -r -f "$appPath"

			echo "Uninstall complete!"
		fi
	elif ([ $settingsExists = 0 ] || [ $install = 1 ]) && [ $run = 0 ]
	then
		# The user specified --install or no settings exist yet.
		# Show dialog to choose new folder paths.
		zenity --forms --title="Login Image Changer" --text="Welcome to Login Image Changer\nhttp://github.com/primaryobjects/loginimagechanger\n\nAutomatically changes the login background image each time your PC starts up.\n\nPictures Folder: $sourcePath\nBackground Image to Change: $destPath\n\nWould you like to setup a random login background image?"
		result=$?

		if [ $result = 0 ]
		then
			sourcePath=$(zenity --file-selection --directory --title="Select a folder containing images")
			result=$?
			if [ $result = 0 ]
			then
				# We have the source folder for images. Now, get the destination background image filename to overwrite.
				origDestPath="$destPath"
				destPath=$(zenity --file-selection --title="Select the background image to overwrite from your installed Login Window Theme")
				result=$?
				if [ $result = 0 ]
				then
					echo ""

					# Restore any previous settings.					
					if [ "$origDestPath" != "none" ]
					then
						# Previously saved settings. Restore backup file, then overwrite with new changes.
						backupFile=$(basename "$origDestPath")
						echo "Restoring backup of $appPath/$backupFile to $origDestPath"
						mv -f "$appPath"/"$backupFile" "$origDestPath"
					fi

					# Save new settings.
					# Create directories (-p to ignore file exists errors).
					mkdir -p "$appPath"

					# Write first line of file.
					echo "$sourcePath" > "$settingsPath"
					# Append second line to file.
					echo "$destPath" >> "$settingsPath"

					echo "Configuration saved to $settingsPath"

					# Make a backup of the destination file.
					cp -f "$destPath" "$appPath"
					echo "Created a backup copy of $destPath to $appPath"

					# Append entry to /etc/rc.local to run at startup.
					if grep -q loginimage "$rcLocalPath"
					then
						echo "loginimage.sh is already installed in $rcLocalPath."
					else
						sed -i '$i \'"$runCommand"'\n' "$rcLocalPath"
						echo "Run command appened to $rcLocalPath"
					fi

					echo "Successfully saved!"
					echo "To see changes, reboot or manually run: sudo bash loginimage.sh"
				fi
			fi
		fi
	else
		if [ "$sourcePath" = "none" ] || [ "$destPath" = "none" ]
		then
			echo "No configuration settings found. Please run: sudo bash loginimage.sh -i"
		else
			# Run randomization script.
			files=("$sourcePath"/*) #creates an array of all the files within src/ */
			filecount="${#files[@]}"         #determines the length of the array
			if [ filecount > 0 ]
			then
				randomid=$((RANDOM % filecount)) #uses $RANDOM to choose a random number between 0 and $filecount
				filetomove="${files[$randomid]}" #the random file wich we'll move

				# Disable case-sensitive regex matching.
				shopt -s nocasematch;

				if [[ $filetomove =~ jpg ]] || [[ $filetomove =~ png ]] || [[ $filetomove =~ gif ]]
				then
					echo "Using source folder: $sourcePath"
					echo "Selected random image $filetomove"
					echo "Copying to destination: $destPath"
					cp "$filetomove" "$destPath"
				else
					echo "No images (.jpg, .gif, .png) found in $sourcePath"
					echo "Please select a different folder for images: sudo bash loginimage.sh -i"
				fi
			fi
		fi
	fi
fi
