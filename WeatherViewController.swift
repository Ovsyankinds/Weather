//
//  WeatherViewController.swift
//  Weather
//
//  Created by Ovsyankinds on 05/10/2017.
//  Copyright © 2017 Ovsyankinds. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import RealmSwift
import Kingfisher


class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var iconWeather: UIImageView!
    
    var locationManager: CLLocationManager!
    var urlGeoCoder = "https://geocode-maps.yandex.ru/1.x/?format=json&lang=en_RU&sco=latlong&kind=locality&geocode="
    
    var urlWeather = "http://api.openweathermap.org/data/2.5/weather?q="
    var appId = "units=metric&appid=9e14b3db00c4243c8cb215eec914140b"
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        
        if(currentLocation.horizontalAccuracy > 0){
            locationManager.stopUpdatingLocation()
            let coordinates = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            self.urlGeoCoder += "\(coordinates.latitude),\(coordinates.longitude)"
            //print(coordinates)
            //print(self.urlGeoCoder)
            self.getCityName(url: self.urlGeoCoder)
        }
    }
    
    func getCityName(url: String){
        Alamofire.request(url).responseJSON{ response in
            if let json = response.result.value{
                var myJSON = json as! [String: Any]
                myJSON = myJSON["response"] as! [String: Any]
                myJSON = myJSON["GeoObjectCollection"] as! [String: Any]
                let myJSONFinal = myJSON["featureMember"] as! NSArray
                var cityName = myJSONFinal[0] as! [String: Any]
                cityName = cityName["GeoObject"] as! [String: Any]
                let cityNameFinal = cityName["name"] as! String
                
                self.urlWeather += "\(cityNameFinal)&\(self.appId)"
                self.getWeather(url: self.urlWeather)
                self.cityLabel.text! += " \(cityNameFinal)"
                
                //print(cityNameFinal)
                //print(self.urlWeather)
            }
        }
    }
    
    func getWeather(url: String){
        Alamofire.request(self.urlWeather).responseJSON{ response in
            if let json = response.result.value{
                var myJSON = json as! [String: Any]
                var img = myJSON["weather"] as! NSArray
                myJSON = myJSON["main"] as! [String: Any]
                var weather = myJSON["temp"] as! Double
                weather = round(weather)
                let weatherInt: Int
                weatherInt = Int(weather)
                self.weatherLabel.text! += " \( String(weatherInt) )"
            
                var icon = img[0] as! [String: Any]
                let iconFinal = icon["icon"] as! String
                print(iconFinal)
                let urlImg = URL(string: "http://openweathermap.org/img/w/\(iconFinal).png")
                self.iconWeather.kf.setImage(with: urlImg)
                
                //print(weather)
            }
        }
    }
    
    func addToDB(cityName: String, temp: String){
        let model = WeatherModel()
        model.city = cityName
        model.temperature = temp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
