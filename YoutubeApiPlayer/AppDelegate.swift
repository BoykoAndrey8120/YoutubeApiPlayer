//
//  AppDelegate.swift
//  YoutubeApiPlayer
//
//  Created by Andrey Boyko on 27.06.2022.
//

import GoogleSignIn
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // account id: migwuq-kApnam-jaxtu8
    // test User:  andreyffff52@gmail.com

    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Initialize Google sign-in.
        GIDSignIn.sharedInstance().clientID = "451736023128-bk42ne9lug1folkcmnb0933avu9lslsf.apps.googleusercontent.com"
    }

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplication.OpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

}
