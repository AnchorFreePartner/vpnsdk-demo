//
//  CategorizationProcessor.swift
//  VPNSDK Demo Hydra Provider
//
//  Created by Dan Vasilev on 31.01.2021.
//

import VPNTunnelProviderSDK
import UserNotifications

class CategorizationProcessor {
    let notificationRequestIdentifier = "neprovider.notificationRequestIdentifier"
    let workQueue = DispatchQueue(label: "neprovider.CategorizationProcessor.workQueue")

    func process(_ hydraCategorization: AFHydraCategorization) {
        if hydraCategorization.action == .bypass {
            return
        }
        sendUserNotificationIfAuthorized(hydraCategorization)
    }

    private func sendUserNotificationIfAuthorized(_ hydraCategorization: AFHydraCategorization) {
        LocalNotificationSender.sendNotification(
            with: hydraCategorization.userNotificationContent,
            identifier: self.notificationRequestIdentifier
        )
    }
}

extension CategorizationProcessor {
    class func `default`() -> CategorizationProcessor {
        return CategorizationProcessor()
    }
}

private extension AFHydraCategorization {
    var localTimestamp: Date? {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self.timestamp))
        return Date(timeInterval: seconds, since: self.timestamp)
    }

    var userNotificationContent: UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        var sourcesText = ""
        for source in self.sources {
            if !sourcesText.isEmpty {
                sourcesText.append(",")
            }
            sourcesText.append(" \(source)")
        }
        var categoryText = ""
        if let category_label = self.category_label {
            categoryText = " CAT: \(category_label);"
        }
        var timestampText = ""
        if let timestamp = self.localTimestamp {
            timestampText = " T: \(timestamp)"
        }

        content.title = self.resource
        content.body = "\(self.actionEmoji)\(categoryText) SRC: \(sourcesText);\(timestampText)"
        return content
    }

    private var actionEmoji: String {
        switch self.action {
        case .proxy:
            return "🅿️"
        case .VPN:
            return "🛡"
        case .bypass:
            return "✅"
        case .block:
            return "🛑"
        @unknown default:
            return ""
        }
    }
}
