//
//  App_Constants.swift
//  VideoAR
//
//  Created by Ninja on 11/2/18.
//  Copyright © 2018 Ninja. All rights reserved.
//

import Foundation


enum StoryBoardIDs: String {
    case LOGIN = "Login"
    case ROOT = "RootTab"
}

enum LoginStatusCodes {
    case LoginSuccess
    case LoginFailed
}

enum AlertStatus: String {
    case Loading
    case Uploading
    case Success
    case Failure
}

enum MediaType: String {
    case Photo
    case Video
}

let DELAY_TIME = 2.0

