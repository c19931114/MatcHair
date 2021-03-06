//
//  User.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/19.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation

struct User: Codable {

    let name: String

    let email: String?

    let imageURL: String

    let uid: String

    let blockedUIDs: [String: Bool]?
}

struct ProfileResponse: Codable {

    let user: User
}

struct UserResponse: Codable {

    let user: User

    let accessToken: String

    let tokenType: String

    private enum CodingKeys: String, CodingKey {

        case user

        case accessToken = "access_token"

        case tokenType = "token_type"
    }
}
