//
//  TableViewContents.swift
//  Table View Source
//
//  Created by Robert Mccahill on 25/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation
import UIKit

public struct TableViewContents<Model>: Collection {
    var sections: [TableViewSection<Model>]
    
    public init(sections: [TableViewSection<Model>] = []) {
        self.sections = sections
    }
    
    public typealias Index = Int
    public typealias Element = TableViewSection<Model>
    
    public var startIndex: Index { return sections.startIndex }
    public var endIndex: Index { return sections.endIndex }
    
    public subscript(index: Index) -> TableViewSection<Model> {
        get { return sections[index] }
    }
    
    subscript(indexPath: IndexPath) -> Model {
        get { return sections[indexPath.section][indexPath.row] }
    }
    
    public func index(after i: Index) -> Index {
        return sections.index(after: i)
    }
}

public struct TableViewSection<Model>: Collection {
    var title: String?
    var contents: [Model]
    
    public init(title: String? = nil, contents: [Model] = []) {
        self.title = title
        self.contents = contents
    }
    
    public typealias Index = Int
    public typealias Element = Model
    
    public var startIndex: Index { return contents.startIndex }
    public var endIndex: Index { return contents.endIndex }
    
    public subscript(index: Index) -> Model {
        get { return contents[index] }
    }
    
    public func index(after i: Index) -> Index {
        return contents.index(after: i)
    }
}
