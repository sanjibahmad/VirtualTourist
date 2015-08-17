//
//  PlacesViewController.swift
//  VirtualTourist
//
//  Created by Sanjib Ahmad on 8/17/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class PlacesViewController: UIViewController {
    var pin: Pin!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tc = tabBarController as! TabBarViewController
        pin = tc.pin
        
        getGooglePlaces()
    }
    
    func getGooglePlaces() {
        GooglePlacesClient.sharedInstance().placesSearch(pin) { placesProperties, errorString in
            if errorString != nil {
                
            } else {
                if let placesProperties = placesProperties {
                    for placeProperty in placesProperties {
                        println(placeProperty)
                    }
                }
            }
        }
    }

}