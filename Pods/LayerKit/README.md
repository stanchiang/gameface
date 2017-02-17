# Layer iOS Releases

This repository contains binary distributions of iOS products released by [Layer](http://layer.com).

If you have any questions, comments, or issues related to any products distributed via this repository then please contact the team by emailing [support@layer.com](mailto:support@layer.com). Questions about pricing or product roadmap can be directed to [growth@layer.com](mailto:growth@layer.com).

## LayerKit

LayerKit is the iOS SDK for interacting with the Layer communications cloud. It provides a simple, object oriented interface to the rich messaging capabilities provided by the platform.

In order to use LayerKit you must be a registered developer with a provisioned application identifier and have configured a backend system to act as an identity provider for your client applications. All aspects of this setup are covered in detail in the [Layer iOS Documentation](https://docs.layer.com/sdk/ios/install).

### Installation

LayerKit can be installed directly into your application by importing a framework or via CocoaPods. Quick installation instructions are provided below for reference, but please refer to the [Layer iOS Documentation](https://docs.layer.com/sdk/ios/install) for full details and troubleshooting.

#### CocoaPods Installation

The recommended path for installation is [CocoaPods](http://cocoapods.org/). CocoaPods provides a simple, versioned dependency management system that automates the tedious and error prone aspects of manually configuring libraries and frameworks. You can add LayerKit to your project via CocoaPods by doing the following:

```sh
$ sudo gem install cocoapods
$ pod setup
```

Now create a `Podfile` in the root of your project directory and add the following:

```ruby
pod 'LayerKit'
```

Complete the installation by executing:

```sh
$ pod install
```

These instructions will setup your local CocoaPods environment and import LayerKit into your project. Once this has completed, test your installation by referring to the [Verifying LayerKit Configuration](#verifying-layerkit-configuration) section below.

#### Framework Installation

If you wish to install LayerKit directly into your application via the binary framework, then you have a choice between two distributions:

* `LayerKit.framework` - This build artifact is a dynamic framework that is compatible with Objective-C and Swift projects that target **iOS 8** and higher.
* `LayerKit.embeddedframework` - This build artifact is a pseudo-framework that contains a static library asset and a set of public header files. It is compatible with Objective-C projects that target **iOS 7** and higher.

Download the appropriate build artifact from this repository and add it to your application:

1. Drag and drop the framework onto your project, instructing Xcode to copy items into your destination group's folder.
2. Update your project settings to include the linker flags: `-ObjC -lz`
3. Add the following Cocoa SDK frameworks to your project: `'CFNetwork', 'Security', 'MobileCoreServices', 'SystemConfiguration', 'libsqlite3.tbd'`
4. *LayerKit.framework only*: The dynamic framework distribution requires the configuration of additional build phases to complete installation. The steps are detailed on the [Layer Knowledge Base](https://support.layer.com/hc/en-us/articles/204256740-Can-I-use-LayerKit-without-CocoaPods-).

Build and run your project to verify installation was successful. Once you have completed a successful build, refer to the [Verifying LayerKit Configuration](#verifying-layerkit-configuration) section below for details on how to test your setup.

### Verifying LayerKit Configuration

Once you have finished installing LayerKit via CocoaPods or framework, you can test your configuration by importing the headers and connecting a client to the Layer cloud. To do so, edit your application delegate to include the code below (note that you must substitute the app ID placeholder text with your actual app identifier):

```objc
#import <LayerKit/LayerKit.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSURL *appID = [NSURL URLWithString:@"INSERT-APPID-URL-HERE"];
	LYRClient *layerClient = [LYRClient clientWithAppID:appID];
	[layerClient connectWithCompletion:^(BOOL success, NSError *error) {
		if (success) {
			NSLog(@"Sucessfully connected to Layer!");
		} else {
			NSLog(@"Failed connection to Layer with error: %@", error);
		}
	}];
}
```

Launch your application and verify that the connection is successful. You are now ready to begin authenticating clients and sending messages. Please refer to the [Layer iOS Documentation](https://docs.layer.com/sdk/ios/install) for details.

## Contact

You can reach the Layer team at any time by emailing [support@layer.com](mailto:support@layer.com).

## License

LayerKit is licensed under the [Layer SDK License](https://github.com/layerhq/releases-ios/LICENSE.md).
