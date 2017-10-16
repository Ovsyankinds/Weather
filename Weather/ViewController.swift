//
//  ViewController.swift
//  Weather
//
//  Created by Ovsyankinds on 05/10/2017.
//  Copyright © 2017 Ovsyankinds. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textLabel: UILabel!
    
    var  timer = Timer()
    var count = 0
    var locationManager: CLLocationManager!
    
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let weatherViewController: WeatherViewController = segue.destination as! WeatherViewController
        
        /*if(segue.identifier == "weatherViewController"){
            weatherViewController
        }*/
    }*/   
    func weatherScreen(){
        count = count + 1
        self.textLabel.text! = "Download data over \(count)"
        activityIndicator.startAnimating()
        if count == 5{
            timer.invalidate()
            activityIndicator.stopAnimating()
            if Reachability.isConnectedToNetwork() == true {
                print("Internet connection OK")
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
                self.performSegue(withIdentifier: "weatherViewController", sender: self)
            } else {
                print("Internet connection FAILED")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.weatherScreen), userInfo: nil, repeats: true)
        
        activityIndicator.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

