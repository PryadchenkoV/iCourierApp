//
//  AddPhoneView.swift
//  iCourier
//
//  Created by Work on 13.12.2021.
//

import SwiftUI
import Combine
import CoreData
import iPhoneNumberField
import CallKit


struct AddPhoneView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    enum Field: Hashable {
        case nameField
        case phoneField
    }
    
    @State var courierName: String = ""
    @State var phoneNumber: String = ""
    
    @State var phoneAttempts = 0
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            VStack {
                Label("Add Courier number", systemImage: "phone")
                    .font(.title)
                TextField("Name", text: $courierName)
                    .padding()
                    .focused($focusedField, equals: .nameField)
                    .overlay(RoundedRectangle(cornerRadius: 10.0)
                                .strokeBorder(Color(uiColor: .separator), style: StrokeStyle(lineWidth: 1.0)))
                iPhoneNumberField(text: $phoneNumber)
                    .font(UIFont(size: 20, weight: .medium, design: .default))
                    .flagHidden(false)
                    .clearsOnEditingBegan(phoneNumber.isEmpty)
                    .defaultRegion(Locale.current.regionCode)
                    .flagSelectable(false)
                    .prefixHidden(false)
                    .keyboardType(.numberPad)
                    .padding()
                    .focused($focusedField, equals: .phoneField)
                    .overlay(RoundedRectangle(cornerRadius: 10.0)
                                .strokeBorder(Color(uiColor: .separator), style: StrokeStyle(lineWidth: 1.0)))
                    .modifier(Shake(animatableData: CGFloat(phoneAttempts)))
                Button {
                    guard !phoneNumber.isEmpty else {
                        focusedField = .phoneField
                        withAnimation {
                            self.phoneAttempts += 1
                        }
                        return
                    }
                    addNewItem()
                } label: {
                    Label("Add", systemImage: "plus")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(.blue)
                        .cornerRadius(10.0)
                        .font(.title2)
                }
            }
            .padding()
        }
    }
    
    func addNewItem() {
//        let item = Courier(context: viewContext)
        let tmpPhoneNumber = phoneNumber
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        let tmpName = courierName.isEmpty ? "Courier" : courierName
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
        
        guard let fileUrl = FileManager.default
           .containerURL(forSecurityApplicationGroupIdentifier: "group.icourier.code.data")?
           .appendingPathComponent("contacts") else { return }
        let string = "\(tmpPhoneNumber),\(tmpName)"
        do {
            try string.write(to: fileUrl, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
        phoneNumber = ""
        courierName = ""
        focusedField = .phoneField
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.pryadchenko.iCourier.Identifer")
    }
}

struct AddPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        AddPhoneView()
            .preferredColorScheme(.light)
    }
}
