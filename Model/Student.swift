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
    var fullname: String
    var email: String
    var username: String
    var password: String
    var university_id: Int
    var year: Int
    var about: String
    var photo: String
    var birthdate: String
    
    init(email: String, username: String, password: String, university_id: Int, year: Int, photo: String = "") {
        self.fullname = ""
        self.email = email
        self.password = password
        self.username = username
        self.university_id = university_id
        self.year = year
        self.about = ""
        self.photo = photo
        self.birthdate = ""
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        fullname = try node.extract("fullname")
        email = try node.extract("email")
        username = try node.extract("username")
        password = try node.extract("password")
        university_id = try node.extract("university_id")
        year = try node.extract("year")
        about = try node.extract("about")
        photo = try node.extract("photo")
        birthdate = try node.extract("birthdate")
    }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "fullname": fullname,
            "email": email,
            "username": username,
            "year": year,
            "university_id": university_id,
            "about": about,
            "birthdate": birthdate,
            "photo": photo,
            "password": password
            ])
    }
    
    func makeJSON() -> JSON {
        return try! JSON([
            "id": id?.int ?? 0,
            "fullname": fullname,
            "email": email,
            "username": username,
            "year": year,
            "university": University.find(university_id)!,
            "about": about,
            "photo": photo,
            "birthdate": birthdate
            ])
    }
    
    func makeBasicJSON() -> JSON {
        return try! JSON([
            "id": id?.int ?? 0,
            "username": username,
            "photo": photo
            ])
    }
    
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
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
