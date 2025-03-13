import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SocialFeed")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Ошибка загрузки CoreData: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения данных: \(error)")
            }
        }
    }
    
    // Сохранение поста в CoreData
    func savePost(_ post: Post) {
        let postEntity = PostEntity(context: context)
        postEntity.id = Int64(post.id)
        postEntity.title = post.title
        postEntity.body = post.body
        saveContext()
    }

    // Загрузка сохраненных постов
    func fetchSavedPosts() -> [Post] {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        do {
            let postEntities = try context.fetch(request)
            return postEntities.map { Post(id: Int($0.id), title: $0.title ?? "", body: $0.body ?? "") }
        } catch {
            print("Ошибка загрузки данных: \(error)")
            return []
        }
    }
}
