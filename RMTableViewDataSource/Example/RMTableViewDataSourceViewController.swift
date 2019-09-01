//
//  ViewController.swift
//  Table View Source
//
//  Created by Robert Mccahill on 05/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import UIKit

public class RMTableViewDataSourceViewController: UIViewController {
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var peopleSource: PeopleSource = SamplePeopleSource()
    var dataSource: TableViewDataSource<Person>!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(searchBar)
        self.view.addSubview(tableView)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                searchBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                searchBar.heightAnchor.constraint(equalToConstant: 44),
                
                tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
                tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                ])
        } else {
            NSLayoutConstraint.activate([
                searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                searchBar.topAnchor.constraint(equalTo: self.view.topAnchor),
                searchBar.heightAnchor.constraint(equalToConstant: 44),
                
                tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
                tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
        }
        
        peopleSource.getPeople { [weak self] people in
            self?.linkTableView(with: people)
        }
    }
    
    private func linkTableView(with people: [Person]) {
        dataSource = TableViewDataSource(contents: people)
        dataSource.link(to: tableView, cellType: PersonTableViewCell.self)
        dataSource.makeSearchable(with: searchBar, onValue: \.name, caseInsensitive: true)
        dataSource.sectionContents(by: \.name)
    }
}
