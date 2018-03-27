//
//  RecordsManager.swift
//  TestTask
//
//  Created by Vadim Rupets on 3/27/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

class RecordsManager {

    private var recordsFilePath: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("records")
    }

    func fetchRecords() -> [Record] {
        guard
            let data = try? Data(contentsOf: recordsFilePath),
            let records = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Record] else {
            return []
        }

        return records
    }

    func saveRecords(_ records: [Record]) throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: records)
        try data.write(to: recordsFilePath)
    }

}
