# Psotify
- Version 1.0.1

About Psotify
- *Psotify is an iOS project inspired by the Spotify mobile app and using the Spotify web API. The user can see new releases albums and album songs, personal playlists, and listen tracks. And also search albums and tracks.*


## Build and Runtime Requirements
- Xcode 14 or later
- iOS 17.5 or later
- Configuring the Project

## Written in Swift
Project written with swift language. UI Framework is SwiftUI. 

## Application Architecture
- *Project written with MVVM Architecture. SOLID principles and Clean architecture. Modular, developable and testable.*
- *Swift Concurrency and Combine*
- *DI Container pattern was used for dependency injection in the project.When you want to add a dependency to somewhere. You can bind it then resolve it with AppDIContainer *
- *Factory and builder were used to create requests.*
- *UserDefaultsService was designed as singleton.* 
- *Services were designed as generic in terms of modularity and independence.*
- *Network requests were managed with use cases*

## Folder Structure and Architecture
- *PostifyTest folder include unit tests.*
- Configurations
- Helpers
- Models
- Resources
- Scenes
- Service
- UseCases
- Utilities

## Dependencies
There is no third party library.

## Unit Tests
Postify has unit tests written for the services *NetworkService and AppDIContainer. AuthUseCase, GetSongUseCase, GetUserProfileUseCase, GetAlbumsUseCase, GetPlaylistsUseCase, GetSearchResultUseCase, GetUserSavedTracksUseCase* usecases are tested and also *MainViewModel* tested. To run the unit tests, press Command+u to run the tests.


https://github.com/user-attachments/assets/42c4f8c7-1bb2-44c7-b730-142c3f06bba1
