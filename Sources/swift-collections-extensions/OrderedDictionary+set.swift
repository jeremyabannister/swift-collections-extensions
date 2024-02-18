//
//  OrderedDictionary+set.swift
//
//
//  Created by Jeremy Bannister on 2/18/24.
//

///
extension OrderedDictionary {
    
    ///
    public mutating func `set`(
        key: Key,
        to newValue: Value?
    ) {
        
        ///
        self[key] = newValue
    }
}
