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
    @IBOutlet weak var welcome: UILabel!
    
    var locationManager: CLLocationManager!
    var urlGeoCoder = "https://geocode-maps.yandex.ru/1.x/?format=json&lang=en_RU&sco=latlong&kind=locality&key=AGGj4lkBAAAAFcT0ZwIAfF_YY3qTRB-7Py_XwFsQilUdyVwAAAAAAAAAAACpbdqLtvnNX6Y6UuiLCdXJJFBvcg==&geocode=" //geocoder Yandex
    
    //var urlGeoCoder = "https://maps.googleapis.com/maps/api/geocode/json?language=ru&latlng=" //google geocoder
    //var appKey = "&key=AIzaSyCKCfPNA6curYCNip6wGUF1w7lx4j8vpMo" //google
        
    var urlWeather = "http://api.openweathermap.org/data/2.5/weather?q="
    var appId = "&lang=ru&units=metric&appid=9e14b3db00c4243c8cb215eec914140b"
    
    /*var date: String!
    var time: String!*/
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if(status == CLAuthorizationStatus.denied){
            print("denied")
            self.performSegue(withIdentifier: "errorViewController", sender: self)
        }
        
    }
    
    //Функция для получения координат местоположения устройства
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        
        if(currentLocation.horizontalAccuracy > 0){
            locationManager.stopUpdatingLocation()
            //let coordinates = CLLocationCoordinate2DMake(53.195727, 45.022592) //Penza
            let coordinates = CLLocationCoordinate2DMake(54.230265, 45.125244) // Saransk
            //let coordinates = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            self.urlGeoCoder += "\(coordinates.latitude),\(coordinates.longitude)" //yandex
            //self.urlGeoCoder += "\(coordinates.latitude),\(coordinates.longitude)\(self.appKey)" //google
            //print(coordinates)
            //print(self.urlGeoCoder)
            self.getCityName(url: self.urlGeoCoder)
            //print(Realm.Configuration.defaultConfiguration.fileURL!)
        }
    }
    
    //Функция для получения названия города по координатам
    //Принимает параметр в виде строки с запросом к сайту geocode-maps.yandex.ru
    func getCityName(url: String){
        Alamofire.request(url).responseJSON{ response in
            if let json = response.result.value{
                var myJSON = json as! [String: Any]
                
                /*let myJSONFinal = myJSON["results"] as! NSArray
                var cityName = myJSONFinal[0] as! [String: Any]
                let cityNameArray = cityName["address_components"] as! NSArray
                var cityNameString = cityNameArray[3] as! [String: Any]
                let cityNameFinal = cityNameString["long_name"] as! String*/
               
                //парсинг ответа яндексовского geocoder'a
                myJSON = myJSON["response"] as! [String: Any]
                myJSON = myJSON["GeoObjectCollection"] as! [String: Any]
                let myJSONFinal = myJSON["featureMember"] as! NSArray
                var cityName = myJSONFinal[0] as! [String: Any]
                cityName = cityName["GeoObject"] as! [String: Any]
                let cityNameFinal = cityName["name"] as! String
                
                let char = cityNameFinal.components(separatedBy: " ")
                var cityNameWeather = ""
                for row in char{
                    cityNameWeather += "\(row)"
                }
                //print(cityNameWeather)
                self.urlWeather += "\(cityNameWeather)\(self.appId)"
                
                //print(cityNameFinal)
                //print(self.urlWeather)
                
                //функция showDBElem возвращает массив, пробегая по элементам выбираем как отображать данные
                //result[0] = 1 - запрашиваем данные из инета
                //result[0] = 2 - запрашиваем данные из БД и кэша
                //result[0] = 3 - регистрируем первый вход пользователя, запрос данных из инета
                let result = self.showDBElem(cityName: cityNameFinal, date: Date())
            
                switch result[0]{
                    case "1":
                        self.getWeather(url: self.urlWeather)
                        self.welcome.text = "Вы заходили более 5 минут назад"
                    
                    case "2":
                        //Прошло временни после первого запроса менее 5 минут
                        //температура и картинка берутся из БД и кэша
                        self.weatherLabel.text! += result[1]             //температура из БД
                        let nameCacheKey = result[2]                    //название ключа для кэша
                        self.welcome.text = "Вы заходили менее 5 минут назад"
                        //отображаем картинку из кеша
                        let imgCash = ImageCache.default.retrieveImageInDiskCache(forKey: "\(nameCacheKey)")
                        self.iconWeather.image = imgCash
                        //self.iconWeather.kf.setImage(with: imgCash as! Resource)
                    
                    case "3":
                        self.getWeather(url: self.urlWeather)
                        self.welcome.text = "Приветствуем Вас в приложении"
                        //print("First enter")
                    
                    default:
                        print("Error")
                    
                }
                self.cityLabel.text! += " \(cityNameFinal)"
            }
        }
    }
    
    //Функция для получения погоды
    //Принимает параметр в виде строки с запросом на сайт openweathermap.org
    func getWeather(url: String){
        Alamofire.request(self.urlWeather).responseJSON{ response in
            if let json = response.result.value{
                var myJSON = json as! [String: Any]
                let cityName = myJSON["name"]
                let img = myJSON["weather"] as! NSArray
                myJSON = myJSON["main"] as! [String: Any]
                var weather = myJSON["temp"] as! Double
                weather = round(weather)
                let weatherInt: Int
                weatherInt = Int(weather)
                self.weatherLabel.text! += " \( String(weatherInt) ) °C"
                
                var icon = img[0] as! [String: Any]
                let iconFinal = icon["icon"] as! String
             
                let urlImg = URL(string: "http://openweathermap.org/img/w/\(iconFinal).png")
                ImageCache.default.removeImage(forKey: "icon")
                let resourseIcon = ImageResource(downloadURL: urlImg!, cacheKey: "icon")
                self.iconWeather.kf.setImage(with: resourseIcon)
                
                let date = Date()
                
                self.addToDB(cityName: cityName as! String, temp: weather, date: date, iconName: "icon")
                
                _ = self.showDBElem(cityName: cityName as! String, date: date/*, time: fullTime*/)
                
                //print(Realm.Configuration.defaultConfiguration.fileURL!)
            }else{
                print("json getWeather error")
            }
        }
    }
    
    //Функция для добавленя данных В БД
    func addToDB(cityName: String, temp: Double, date: Date, iconName: String){
        let model = WeatherModel()
        model.city = cityName
        model.temperature = Int(temp)
        model.date = date
        model.iconName = iconName
        //model.time = time
        
        let realm = try! Realm()
        try! realm.write{
            realm.add(model)
        }
    }
    
    //Функция для получения данных с БД
    func showDBElem(cityName: String, date: Date/*, time: String*/) -> Array<String>{
        let realm = try! Realm()
        let result = realm.objects(WeatherModel.self)
        let calendar = Calendar.current
        var date = calendar.dateComponents([.minute], from: date)
        //print(date.minute!)
        var differentDate: Int!
        var param: Array<String> = []
        if(result.count > 0){
        for row in result{
            if(row["city"] as! String == cityName){
                let myDate = calendar.dateComponents([.minute], from: row["date"] as! Date)
                differentDate = abs(date.minute! - myDate.minute!)
                //print(myDate.minute!)
                //print(row)
                //print(differentDate)
                if(differentDate > 5){
                    param = ["1"]
                    //print("Прошло с момента запроса ",differentDate, " минут")
                }else{
                    param = ["2", " \(String(describing: row["temperature"]!)) °C", "\(String(describing: row["iconName"]!))"]
                    //print("Прошло с момента запроса ",differentDate, " минут")
                }
            }else{
                param = ["3"]
            }
        }
        }else{
            param = ["3"]
        }
        
        return param
        //print(result[0]["time"]!)
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
