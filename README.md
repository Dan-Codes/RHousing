# RHousing

To run the Cribb app, follow these instructions carefully.

1.  Open Terminal.
2.  If you have not installed cocopods —
        — In Terminal, type "sudo gem install cocoapods"
        — This will ask for your computer password. Enter it and let cocoapods fully install.
3.  Make sure your current directory is set to the directory you want to clone the app under.
4.  Enter the following commands:
        — "git clone https://github.com/Dan-Codes/RHousing.git"
        — "cd RHousing/"
        — "pod install"
5.  Open the .xworkspace file inside the RHousing folder.
6.  Ensure that the file GoogleService-Info.plist is not corrupted (i.e. displaying as red text) in the workspace. If it is, there is an additional GoogleService-Info.plist file in the RHousing directory; delete the corrupted instance and replace it with the working file.
7.  Make sure you are in simulator mode, with iPhone XR or XS Max selected. The current version of the app is only optimized to work in these environments. Otherwise, the app will not work properly on any other iPhone model.
8.  Press command + B (or click on the build button in Xcode). The build stage might take a while.
9.  The simulator should appear and you should be able to select and run the Cribb app from the iPhone XR or XS Max home page.
10. When signing up, use a @syr.edu email (works even for made up emails of the form user@syr.edu, for now).

Enjoy our application and please provide feedback on our project!
