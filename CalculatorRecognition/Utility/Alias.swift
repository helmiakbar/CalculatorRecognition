//
//  Alias.swift
//  CalculatorRecognition
//
//  Created by tamu on 23/03/23.
//

import Foundation

// Custom Result + Custom Return
typealias SingleResultWithReturn<T, ReturnType> = ((T) -> ReturnType)
typealias DoubleResultWithReturn<T1, T2, ReturnType> = ((T1, T2) -> ReturnType)
typealias TripleResultWithReturn<T1, T2, T3, ReturnType> = ((T1, T2, T3) -> ReturnType)
// Max limit should be three arguments only

// Custom Result + Void Return
typealias SingleResult<T> = SingleResultWithReturn<T, Void>
typealias DoubleResult<T1, T2> = DoubleResultWithReturn<T1, T2, Void>
typealias TripleResult<T1, T2, T3> = TripleResultWithReturn<T1, T2, T3, Void>
