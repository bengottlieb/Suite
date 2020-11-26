//
//  LoadingState.swift
//  
//
//  Created by ben on 11/26/20.
//

import Foundation

public enum LoadingState<Value> { case idle, loading, failed(Error), loaded(Value) }

