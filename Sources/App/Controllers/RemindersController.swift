import Vapor
import FluentProvider

struct RemindersController {
    
    func addRoutes(to drop: Droplet) {
        // Create route group under /api/reminders/
        let reminderGroup = drop.grouped("api", "reminders")
        
        // Register a new POST route at /api/reminders/create
        reminderGroup.post("create", handler: createReminder)
        
        // Register a new GET route at /api/reminders to get all reminders
        reminderGroup.get(handler: allReminders)
        
        // Register a new GET route at /api/reminders to get single reminder
        reminderGroup.get(Reminder.parameter, handler: getReminder)
        
        // Register a new GET route at /api/reminders/<ID>/categories/
        reminderGroup.get(Reminder.parameter, "categories", handler: getRemindersCategories)
    }
    
    // Create new reminder using JSON body
    // Return reminder
    func createReminder(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }
        
        let reminder = try Reminder(json: json)
        try reminder.save()
        
        if let categories = json["categories"]?.array {
            for categoryJSON in categories {
                guard let categoryName = categoryJSON.string else {
                    throw Abort.badRequest
                }
                try Category.addCategory(categoryName, to: reminder)
            }
        }
        
        return reminder
    }
    
    // Return all reminders
    func allReminders(_ req: Request) throws -> ResponseRepresentable {
        let reminders = try Reminder.all()
        return try reminders.makeJSON()
    }
    
    // Return a single reminder
    func getReminder(_ req: Request) throws -> ResponseRepresentable {
        let reminder = try req.parameters.next(Reminder.self)  // Pull out model or throw error
        return reminder
    }
    
    // Get categories for reminder
    func getRemindersCategories(_ req: Request) throws -> ResponseRepresentable {
        let reminder = try req.parameters.next(Reminder.self)
        return try reminder.categories.all().makeJSON()
    }
}
