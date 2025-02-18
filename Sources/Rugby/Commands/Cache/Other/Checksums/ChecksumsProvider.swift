//
//  ChecksumsProvider.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct Checksum {
    static let separator = ": "
    let name: String
    var value: String

    var string: String { name + Self.separator + value }

    init?(string: String) {
        let parts = string.components(separatedBy: Self.separator)
        guard parts.count == 2 else { return nil }
        self.name = parts[0].trimmingCharacters(in: ["\""])
        self.value = parts[1]
    }

    init(name: String, checksum: String) {
        self.name = name
        self.value = checksum
    }
}

final class ChecksumsProvider {
    private let podsProvider = PodsProvider.shared
    private var cachedChecksums: [String: Checksum]?

    func getChecksums(forPods pods: Set<String>) throws -> [Checksum] {
        let selectedCachedChecksums = pods.compactMap { cachedChecksums?[$0] }
        if selectedCachedChecksums.count == pods.count { return selectedCachedChecksums }

        let checksums = try podsProvider.pods()
            .filter { pods.contains($0.name) }
            .map { try $0.combinedChecksum() }

        cachedChecksums = checksums.reduce(into: [:]) { $0[$1.name] = $1 }
        return checksums
    }
}
