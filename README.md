![Eterna Chat](/Login/Logox180.png?raw=true "Eterna Chat Icon")
# eternachat
Eterna Chat iOS app

This is the client-side app, written in Objective C for iPhone devices, that allows Eterna users to connect to their community via chat while on the go.

Please refer to notes from **eternacon2016** for more detailed information.

### Installation

To install the app, you can search for it on the Apple iTunes store. Alternatively you can also build/make it from the source code provided here. To do this, you'll need a computer running OS X El Capitan (10.11.5) as well as Xcode 7.3.1+. After downloading the source code you can open the app in xcode by double clicking on the **Eterna Chat.xcworkspace** file, **not** the *.xcodeproj* file. Then click Build -> Run and you should be able to run the app on the simulator. The app should look like the screenshot below.

![Eterna Chat App](/Screenshots/1.png?raw=true "Eterna Chat App")

### Code structure

First off, note that all the main source code goes in the **Login/** folder, `.xib` files are UI design files for Interface Builder, `.h` files are header files for classes, and `.m` files are their class implementations. All code is written in Objective-C.

1. AppDelegate - Class that handles overall application behavior (delegates actions/events)
2. BaseViewController - Controls behavior for the tab view
3. HomeViewController - Controls behavior for the chat window
4. LoginViewController - Controls behavior for the login window
5. ColorViewController - Controls behavior for the color chooser window

### Contributing

All contributions are welcome to this app! Some features that we're still working on and would like to add include the following:

1. notifications
2. android support
3. viewing puzzle screenshots directly in the app
4. ignoring players
5. private message support
6. IRC commands
7. channel/room support

It would also be nice to rewrite the app in Swift and make it cleaner to better support IRC commands, but that's for the future.

### Contact/support

```
mail: vineetsk1 [at] gmail [period] com
eterna: vineetkosaraju
```
