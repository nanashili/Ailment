//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Ailment

struct MockedReporter: AilmentReporting {

    var ailmentSector: AilmentSector!

    func report() -> AilmentSector {
        return ailmentSector
    }
}
