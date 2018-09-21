//
//  UserManager.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/20.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation

class UserManager {

    static let shared = UserManager()

    func getUserToken() -> String? {

        guard let userToken = UserDefaults.standard.string(forKey: "userToken") else {
            return nil
        }
        return userToken
    }

    func getUserUID() -> String? {

        guard let userUID = UserDefaults.standard.string(forKey: "userUID") else {
            return nil
        }
        return userUID
    }

    func getUserName() -> String? {

        guard let userName = UserDefaults.standard.string(forKey: "userName") else {
            return nil
        }
        return userName
    }

    func getUserPhotoURL() -> URL? {

        guard let photoURL = UserDefaults.standard.url(forKey: "photoURL") else {
            return nil
        }
        return photoURL
    }

}
