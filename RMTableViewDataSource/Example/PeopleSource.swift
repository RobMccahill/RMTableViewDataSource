//
//  PeopleSource.swift
//  Table View Source
//
//  Created by Robert Mccahill on 31/08/2019.
//  Copyright © 2019 Robert Mccahill. All rights reserved.
//

import Foundation

protocol PeopleSource {
    func getPeople(onResult: @escaping ([Person]) -> Void)
}

class SamplePeopleSource: PeopleSource {
    var personCount = 100
    
    var sampleNames = [
        "John",
        "Mary",
        "Michael",
        "Jane",
        "Tom",
        "Anne"
    ]
    
    func getPeople(onResult: @escaping ([Person]) -> Void) {
        var people = [Person]()
        for _ in 0..<personCount {
            let randomName = sampleNames[Int.random(in: 0..<sampleNames.count)]
            let randomAge = Int.random(in: 1..<100)
            
            people.append(Person(name: randomName, age: randomAge))
        }
        
        onResult(people)
    }
}

public struct Person {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
