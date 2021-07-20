#!/bin/bash

# This script creates a desktop entry file and places it in /usr/share/applications directory
# Run this script file with root permission

tempFile=/tmp/temp.desktop # Temporary location for creating the entry file

# Deleting the temporary entry file if it already exists
if [ -e "$tempFile" ]; then
    rm -f "$tempFile"
fi

# Creating the temporary entry file
touch $tempFile

printf "# This is a desktop entry file created by createDesktopEntry.sh\n
# You can modify this file to add additional options as per the requirements\n\n" >$tempFile
printf "[Desktop Entry]\n\n" >>$tempFile

# Getting the path of the executable file from the user
echo -n "Enter path to the executable file: "
read Path
until [ -n "$Path" ]; do
    echo "Application path cannot be empty"
    echo -n "Please try again: "
    read Path
done
absolutePath=$(realpath $Path)

# Checking if the provided path is a valid path to executable file
if [ -e "$Path" ]; then         # Checking if the file exists
    if [ -f "$Path" ]; then     # Checking whether the file is a regular file
        if [ -x "$Path" ]; then # Checking whether the file is executable
            printf "Type=Application\n\n" >>$tempFile
            printf "Exec=$absolutePath\n\n" >>$tempFile
            echo ""
            echo -n "Does the program run in a terminal?[Y/n]: "
            read Terminal
            case "$Terminal" in
            n | N)
                printf "Terminal=false\n\n" >>$tempFile
                ;;
            *)
                printf "Terminal=true\n\n" >>$tempFile
                ;;
            esac
            # Reading Name
            echo ""
            echo "The name you enter below will be used for the application launcher"
            echo -n "[Required]Enter Name: "
            read Name
            until [ -n "$Name" ]; do
                echo "Name cannot be empty"
                echo -n "Please try again: "
                read Name
            done
            printf "Name=$Name\n\n" >>$tempFile
            # Reading GenericName
            echo ""
            echo -n "[Optional]Enter GenericName: "
            read GenericName
            if [ ! -z "$GenericName" ]; then
                printf "GenericName=$GenericName\n\n" >>$tempFile
            fi
            # Reading Comment for the application
            echo ""
            echo -n "[Optional]Enter Comment: "
            read Comment
            if [ ! -z "$Comment" ]; then
                printf "Comment=$Comment\n\n" >>$tempFile
            fi
            # Reading path to the icon
            echo ""
            echo "The path you provide below will be used to display as an icon for the launcher"
            echo -n "[Optional]Enter path to icon: "
            read Icon
            if [ ! -z "$Icon" ]; then
                if [ -e "$Icon" ]; then
                    iconName=$(basename "$Icon")
                    iconFilename=${iconName%.*}
                    iconFileExtension=${iconName##*.}
                    if [ -e "/usr/share/icons/$iconName" ]; then
                        newIconName="$iconFilename-$(date +%Y-%m-%d).$iconFileExtension"
                        cp "$Icon" "/usr/share/icons/$newIconName"
                        printf "Icon=$newIconName\n\n" >>$tempFile
                    else
                        cp "$Icon" "/usr/share/icons/$iconName"
                        printf "Icon=$iconName\n\n" >>$tempFile
                    fi
                else
                    echo "The specified file does not exist"
                fi
            fi
            # Replacing spaces ' ' with hyphens '-' in the $Name
            fileName=$(tr -s ' ' '-' <<<$Name)
            # Checking if the desktop entry already exists
            while [ -e "/usr/share/applications/$fileName.desktop" ]; do
                echo ""
                echo "A desktop entry with the filename \"$fileName\" already exists"
                echo "Enter [y] to replace or [n] to save with new filename"
                read choice
                case "$choice" in
                y | Y)
                    filename="$filename"
                    ;;
                n | N)
                    echo ""
                    echo -n "Enter new filename (without extension): "
                    read newFilename
                    until [ -n "$newFilename" ]; do
                        echo "Filename cannot be blank"
                        echo -n "Please try again: "
                        read newFilename
                    done
                    fileName=$(tr -s ' ' '-' <<<$newFilename)
                    ;;
                *)
                    echo "Unknown response \"$choice\""
                    echo "Terminating script..."
                    rm -f "$tempFile"
                    exit 1
                    ;;
                esac
            done
            mv "$tempFile" "/usr/share/applications/$fileName.desktop"
        else
            echo ""
            echo "Error: \"$absolutePath\" is not an executable file"
            echo "Terminating script..."
            rm -f "$tempFile"
            exit 1
        fi
    else
        echo ""
        echo "Error: \"$absolutePath\" is a directory"
        echo "Terminating script..."
        rm -f "$tempFile"
        exit 1
    fi
else
    echo ""
    echo "Error: \"$absolutePath\": No such file or directory"
    echo "Terminating script..."
    rm -f "$tempFile"
    exit 1
fi

echo ""
if [ ! -z "$newFilename" ]; then
    echo "$newFilename.desktop file has been created is  /usr/share/applications  directory"
else
    echo "$fileName.desktop file has been created in  /usr/share/applications  directory"
fi
echo "You can modify this file to add new options"
