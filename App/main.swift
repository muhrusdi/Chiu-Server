import Vapor
import HTTP
import VaporMySQL
import Foundation

let mysql = try VaporMySQL.Provider(host: "localhost", user: "root", password: "", database: "diplomski")


let drop = Droplet(preparations: [Student.self, University.self, Group.self, Post.self, Comment.self, StudentGroup.self], initializedProviders: [mysql])
drop.hash.key = "ZGlwbG9tc2tp"

let version = try mysql.driver.raw("SELECT @@version")
print(version)

let _ = drop.config["app", "key"].string ?? ""


func emailSufix(_ email: Valid<Email>) -> String {
    return email.value.characters.split(separator: "@", maxSplits: 2, omittingEmptySubsequences: true).map(String.init)[1]
}

//drop.group(ChiuAuthMiddleware()) { auth in
let auth = drop
    auth.group("api") { api in
        
        // MARK: Get university from email COMPLETE
        api.get("university") { request in
            
            // Check parameters
            guard let email: Valid<Email> = try request.data["email"]?.validated() else {
                throw Abort.badRequest
            }
            
            // Check which university the email belongs to
            guard let university = try University.query().filter("email_sufix", emailSufix(email)).first() else {
                throw Abort.notFound
            }
            
            return university
        }
        
        
        // MARK: Register COMPLETE
        api.post("register") { request in
            
            // Check all parameters
            guard let username = request.data["username"]?.string, let password = request.data["password"]?.string, let email: Valid<Email> = try request.data["email"]?.validated(), let year = request.data["year"]?.int else {
                throw Abort.badRequest
            }
            
            // Check for optional parameters
            let photo = request.data["photo"]?.string ?? ""
            
            // Check if user doesn't exist
            guard try Student.query().filter("email", email.value).first() == nil else {
                throw Abort.custom(status: .conflict, message: "User already exists")
            }
            
            // Check which university the email belongs to
            guard let university = try University.query().filter("email_sufix", emailSufix(email)).first() else {
                throw Abort.custom(status: .notAcceptable, message: "Email not from university")
            }
            
            // Hash the password
            let hashedPassword = drop.hash.make(password)
            
            // Create a user
            var student = Student(email: email.value, username: username, password: hashedPassword, university_id: university.id!.int!, year: year, photo: photo)
            try student.save()
            
            return student
        }
        
        
        // MARK: Login COMPLETE
        api.get("login") { request in
            
            // Check parameters
            guard let email: Valid<Email> = try request.data["email"]?.validated(), let password = request.data["password"]?.string else {
                throw Abort.badRequest
            }
            
            // Find student
            guard let student = try Student.query().filter("password", drop.hash.make(password)).filter("email", email.value).first() else {
                throw Abort.badRequest
            }
            
            return student
        }
        
        
        // MARK: Get university groups COMPLETE
        api.get("university", University.self, "groups") { request, university in
            return try Group.query().filter("university_id", university.id!.int!).all().makeResponse()
        }
        
        
        // MARK: Get group posts COMPLETE
        api.get("group", Group.self, "posts") { request, group in
            return try Post.query().filter("group_id", group.id!.int!).all().makeResponse()
        }
        
        
        // MARK: Get post comments COMPLETE
        api.get("post", Post.self, "comments") { request, post in
            return try Comment.query().filter("post_id", post.id!.int!).all().makeResponse()
        }
        
        // MARK: Post post COMPLETE
        api.post("group", Group.self, "post") { request, group in
            
            // Check parameters
            guard let student_id = request.data["student_id"]?.int, let student = try Student.find(student_id), let password = request.data["password"]?.string, let title = request.data["title"]?.string, let text = request.data["text"]?.string, let typeString = request.data["type"]?.string, let type = PostType(rawValue: typeString) else {
                throw Abort.badRequest
            }
            
            // Check optional parameters
            let content_url = request.data["content_url"]?.string
            guard (type == .Text || (content_url != nil))  else {
                throw Abort.badRequest
            }
            
            // Check authorization
            guard drop.hash.make(password) == student.password else {
                throw Abort.custom(status: .unauthorized, message: "You do not have a permission to do this!")
            }
            
            var post = Post(student_id: student_id, group_id: group.id!.int!, title: title, text: text, type: type, content_url: content_url ?? "")
            try post.save()
            return post
        }
        
        
        // MARK: Post comment COMPLETE
        api.post("post", Post.self, "comment") { request, post in
            
            // Check parameters
            guard let student_id = request.data["student_id"]?.int, let student = try Student.find(student_id), let password = request.data["password"]?.string, let text = request.data["text"]?.string else {
                throw Abort.badRequest
            }
            
            // Check authorization
            guard drop.hash.make(password) == student.password else {
                throw Abort.custom(status: .unauthorized, message: "You do not have a permission to do this!")
            }
            
            // Create a comment
            var comment = Comment(student_id: student.id!.int!, post_id: post.id!.int!, text: text)
            try comment.save()
            
            return comment
        }
        
        
        // MARK: Update student COMPLETE
        api.post("student", Student.self) { request, student in
            
            var mutableStudent = student
            
            // Check authorization
            guard let password = request.data["password"]?.string, student.password == drop.hash.make(password) else {
                throw Abort.custom(status: .unauthorized, message: "You do not have a permission to do this!")
            }

            if let fullname = request.data["fullname"]?.string {
                mutableStudent.fullname = fullname
            }
            
            if let year = request.data["year"]?.int {
                mutableStudent.year = year
            }
            
            if let birthdate = request.data["birthdate"]?.string {
                mutableStudent.birthdate = birthdate
            }

            if let about = request.data["about"]?.string {
                mutableStudent.about = about
            }
            
            if let photo = request.data["photo"]?.string {
                mutableStudent.photo = photo
            }

            try mutableStudent.save()
            return mutableStudent
        }
        
        // MARK: Get student COMPLETE
        api.get("student", Student.self) { request, student in
            return student
        }
        
        
        // MARK: Get students groups COMPLETE
        api.get("student", Student.self, "groups") { request, student in
            return try StudentGroup.query().filter("student_id", student.id!.int!).all().makeResponse()
        }
        
        
        // MARK: Set students groups COMPLETE
        api.post("student", Student.self, "groups") { request, student in
            
            // Check authorization
            guard let password = request.data["password"]?.string, student.password == drop.hash.make(password) else {
                throw Abort.custom(status: .unauthorized, message: "You do not have a permission to do this!")
            }
            
            // Get students groups
            guard let groups_ids = request.data["group_ids"]?.array else {
                throw Abort.custom(status: .badRequest, message: "Groups not sent")
            }
            
            // Remove current groups
            try StudentGroup.query().filter("student_id", student.id!.int!).delete()
            
            // Add each group
            for group_id in groups_ids where (group_id.int != nil) {
                if try Group.find(group_id.int!) != nil {
                    var group = StudentGroup(student_id: student.id!.int!, group_id: group_id.int!)
                    try group.save()
                }
                
            }
            
            // Return all groups
            return try StudentGroup.query().filter("student_id", student.id!.int!).all().makeResponse()
        }
    }
//}


drop.get("/") { request in
    return try drop.view("welcome.html")
}

let port = drop.config["app", "port"].int ?? 80
drop.serve()
