//
//  ChiuAuthMiddleware.swift
//  Diplomski
//
//  Created by Stefan Salatic on 5/8/16.
//
//

import Vapor
import HTTP

let API_KEY = "key"

class ChiuAuthMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        if let apiKey = request.headers["api_key"]?.string, apiKey == API_KEY {
            return try chain.respond(to: request)
        }
        throw Abort.custom(status: .forbidden, message: "Permission denied")
    }
}
