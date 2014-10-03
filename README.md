SuperLachaise
=============

An iOS application for navigating the Père-Lachaise Cemetery in Paris

Installation
------------

Required : Xcode, git, python

 * Open the directory where you want to download the project in a terminal window.
 * Use git to clone the project :
    git clone https://github.com/MaximeLM/SuperLachaise.git
 * Download the submodules :
    cd SuperLachaise
    git submodule update --init --recursive
 * Duplicate and rename the folder PereLachaise/Resources/glyphicons-sample :
    cp -r PereLachaise/Resources/glyphicons-sample PereLachaise/Resources/glyphicons
 * Run the script download_images_commons_iphone.sh to download the required pictures from Wikimedia Commons :
    PereLachaise/Resources/download_images_commons_iphone.sh
 * Double-click on PereLachaise.xcodeproj to open the project in Xcode.
