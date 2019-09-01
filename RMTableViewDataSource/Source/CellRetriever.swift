//
//  CellRetriever.swift
//  Table View Source
//
//  Created by Robert Mccahill on 31/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation
import UIKit

///Provides a type-safe method of registering and dequeueing reusable cells
public class CellRetriever {
    let tableView: UITableView
    let cellTypes: [CellIdentifiable.Type]
    
    public init(tableView: UITableView, cellTypes: [CellIdentifiable.Type]) {
        self.tableView = tableView
        self.cellTypes = cellTypes
        
        registerCells()
    }
    
    private func registerCells() {
        for cell in cellTypes {
            switch cell.registrationMethod {
            case .standard:
                tableView.register(cell, forCellReuseIdentifier: cell.reuseIdentifier)
            case .nib(let nib):
                tableView.register(nib, forCellReuseIdentifier: cell.reuseIdentifier)
            case .none:
                break
            }
        }
    }
    
    public func retreieve<C: CellIdentifiable>(cell: C.Type, for indexPath: IndexPath? = nil) -> C {
        if let indexPath = indexPath {
            return tableView.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath) as! C
        } else {
            return tableView.dequeueReusableCell(withIdentifier: C.reuseIdentifier) as! C
        }
    }
}
