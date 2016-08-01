import Vapor
import HTTP
import VaporMySQL


let mysql = try VaporMySQL.Provider(host: "localhost", user: "root", password: "", database: "diplomski")


let drop = Droplet(preparations: [Student.self, University.self, Group.self, Post.self], initializedProviders: [mysql])

let version = try mysql.driver.raw("SELECT @@version")
print(version)

let _ = drop.config["app", "key"].string ?? ""


drop.group("api") { api in

    api.post("user") { request in
        guard let email = request.data["email"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Email not provided")
        }
        
        guard let name = request.data["name"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Name not provided")
        }
        
        
        /*var student = Student(name: name, email: email)
        
        try student.save()
 
        return student*/
        return "OK"
    }
    
    api.get("university") { request in
        guard let sufix = request.data["email_sufix"]?.string else {
            throw Abort.badRequest
        }
        
        if let university = try University.query().filter("email_sufix", sufix).first() {
            return university
        }
        
        throw Abort.notFound
    }
    
    
    
    // MARK: Register
    api.post("register") { request in
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string, let email = request.data["email"]?.string else {
            throw Abort.badRequest
        }
        
        if let _ = try Student.query().filter("email", email).first() {
            throw Abort.custom(status: .notAcceptable, message: "User already exists")
        }
        
        var sufix = email.characters.split(separator: "@", maxSplits: 2, omittingEmptySubsequences: true).map(String.init)[1]
        
        guard let university = try University.query().filter("email_sufix", sufix).first() else {
            throw Abort.custom(status: .notAcceptable, message: "Email not from university")
        }
        
        var student = Student(email: email, username: username, password: password)
        
        try student.save()
        
        return student
        
    }
    
    // MARK: Login
    api.get("login") { request in
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string else {
            throw Abort.badRequest
        }
        if let student = try Student.query().filter("password", password).filter("username", username).first() {
            return student
        }
        throw Abort.badRequest
    }
    

    // MARK: University sufix
    api.get("groups") { request in
        guard let university = request.data["university"]?.string else {
            throw Abort.custom(status: .badRequest, message: "University ID is required")
        }
        return try Group.query().filter("university_id", university).all().makeResponse(request: request)
    }
    
    // MARK: Group posts
    api.get("posts") { request in
        guard let group = request.data["group"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Group ID is required")
        }
        return try Post.all().makeResponse(request: request)// query().filter("group_id", group).all().makeResponse(request: request)
    }
}






























drop.get("/") { request in
    return try drop.view("welcome.html")
}

/**
    This route shows how to access request
    data. POST to this route with either JSON
    or Form URL-Encoded data with a structure
    like:

    {
        "users" [
            {
                "name": "Test"
            }
        ]
    }

    You can also access different types of
    request.data manually:

    - Query: request.data.query
    - JSON: request.data.json
    - Form URL-Encoded: request.data.formEncoded
    - MultiPart: request.data.multipart
*/
drop.get("data", Int.self) { request, int in
    return try JSON([
        "int": int,
        "name": request.data["name"].string ?? "no name"
    ])
}

/**
    Here's an example of using type-safe routing to ensure 
    only requests to "posts/<some-integer>" will be handled.

    String is the most general and will match any request
    to "posts/<some-string>". To make your data structure
    work with type-safe routing, make it StringInitializable.

    The User model included in this example is StringInitializable.
*/
drop.get("posts", Int.self) { request, postId in
    return "Requesting post with ID \(postId)"
}

/**
    This will set up the appropriate GET, PUT, and POST
    routes for basic CRUD operations. Check out the
    UserController in App/Controllers to see more.

    Controllers are also type-safe, with their types being
    defined by which StringInitializable class they choose
    to receive as parameters to their functions.
*/

//let users = UserController(droplet: drop)
//drop.resource("users", users)



/**
    A custom validator definining what
    constitutes a valid name. Here it is 
    defined as an alphanumeric string that
    is between 5 and 20 characters.
*/
class Name: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(5)
            && Count.max(20)

        try evaluation.validate(input: value)
    }
}

/**
    By using `Valid<>` properties, the
    employee class ensures only valid
    data will be stored.
*/
class Employee {
    var email: Valid<Email>
    var name: Valid<Name>

    init(request: Request) throws {
        email = try request.data["email"].validated()
        name = try request.data["name"].validated()
    }
}

/**
    Allows any instance of employee
    to be returned as Json
*/
extension Employee: JSONRepresentable {
    func makeJSON() throws -> JSON {
        return try JSON([
            "email": email.value,
            "name": name.value
        ])
    }
}


let port = drop.config["app", "port"].int ?? 80

// Print what link to visit for default port
drop.serve()
