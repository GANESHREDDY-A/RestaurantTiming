//
//  LoaderView.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import SwiftUI

struct LoaderView: View {
    var tintColor: Color = .blue
    var scaleSize: CGFloat = 1.0
    
    var body: some View {
        ProgressView()
            .scaleEffect(scaleSize, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
    }
}
