//
//  RoundedButton.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/2/22.
//

import SwiftUI

struct RoundedTapButton: View {
    // MARK: - Properties.
    let title: String
    var titleColor = Color.white
    var backgroundColor = Color.mint
    let onTappedHandler: () -> Void
    
    // MARK: - View declaration.
    var body: some View {
        RoundedButton(title: title, titleColor: titleColor, backgroundColor: backgroundColor)
        .onTapGesture {
            onTappedHandler()
        }
    }
}

struct RoundedButton: View {
    // MARK: - Properties.
    let title: String
    var titleColor = Color.white
    var backgroundColor = Color.mint
    
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
    }
}

struct RoundedButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RoundedButton(title: "Button").padding(10)
            RoundedTapButton(title: "Tap Button", onTappedHandler: {}).padding(10)
        }
    }
}
