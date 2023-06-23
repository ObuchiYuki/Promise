//
//  File.swift
//  
//
//  Created by yuki on 2023/06/23.
//

public protocol PromiseProtocol<Output, Failure> {
    associatedtype Output
    associatedtype Failure: Error
    
    func subscribe(_ resolve: @escaping (Output) -> (), _ reject: @escaping (Failure) -> ())
    func reject(_ failure: Failure)
    func fulfill(_ output: Output)
}
