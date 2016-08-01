//
//  Post.swift
//  Diplomski
//
//  Created by Stefan Salatic on 31/7/16.
//
//

import Vapor
import Fluent
import HTTP

enum PostType: String {
    case Text = "text"
    case Photo = "photo"
    case Video = "video"
}

final class Post: Model {
    
    var id: Node?
    var student_id: Int
    var group_id: Int
    var text: String?
    var title: String
    var content_url: String
    var date_updated: Int
    var date_created: Int
    
    
    private var type_string: String
    
    var type: PostType {
        get {
            return PostType(rawValue: type_string)!
        } set {
            type_string = type.rawValue
        }
    }
    
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        student_id = try node.extract("student_id")
        group_id = try node.extract("group_id")
        text = try node.extract("text")
        title = try node.extract("title")
        content_url = try node.extract("content_url")
        date_updated = try node.extract("date_updated")
        date_created = try node.extract("date_created")
        type_string = try node.extract("type_string")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "user": Student.find(student_id),
            "text": text,
            "title": title,
            "content_url": content_url,
            "type": type_string,
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

extension Sequence where Iterator.Element == Post {
    func makeJSON() -> JSON {
        return .array(self.map { $0.makeJSON() })
    }
    
    func makeResponse(request: Request) -> Response {
        return try! makeJSON().makeResponse()
    }
}
