//
//  TableViewDataSource.swift
//  Table View Source
//
//  Created by Robert Mccahill on 05/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation
import UIKit

public class TableViewDataSource<Model>: NSObject, UITableViewDataSource {
    ///The unfiltered contents of the data source. Note: This does not always reflect the contents of the table view, as a search in progress will return the filtered contents instead
    public var contents: TableViewContents<Model> {
        didSet {
            if !contentUpdateInProgress {
                onContentsUpdate(activeSource)
            }
        }
    }
    
    ///The data source contents, filtered by the active query
    public var filteredContents = TableViewContents<Model>() {
        didSet {
            if !contentUpdateInProgress {
                onContentsUpdate(activeSource)
            }
        }
    }
    
    ///The up to date contents of the data source - This will return the original contents if no search is active, or the filtered contents, if a search is active
    public var activeSource: TableViewContents<Model> {
        get {
            if let searchSource = searchSource, let activeQuery = searchSource.activeQuery, activeQuery != "" {
                return filteredContents
            } else {
                return contents
            }
        }
    }
    
    //Typealiases
    public typealias ContentsUpdateHandler = ((TableViewContents<Model>) -> Void)
    
    public typealias CellConfigurator = ((CellIdentifiable) -> CellIdentifiable)
    public typealias CellRetrieverConfigurator = ((CellRetriever, Model, IndexPath) -> CellIdentifiable)
    
    public typealias SearchFilteringMethod = ((Model, String) -> Bool)
    
    public typealias SectioningMethod = ((Model) -> String)
    
    private var contentUpdateInProgress = false
    
    public var onContentsUpdate: ContentsUpdateHandler!
    
    //Variables
    public var tableView: UITableView!
    
    private var cellRetriever: CellRetriever!
    private var retrieverConfigurator: CellRetrieverConfigurator?
    
    private var searchSource: SearchSource?
    private var filteringMethod: SearchFilteringMethod?
    
    private var indexDisplayMethod: IndexDisplayMethod = .singleLetter
    private var sectioningMethod: SectioningMethod?
    private var sortAlphabetically: Bool = true
    
    public convenience init(title: String? = nil, contents: [Model], onContentsUpdate: ContentsUpdateHandler? = nil) {
        self.init(contents: TableViewContents(sections: [TableViewSection(title: title, contents: contents)]))
    }
    
    public init(contents: TableViewContents<Model> = .init(), onContentsUpdate: ContentsUpdateHandler? = nil) {
        self.contents = contents
        
        super.init()
        
        if let onContentsUpdate = onContentsUpdate {
            self.onContentsUpdate = onContentsUpdate
        } else {
            self.onContentsUpdate = { [weak self] contents in
                self?.tableView?.reloadData()
            }
        }
    }
    
    ///Links the provided table view to this data source, registers the provided cell to the table view, and updates table view cells with the relevant model object
    public func link<C: CellBindable>(to tableView: UITableView, cellType: C.Type) where C.Model == Model {
        self.link(to: tableView, cellTypes: [cellType]) { cellRetriever, model, indexPath in
            let cell = cellRetriever.retreieve(cell: cellType, for: indexPath)
            cell.bind(to: model)
            return cell
        }
    }
    
    public func link<C: CellIdentifiable>(to tableView: UITableView, cellType: C.Type, configurator: @escaping ((Model, C) -> CellIdentifiable)) {
        self.link(to: tableView, cellTypes: [cellType], configurator: { cellRetriever, model, indexPath in
            let cell = cellRetriever.retreieve(cell: cellType, for: indexPath)
            return configurator(model, cell)
        })
    }
    
    public func link<C: CellIdentifiable>(to tableView: UITableView, cellTypes: [C.Type], configurator: @escaping CellRetrieverConfigurator) {
        self.tableView = tableView
        tableView.dataSource = self
        
        self.cellRetriever = CellRetriever(tableView: tableView, cellTypes: cellTypes)
        self.retrieverConfigurator = configurator
    }
    
    public func update(with contents: [Model], title: String? = nil) {
        self.update(withContents: TableViewContents<Model>(sections: [TableViewSection<Model>(title: title, contents: contents)]))
    }
    
    ///Assigns the new contents to the data source, and re-runs the filtering and sectioning processes assigned to the source
    public func update(withContents contents: TableViewContents<Model>) {
        contentUpdateInProgress = true
        
        self.contents = contents
        
        //re-apply filtering and sectioning methods when contents are updated
        filterContents()
        
        if let sectioningMethod = sectioningMethod {
            self.sectionContents(sectioningMethod: sectioningMethod, indexDisplayMethod: indexDisplayMethod, sortAlphabetically: sortAlphabetically)
        }
        
        contentUpdateInProgress = false
        
        self.onContentsUpdate(activeSource)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return activeSource.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeSource[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let retrieverConfigurator = retrieverConfigurator else {
            fatalError("No cell retriever has been provided")
        }
        
        let model = activeSource[indexPath]
        return retrieverConfigurator(cellRetriever, model, indexPath)
    }
    
    //MARK: Search Bar Methods
    
    public func makeSearchable(searchSource: SearchSource, criteria: @escaping SearchFilteringMethod) {
        self.searchSource = searchSource
        self.filteringMethod = criteria
    }
    
    public func makeSearchable(searchSource: SearchSource, onValue value: KeyPath<Model, String>, caseInsensitive: Bool = true) {
        self.makeSearchable(searchSource: searchSource, criteria: { model, searchText in
            if caseInsensitive {
                return model[keyPath: value].lowercased().contains(searchText.lowercased())
            } else {
                return model[keyPath: value].contains(searchText)
            }
        })
    }
    
    public func makeSearchable(with searchBar: UISearchBar, criteria: @escaping SearchFilteringMethod) {
        let searchBarSource = UISearchBarSource(searchBar: searchBar) { searchText in
            self.filterContents()
        }
        
        self.makeSearchable(searchSource: searchBarSource, criteria: criteria)
    }
    
    public func makeSearchable(with searchBar: UISearchBar, onValue value: KeyPath<Model, String>, caseInsensitive: Bool = true) {
        let searchBarSource = UISearchBarSource(searchBar: searchBar) { searchText in
            self.filterContents()
        }
        
        self.makeSearchable(searchSource: searchBarSource, onValue: value, caseInsensitive: caseInsensitive)
    }
    
    private func filterContents() {
        var filteredContents = TableViewContents<Model>()
        
        guard let searchSource = searchSource, let filteringMethod = filteringMethod else {
            self.filteredContents = filteredContents
            return
        }
        
        guard let activeQuery = searchSource.activeQuery, activeQuery != "" else {
            self.filteredContents = filteredContents
            return
        }
        
        for section in contents {
            var filteredSection = TableViewSection<Model>(title: section.title)
            
            for model in section {
                let meetsCriteria = filteringMethod(model, activeQuery)
                
                if meetsCriteria {
                    filteredSection.contents.append(model)
                }
            }
            
            if filteredSection.contents.count > 0 {
                filteredContents.sections.append(filteredSection)
            }
        }
        
        self.filteredContents = filteredContents
    }
    
    //MARK: Sectioning Methods
    public func sectionContents(by keyPath: KeyPath<Model, String>, indexDisplayMethod: IndexDisplayMethod = .singleLetter, sortAlphabetically: Bool = true) {
        self.sectionContents(sectioningMethod: { model in
            if indexDisplayMethod == .singleLetter {
                if let firstCharacter = model[keyPath: keyPath].first {
                    return String(firstCharacter)
                } else {
                    return ""
                }
            } else {
                return model[keyPath: keyPath]
            }
        }, indexDisplayMethod: indexDisplayMethod, sortAlphabetically: sortAlphabetically)
    }
    
    public func sectionContents(sectioningMethod: @escaping SectioningMethod, indexDisplayMethod: IndexDisplayMethod = .singleLetter, sortAlphabetically: Bool = true) {
        self.sectioningMethod = sectioningMethod
        self.indexDisplayMethod = indexDisplayMethod
        
        var sectionedContents = TableViewContents<Model>()
        
        var contentsDictionary = [String : [Model]]()
        
        //todo: assess optimization here - potential for saving collection passes / copying
        for section in contents {
            for model in section.contents {
                let sectionName = sectioningMethod(model)
                
                var indexedSection = contentsDictionary[sectionName, default: []]
                indexedSection.append(model)
                contentsDictionary[sectionName] = indexedSection
            }
        }
        
        if sortAlphabetically {
            let sortedDictionary = contentsDictionary.sorted(by: { $0.key < $1.key })
            
            for (title, contents) in sortedDictionary where !contents.isEmpty {
                sectionedContents.sections.append(TableViewSection<Model>(title: title, contents: contents))
            }
            
        } else {
            for (title, contents) in contentsDictionary where !contents.isEmpty {
                sectionedContents.sections.append(TableViewSection<Model>(title: title, contents: contents))
            }
        }
        
        contents = sectionedContents
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return activeSource[section].title
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        switch self.indexDisplayMethod {
        case .none:
            return nil
        case .singleLetter:
            return contents.compactMap {
                if let firstCharacter = $0.title?.first {
                    return String(firstCharacter)
                } else {
                    return nil
                }
            }
        case .full:
            return contents.compactMap { $0.title }
        }
    }
}


public enum IndexDisplayMethod {
    case singleLetter
    case full
    case none
}
