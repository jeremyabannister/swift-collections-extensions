//
//  make_ordered_dictionary.swift
//
//
//  Created by Jeremy Bannister on 2/18/24.
//

///
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0.0, tvOS 13.0.0, *)
extension Sequence where Element: Hashable {
    
    ///
    public func asyncMakeOrderedDictionary<
        Value
    >(
        _ valueMap: @escaping (Element)async throws->Value
    ) async rethrows -> OrderedDictionary<Element, Value> {
        
        ///
        try await asyncMakeOrderedDictionary(
            key: { $0 },
            value: valueMap
        )
    }
    
    ///
    public func concurrentMakeOrderedDictionary<
        Value
    >(
        _ valueMap: @escaping (Element)async throws->Value
    ) async rethrows -> OrderedDictionary<Element, Value> {
        
        ///
        try await concurrentMakeOrderedDictionary(
            key: { $0 },
            value: valueMap
        )
    }
    
    ///
    public func asyncMakeCompactOrderedDictionary<
        Value
    >(
        _ valueMap: (Element)async throws->Value?
    ) async rethrows -> OrderedDictionary<Element, Value> {
        
        ///
        try await asyncMakeCompactOrderedDictionary(
            key: { $0 },
            value: valueMap
        )
    }
    
    ///
    public func concurrentMakeCompactOrderedDictionary<
        Value
    >(
        _ valueMap: (Element)async throws->Value?
    ) async rethrows -> OrderedDictionary<Element, Value> {
        
        ///
        try await asyncMakeCompactOrderedDictionary(
            key: { $0 },
            value: valueMap
        )
    }
}

///
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0.0, tvOS 13.0.0, *)
extension Sequence {
    
    ///
    public func asyncMakeOrderedDictionary<
        Key: Hashable,
        Value
    >(
        key keyMap: @escaping (Element) async throws -> Key,
        value valueMap: @escaping (Element) async throws -> Value
    ) async rethrows -> OrderedDictionary<Key, Value> {
        
        ///
        try await self.asyncMakeCompactOrderedDictionary(
            key: { try await keyMap($0) },
            value: { try await valueMap($0) }
        )
    }
    
    ///
    public func concurrentMakeOrderedDictionary<
        Key: Hashable,
        Value
    >(
        key keyMap: @escaping (Element) async throws -> Key,
        value valueMap: @escaping (Element) async throws -> Value
    ) async rethrows -> OrderedDictionary<Key, Value> {
        
        ///
        try await self.concurrentMakeCompactOrderedDictionary(
            key: { try await keyMap($0) },
            value: { try await valueMap($0) }
        )
    }
    
    /// Turn any Collection into an OrderedDictionary by transforming each element into both an optional key and an optional value. If either the key or the value is nil, nothing is added to the result and the element is skipped
    public func asyncMakeCompactOrderedDictionary<
        Key: Hashable,
        Value
    >(
        key keyMap: (Element) async throws -> Key?,
        value valueMap: (Element) async throws -> Value?
    ) async rethrows -> OrderedDictionary<Key, Value> {
        
        ///
        try await self.asyncReduce(into: .init(minimumCapacity: self.underestimatedCount)) { dictionary, element in

            ///
            guard let key = try await keyMap(element) else { return }

            ///
            dictionary[key] = try await valueMap(element)
        }
    }
    
    /// Turn any Collection into an OrderedDictionary by transforming each element into both an optional key and an optional value. If either the key or the value is nil, nothing is added to the result and the element is skipped
    public func concurrentMakeCompactOrderedDictionary<
        Key: Hashable, Value
    >(
        key keyMap: @escaping (Element) async throws -> Key?,
        value valueMap: @escaping (Element) async throws -> Value?
    ) async rethrows -> OrderedDictionary<Key, Value> {
        
        ///
        return try await withThrowingTaskGroup(of: (key: Key, value: Value)?.self) { taskGroup in
            
            ///
            self.forEach { element in
                
                ///
                taskGroup.addTask {
                    
                    ///
                    guard let key = try await keyMap(element) else { return nil }
                    
                    ///
                    guard let value = try await valueMap(element) else { return nil }

                    ///
                    return (key, value)
                }
            }
            
            ///
            var dictionary: OrderedDictionary<Key, Value> = [:]
            
            ///
            for try await keyAndValue in taskGroup {
                
                ///
                guard let (key, value) = keyAndValue else { continue }
                
                ///
                dictionary[key] = value
            }
            
            ///
            return dictionary
        }
    }
}

///
extension Sequence where Element: Hashable {
    
    /// Creates an OrderedDictionary by iterating over all elements and mapping each one to a value, then storing that value in the new dictionary using the element as the key.
    ///
    /// - Parameter mapping: The transform function which takes in an element of the receiver and returns the corresponding value which should be stored in the new dictionary.
    public func makeOrderedDictionary<
        Value
    >(
        _ valueMap: (Element)throws->Value
    ) rethrows -> OrderedDictionary<Element, Value> {
        
        ///
        try makeOrderedDictionary(
            key: { $0 },
            value: valueMap
        )
    }
    
    ///
    public func makeCompactOrderedDictionary<
        Value
    >(
        _ valueMap: (Element)throws->Value?
    ) rethrows -> OrderedDictionary<Element, Value> {
        
        ///
        try makeCompactOrderedDictionary(
            key: { $0 },
            value: valueMap
        )
    }
}

///
extension Sequence {
    
    /// Returns an OrderedDictionary containing the elements of this sequence, keyed by the hashable value found for each element at the given key path.
    public func makeOrderedDictionary<
        Key: Hashable
    >(
        key keyPath: KeyPath<Element, Key>
    ) -> OrderedDictionary<Key, Element> {
        
        ///
        self.makeOrderedDictionary(
            key: { $0[keyPath: keyPath] },
            value: { $0 }
        )
    }
    
    /// Returns an OrderedDictionary containing some of the elements of this sequence, keyed by the hashable value found for each element at the given key path, if it was not nil.
    public func makeOrderedDictionary<
        Key: Hashable
    >(
        key keyPath: KeyPath<Element, Key?>
    ) -> OrderedDictionary<Key, Element> {
        
        ///
        self.makeCompactOrderedDictionary(
            key: { $0[keyPath: keyPath] },
            value: { $0 }
        )
    }
}

///
extension Sequence {
    
    /// Turn any Sequence into an OrderedDictionary by transforming each element into both a Key and a Value.
    public func makeOrderedDictionary<
        Key: Hashable,
        Value
    >(
        key keyMap: (Element) throws -> Key,
        value valueMap: (Element) throws -> Value
    ) rethrows -> OrderedDictionary<Key, Value> {
        
        ///
        try self.makeCompactOrderedDictionary(
            key: { try keyMap($0) },
            value: { try valueMap($0) }
        )
    }
    
    /// Turn any Sequence into an OrderedDictionary by transforming each element into both an optional key and an optional value. If either the key or the value is nil, nothing is added to the result and the element is skipped.
    public func makeCompactOrderedDictionary<
        Key: Hashable,
        Value
    >(
        key keyMap: (Element) throws -> Key?,
        value valueMap: (Element) throws -> Value?
    ) rethrows -> OrderedDictionary<Key, Value> {
        
        ///
        try self.reduce(into: .init(minimumCapacity: self.underestimatedCount)) { dictionary, element in
            
            ///
            guard let key = try keyMap(element) else { return }
            
            ///
            try dictionary[key] = valueMap(element)
        }
    }
}
