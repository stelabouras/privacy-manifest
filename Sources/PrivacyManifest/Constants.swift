//
//  Constants.swift
//
//
//  Created by Stelios Petrakis on 14/4/24.
//

import Foundation

struct CliSyntaxColor {
    static let WHITE_BOLD = "\u{001B}[0;1m"
    static let RED = "\u{001B}[0;0;31m"
    static let GREEN = "\u{001B}[0;32m"
    static let YELLOW = "\u{001B}[0;33m"
    static let BLUE = "\u{001B}[0;34m"
    static let MAGENTA = "\u{001B}[0;35m"
    static let CYAN = "\u{001B}[0;36m"
    static let PINK = "\u{001B}[0;91m"
    static let GREEN_BRIGHT = "\u{001B}[0;92m"
    static let YELLOW_BRIGHT = "\u{001B}[0;93m"
    static let BLUE_BRIGHT = "\u{001B}[0;94m"
    static let MAGENTA_BRIGHT = "\u{001B}[0;95m"
    static let CYAN_BRIGHT = "\u{001B}[0;96m"
    static let END = "\u{001B}[0;0m"
}

let PACKAGE_SWIFT_FILENAME = "Package.swift"
let XCODE_PROJECT_PATH_EXTENSION = "xcodeproj"
let XCODE_WORKSPACE_PATH_EXTENSION = "xcworkspace"

enum RequiredReasonKey: CaseIterable, Comparable {
    case FILE_TIMESTAMP_APIS_KEY
    case SYSTEM_BOOT_APIS_KEY
    case DISK_SPACE_APIS_KEY
    case ACTIVE_KEYBOARD_APIS_KEY
    case USER_DEFAULTS_APIS_KEY
    case CORELOCATION_FRAMEWORK_KEY
    case HEALTHKIT_FRAMEWORK_KEY
    case CRASH_FRAMEWORK_KEY
    case CONTACTS_FRAMEWORK_KEY
    case THIRD_PARTY_SDK_KEY
    
    var description: String {
        switch self {
        case .FILE_TIMESTAMP_APIS_KEY:
            return "File Timestamp APIs"
        case .SYSTEM_BOOT_APIS_KEY:
            return "System boot time APIs"
        case .DISK_SPACE_APIS_KEY:
            return "Disk space APIs"
        case .ACTIVE_KEYBOARD_APIS_KEY:
            return "Active keyboard APIs"
        case .USER_DEFAULTS_APIS_KEY:
            return "User defaults APIs"
        case .CORELOCATION_FRAMEWORK_KEY:
            return "Core Location"
        case .HEALTHKIT_FRAMEWORK_KEY:
            return "HealthKit"
        case .CRASH_FRAMEWORK_KEY:
            return "Crash data"
        case .CONTACTS_FRAMEWORK_KEY:
            return "Contacts"
        case .THIRD_PARTY_SDK_KEY:
            return "Third-party SDKs"
        }
    }

    var privacyManifestKey: String? {
        switch self {
        case .FILE_TIMESTAMP_APIS_KEY:
            return "NSPrivacyAccessedAPICategoryFileTimestamp"
        case .SYSTEM_BOOT_APIS_KEY:
            return "NSPrivacyAccessedAPICategorySystemBootTime"
        case .DISK_SPACE_APIS_KEY:
            return "NSPrivacyAccessedAPICategoryDiskSpace"
        case .ACTIVE_KEYBOARD_APIS_KEY:
            return "NSPrivacyAccessedAPICategoryActiveKeyboards"
        case .USER_DEFAULTS_APIS_KEY:
            return "NSPrivacyAccessedAPICategoryUserDefaults"
        default:
            return nil
        }
    }

    var reasons: [String: String] {
        switch self {
        case .DISK_SPACE_APIS_KEY:
            return [
                "85F4.1" : """
Declare this reason to display disk space information to the
person using the device.
Disk space may be displayed in units of information (such as bytes)
or units of time combined with a media type (such as minutes of HD video).

Information accessed for this reason, or any derived information,
may not be sent off-device. There is an exception that allows the app to
send disk space information over the local network to another device
operated by the same person only for the purpose of displaying disk space
information on that device; this exception only applies if the user has
provided explicit permission to send disk space information,
and the information may not be sent over the Internet.
""",
                "E174.1" : """
Declare this reason to check whether there is sufficient disk space to
write files, or to check whether the disk space is low so that the app can
delete files when the disk space is low. The app must behave differently
based on disk space in a way that is observable to users.

Information accessed for this reason, or any derived information,
may not be sent off-device. There is an exception that allows the app to
avoid downloading files from a server when disk space is insufficient.
""",
                "7D9E.1" : """
Declare this reason to include disk space information in an optional bug
report that the person using the device chooses to submit.
The disk space information must be prominently displayed to the person as
part of the report.

Information accessed for this reason, or any derived information,
may be sent off-device only after the user affirmatively chooses to submit
the specific bug report including disk space information,
and only for the purpose of investigating or responding to the bug report.
""",
                "B728.1" : """
Declare this reason if your app is a health research app, and you access
this API category to detect and inform research participants about low disk
space impacting the research data collection.

Your app must comply with App Store Review Guideline §5.1.3.
Your app must not offer any functionality other than providing information
about and allowing people to participate in health research.
"""
            ]
        case .FILE_TIMESTAMP_APIS_KEY:
            return [
                "DDA9.1" : """
Declare this reason to display file timestamps to the person using the device.

Information accessed for this reason, or any derived information,
may not be sent off-device.
""",
                "C617.1" : """
Declare this reason to access the timestamps, size, or other metadata of files
inside the app container, app group container, or the app’s CloudKit container.
""",
                "3B52.1" : """
Declare this reason to access the timestamps, size, or other metadata of files
or directories that the user specifically granted access to, such as using
a document picker view controller.
""",
                "0A2A.1" : """
Declare this reason if your third-party SDK is providing a wrapper function
around file timestamp API(s) for the app to use, and you only access the
file timestamp APIs when the app calls your wrapper function. This reason may
only be declared by third-party SDKs. This reason may not be declared if your
third-party SDK was created primarily to wrap required reason API(s).

Information accessed for this reason, or any derived information, 
may not be used for your third-party SDK’s own purposes or sent off-device
by your third-party SDK.
"""
            ]
        case .SYSTEM_BOOT_APIS_KEY:
            return [
                "35F9.1" : """
Declare this reason to access the system boot time in order to measure the
amount of time that has elapsed between events that occurred within the app
or to perform calculations to enable timers.

Information accessed for this reason, or any derived information,
may not be sent off-device. There is an exception for information about the
amount of time that has elapsed between events that occurred within the app,
which may be sent off-device.
""",
                "8FFB.1" : """
Declare this reason to access the system boot time to calculate absolute
timestamps for events that occurred within your app, such as events related
to the UIKit or AVFAudio frameworks.

Absolute timestamps for events that occurred within your app may be sent
off-device. System boot time accessed for this reason, or any other information
derived from system boot time, may not be sent off-device.
""",
                "3D61.1" : """
Declare this reason to include system boot time information in an optional
bug report that the person using the device chooses to submit.
The system boot time information must be prominently displayed to the person
as part of the report.

Information accessed for this reason, or any derived information,
may be sent off-device only after the user affirmatively chooses to submit
the specific bug report including system boot time information,
and only for the purpose of investigating or responding to the bug report.
"""
            ]
        case .ACTIVE_KEYBOARD_APIS_KEY:
            return [
                "3EC4.1" : """
Declare this reason if your app is a custom keyboard app, and you access
this API category to determine the keyboards that are active on the device.

Providing a systemwide custom keyboard to the user must be the primary
functionality of the app.

Information accessed for this reason, or any derived information,
may not be sent off-device.
""",
                "54BD.1" : """
Declare this reason to access active keyboard information to present
the correct customized user interface to the person using the device.
The app must have text fields for entering or editing text and must behave
differently based on active keyboards in a way that is observable to users.

Information accessed for this reason, or any derived information,
may not be sent off-device.
"""
            ]
        case .USER_DEFAULTS_APIS_KEY:
            return [
                "CA92.1" : """
Declare this reason to access user defaults to read and write information
that is only accessible to the app itself.

This reason does not permit reading information that was written by
other apps or the system, or writing information that can be accessed by
other apps.
""",
                "1C8F.1" : """
Declare this reason to access user defaults to read and write information
that is only accessible to the apps, app extensions, and App Clips that
are members of the same App Group as the app itself.

This reason does not permit reading information that was written by apps,
app extensions, or App Clips outside the same App Group or by the system.
Your app is not responsible if the system provides information from the
global domain because a key is not present in your requested domain while
your app is attempting to read information that apps, app extensions,
or App Clips in your app’s App Group write.

This reason also does not permit writing information that can be accessed
by apps, app extensions, or App Clips outside the same App Group.
""",
                "C56D.1" : """
Declare this reason if your third-party SDK is providing a wrapper function
around user defaults API(s) for the app to use, and you only access the
user defaults APIs when the app calls your wrapper function.
This reason may only be declared by third-party SDKs.
This reason may not be declared if your third-party SDK was created primarily
to wrap required reason API(s).

Information accessed for this reason, or any derived information,
may not be used for your third-party SDK’s own purposes or sent off-device
by your third-party SDK.
""",
                "AC6B.1" : """
Declare this reason to access user defaults to read the
com.apple.configuration.managed key to retrieve the managed app configuration
set by MDM, or to set the com.apple.feedback.managed key to store
feedback information to be queried over MDM, as described in the
Apple Mobile Device Management Protocol Reference documentation.
"""
            ]
        case .CORELOCATION_FRAMEWORK_KEY:
            return [:] // TODO
        case .HEALTHKIT_FRAMEWORK_KEY:
            return [:] // TODO
        case .CRASH_FRAMEWORK_KEY:
            return [:] // TODO
        case .CONTACTS_FRAMEWORK_KEY:
            return [:] // TODO
        case .THIRD_PARTY_SDK_KEY:
            return [
                "reason" : """
\(CliSyntaxColor.BLUE_BRIGHT)
ℹ---------------------------------------------------------------------------------+
| You must include the privacy manifest for any of the above SDKs when you submit |
| new apps in App Store Connect that include those SDKs, or when you submit an    |
| app update that adds one of the listed SDKs as part of the update.              |
| Signatures are also required in these cases where the listed SDKs are used      |
| as binary dependencies. Any version of a listed SDK, as well as any SDKs that   |
| repackage those on the list, are included in the requirement.                   |
+---------------------------------------------------------------------------------+
\(CliSyntaxColor.END)
"""]
        }
    }

    var link: String {
        switch self {
        case .FILE_TIMESTAMP_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278393"
        case .SYSTEM_BOOT_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278394"
        case .DISK_SPACE_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278397"
        case .ACTIVE_KEYBOARD_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278400"
        case .USER_DEFAULTS_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278401"
        case .CORELOCATION_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263133"
        case .HEALTHKIT_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263132"
        case .CRASH_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263159"
        case .CONTACTS_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263130"
        case .THIRD_PARTY_SDK_KEY:
            return "https://developer.apple.com/support/third-party-SDK-requirements/"
        }
    }
}

let ALLOWED_EXTENSIONS = [
    "m",    // Objective-C
    "mm",   // Objective-C++
    "c",    // C
    "cpp",  // C++
    "swift" // Swift
]

// Look through the code for the listed strings (Case Sensitive)
let APIS_TO_CHECK: [String: [RequiredReasonKey]] = [
    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
    "creationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "modificationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "fileModificationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "contentModificationDateKey": [.FILE_TIMESTAMP_APIS_KEY],
    "creationDateKey": [.FILE_TIMESTAMP_APIS_KEY],
    "getattrlist(": [.FILE_TIMESTAMP_APIS_KEY, .DISK_SPACE_APIS_KEY], // also covers: fgetattrlist(
    "getattrlistbulk(": [.FILE_TIMESTAMP_APIS_KEY],
    "fstat(": [.FILE_TIMESTAMP_APIS_KEY],
    "fstatat(": [.FILE_TIMESTAMP_APIS_KEY],
    "lstat(": [.FILE_TIMESTAMP_APIS_KEY],
    "getattrlistat(": [.FILE_TIMESTAMP_APIS_KEY, .DISK_SPACE_APIS_KEY],
    "systemUptime": [.SYSTEM_BOOT_APIS_KEY],
    "mach_absolute_time(": [.SYSTEM_BOOT_APIS_KEY],

    "volumeAvailableCapacityKey": [.DISK_SPACE_APIS_KEY],
    "volumeAvailableCapacityForImportantUsageKey": [.DISK_SPACE_APIS_KEY],
    "volumeAvailableCapacityForOpportunisticUsageKey": [.DISK_SPACE_APIS_KEY],
    "volumeTotalCapacityKey": [.DISK_SPACE_APIS_KEY],
    "systemFreeSize": [.DISK_SPACE_APIS_KEY],
    "systemSize": [.DISK_SPACE_APIS_KEY],
    "statfs(": [.DISK_SPACE_APIS_KEY], // also covers: fstatfs(
    "statvfs(": [.DISK_SPACE_APIS_KEY], // also covers: fstatvfs(

    "activeInputModes": [.ACTIVE_KEYBOARD_APIS_KEY],

    "UserDefaults": [.USER_DEFAULTS_APIS_KEY],

    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests
    "import CoreLocation": [.CORELOCATION_FRAMEWORK_KEY],
    "#import <CoreLocation/CoreLocation.h>": [.CORELOCATION_FRAMEWORK_KEY],

    "import HealthKit": [.HEALTHKIT_FRAMEWORK_KEY],
    "#import <HealthKit/HealthKit.h>": [.HEALTHKIT_FRAMEWORK_KEY],
    "#import <HealthKitUI/HealthKitUI.h>": [.HEALTHKIT_FRAMEWORK_KEY],

    "import Sentry": [.CRASH_FRAMEWORK_KEY],
    "#import <Sentry/Sentry.h>": [.CRASH_FRAMEWORK_KEY],
    "import Instabug": [.CRASH_FRAMEWORK_KEY],
    "#import <Instabug/Instabug.h>": [.CRASH_FRAMEWORK_KEY],
    "#import \"Countly.h\"": [.CRASH_FRAMEWORK_KEY],
    "import Bugsnag": [.CRASH_FRAMEWORK_KEY],
    "#import <Bugsnag/Bugsnag.h>": [.CRASH_FRAMEWORK_KEY],
    "#import <Firebase": [.CRASH_FRAMEWORK_KEY],
    "import Firebase": [.CRASH_FRAMEWORK_KEY],
    // TODO: Add more third-party crash frameworks here

    "import Contacts": [.CONTACTS_FRAMEWORK_KEY],
    "#import <ContactsUI/ContactsUI.h>": [.CONTACTS_FRAMEWORK_KEY],
    "#import <Contacts/Contacts.h>": [.CONTACTS_FRAMEWORK_KEY]
]

// Look through the Frameworks Build Phase or Package Dependencies for the
// listed strings (Case Insensitive)
let SDKS_TO_CHECK: [String: RequiredReasonKey] = [
    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests
    "sentry-cocoa": .CRASH_FRAMEWORK_KEY,
    "Sentry": .CRASH_FRAMEWORK_KEY,
    "Instabug": .CRASH_FRAMEWORK_KEY,
    "countly": .CRASH_FRAMEWORK_KEY,
    "Bugsnag": .CRASH_FRAMEWORK_KEY,
    "firebase": .CRASH_FRAMEWORK_KEY,
    // TODO: Add more third-party crash frameworks here

    "CoreLocation": .CORELOCATION_FRAMEWORK_KEY,
    "HealthKit": .HEALTHKIT_FRAMEWORK_KEY,
    "Contacts": .CONTACTS_FRAMEWORK_KEY, // also covers ContactsUI

    // Ref: https://developer.apple.com/support/third-party-SDK-requirements/
    "Abseil": .THIRD_PARTY_SDK_KEY,
    "AFNetworking": .THIRD_PARTY_SDK_KEY,
    "Alamofire": .THIRD_PARTY_SDK_KEY,
    "AppAuth": .THIRD_PARTY_SDK_KEY, // also covers: GTMAppAuth
    "BoringSSL": .THIRD_PARTY_SDK_KEY,
    "openssl_grpc": .THIRD_PARTY_SDK_KEY,
    "Capacitor": .THIRD_PARTY_SDK_KEY,
    "Charts": .THIRD_PARTY_SDK_KEY,
    "connectivity_plus": .THIRD_PARTY_SDK_KEY,
    "Cordova": .THIRD_PARTY_SDK_KEY,
    "device_info_plus": .THIRD_PARTY_SDK_KEY,
    "DKImagePickerController": .THIRD_PARTY_SDK_KEY,
    "DKPhotoGallery": .THIRD_PARTY_SDK_KEY,
    "FBAEMKit": .THIRD_PARTY_SDK_KEY,
    "FBLPromises": .THIRD_PARTY_SDK_KEY,
    "FBSDKCoreKit": .THIRD_PARTY_SDK_KEY, // also covers: FBSDKCoreKit_Basics
    "FBSDKLoginKit": .THIRD_PARTY_SDK_KEY,
    "FBSDKShareKit": .THIRD_PARTY_SDK_KEY,
    "file_picker": .THIRD_PARTY_SDK_KEY,
    "FirebaseABTesting": .THIRD_PARTY_SDK_KEY,
    "FirebaseAuth": .THIRD_PARTY_SDK_KEY,
    "FirebaseCore": .THIRD_PARTY_SDK_KEY, // also covers: FirebaseCoreDiagnostics, FirebaseCoreExtension, FirebaseCoreInternal
    "FirebaseCrashlytics": .THIRD_PARTY_SDK_KEY,
    "FirebaseDynamicLinks": .THIRD_PARTY_SDK_KEY,
    "FirebaseFirestore": .THIRD_PARTY_SDK_KEY,
    "FirebaseInstallations": .THIRD_PARTY_SDK_KEY,
    "FirebaseMessaging": .THIRD_PARTY_SDK_KEY,
    "FirebaseRemoteConfig": .THIRD_PARTY_SDK_KEY,
    "Flutter": .THIRD_PARTY_SDK_KEY, // also covers: flutter_inappwebview, flutter_local_notifications, fluttertoast
    "FMDB": .THIRD_PARTY_SDK_KEY,
    "geolocator_apple": .THIRD_PARTY_SDK_KEY,
    "GoogleDataTransport": .THIRD_PARTY_SDK_KEY,
    "GoogleSignIn": .THIRD_PARTY_SDK_KEY,
    "GoogleToolboxForMac": .THIRD_PARTY_SDK_KEY,
    "GoogleUtilities": .THIRD_PARTY_SDK_KEY,
    "grpcpp": .THIRD_PARTY_SDK_KEY,
    "GTMSessionFetcher": .THIRD_PARTY_SDK_KEY,
    "hermes": .THIRD_PARTY_SDK_KEY,
    "image_picker_ios": .THIRD_PARTY_SDK_KEY,
    "IQKeyboardManager": .THIRD_PARTY_SDK_KEY, // also covers: IQKeyboardManagerSwift
    "Kingfisher": .THIRD_PARTY_SDK_KEY,
    "leveldb": .THIRD_PARTY_SDK_KEY,
    "Lottie": .THIRD_PARTY_SDK_KEY,
    "MBProgressHUD": .THIRD_PARTY_SDK_KEY,
    "nanopb": .THIRD_PARTY_SDK_KEY,
    "OneSignal": .THIRD_PARTY_SDK_KEY, // also covers: OneSignalCore, OneSignalExtension, OneSignalOutcomes
    "OpenSSL": .THIRD_PARTY_SDK_KEY,
    "OrderedSet": .THIRD_PARTY_SDK_KEY,
    "package_info": .THIRD_PARTY_SDK_KEY, // also covers: package_info_plus
    "path_provider": .THIRD_PARTY_SDK_KEY, // also covers: path_provider_ios
    "Promises": .THIRD_PARTY_SDK_KEY,
    "Protobuf": .THIRD_PARTY_SDK_KEY,
    "Reachability": .THIRD_PARTY_SDK_KEY,
    "RealmSwift": .THIRD_PARTY_SDK_KEY,
    "RxCocoa": .THIRD_PARTY_SDK_KEY,
    "RxRelay": .THIRD_PARTY_SDK_KEY,
    "RxSwift": .THIRD_PARTY_SDK_KEY,
    "SDWebImage": .THIRD_PARTY_SDK_KEY,
    "share_plus": .THIRD_PARTY_SDK_KEY,
    "shared_preferences_ios": .THIRD_PARTY_SDK_KEY,
    "SnapKit": .THIRD_PARTY_SDK_KEY,
    "sqflite": .THIRD_PARTY_SDK_KEY,
    "Starscream": .THIRD_PARTY_SDK_KEY,
    "SVProgressHUD": .THIRD_PARTY_SDK_KEY,
    "SwiftyGif": .THIRD_PARTY_SDK_KEY,
    "SwiftyJSON": .THIRD_PARTY_SDK_KEY,
    "Toast": .THIRD_PARTY_SDK_KEY,
    "UnityFramework": .THIRD_PARTY_SDK_KEY,
    "url_launcher": .THIRD_PARTY_SDK_KEY, // also covers: url_launcher_ios
    "video_player_avfoundation": .THIRD_PARTY_SDK_KEY,
    "wakelock": .THIRD_PARTY_SDK_KEY,
    "webview_flutter_wkwebview": .THIRD_PARTY_SDK_KEY
]
