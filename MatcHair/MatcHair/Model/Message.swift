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

    let fromId: String
    let text: String
    let timestamp: Int
    let toId: String
    let imageUrl: String?
    let imageWidth: Int
    let imageHeight: Int
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }

}
