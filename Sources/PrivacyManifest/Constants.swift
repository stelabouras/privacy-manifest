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

enum RequiredReasonKey: CaseIterable {
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
    "AppAuth": .THIRD_PARTY_SDK_KEY,
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
    "FBSDKCoreKit": .THIRD_PARTY_SDK_KEY,
    "FBSDKCoreKit_Basics": .THIRD_PARTY_SDK_KEY,
    "FBSDKLoginKit": .THIRD_PARTY_SDK_KEY,
    "FBSDKShareKit": .THIRD_PARTY_SDK_KEY,
    "file_picker": .THIRD_PARTY_SDK_KEY,
    "FirebaseABTesting": .THIRD_PARTY_SDK_KEY,
    "FirebaseAuth": .THIRD_PARTY_SDK_KEY,
    "FirebaseCore": .THIRD_PARTY_SDK_KEY,
    "FirebaseCoreDiagnostics": .THIRD_PARTY_SDK_KEY,
    "FirebaseCoreExtension": .THIRD_PARTY_SDK_KEY,
    "FirebaseCoreInternal": .THIRD_PARTY_SDK_KEY,
    "FirebaseCrashlytics": .THIRD_PARTY_SDK_KEY,
    "FirebaseDynamicLinks": .THIRD_PARTY_SDK_KEY,
    "FirebaseFirestore": .THIRD_PARTY_SDK_KEY,
    "FirebaseInstallations": .THIRD_PARTY_SDK_KEY,
    "FirebaseMessaging": .THIRD_PARTY_SDK_KEY,
    "FirebaseRemoteConfig": .THIRD_PARTY_SDK_KEY,
    "Flutter": .THIRD_PARTY_SDK_KEY,
    "flutter_inappwebview": .THIRD_PARTY_SDK_KEY,
    "flutter_local_notifications": .THIRD_PARTY_SDK_KEY,
    "fluttertoast": .THIRD_PARTY_SDK_KEY,
    "FMDB": .THIRD_PARTY_SDK_KEY,
    "geolocator_apple": .THIRD_PARTY_SDK_KEY,
    "GoogleDataTransport": .THIRD_PARTY_SDK_KEY,
    "GoogleSignIn": .THIRD_PARTY_SDK_KEY,
    "GoogleToolboxForMac": .THIRD_PARTY_SDK_KEY,
    "GoogleUtilities": .THIRD_PARTY_SDK_KEY,
    "grpcpp": .THIRD_PARTY_SDK_KEY,
    "GTMAppAuth": .THIRD_PARTY_SDK_KEY,
    "GTMSessionFetcher": .THIRD_PARTY_SDK_KEY,
    "hermes": .THIRD_PARTY_SDK_KEY,
    "image_picker_ios": .THIRD_PARTY_SDK_KEY,
    "IQKeyboardManager": .THIRD_PARTY_SDK_KEY,
    "IQKeyboardManagerSwift": .THIRD_PARTY_SDK_KEY,
    "Kingfisher": .THIRD_PARTY_SDK_KEY,
    "leveldb": .THIRD_PARTY_SDK_KEY,
    "Lottie": .THIRD_PARTY_SDK_KEY,
    "MBProgressHUD": .THIRD_PARTY_SDK_KEY,
    "nanopb": .THIRD_PARTY_SDK_KEY,
    "OneSignal": .THIRD_PARTY_SDK_KEY,
    "OneSignalCore": .THIRD_PARTY_SDK_KEY,
    "OneSignalExtension": .THIRD_PARTY_SDK_KEY,
    "OneSignalOutcomes": .THIRD_PARTY_SDK_KEY,
    "OpenSSL": .THIRD_PARTY_SDK_KEY,
    "OrderedSet": .THIRD_PARTY_SDK_KEY,
    "package_info": .THIRD_PARTY_SDK_KEY,
    "package_info_plus": .THIRD_PARTY_SDK_KEY,
    "path_provider": .THIRD_PARTY_SDK_KEY,
    "path_provider_ios": .THIRD_PARTY_SDK_KEY,
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
    "url_launcher": .THIRD_PARTY_SDK_KEY,
    "url_launcher_ios": .THIRD_PARTY_SDK_KEY,
    "video_player_avfoundation": .THIRD_PARTY_SDK_KEY,
    "wakelock": .THIRD_PARTY_SDK_KEY,
    "webview_flutter_wkwebview": .THIRD_PARTY_SDK_KEY
]
