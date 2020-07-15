//
//  AlamofireObjectMapper+Rx.swift
//  VolantDesDomes
//
//  Created by Drusy on 15/03/2019.
//  Copyright © 2019 Openium. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import Alamofire
import ObjectMapper
import RxAlamofire
import RxSwift

// MARK: SessionManager

extension Reactive where Base: Session {
    
    public func responseObject<T: BaseMappable>(_ url: URLRequestConvertible)
        -> Observable<(HTTPURLResponse, T)> {
            
            return request(urlRequest: url)
                .validate()
                .debugLog()
                .flatMap { request in
                    return request.rx.responseObject()
            }
    }
    
    public func object<T: BaseMappable>(_ url: URLRequestConvertible)
        -> Observable<T> {
            return request(urlRequest: url)
                .validate()
                .debugLog()
                .flatMap { request in
                    return request.rx.object()
            }
    }
    
    public func responseObjectArray<T: BaseMappable>(_ url: URLRequestConvertible, keyPath: String? = nil)
        -> Observable<(HTTPURLResponse, [T])> {
            
            return request(urlRequest: url)
                .validate()
                .debugLog()
                .flatMap { request in
                    return request.rx.responseObjectArray(keyPath: keyPath)
            }
    }
    
    public func objectArray<T: BaseMappable>(_ url: URLRequestConvertible, keyPath: String? = nil)
        -> Observable<[T]> {
            return request(urlRequest: url)
                .validate()
                .debugLog()
                .flatMap { request in
                    return request.rx.objectArray(keyPath: keyPath)
            }
    }
}

// MARK: DataRequest

extension Reactive where Base: DataRequest {
    
    fileprivate func responseObject<T: BaseMappable>(queue: DispatchQueue = .main,
                                                     keyPath: String? = nil,
                                                     mapToObject object: T? = nil,
                                                     context: MapContext? = nil)
        -> Observable<(HTTPURLResponse, T)> {
            
            return Observable.create { observer in
                
                let dataRequest = self.base.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, context: context) { packedResponse in
                    
                    switch packedResponse.result {
                    case .success(let result):
                        if let httpResponse = packedResponse.response {
                            observer.on(.next((httpResponse, result)))
                        } else {
                            observer.on(.error(RxAlamofireUnknownError))
                        }
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error as Error))
                    }
                }
                
                return Disposables.create {
                    dataRequest.cancel()
                }
            }
    }
    
    fileprivate func object<T: BaseMappable>(queue: DispatchQueue = .main,
                                             keyPath: String? = nil,
                                             mapToObject object: T? = nil,
                                             context: MapContext? = nil)
        -> Observable<T> {
            
            return Observable.create { observer in
                let dataRequest = self.base.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, context: context) { (packedResponse: DataResponse<T, AFError>) in
                    switch packedResponse.result {
                    case .success(let result):
                        if packedResponse.response != nil {
                            observer.on(.next(result))
                        } else {
                            observer.on(.error(RxAlamofireUnknownError))
                        }
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error as Error))
                    }
                }
                
                return Disposables.create {
                    dataRequest.cancel()
                }
            }
    }
    
    fileprivate func responseObjectArray<T: BaseMappable>(queue: DispatchQueue = .main,
                                                          keyPath: String? = nil,
                                                          context: MapContext? = nil)
        -> Observable<(HTTPURLResponse, [T])> {
            
            return Observable.create { observer in
                let dataRequest = self.base.responseArray(queue: queue, keyPath: keyPath, context: context) { (packedResponse: DataResponse<[T], AFError>) in
                    
                    switch packedResponse.result {
                    case .success(let result):
                        if let httpResponse = packedResponse.response {
                            observer.on(.next((httpResponse, result)))
                        } else {
                            observer.on(.error(RxAlamofireUnknownError))
                        }
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error as Error))
                    }
                }
                
                return Disposables.create {
                    dataRequest.cancel()
                }
            }
    }
    
    fileprivate func objectArray<T: BaseMappable>(queue: DispatchQueue = .main,
                                                  keyPath: String? = nil,
                                                  context: MapContext? = nil)
        -> Observable<[T]> {
            
            return Observable.create { observer in
                let dataRequest = self.base.responseArray(queue: queue, keyPath: keyPath, context: context) { (packedResponse: DataResponse<[T], AFError>) in
                    switch packedResponse.result {
                    case .success(let result):
                        if packedResponse.response != nil {
                            observer.on(.next(result))
                        } else {
                            observer.on(.error(RxAlamofireUnknownError))
                        }
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error as Error))
                    }
                }
                
                return Disposables.create {
                    dataRequest.cancel()
                }
            }
    }
}
