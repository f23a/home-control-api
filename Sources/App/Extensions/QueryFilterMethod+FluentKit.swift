//
//  Filter.swift
//  home-control-api
//
//  Created by Christoph Pageler on 10.11.24.
//

import HomeControlKit
import FluentKit

extension QueryFilterMethod {
    var fluentMethod: DatabaseQuery.Filter.Method {
        switch self{
        case .equal: return .equal
        case .notEqual: return .notEqual
        case .greaterThan: return .greaterThan
        case .greaterThanOrEqual: return .greaterThanOrEqual
        case .lessThan: return .lessThan
        case .lessThanOrEqual: return .lessThanOrEqual
        }
    }
}
