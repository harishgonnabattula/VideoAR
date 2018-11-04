//
//  Helper.swift
//  VideoAR
//
//  Created by Ninja on 11/2/18.
//  Copyright © 2018 Ninja. All rights reserved.
//

import UIKit
import JGProgressHUD

struct Helper {
    static func getViewControllerBy(id: StoryBoardIDs) -> UIViewController {
        return UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: id.rawValue)
    }
}

struct AlertHelper {
    static func showAlert(of type: AlertStatus, info: String = "", with label:String = "") -> JGProgressHUD {
        
        let hud = JGProgressHUD(style: .light)
        switch type {
        case AlertStatus.Failure:
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.textLabel.text = "Error"
        case AlertStatus.Success:
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.textLabel.text = "Success"
        case AlertStatus.Loading:
            hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
            hud.textLabel.text = "Loading"
        default:
            hud.textLabel.text = label
        }
        hud.detailTextLabel.text = info
        return hud
    }
}

struct Assests {
    static var defaults = UserDefaults.standard
    static func setImgUrl(url: URL?) {
        defaults.set(url, forKey: "markerImg")
    }
    static func setVidUrl(url: URL?) {
        defaults.set(url, forKey: "markerVid")
    }
    static func getImgUrl() -> URL? {
        return defaults.url(forKey: "markerImg")
    }
    static func getVidUrl() -> URL? {
        return defaults.url(forKey: "markerVid")
    }
}
