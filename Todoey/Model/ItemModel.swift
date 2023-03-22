//
//  ItemModel.swift
//  Todoey
//
//  Created by Андрей Фроленков on 22.03.23.
//

import Foundation

struct ItemModel: Codable {
    
    let title: String
    var done: Bool = false
}
