import CoreData

@objc(PostEntity)
public class PostEntity: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var body: String?
}

extension PostEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostEntity> {
        return NSFetchRequest<PostEntity>(entityName: "PostEntity")
    }
}
