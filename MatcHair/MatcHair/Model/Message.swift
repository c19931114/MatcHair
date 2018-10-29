//
//  Message.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/26.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation
import Firebase

struct Message: Codable {

    let fromID: String
    let text: String
    let timestamp: Int
    let toID: String
    let imageUrl: String?
    let imageWidth: Int
    let imageHeight: Int
    
    func chatPartnerId() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }

}
