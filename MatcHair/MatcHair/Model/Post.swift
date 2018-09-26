//
//  Post.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/26.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation

struct Post: Codable {
    let category: Category
    let content: String
    let payment: String
    let pictureURL: String
    let reservation: Reservation
    let user: User
}

struct Category: Codable {
    let dye: Bool?
    let haircut: Bool?
    let other: Bool
    let permanent: Bool
    let shampoo: Bool
    let treatment: Bool
}

struct Reservation: Codable {
    let date: String
    let location: Location
    let time: TimeInterval
}

struct Location: Codable {
    let address: String
    let city: String
    let district: String
}

struct TimeInterval: Codable {
    let afternoon: Bool
    let morning: Bool
    let night: Bool
}
