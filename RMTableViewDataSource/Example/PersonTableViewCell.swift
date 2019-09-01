//
//  PersonTableViewCell.swift
//  Table View Source
//
//  Created by Robert Mccahill on 31/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation
import UIKit

public class PersonTableViewCell: UITableViewCell, CellBindable {
    public var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var ageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(ageLabel)
        
        nameLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            ageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ageLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            ageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
    }
    
    public func bind(to person: Person) {
        nameLabel.text = person.name
        ageLabel.text =  person.age == 1 ? "\(person.age) year old" : "\(person.age) years old"
    }
}

extension PersonTableViewCell: CellIdentifiable {
    public static var reuseIdentifier = String(describing: self)
    public static var registrationMethod: RegistrationMethod = .standard
}
