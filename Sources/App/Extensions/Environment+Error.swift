//
//  Environment+Error.swift
//  home-control-api
//
//  Created by Christoph Pageler on 26.09.24.
//

import Vapor

extension Environment {
    enum Error: Swift.Error {
        case missingKey
    }
}

