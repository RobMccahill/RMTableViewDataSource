//
//  CellBindable.swift
//  Table View Source
//
//  Created by Robert Mccahill on 31/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation

public protocol CellBindable: CellIdentifiable {
    associatedtype Model
    
    func bind(to model: Model)
}
