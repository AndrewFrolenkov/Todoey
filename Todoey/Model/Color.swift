//
//  Color.swift
//  Todoey
//
//  Created by Андрей Фроленков on 24.03.23.
//

import Foundation
import RealmSwift

class Color: Object {
    
    @objc dynamic var hue: String = ""
    @objc dynamic var saturation: String = ""
    @objc dynamic var brightness: String = ""
    var parentCategory = LinkingObjects(fromType: Category.self, property: "color")
}
