//
//  CellIdentifiable.swift
//  Table View Source
//
//  Created by Robert Mccahill on 31/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation
import UIKit

///A protocol for representing reuse identifiers for a table view cells and the preferred registration method for the cell
public protocol CellIdentifiable: UITableViewCell {
    static var reuseIdentifier: String { get }
    static var registrationMethod: RegistrationMethod { get }
}

///An enum to represent the preferred registration method for a table view cell
///
///There are three ways of providing a reuse identifier for a cell. The first is providing the reuse identifier for a prototype cell in a storyboard. Using this method, the prototype cell is automatically registered to the table view, so no registration is needed.
///
///The second method is to create a table view cell by using a nib file. This nib file must be registered, along with the reuse identifier.
///
///The third method is to create a table view cell programmatically, and only the reuse identifier is needed in this case
public enum RegistrationMethod {
    case standard
    case nib(UINib)
    case none
}
