Drift
============
[![CocoaPods](https://img.shields.io/cocoapods/v/Drift.svg)](https://github.com/Driftt/drift-sdk-ios)

DriftSDK is the official Drift SDK written in Swift enabling you to both send announcements and collect vital NPS responses all within the app!


# Features:
- Send NPS to your customers
- Send Product announcements to your customers
- Create conversations from your app
- View past conversations from your app.


# Getting Setup

## Installation
DriftSDK can be added to your project using CocoaPods by adding the following line to your `Podfile`:

```ruby
pod 'Drift-SDK', '~> 1.0.0'
```

## Registering

To get started with the Drift iOS SDK you need an embed ID from your Drift settings page. This can be accessed [here](https://app.driftt.com/settings)

In your AppDelegate `didFinishLaunchingWithOptions` call:
```Swift
  Drift.setup("")
```

or in ObjC
```objectivec
  [Drift setup:@""];
```

Once your user has successfully logged into the app registering a user with the device is done by calling register user with a unique identifier, typically the id from your database, and their email address:

```Swift
  Drift.registerUser("", email: "")
```
or in ObjC
```objectivec
  [Drift registerUser:@"" email:@""];
```

When your user logs out simply call logout so they stop receiving campaigns.

```Swift
  Drift.logout()
```

or in ObjC

```objectivec
  [Drift logout];
```

Thats it. Your good to go!!

# Messaging

A user can begin a conversation in response to a campaign or by presenting the conversations list

```Swift
  Drift.showConversations()
```

or in ObjC

```objectivec
  [Drift showConversations];
```

Thats it. Your good to go!!


# Contributing

Contributions are very welcome 🤘.
