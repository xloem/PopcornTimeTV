

import Foundation
import SwiftyJSON
/**
 A manager class that automatically looks for new releases from github and presents them to the user.
 */
public final class UpdateManager: NSObject {
    
    /**
     Determines the frequency in which the the version check is performed.
     
     - .immediately:    Version check performed every time the app is launched.
     - .daily:          Version check performedonce a day.
     - .weekly:         Version check performed once a week.
     */
    public enum CheckType: Int {
        /// Version check performed every time the app is launched.
        case immediately = 0
        /// Version check performed once a day.
        case daily = 1
        /// Version check performed once a week.
        case weekly = 7
    }
    
    /// Current version (CFBundleShortVersionString.CFBundleVersion) of running application.
    private let currentApplicationVersion = "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!).\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)"
    
    /// Designated Initialiser.
    public static let shared = UpdateManager()
    
    /// The version that the user does not want installed. If the user has never clicked "Skip this version" this variable will be `nil`, otherwise it will be the last version that the user opted not to install.
    private var skipReleaseVersion: VersionString? {
        get {
            guard let data = Session.skipReleaseVersion,
                  let version = try? JSONDecoder().decode(VersionString.self, from: data)
            else {
                return nil
            }
            return version
        } set {
            if let newValue = newValue {
                Session.skipReleaseVersion = try? JSONEncoder().encode(newValue)
            } else {
                Session.skipReleaseVersion = nil
            }
        }
    }
    
    /// The date of the last time `checkForUpdates:completion:` was called. If version check was never called, `checkForUpdates:completion:` is called.
    fileprivate var lastVersionCheckPerformedOnDate: Date {
        get {
            return UserDefaults.standard.object(forKey: "lastVersionCheckPerformedOnDate") as? Date ?? {
                checkForUpdates()
                return self.lastVersionCheckPerformedOnDate
                }()
        } set {
            UserDefaults.standard.set(newValue, forKey: "lastVersionCheckPerformedOnDate")
        }
    }
    
    /// Returns the number of days it has been since `checkForUpdates:completion:` has been called.
    private var daysSinceLastVersionCheckDate: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: lastVersionCheckPerformedOnDate, to: Date())
        return components.day!
    }
    
    /**
     Checks github repository for new releases.
     
     - Parameter sucess: Optional callback indicating the status of the operation.
     */
    public func checkVersion(_ checkType: CheckType, completion: ((_ success: Bool) -> Void)? = nil) {
        if checkType == .immediately || checkType.rawValue <= daysSinceLastVersionCheckDate {
            checkForUpdates(completion)
        }
    }
    
    private func checkForUpdates(_ completion: ((_ success: Bool) -> Void)? = nil) {
//        lastVersionCheckPerformedOnDate = Date()
//        Alamofire.request("https://api.github.com/repos/PopcornTimeTV/PopcornTimeTV/releases").validate().responseJSON { (response) in
//            guard let value = response.result.value else { completion?(false); return }
//            let responseObject = JSON(value)
//            let sortedReleases = responseObject.compactMap({VersionString($1["tag_name"].string!, $1["published_at"].string!)}).sorted(by: {$0 > $1})
//
//            if let latestRelease = sortedReleases.first,
//                let currentRelease = sortedReleases.filter({$0.buildNumber == self.currentApplicationVersion}).first,
//                latestRelease > currentRelease && self.skipReleaseVersion?.buildNumber != latestRelease.buildNumber {
//
//                let alert = UIAlertController(title: "Update Available".localized, message: .localizedStringWithFormat("%@ version %@ of Popcorn Time is now available.".localized, latestRelease.releaseType.rawValue.localized, latestRelease.buildNumber), preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "Maybe Later".localized, style: .default, handler: nil))
//
//                alert.addAction(UIAlertAction(title: "Skip This Version".localized, style: .default) { _ in
//                    self.skipReleaseVersion = latestRelease
//                })
//
//                let isCydiaInstalled = UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
//
//                alert.addAction(UIAlertAction(title: "Update".localized, style: .default) { _ in
//                    if isCydiaInstalled {
//                        let url = URL(string: "cydia://package/\(Bundle.main.bundleIdentifier!)")!
//                        if #available(iOS 10.0, tvOS 10.0, *) {
//                            UIApplication.shared.open(url)
//                        } else {
//                            UIApplication.shared.openURL(url)
//                        }
//                    } else {
//                        let instructionsAlert = UIAlertController(title: "Sideloading Instructions".localized, message: "Unfortunately, in-app updates are not available for un-jailbroken devices. Please follow the sideloading instructions available in the PopcornTimeTV repo's wiki.".localized, preferredStyle: .alert)
//                        instructionsAlert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
//                        instructionsAlert.show(animated: true)
//                    }
//                })
//                completion?(true)
//                alert.show(animated: true)
//            } else {
//                completion?(false)
//            }
//        }
    }
}

internal struct VersionString: Codable {
    
    enum ReleaseType: String {
        case beta = "Beta"
        case stable = "Stable"
    }
    
    let date: Date
    let buildNumber: String
    var releaseType: ReleaseType {
        let components = buildNumber.components(separatedBy: ".")
        if let first = components.first, let _ = components[safe: 1], let _ = components[safe: 2] {
            if first == "0" // Beta release. Format will be 0.<major>.<minor>-<patch>.
            {
                return .beta
            } else // Stable release. Format will be <major>.<minor>.<patch>.
            {
                return .stable
            }
        }
        
        return .beta
    }
    
    init?(_ string: String, _ dateString: String) {
        self.buildNumber = string
        self.date = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter.date(from: dateString)!
        }()
        return nil
    }
    
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(date, forKey: "date")
//        aCoder.encode(buildNumber, forKey: "buildNumber")
//        aCoder.encode(releaseType.rawValue, forKey: "releaseType")
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        guard let date = aDecoder.decodeObject(forKey: "date") as? Date,
//            let buildNumber = aDecoder.decodeObject(forKey: "buildNumber") as? String,
//            let releaseTypeRawValue = aDecoder.decodeObject(forKey: "releaseType") as? String,
//            let releaseType = ReleaseType(rawValue: releaseTypeRawValue) else { return nil }
//        self.date = date
//        self.buildNumber = buildNumber
//        self.releaseType = releaseType
//    }
    
//    func archived() -> Data {
//        return NSKeyedArchiver.archivedData(withRootObject: self)
//    }
//    
//    class func unarchive(_ data: Data) -> VersionString? {
//        return NSKeyedUnarchiver.unarchiveObject(with: data) as? VersionString
//    }
}

internal func >(lhs: VersionString, rhs: VersionString) -> Bool {
    return lhs.date.compare(rhs.date) == .orderedDescending
}

internal func <(lhs: VersionString, rhs: VersionString) -> Bool {
    return lhs.date.compare(rhs.date) == .orderedAscending
}

internal func ==(lhs: VersionString, rhs: VersionString) -> Bool {
    return lhs.date.compare(rhs.date) == .orderedSame
}

// MARK: - Extensions

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
