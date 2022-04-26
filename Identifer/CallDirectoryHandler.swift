//
//  CallDirectoryHandler.swift
//  Identifer
//
//  Created by Work on 13.12.2021.
//

import Foundation
import CallKit
import CoreData

class CallDirectoryHandler: CXCallDirectoryProvider {

    var coreDataContext: NSManagedObjectContext!
    var objectsArray = [Any]()
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
//        let fileManager = FileManager.default
//        var containerPath = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.icourier.core.data")
//        
//        containerPath = containerPath?.appendingPathComponent("iCourier.sqlite")
//        let modelURL = Bundle.main.url(forResource: "iCourier", withExtension: "momd")
//        let model = NSManagedObjectModel(contentsOf: modelURL!)
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
//        do {
//            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: containerPath, options: nil)
//        } catch {
//            print("yellow")
//        }
//        
//        coreDataContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        coreDataContext.persistentStoreCoordinator = coordinator
//        
//        
//        let moc = coreDataContext
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Courier")
//        request.sortDescriptors = [NSSortDescriptor(key: "phoneNumber", ascending: true)]
//        do {
//            try
//            self.objectsArray = moc?.fetch(request) as [Any]
//                print ("objects count \(objectsArray.count)")
//        } catch {
//            // failure
//            print("Fetch failed")
//        }
        // Check whether this is an "incremental" data request. If so, only provide the set of phone number blocking
        // and identification entries which have been added or removed since the last time this extension's data was loaded.
        // But the extension must still be prepared to provide the full set of data at any time, so add all blocking
        // and identification phone numbers if the request is not incremental.
//        if context.isIncremental {
//            addOrRemoveIncrementalIdentificationPhoneNumbers(to: context)
//        } else {
            addAllIdentificationPhoneNumbers(to: context)
//        }

        context.completeRequest()
    }

    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //
        // Numbers must be provided in numerically ascending order.
        guard let fileUrl = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.icourier.code.data")?
            .appendingPathComponent("contacts") else { return }
       
        guard let reader = LineReader(path: fileUrl.path) else { return }
       
        for line in reader {
            autoreleasepool {
                // удаляем перевод строки в конце
                let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
               
                // отделяем номер от имени
                let components = line.components(separatedBy: ",")
               
                // приводим номер к Int64
                guard let phone = Int64(components[0]) else { return }
                let name = components[1]
               
                context.addIdentificationEntry(withNextSequentialPhoneNumber: phone, label: name)
            }
        }
    }

    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve any changes to the set of phone numbers to identify (and their identification labels) from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        let phoneNumbersToAdd: [CXCallDirectoryPhoneNumber] = [ 1_408_555_5678 ]
        let labelsToAdd = [ "New local business" ]

        for (phoneNumber, label) in zip(phoneNumbersToAdd, labelsToAdd) {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
        }

        let phoneNumbersToRemove: [CXCallDirectoryPhoneNumber] = [ 1_888_555_5555 ]

        for phoneNumber in phoneNumbersToRemove {
            context.removeIdentificationEntry(withPhoneNumber: phoneNumber)
        }

        // Record the most-recently loaded set of identification entries in data store for the next incremental load...
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
