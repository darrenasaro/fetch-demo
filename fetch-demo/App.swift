import SwiftUI
import CoreImage
import CoreStore
import CoreData

@main
struct App: SwiftUI.App {
  init() {
    let coreData = CoreDataWrapper()
    coreData.populate()
    print("CoreData fetch: \(coreData.fetch())")
    
    let coreStore = CoreStoreWrapper()
    print("CoreStore fetch: \(coreStore.fetch())")
  }

  var body: some Scene {
    WindowGroup {
      EmptyView()
    }
  }
}

let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let sqliteFileUrl = documentsPath.appendingPathComponent("Model.sqlite")

class CoreDataWrapper {
  private let context: NSManagedObjectContext
  
  init() {
    let container = NSPersistentContainer(name: "Model")
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: container.managedObjectModel)
    
    try! coordinator.addPersistentStore(
      ofType: NSSQLiteStoreType,
      configurationName: nil,
      at: sqliteFileUrl,
      options: [:]
    )
    container.loadPersistentStores { _, _ in }
    
    context = container.viewContext
  }
  
  func populate() {
    ["a", "b", "c"].forEach {
      let model = NSEntityDescription.insertNewObject(forEntityName: "EntityA", into: context) as! EntityA
      model.id = $0
    }
    try! context.save()
  }
  
  func fetch() -> [EntityA] {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EntityA")
    return try! context.fetch(fetchRequest) as! [EntityA]
  }
}

class CoreStoreWrapper {
  private let dataStack: DataStack
  
  init() {
    dataStack = DataStack(xcodeModelName: "Model")
    let storage = SQLiteStore(fileURL: sqliteFileUrl)
    try! dataStack.addStorageAndWait(storage)
  }
  
  func fetch() -> [EntityA] {
    return try! dataStack.fetchAll(From<EntityA>(nil))
  }
}
