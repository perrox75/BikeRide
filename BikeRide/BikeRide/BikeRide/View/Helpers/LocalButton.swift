//
//  LocalButton.swift
//  BikeRide
//
//  Created by perrox75 on 10/08/2021.
//

import SwiftUI

struct LocalButton: View {
    @Binding var isLocal: Bool

    var body: some View {
        Button(action: {isLocal.toggle()}) {
            Image(systemName: isLocal ? "icloud.circle.fill" : "icloud.circle")
                .foregroundColor(isLocal ? Color.yellow : Color.gray)
        }
    }
}

#if !TEST
struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        LocalButton(isLocal: .constant(true))
    }
}
#endif
