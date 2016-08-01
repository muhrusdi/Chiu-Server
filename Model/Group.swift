//
//  Group.swift
//  Diplomski
//
//  Created by Stefan Salatic on 31/7/16.
//
//

import Vapor
import Fluent
import HTTP

final class Group: Model {
    
    var id: Node?
    var name: String
    var short_name: String
    var year: Int
    var university_id: Int
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        short_name = try node.extract("short_name")
        year = try node.extract("year")
        university_id = try node.extract("university_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "short_name": short_name,
            "year": year
            ])
    }
    
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}

extension Sequence where Iterator.Element == Group {
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
    
    func makeResponse(request: Request) -> Response {
        return try! makeJSON().makeResponse()
    }
}
