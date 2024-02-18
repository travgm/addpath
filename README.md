# addpath

A small x86_64 utility that when ran from a directory adds that current directory to the System path.

After it adds the directory to the path it opens the system environment variables dialog to verify the changes.

# requirements
- x86_64
- Tested on Windows 11 Pro
- If you want to build from source you will need fasmg

# building
Assuming you have added the root of fasmg to your system path. Just run:

`.\build.bat`

and it will build with the right headers. If you dont't want to build it you can download the executable from the [releases](https://github.com/travgm/addpath/releases/tag/1.0) section.

# running
Drop addpath.exe in whatever directory you want added to the system path and then run it! 

*Note: You must run it as a user with administrative rights. You can right-click->Run as Administrator if needed.*


 
