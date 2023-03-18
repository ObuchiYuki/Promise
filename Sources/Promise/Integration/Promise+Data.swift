//
//  Promise+Data.swift
//  
//
//  Created by yuki on 2021/10/24.
//

#if canImport(Foundation)
import Foundation

extension Data {
    public static func async(contentsOf url: URL) -> Promise<Data, Error> {
        URLSession.shared.data(for: url)
    }
}
#endif
