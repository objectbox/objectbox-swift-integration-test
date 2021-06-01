//
//  AppDelegate.swift
//  IntTestmacOSOneEntityApp
//
//  Created by Marcin Krzyzanowski on 01/06/2021.
//  Copyright © 2021 ObjectBox. All rights reserved.
//

import Cocoa
import ObjectBox

@main
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let databaseName = "test"
        let appSupport = try! FileManager.default.url(for: .applicationSupportDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true).appendingPathComponent(Bundle.main.bundleIdentifier!)

        let directory = appSupport.appendingPathComponent(databaseName)
        try? FileManager.default.createDirectory(at: directory,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)

        let store = try! Store(directoryPath: directory.path)

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

