//
//  model.swift
//  Notes flipping
//
//  Created by Анастасия Гладкова on 19.05.2020.
//  Copyright © 2020 Анастасия Гладкова. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var favourite: Bool = false
}
