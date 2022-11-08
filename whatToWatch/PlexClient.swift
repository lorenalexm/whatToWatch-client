//
//  PlexClient.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/2/22.
//

import Foundation
import PlexKit

// MARK: - Errors.
enum PlexClientError: Error {
    case noValidClient
    case failedClientRequest
    case signInFailed
    case notSignedIn
    case noServersFound
    case noLibrariesFound
    case noMediaFound
    case noImageFound
    case invalidServerAddress
}

extension PlexClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noValidClient:
            return "A valid client object does not exist."
        case .failedClientRequest:
            return "Request to Plex has failed."
        case .signInFailed:
            return "Failed to sign-in to Plex."
        case .notSignedIn:
            return "User is not currently signed in to Plex."
        case .noServersFound:
            return "Unable to find any servers associated with the user."
        case .noLibrariesFound:
            return "Unable to find any media libraries within the server."
        case .noMediaFound:
            return "Unable to find any media within the library."
        case .noImageFound:
            return "Unabled to find the requested image on the server."
        case .invalidServerAddress:
            return "Server resource provided an invalid server address."
        }
    }
}

class PlexClient: ObservableObject {
    // MARK: - Properties.
    @Published var client: Plex
    @Published var user: PlexUser?
    private var serverUrl = ""
    
    // MARK: - Functions.
    /// Creates and configures the `Plex` object to be used for requests.
    init() {
        guard let clientId = Bundle.main.infoDictionary?["CLIENT_ID"] as? String else {
            fatalError("Unable to aquire CLIENT_ID from Bundle!")
        }
        
        let clientInfo = Plex.ClientInfo(clientIdentifier: clientId, product: "whatToWatch", version: "0.1.1")
        client = Plex(sessionConfiguration: .default, clientInfo: clientInfo)
        loadUserFromDefaults()
    }
    
    /// Attempts to signin to Plex with the given `username` and `password`. Stores the returned `PlexUser` object.
    /// - Parameters:
    ///   - username: A valid username to attempt to sign-in to Plex with.
    ///   - password: The password associated with the Plex username.
    ///   - completionHandler: Provides either a `Void` success or a `PlexClientError` if sign-in fails.
    func signIn(username: String, password: String, completionHandler: @escaping (Result<Void, PlexClientError>) -> Void) {
        client.request(Plex.ServiceRequest.SimpleAuthentication(username: username, password: password)) { result in
            switch result {
            case let .success(response):
                DispatchQueue.main.async { [unowned self] in
                    user = response.user
                    saveUserToDefaults(user!)
                }
                completionHandler(.success(()))
            case let .failure(error):
                print("Sign-in failed with the error: \(error.localizedDescription)")
                completionHandler(.failure(.signInFailed))
            }
        }
    }
    
    /// Attempts to load the servers available to the user.
    /// - Parameter completionHandler: Provides either an array of `PlexResource` objects or a `PlexClientError` if unable to fetch.
    func listServers(completionHandler: @escaping (Result<[PlexResource], PlexClientError>) -> Void) {
        guard let user else {
            completionHandler(.failure(.notSignedIn))
            return
        }
        
        client.request(Plex.ServiceRequest.Resources(), token: user.authToken) { result in
            switch result {
            case .success(let response):
                let servers = response.filter { $0.capabilities.contains(.server) }
                guard servers.count > 0 else {
                    completionHandler(.failure(.noServersFound))
                    return
                }
                completionHandler(.success(servers))
            case .failure(let error):
                print("Fetching servers failed with the error: \(error.localizedDescription)")
                completionHandler(.failure(.failedClientRequest))
            }
        }
    }
    
    /// Attempts to load the libraries from a specific server.
    /// - Parameters:
    ///   - completionHandler: Provides either an array of `PlexLibrary` objects or a `PlexClientError` if unable to fetch.
    func listLibraries(completionHandler: @escaping (Result<[PlexLibrary], PlexClientError>) -> Void) {
        guard let user else {
            completionHandler(.failure(.notSignedIn))
            return
        }
        guard !serverUrl.isEmpty else {
            completionHandler(.failure(.noServersFound))
            return
        }
        
        client.request(Plex.Request.Libraries(), from: URL(string: serverUrl)!, token: user.authToken) { result in
            switch result {
            case .success(let response):
                let libraries = response.mediaContainer.directory.filter { $0.type == .movie}
                guard libraries.count > 0 else {
                    completionHandler(.failure(.noLibrariesFound))
                    return
                }
                completionHandler(.success(libraries))
                
            case .failure(let error):
                print("Fetching libraries failed with the error: \(error.localizedDescription)")
                completionHandler(.failure(.failedClientRequest))
            }
        }
    }
    
    /// Attempts to load all of the movies from a given library.
    /// - Parameters:
    ///   - library: The `PlexLibrary` to load the movies from.
    ///   - completionHandler: Provides either an array of `PlexMediaItem` objects or a `PlexClientError` if unable to fetch.
    func listMovies(from library: PlexLibrary, completionHandler: @escaping(Result<[PlexMediaItem], PlexClientError>) -> Void) {
        guard let user else {
            completionHandler(.failure(.notSignedIn))
            return
        }
        guard !serverUrl.isEmpty else {
            completionHandler(.failure(.noServersFound))
            return
        }
        
        client.request(Plex.Request.LibraryItems(key: library.key, mediaType: .movie), from: URL(string: serverUrl)!, token: user.authToken) { result in
            switch result {
            case .success(let response):
                completionHandler(.success(response.mediaContainer.metadata))
            case .failure(let error):
                print("Fetching movies failed with the error: \(error.localizedDescription)")
                completionHandler(.failure(.noMediaFound))
            }
        }
    }
    
    /// Attempts to fetch an image from the Plex server.
    /// - Parameters:
    ///   - path: The path provided by a `PlexMediaItem` pointing to an image.
    ///   - completionHandler: Provided either a `Data` object representing the image or a `PlexClientError` if unable to fetch.
    func fetchImage(path: String, completionHandler: @escaping(Result<Data, PlexClientError>) -> Void) {
        guard let user else {
            completionHandler(.failure(.notSignedIn))
            return
        }
        guard !serverUrl.isEmpty else {
            completionHandler(.failure(.noServersFound))
            return
        }
        
        client.request(Plex.Request.Image(path: path), from: URL(string: serverUrl)!, token: user.authToken) { result in
            switch result {
            case .success(let image):
                completionHandler(.success(image))
            case .failure(let error):
                print("Fetching an image filed with the error: \(error.localizedDescription)")
                completionHandler(.failure(.noImageFound))
            }
        }
    }
    
    // MARK: - Helper functions.
    /// Attempts to save the `PlexUser` property to the `UserDefaults` to be loaded in the future.
    /// - Parameter user: The `PlexUser` to be saved, should only be the class property used.
    private func saveUserToDefaults(_ user: PlexUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "User")
        }
    }
    
    /// Attempts to load a `PlexUser` object from the `UserDefaults` and set its value to the class `user` property.
    private func loadUserFromDefaults() {
        guard let savedUser = UserDefaults.standard.object(forKey: "User") as? Data else {
            print("Failed to retreive a PlexUser object from UserDefaults.")
            return
        }
        
        user = try? JSONDecoder().decode(PlexUser.self, from: savedUser)
    }
    
    /// Saves the server connection uri to a property for future use.
    /// - Parameter server: The server to capture the uri from.
    func saveUrlTo(server: PlexResource) {
        guard server.connections.count > 0 else {
            print("No server connection found to save.")
            return
        }
        serverUrl = server.connections[0].uri
    }
}
