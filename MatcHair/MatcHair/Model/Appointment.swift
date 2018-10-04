//
//  RevervationCellMdl.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/2.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation

struct Appointment: Codable {
    let modelUID: String
    let designerUID: String
    let postID: String
    let statement: String
    let timing: String
}