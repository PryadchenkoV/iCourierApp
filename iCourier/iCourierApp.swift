//
//  iCourierApp.swift
//  iCourier
//
//  Created by Work on 13.12.2021.
//

import SwiftUI

@main
struct iCourierApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AddPhoneView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
