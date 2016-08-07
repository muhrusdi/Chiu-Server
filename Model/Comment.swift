//
//  Comment.swift
//  Diplomski
//
//  Created by Stefan Salatic on 6/8/16.
//
//


import Vapor
import Fluent
import HTTP
import Foundation


final class Comment: Model {
    
    var id: Node?
    var student_id: Int
    var post_id: Int
    var text: String
    var date_updated: Int
    var date_created: Int
    
    init(student_id: Int, post_id: Int, text: String) {
        self.student_id = student_id
        self.post_id = post_id
        self.text = text
        self.date_created = Int(NSDate().timeIntervalSince1970)
        self.date_updated = Int(NSDate().timeIntervalSince1970)
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        student_id = try node.extract("student_id")
        post_id = try node.extract("post_id")
        text = try node.extract("text")
        date_updated = try node.extract("date_updated")
        date_created = try node.extract("date_created")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "student_id": student_id,
            "post_id": post_id,
            "text": text,
            "date_updated": date_updated,
            "date_created": date_created
            ])
    }
    
    func makeJSON() -> JSON {
        return try! JSON([
            "id": id?.int ?? 0,
            "student": Student.find(student_id)!.makeBasicJSON(),
            "text": text,
            "date_updated": date_updated,
            "date_created": date_created
            ])
    }
    
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}

extension Sequence where Iterator.Element == Comment {
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
    
    func makeResponse() -> Response {
        return try! makeJSON().makeResponse()
    }
}

