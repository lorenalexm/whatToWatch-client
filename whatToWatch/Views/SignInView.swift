//
//  SignInView.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/2/22.
//

import SwiftUI
import AlertToast

struct SignInView: View {
    // MARK: - Properties.
    @EnvironmentObject private var plexClient: PlexClient
    @FocusState private var focused: Fields?
    @State private var username = ""
    @State private var password = ""
    
    @State private var toastShowing = false
    @State private var toastType = AlertToast.AlertType.regular
    @State private var toastTitle = ""
    @State private var toastSubTitle = ""
    
    private enum Fields: Hashable {
        case username
        case password
    }
    
    // MARK: - View declaration.
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("👋")
                        .font(.system(size: 64))
                        .padding(.trailing, 10)
                    Text("Hello,\nSign-in now.")
                        .font(.largeTitle)
                }.padding(.bottom)
                Text("Can't decide what to watch? Login to your Plex account, find a friend, and swipe through movies until everyone has a match!")
                    .padding(.bottom, 30)
            }
            
            Spacer()
            
            TextField("Please enter your Plex username", text: $username)
                .focused($focused, equals: .username)
            Divider()
                .frame(height: 1)
                .padding(.bottom, 10)
            SecureField("Please enter your password", text: $password)
                .focused($focused, equals: .password)
            Divider()
                .frame(height: 1)
                .padding(.bottom)
            RoundedTapButton(title: "Sign-in", backgroundColor: .mint) {
                guard !username.isEmpty else {
                    focused = .username
                    toastType = .error(.red)
                    toastTitle = "Missing field!"
                    toastSubTitle = "Username must not be blank."
                    toastShowing = true
                    return
                }
                guard !password.isEmpty else {
                    focused = .password
                    toastType = .error(.red)
                    toastTitle = "Missing field!"
                    toastSubTitle = "Password must not be blank."
                    toastShowing = true
                    return
                }
                plexClient.signIn(username: username, password: password) { result in
                    switch result {
                    case .success(_):
                        print("Successfully signed in!")
                    case .failure(let error):
                        toastType = .error(.red)
                        toastTitle = "Sign-in error!"
                        toastSubTitle = "Server returned an error of: \(error.localizedDescription)."
                        toastShowing = true
                    }
                }
            }
        }
        .navigationTitle("Sign-in")
        .padding(.horizontal, 40)
        .toast(isPresenting: $toastShowing, duration: 2.0, alert: {
            AlertToast(displayMode: .banner(.slide), type: toastType, title: toastTitle, subTitle: toastSubTitle)
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
