Login Image Changer
=========
### for Linux Mint


Login Image Changer lets you automatically change the login background each time your computer starts up. It selects a random image from a target folder and updates your theme's background image, giving you a fresh and exciting new image for your login screen each time!

![Screenshot 1](https://raw.githubusercontent.com/primaryobjects/loginimagechanger/master/screenshots/login1-500x300.png)

![Screenshot 2](https://raw.githubusercontent.com/primaryobjects/loginimagechanger/master/screenshots/login2-500x300.png)

![Screenshot 3](https://raw.githubusercontent.com/primaryobjects/loginimagechanger/master/screenshots/login3-500x300.png)

It's as simple as this:

- Run loginimage.sh.
- Select a folder of images.
- Select the background image for your current login theme.

That's it!

Install
---

1. Download [loginimage.sh](https://raw.githubusercontent.com/primaryobjects/loginimagechanger/master/loginimage.sh) and place it in a folder, such as ~/Documents/login-image-changer.

 ```sh
 cd ~/Documents/login-image-changer
 sudo bash loginimage.sh
 ```

 ![Initial setup screen](https://raw.githubusercontent.com/primaryobjects/loginimagechanger/master/screenshots/screenshot1.png)

2. Select a folder of images.

 ![Select a folder of images](https://raw.githubusercontent.com/primaryobjects/loginimagechanger/master/screenshots/screenshot2.png)

3. Select the background image of your currently installed login theme. This file will be overwritten by Login Image Changer each time your PC starts up. Hint: Login themes are accessible via the Linux "Login Window" app. GDM themes are located in /usr/share/mdm/themes, while HTML themes are located in /usr/share/mdm/html-themes. You must select the background image for your *currently* installed theme, otherwise there will be no effect. Check the "Login Window" app to see which theme you have active. In the screenshot below, /usr/share/mdm/themes/GDewM/bg.png is the background image used in the theme.

 ![Select a background image from the current Login theme](https://raw.githubusercontent.com/primaryobjects/loginimagechanger/master/screenshots/screenshot3.png)

4. It's now installed to run automatically at startup! If you want, you can manually run loginimage.sh to kick off the first random image.
 ```sh
 sudo bash loginimage.sh
 ```

5. Logout or restart your PC to see the changes take effect.

Command Line Arguments
---

-h, --help - Displays help
```sh
sudo bash loginimage.sh -h
```

-r, --run - Run login image changer and change background image
```sh
sudo bash loginimage.sh -r
```

-i, --install - Displays UI to select a new folder and modify settings
```sh
sudo bash loginimage.sh -i
```

-u, --uninstall - Restores a backup of the original theme image, removes the settings folder, removes the auto-run entry from /etc/rc.local
```sh
sudo bash loginimage.sh -u
```

Technical Details
---

Login Image Changer uses Zenity for the user interface. The first time it runs without command line arguments, it checks if the folder exists /usr/share/login-image-changer. If the folder does not exist, the GUI will display, allowing the user to choose options. Upon saving, the folder will be created. The folder contains a settings file and a backup copy of the target theme image to be overwritten.

Saving creates the following auto-run entry in /etc/rc.local (substituting the path of where the script is ran from):
```sh
sudo bash "/home/username/Documents/login-image-changer/loginimage.sh" -r
```
This allows the script to run each time the computer starts up.

If you get tired of the fresh and exciting login background images, you can always uninstall with the -u switch.

Uninstalling cleans up the files by copying the backup image from /usr/share/login-image-changer back into the original theme folder, removing the entry from /etc/rc.local, and removing the settings folder /usr/share/login-image-changer.

The script also restores the backup of the theme image when you use the -i switch to pick a new folder and/or theme. This way, if you change themes (in which case, Login Image Changer will be updating the wrong background image now), you can use the -i switch to run the GUI and select the new theme filename. The prior theme will have its original background image restored and the new theme will now be updated upon each PC startup.

License
----

MIT

Author
----
Kory Becker
http://www.primaryobjects.com/kory-becker.aspx
