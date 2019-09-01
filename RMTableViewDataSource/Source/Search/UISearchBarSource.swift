//
//  UISearchBarSource.swift
//  Table View Source
//
//  Created by Robert Mccahill on 31/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation
import UIKit

public class UISearchBarSource: NSObject, SearchSource {
    public var activeQuery: String?
    public var queryUpdated: QueryUpdateHandler
    public var preExistingDelegate: UISearchBarDelegate?
    
    let searchBar: UISearchBar
    
    public init(searchBar: UISearchBar, queryUpdatedHandler: @escaping QueryUpdateHandler) {
        self.searchBar = searchBar
        self.queryUpdated = queryUpdatedHandler
        
        if let existingDelegate = searchBar.delegate {
            self.preExistingDelegate = existingDelegate
        }
        
        super.init()
        searchBar.delegate = self
    }
}

extension UISearchBarSource: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        activeQuery = searchText
        queryUpdated(searchText)
        
        preExistingDelegate?.searchBar?(searchBar, textDidChange: searchText)
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        preExistingDelegate?.searchBarTextDidEndEditing?(searchBar)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        preExistingDelegate?.searchBarCancelButtonClicked?(searchBar)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        preExistingDelegate?.searchBarSearchButtonClicked?(searchBar)
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        preExistingDelegate?.searchBarTextDidBeginEditing?(searchBar)
    }
    
    public func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        preExistingDelegate?.searchBarBookmarkButtonClicked?(searchBar)
    }
    
    public func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        preExistingDelegate?.searchBarResultsListButtonClicked?(searchBar)
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return preExistingDelegate?.searchBarShouldEndEditing?(searchBar) ?? true
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return preExistingDelegate?.searchBarShouldBeginEditing?(searchBar) ?? true
    }
    
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        preExistingDelegate?.searchBar?(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
    }
    
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return preExistingDelegate?.searchBar?(searchBar, shouldChangeTextIn: range, replacementText: text) ?? true
    }
}
