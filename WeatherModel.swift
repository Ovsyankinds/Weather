//
//  WeatherModel.swift
//  Weather
//
//  Created by Ovsyankinds on 10/10/2017.
//  Copyright © 2017 Ovsyankinds. All rights reserved.
//

import UIKit
import RealmSwift

class WeatherModel: Object{
    dynamic var date: Date!
    dynamic var city = ""
    dynamic var temperature = 0
    dynamic var iconName = ""
}
