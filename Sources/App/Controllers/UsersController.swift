import Vapor
import FluentProvider

struct UsersController {

    func addRoutes(to drop: Droplet) {
        // Create route group under /api/reminders/
        let userGroup = drop.grouped("api", "users")
        
        // Create user route
        userGroup.post("create", handler: createUser)
        
        // Get all users route
        userGroup.get(handler: allUsers)
        
        // Get single user route
        userGroup.get(User.parameter, handler: getUser)
    }
    
    // Return new user object
    func createUser(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }
        let user = try User(json: json)
        try user.save()
        return user
    }
    
    // Return all users
    func allUsers(_ req: Request) throws -> ResponseRepresentable {
        let users = try User.all()
        return try users.makeJSON()
    }
    
    // Return single user
    func getUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return user
    }
}
