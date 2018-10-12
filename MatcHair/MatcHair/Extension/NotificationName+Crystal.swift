//
//  NotificationName+Crystal.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/9.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation

extension Notification.Name {

    static let reFetchAllPosts = Notification.Name("reFetchAllPosts")
    static let reFetchMyPosts = Notification.Name("reFetchMyPosts")
    static let reFetchLikePosts = Notification.Name("reFetchLikePosts")

    static let reFetchModelPendingAppointments = Notification.Name("reFetchModelPendingAppointments")
    static let reFetchModelConfirmAppointments = Notification.Name("reFetchModelConfirmAppointments")
    static let reFetchModelCompleteAppointments = Notification.Name("reFetchModelCompleteAppointments")

    static let reFetchDesignerPendingAppointments = Notification.Name("reFetchDesignerPendingAppointments")
    static let reFetchDesignerConfirmAppointments = Notification.Name("reFetchDesignerConfirmAppointments")
    static let reFetchDesignerCompleteAppointments = Notification.Name("reFetchCompleteConfirmAppointments")

}
