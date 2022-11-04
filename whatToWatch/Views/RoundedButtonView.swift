//
//  RoundedButtonView.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/2/22.
//

import SwiftUI

struct RoundedButtonView: View {
    // MARK: - Properties.
    let title: String
    var titleColor = Color.white
    var backgroundColor = Color.mint
    let onTappedHandler: () -> Void
    
    // MARK: - View declaration.
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .frame(height: 60)
                .foregroundColor(backgroundColor)
            
            Text(title)
                .foregroundColor(titleColor)
                .font(.title2)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTappedHandler()
        }
    }
}

struct RoundedButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButtonView(title: "Button", onTappedHandler: {}).padding(10)
    }
}
