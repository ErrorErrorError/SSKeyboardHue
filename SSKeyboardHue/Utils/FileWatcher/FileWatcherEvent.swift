import Foundation
/**
 * - Parameters:
 *    - id: is an id number that the os uses to differentiate between events.
 *    - path: is the path the change took place. its formated like so: Users/John/Desktop/test/text.txt
 *    - flag: pertains to the file event type.
 * ## Examples:
 * let url = NSURL(fileURLWithPath: event.path)//<--formats paths to: file:///Users/John/Desktop/test/text.txt
 * Swift.print("fileWatcherEvent.fileChange: " + "\(event.fileChange)")
 * Swift.print("fileWatcherEvent.fileModified: " + "\(event.fileModified)")
 * Swift.print("\t eventId: \(event.id) - eventFlags:  \(event.flags) - eventPath:  \(event.path)")
 */
public class FileWatcherEvent {
    public var id: FSEventStreamEventId
    public var path: URL
    public var flags: FSEventStreamEventFlags
    init(_ eventId: FSEventStreamEventId, _ eventPath: URL, _ eventFlags: FSEventStreamEventFlags) {
        self.id = eventId
        self.path = eventPath
        self.flags = eventFlags
    }
}
/**
 * The following code is to differentiate between the FSEvent flag types (aka file event types)
 * - Remark: Be aware that .DS_STORE changes frequently when other files change
 */
extension FileWatcherEvent {
    /*general*/
    var fileChange: Bool { return (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsFile)) != 0 }
    var dirChange: Bool { return (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsDir)) != 0 }
    /*CRUD*/
    var created: Bool { return (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated)) != 0 }
    var removed: Bool { return (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved)) != 0 }
    var renamed: Bool { return (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed)) != 0 }
    var modified: Bool { return (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified)) != 0 }
}
/**
 * Convenince
 */
extension FileWatcherEvent {
    public var eventOccuedWithLocation : EventAndLocation {
        var eventType: FileWatcherEventTypes
        if (fileChange) {
            if (created) {
                eventType = FileWatcherEventTypes.fileCreated
            } else if (removed) {
                eventType = FileWatcherEventTypes.fileRemoved
            } else if (renamed) {
                eventType = FileWatcherEventTypes.fileRenamed
            } else {
                eventType = FileWatcherEventTypes.fileModified
            }
        } else if (dirChange) {
            if (created) {
                eventType = FileWatcherEventTypes.dirCreated
            } else if (removed) {
                eventType = FileWatcherEventTypes.dirRemoved
            } else if (renamed) {
                eventType = FileWatcherEventTypes.dirRenamed
            } else {
                eventType = FileWatcherEventTypes.dirModifier
            }
        } else {
            eventType = FileWatcherEventTypes.none
        }
        
        return EventAndLocation(eventType: eventType, path: self.path)
    }
}

extension FileWatcherEvent {
    public struct EventAndLocation {
        var eventType: FileWatcherEventTypes
        var path: URL
    }
}

extension FileWatcherEvent {
    public enum FileWatcherEventTypes {
        case fileCreated
        case fileRemoved
        case fileRenamed
        case fileModified
        case dirCreated
        case dirRemoved
        case dirRenamed
        case dirModifier
        case none
    }
}

/**
 * Simplifies debugging
 * ## Examples:
 * Swift.print(event.description)//Outputs: The file /Users/John/Desktop/test/text.txt was modified
 */
extension FileWatcherEvent {
    public var description: String {
        var result = "The \(fileChange ? "file":"directory") \(self.path.path) was"
        if self.removed { result += " removed" }
        else if self.created { result += " created" }
        else if self.renamed { result += " renamed" }
        else if self.modified { result += " modified" }
        return result
    }
}
