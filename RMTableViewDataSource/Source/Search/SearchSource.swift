//
//  SearchSource.swift
//  Table View Source
//
//  Created by Robert Mccahill on 31/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation

public protocol SearchSource {
    typealias QueryUpdateHandler = ((String?) -> Void)
    var activeQuery: String? { get }
    var queryUpdated: QueryUpdateHandler { get set }
}
