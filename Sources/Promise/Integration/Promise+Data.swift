//
//  Promise+Data.swift
//  
//
//  Created by yuki on 2021/10/24.
//

import Foundation

extension Data {
    public static func async(contentsOf url: URL) -> Promise<Data, Error> {
        Promise.asyncError(on: .global()) { resolve, _ in
            try resolve(self.init(contentsOf: url))
        }
    }
}
