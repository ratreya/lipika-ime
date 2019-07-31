/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2019 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Foundation

class AsyncDispatcher {
    private var pendingWorkItems = [String: DispatchWorkItem]()
    
    func schedule(deadline: DispatchTime, work: @escaping () -> Void) {
        let id = UUID().uuidString
        pendingWorkItems[id] = DispatchWorkItem(block: work)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
            self.pendingWorkItems[id]?.perform()
            self.pendingWorkItems.removeValue(forKey: id)
        }
    }
    
    func cancelAll() {
        pendingWorkItems.values.forEach() { $0.cancel() }
        pendingWorkItems.removeAll()
    }
}
