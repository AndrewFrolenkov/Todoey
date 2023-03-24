//
//  Category.swift
//  Todoey
//
//  Created by Андрей Фроленков on 24.03.23.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let color = List<Color>()
    let items = List<Item>()
    
}
