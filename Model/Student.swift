//
//  Student.swift
//  Diplomski
//
//  Created by Stefan Salatic on 1/8/16.
//
//

import Vapor
import Fluent
import HTTP

final class Student: Model {
    var id: Node?
    var fullname: String?
    var email: String
    var username: String
    var password: String?
    
    init(fullname: String? = nil, email: String, username: String, password: String) {
        self.fullname = fullname
        self.email = email
        self.password = password
        self.username = username
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        fullname = try node.extract("fullname")
        email = try node.extract("email")
        username = try node.extract("username")
        password = try node.extract("password")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "fullname": fullname,
            "email": email,
            "username": username
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
    
    func makeResponse(request: Request) -> Response {
        return try! makeJSON().makeResponse()
    }
}

extension Sequence where Iterator.Element == Student {
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
    
    func makeResponse() -> Response {
        return try! makeJSON().makeResponse()
    }
}
