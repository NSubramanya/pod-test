# Description

This pod simplifies the implementation of barcode scanner. It supports scanning of EAN-8, EAN-13, code38, code128, QRCode and DataMatrix barcode types.

# How To Get Started

- Clone [CML_SCAN](https://sources.clasp-infra.com/tfs/DefaultCollection/Mobile/CML/_git/CML_SCAN) and try out the included iOS example app written in Swift.
- Check out the [documentation](https://sources.clasp-infra.com/tfs/DefaultCollection/Mobile/CML/_git/CML_SCAN?path=%2FREADME.md&version=GBmaster&_a=contents) for a comprehensive look at all of the methods available in CML_SCAN.

# Communication

- If you need help or like to ask a general question, write an email to sukhjeetsingh.s@solcen.in or subramanya.n@solcen.in.

- If you found a bug, and can provide steps to reliably reproduce it, open an issue on [JIRA](https://jasmin.clasp-infra.com/jira/issues/?jql=project%20%3D%20CML).

- If you have a feature request, open an issue on [JIRA](https://jasmin.clasp-infra.com/jira/issues/?jql=project%20%3D%20CML).

# Installation with CocoaPods

CocoaPods is a dependency manager for Objective-C and Swift, which automates and simplifies the process of using 3rd-party libraries like CML_SCAN in your projects. You can install it with the following command:
```
$ sudo gem install cocoapods
```

### Podfile

To integrate CML_SCAN into your Xcode project using CocoaPods, specify it in your Podfile:

```
platform :ios, '8.0'
target 'TargetName' do
  use_frameworks!
  pod 'CML_SCAN', git: "https://sources.clasp-infra.com/tfs/DefaultCollection/Mobile/CML/_git/CML_SCAN"

end
```

Then, run the following command:
```
$ pod install
```

# Requirements

- iOS 8.0+
- Xcode 8.0+
- Swift 3.0+

# Features

- Start Scanning with supported barcode types.
- Get barcode value back.
- Turn vibration on or off.
- Switch camera.

# Usage

### Start Scanning with supported barcode types

In order to start scanning for selected barcodes, you have to provide an array containing the enum(declared in ScanView) values of the barcode types that you want to support as a parameter to the `startScanning` method.

```
let types = [Types.qrCode, Types.code128, Types.code39, Types.ean13, Types.ean8, Types.dataMatrix]
        cameraView.startScanning(with: types) { error in
            if let error = error {
                // do something with error
            }
        }
```

### Get barcode value back

In order to get the barcode value back, you are supposed to confirm to the protocol `BarcodeScannerDelegate` and implement the function `didRecieveBarcode(barcode: String?, barcodeType: String?)`. If the values of `barcode` and `barcodeType` are nil, you can present an alert to the user informing that the barcode not found.

```
func didReceiveBarcode(barcode: String?, barcodeType: String?) {
        if let barcode = barcode,
        let barcodeType = barcodeType {
            // do something with the value.
        } else {
            // present an alert informing that barcode was not found.
        }
    }
```

### Turn vibration on or off

In order to turn the vibration on or off, you have to call `should(vibrate beTurnedOn: Bool)` method. By default, the vibration is turned on which can be felt on a successful scan.

```
cameraView.should(vibrate: false)
```

### Switch camera

In order to switch Camera front to back or vice versa, call `switchCamera` method of `ScanView`. By default, it will open back camera.

```
cameraView.switchCamera()
```

# Credits
CML_SCAN is owned and maintained by Chanel.
CML_SCAN was originally created by Sukhjeet Singh Sandhu and Subramanya Nagraj.

# Security Disclosure

If you believe you have identified a security vulnerability with CML_SCAN, you should report it as soon as possible to XXXXXXX. Please do not post it to a public issue tracker.

# License

CML_SCAN is released under the Chanel license. See [LICENSE](https://sources.clasp-infra.com/tfs/DefaultCollection/Mobile/CML/_git/CML_SCAN?path=%2FLicense.md&version=GBmaster&_a=contents) for details.
