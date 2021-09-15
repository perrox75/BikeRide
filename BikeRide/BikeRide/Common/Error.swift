//
//  Error.swift
//  WatchTransfer
//
//  Created by perrox75 on 26/08/2021.
//

import SwiftUI

enum BikeRideError: LocalizedError {
    case sessionNotSupported
    case fileNotCreated
    
    var errorDescription: String? {
        switch self {
        case .sessionNotSupported:
            return "Session not supported."
        case .fileNotCreated:
            return "Unable to create file."
        }
    }
}

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
}

class ErrorHandling: ObservableObject {
    @Published var currentAlert: ErrorAlert?
    
    func handle(error: BikeRideError) {
        currentAlert = ErrorAlert(message: error.localizedDescription)
    }
}

protocol ClassName {}
extension ClassName {
    func className() -> String {
        return String(describing: type(of: self))
    }
}

struct HandleErrorsByShowingAlertViewModifier: ViewModifier {
    @StateObject var errorHandling = ErrorHandling()
    
    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            // Applying the alert for error handling using a background element
            // is a workaround, if the alert would be applied directly,
            // other .alert modifiers inside of content would not work anymore
            .background(
                EmptyView()
                    .alert(item: $errorHandling.currentAlert) { currentAlert in
                        Alert(
                            title: Text("Error"),
                            message: Text(currentAlert.message),
                            dismissButton: .default(Text("Ok")) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
}
