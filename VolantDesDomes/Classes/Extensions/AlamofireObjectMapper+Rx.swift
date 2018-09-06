//
//  AlamofireObjectMapper+Rx.swift
//  VolantDesDomes
//
//  Created by Drusy on 28/01/2017.
//  Copyright © 2017 Openium. All rights reserved.
//

import AlamofireObjectMapper
import Alamofire
import ObjectMapper
import RxAlamofire
import RxSwift

// MARK: SessionManager

extension Reactive where Base: SessionManager {
    
    public func responseObject<T: BaseMappable>(_ method: Alamofire.HTTPMethod,
                                                _ url: URLConvertible,
                                                _ parameters: [String: Any]? = nil,
                                                encoding: ParameterEncoding = JSONEncoding.default,
                                                headers: [String: String]? = nil)
        -> Observable<(HTTPURLResponse, T)> {
            
            return request(method, url, parameters: parameters, encoding: encoding, headers: headers)
                .flatMap { request in
                    return request.rx.responseObject()
            }
    }
    
    public func object<T: BaseMappable>(_ method: Alamofire.HTTPMethod,
                                        _ url: URLConvertible,
                                        _ parameters: [String: Any]? = nil,
                                        encoding: ParameterEncoding = JSONEncoding.default,
                                        headers: [String: String]? = nil)
        -> Observable<T> {
            
            return request(method, url, parameters: parameters, encoding: encoding, headers: headers)
                .flatMap { request in
                    return request.rx.object()
            }
    }
    
    public func responseObjectArray<T: BaseMappable>(_ method: Alamofire.HTTPMethod,
                                                     _ url: URLConvertible,
                                                     _ parameters: [String: Any]? = nil,
                                                     keyPath: String? = nil,
                                                     encoding: ParameterEncoding = JSONEncoding.default,
                                                     headers: [String: String]? = nil)
        -> Observable<(HTTPURLResponse, [T])> {
            
            return request(method, url, parameters: parameters, encoding: encoding, headers: headers)
                .flatMap { request in
                    return request.rx.responseObjectArray(keyPath: keyPath)
            }
    }
    
    public func objectArray<T: BaseMappable>(_ method: Alamofire.HTTPMethod,
                                             _ url: URLConvertible,
                                             _ parameters: [String: Any]? = nil,
                                             keyPath: String? = nil,
                                             encoding: ParameterEncoding = JSONEncoding.default,
                                             headers: [String: String]? = nil)
        -> Observable<[T]> {
            return request(
                method,
                url,
                parameters: parameters,
                encoding: encoding,
                headers: headers
                ).flatMap { request in
                    return request.rx.objectArray(keyPath: keyPath)
            }
    }
}

// MARK: DataRequest

extension Reactive where Base: DataRequest {
    
    func responseObject<T: BaseMappable>(queue: DispatchQueue? = nil,
                                         keyPath: String? = nil,
                                         mapToObject object: T? = nil,
                                         context: MapContext? = nil)
        -> Observable<(HTTPURLResponse, T)> {
            
            return Observable.create { observer in
                let dataRequest = self.base.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, context: context) { (packedResponse: DataResponse<T>) in
                    
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
    
    func object<T: BaseMappable>(queue: DispatchQueue? = nil,
                                 keyPath: String? = nil,
                                 mapToObject object: T? = nil,
                                 context: MapContext? = nil)
        -> Observable<T> {
            
            return Observable.create { observer in
                let dataRequest = self.base.responseObject { (packedResponse: DataResponse<T>) in
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
    
    func responseObjectArray<T: BaseMappable>(queue: DispatchQueue? = nil,
                                              keyPath: String? = nil,
                                              context: MapContext? = nil)
        -> Observable<(HTTPURLResponse, [T])> {
            
            return Observable.create { observer in
                let dataRequest = self.base.responseArray(queue: queue, keyPath: keyPath, context: context) { (packedResponse: DataResponse<[T]>) in
                    
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
    
    func objectArray<T: BaseMappable>(queue: DispatchQueue? = nil,
                                      keyPath: String? = nil,
                                      context: MapContext? = nil)
        -> Observable<[T]> {
            
            return Observable.create { observer in
                let dataRequest = self.base.responseArray(queue: queue, keyPath: keyPath, context: context) { (packedResponse: DataResponse<[T]>) in
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
