RMTableViewDataSource
======

This is a framework aimed to solve some core tasks associated with UITableViews, including cell registration and dequeuing, searching, and sectioning of data, and leverages Swifts strong type system to provide clean and clear sytax to provide feedback at compile time.

As a sample, here is a table view that handles delegate assignment, cell registration, search, and segmenting of data based off a provided value:

```
let people = [
    Person(name: "John", age: 20),
    Person(name: "Mary", age: 43)
]

let dataSource: TableViewDataSource<Person> = TableViewDataSource(contents: people)
dataSource.link(to: tableView, cellType: PersonTableViewCell.self)
dataSource.makeSearchable(with: searchBar, onValue: \.name, caseInsensitive: true)
dataSource.sectionContents(by: \.name)
```

## Why would I use this framework?

Currently, many common tasks associated with using a UITableView are lengthy and error-prone. Even setting up the simplest of lists can incur a significant amount of boilerplate, and common mistakes such as failing to register cells for dequeuing, or failing to set the table view data source correctly.

Similar issues exist for searching. Without this framework, the search bar would have to be wired to a custom function to filter the relevant collection, and the table view would have to be updated automatically. 

A secondary array would also be needed to store the filtered results, and logic has to be implemented to swap between the full array, and the filtered array when it comes to actions like cell tapping, etc. With this solution, the `activeSource` property can be utilized to simplify the logic and minimize mistakes, and the search bar delegate methods are handled automatically.

Finally, table view sectioning has always been a cumbersome feature to implement, with multiple collections required to handle section titles, as well as the nested collection nature needed to accomplish a very common feature.

When searching and sectioning is combined, at minimum there's at least 5 separate collections that all need to be managed, updated and kept in sync with the table view. 

The aim of this framework is to enable these features in a clean, consise and type-safe manner, allowing the developer to focus on more important tasks like styling and animations, and minimizing common logical mistakes.

## Usage

### Cell Registration

In order to register cells in the correct manner, the required UITableViewCell must conform to the CellIdentifiable, providing a reuse identifier, and the preferred method of registration. An example of such is provided below:

```swift
extension PersonTableViewCell: CellIdentifiable {
    public static var reuseIdentifier = String(describing: self)
    public static var registrationMethod: RegistrationMethod = .standard
}
```

There are three types of registration, to reflect the various ways a cell can be defined.

When defined in a storyboard, registration is automatically handled, so the registration method should be set to `.none`

When declared using a nib, the nib should be provided through the associated value `.nib(nib)`

When declared programmatically, use the `.standard` option to ensure the cell is registered correctly

If more than one cell type is needed, or more logic is needed when it comes to cell linking, utilize the following methods:

```
dataSource.link(to: tableView, cellTypes: [PersonTableViewCell.self], configurator: { cellRetriever, person, indexPath in

    let cell = cellRetriever.retreieve(cell: PersonTableViewCell.self, for: indexPath)
    cell.bind(to: person)
    return cell
})
```

### Cell binding

In order to create an association between the data source contents, and the desired cell, the desired cell must conform to CellBindable.
The single requirement of CellBindable is a method formatted like so:

```
func bind(to model: Model)
```

where `Model` is the entity to bind to. As an example, the PersonTableViewCell conforms to CellBindable by having the following method

```
func bind(to person: Person)
```

Swifts type system is powerful enough to infer Person as the associated type, and will notify through an error if there is a mismatch between the CellBindable type and the DataSource model type.

CellBindable is an optional protocol - it is simply used to create a more consise usage of the class. The two methods provided below are functionally equivalent, but cellbindable provides a cleaner way of linking the source to the cells

```
dataSource.link(to: tableView, cellType: PersonTableViewCell.self)

dataSource.link(to: tableView, cellTypes: [PersonTableViewCell.self], configurator: { cellRetriever, person, indexPath in

    let cell = cellRetriever.retreieve(cell: PersonTableViewCell.self, for: indexPath)
    cell.bind(to: person)
    return cell
})
```

### Searching

As of now, the main source of searching is done through a UISearchBar. In order to link up other sources, ensure the source conforms to the SearchSource protocol, and is passed through the provided method.

The method above takes the provided key-value, converts it to lowercase, and compares it with the text of the uisearchbar.
If more customized logic is required, a closure can be provided for more customized matching.

For example, to make the `age` property searchable, use the code below:

```swift
dataSource.makeSearchable(with: searchBar, criteria: { person, searchText in
    return String(person.age).contains(searchText)
})
```

### Sectioning
The sectioning method has three properties to pass: 
1) The sectioning method itself. Alternatively, a key value can be passed, as indicated in the example above
2) The indexing method. This applies to the indexes on the right hand side of the table view used for quick navigation. The three options are `singleLetter` (the default), `full`, and `none`
3) Whether the collection should be sorted alphabetically or not.


## Future Features
This is very much a work in progress - consider the initial version a proof of concept.

Upcoming features:

* Cocoapods support
* More sectioning options
* More support for section sorting
* Asynchronous searching
* Table View state handling (loading, loaded, error, etc.)

