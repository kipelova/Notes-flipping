//
//  model.swift
//  Notes flipping
//
//  Created by Анастасия Гладкова on 19.05.2020.
//  Copyright © 2020 Анастасия Гладкова. All rights reserved.
//

import Foundation
import RealmSwift
import PDFKit

class Note: Object {
    @objc dynamic var name: String!
    @objc dynamic var favourite: Bool = false
    @objc dynamic var document: Data!
    @objc dynamic var automatic: Bool = false
    @objc dynamic var vertical: Bool = true
    @objc dynamic var icon: Bool = false
    
    static func == (first: Note, second: Note) -> Bool {
        return first.name == second.name && first.favourite == second.favourite && first.document == second.document && first.automatic == second.automatic && first.vertical == second.vertical && first.icon == second.icon
    }
}
