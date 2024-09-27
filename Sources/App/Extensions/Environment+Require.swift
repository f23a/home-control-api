//
//  Environment+Require.swift
//  home-control-api
//
//  Created by Christoph Pageler on 26.09.24.
//

import Vapor

extension Environment {
    static func require(_ key: String) throws -> String {
        guard let value = get(key) else { throw Error.missingKey(key: key) }
        return value
    }
}
