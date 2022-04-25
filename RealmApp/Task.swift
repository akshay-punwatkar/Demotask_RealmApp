//
//  Task.swift
//  RealmApp
//
//  Created by Zhanibek Lukpanov on 12.03.2020.
//  Copyright © 2020 Zhanibek Lukpanov. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var completed = false
    
}
