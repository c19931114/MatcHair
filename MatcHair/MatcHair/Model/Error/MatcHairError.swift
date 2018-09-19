//
//  MatcHairError.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/19.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation

enum MatcHairError: String, Error {

    case loginFacebookFail = "Login with facebook fail."

    case loginFacebookReject = "Please permit the facebook login as MatcHair login."

    case serverError = "MatcHair client error"
}
