//
//  StudentGroup.swift
//  Diplomski
//
//  Created by Stefan Salatic on 6/8/16.
//
//

import Vapor
import Fluent
import HTTP

final class StudentGroup: Model {
    
    var id: Node?
    var student_id: Int
    var group_id: Int
    
    init(student_id: Int, group_id: Int) {
        self.student_id = student_id
        self.group_id = group_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        student_id = try node.extract("student_id")
        group_id = try node.extract("group_id")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "student_id": student_id,
            "group_id": group_id
            ])
    }
    
    func makeJSON() throws -> JSON {
        return try Group.find(group_id)!.makeJSON()
    }
    
    
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}

extension Sequence where Iterator.Element == StudentGroup {
    func makeJSON() throws -> JSON {
        return .array(try self.map { try $0.makeJSON() })
    }
    
    func makeResponse() -> Response {
        return try! makeJSON().makeResponse()
    }
}
