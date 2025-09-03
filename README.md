# Video Player Demo

This is an iOS app built with SwiftUI, AVPlayer, and Combine.

The selected architecture is MVVM. A network manager has been included, which relies on an abstraction, with the goal of creating a real-world implementation, as well as mock implementations that are used for testing and previews within Xcode. Network calls are automatically cached, so the app can run offline.

The network manager includes only one get call to consume endpoints with abstract parameters to avoid multiple implementations. It also includes functions for downloading files. Downloads are monitored from the viewmodel layer by subscribing to available publishers in the network manager. This way, the download progress can be monitored and error alerts displayed if necessary.

The video playback screen includes logic that detects if the video has already been downloaded and plays it from a local file, allowing videos to be viewed offline.

Unit tests have been included that check logic in the different view models.

**Building the project**

The project has no external dependencies, so to build it you just need to open it with Xcode and run the project (⌘R).