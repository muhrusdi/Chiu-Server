//
//  University.swift
//  Diplomski
//
//  Created by Stefan Salatic on 31/7/16.
//
//

import Vapor
import Fluent
import HTTP

final class University: Model {
    
    var id: Node?
    var name: String
    var address: String
    var email_sufix: String
    var image_url: String

    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        address = try node.extract("address")
        email_sufix = try node.extract("email_sufix")
        image_url = try node.extract("image_url")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "address": address,
            "email_sufix": email_sufix,
            "image_url": image_url
            ])
    }
    
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}

extension Sequence where Iterator.Element == University {
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
    
    func makeResponse() -> Response {
        return try! makeJSON().makeResponse()
    }
}
