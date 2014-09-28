SuperLachaise
=============

An iOS application for navigating the Père-Lachaise Cemetery in Paris

Installation
------------

Required : Xcode, git, python

 * Create a directory where you want to download the project. You can name it SuperLachaise.
 * Open that directory in a terminal window.
 * Use git to clone the project :
      git clone MaximeLM@github.com:SuperLachaise .
 * Update git submodules :
      git submodule update --init
 * Duplicate and rename the folder PereLachaise/Images-sample.xcassets :
      cp -r PereLachaise/Images-sample.xcassets PereLachaise/Images.xcassets
 * Duplicate and rename the folder PereLachaise/Resources/glyphicons-sample :
      cp -r PereLachaise/Resources/glyphicons-sample PereLachaise/Resources/glyphicons
 * Run the script download_images_commons_iphone.sh to download the required pictures from Wikimedia Commons :
      PereLachaise/Resources/download_images_commons_iphone.sh
 * Double-click on PereLachaise.xcodeproj to open the project in Xcode.
