//
//  Appointment.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/5.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation

struct Appointment { // 這邊沒有要 Codable 喔
    
    let info: AppointmentInfo
    let designer: User?
    let designerImageURL: URL?
    let model: User?
    let modelImageURL: URL?
    let postInfo: PostInfo

}

struct AppointmentInfo: Codable {
    let modelUID: String
    let designerUID: String
    let postID: String
    let timing: String
    let appointmentID: String
    let createTime: Int
}
