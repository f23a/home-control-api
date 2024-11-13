//
//  QuerySortDirection+FluentKit.swift
//  home-control-api
//
//  Created by Christoph Pageler on 10.11.24.
//

import HomeControlKit
import FluentKit

extension QuerySortDirection {
    var fluentDirection: DatabaseQuery.Sort.Direction {
        switch self {
        case .ascending: return .ascending
        case .descending: return .descending
        }
    }
}
