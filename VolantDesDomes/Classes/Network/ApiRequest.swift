//
//  ApiRequest.swift
//  GFors
//
//  Created by Drusy on 04/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RxAlamofire
import RxSwift

class BearerRetrier: RequestRetrier {
    
    let disposeBag = DisposeBag()
    var retryCounter = 0
    
    func should(_ manager: SessionManager, retry request: Request, with error: Swift.Error, completion: @escaping RequestRetryCompletion) {
        print("Counter : \(retryCounter)")
        if retryCounter <= 3 {
            if request.response?.statusCode == 401 || request.response?.statusCode == 403 {
                retryCounter += 1
                print("Refresh token -> \(retryCounter)")
                
//                UserManager.shared.refreshToken(force: true)
//                    .ignoreElements()
//                    .observeOn(MainScheduler.instance)
//                    .subscribe(
//                        onCompleted: {
//                            completion(true, 0.0)
//                    },
//                        onError: { error in
//                            print(error)
//                            completion(false, 0.0)
//                    })
//                    .disposed(by: disposeBag)
            } else {
                retryCounter = 0
                completion(false, 0.0)
            }
        } else {
            retryCounter = 0
            completion(false, 0.0)
        }
    }
}

class BearerAdapter: RequestAdapter {
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
//        var urlReq = urlRequest
//
//        if let token = UserManager.shared.token() {
//            urlReq.addValue("Bearer \(token)", forHTTPHeaderField: R.secure.header_authorization)
//        }
        
        return urlRequest
    }
}

class BearerAdapterSessionManager: SessionManager {
    init() {
        super.init()
        
        self.adapter = BearerAdapter()
    }
}

class BearerRetrierSessionManager: BearerAdapterSessionManager {
    override init() {
        super.init()
        
        self.retrier = BearerRetrier()
    }
}

class ApiRequest {
    static let defaultSessionManager = SessionManager.default
    static let bearerRetrierSessionManager = BearerRetrierSessionManager()
    static let bearerAdapterSessionManager = BearerAdapterSessionManager()
    static var hostURL: String {
        return "https://beta.volantdesdomes.fr"
    }
    
    static let headers: [String: String] = [
        "Accept": "application/json",
        "Cache-Control": "no-cache",
        "Accept-Encoding": "gzip"
    ]
    
    // MARK: -
    
    @discardableResult
    static func responseObject<T: StaticMappable, U: Queryable & URLRequestConvertible>(forType type: T.Type, urlRequest: U, handler: ((DataResponse<T>) -> Void)? = nil) -> Request {
        let request = ApiRequest.request(with: urlRequest)
        
        request.responseObject { (response: DataResponse<T>) in
            handler?(response)
        }
        
        return request
    }
    
    static func sessionManager<U: Queryable & URLRequestConvertible>(for urlRequest: U) -> SessionManager {
        var sessionManager = ApiRequest.defaultSessionManager
        
        if urlRequest.isSecured {
            sessionManager = urlRequest.shouldUseBearerRetrierIfSecured ? ApiRequest.bearerRetrierSessionManager : ApiRequest.bearerAdapterSessionManager
        }
        
        return sessionManager
    }
    
    static func request<U: Queryable & URLRequestConvertible>(with urlRequest: U) -> DataRequest {
        return ApiRequest.sessionManager(for: urlRequest).request(urlRequest).validate().debugLog()
    }
    
    static func upload<U: Queryable & URLRequestConvertible>(with urlRequest: U, data: @escaping (MultipartFormData) -> Void) -> Observable<UploadRequest> {
        return ApiRequest.sessionManager(for: urlRequest).rx.encodeMultipartUpload(to: urlRequest, data: data)
    }
    
    // MARK: - Classic way
    
    static func startUploadQuery<T: StaticMappable, U: Queryable & URLRequestConvertible>(
        forType type: T.Type,
        urlRequest: U,
        data: Data,
        name: String,
        fileExtension: String,
        mimeType: String,
        successHandler: @escaping (_ response: DataResponse<T>) -> Void,
        errorHandler: @escaping (_ error: Error) -> Void,
        progressHandler: ((_ progress: Progress) -> Void)? = nil) {
        
        let parameters = urlRequest.parameters() ?? [:]
        var sessionManager = ApiRequest.defaultSessionManager
        
        if urlRequest.isSecured {
            sessionManager = urlRequest.shouldUseBearerRetrierIfSecured ? ApiRequest.bearerRetrierSessionManager : ApiRequest.bearerAdapterSessionManager
        }
        
        let encodingCompletionHandler: (SessionManager.MultipartFormDataEncodingResult) -> Void = { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress { progress in
                    progressHandler?(progress)
                }
                upload.validate().debugLog()
                upload.responseObject { (response: DataResponse<T>) in
                    if let error = response.result.error {
                        errorHandler(error)
                    } else {
                        successHandler(response)
                    }
                }
            case .failure(let encodingError):
                errorHandler(encodingError)
            }
        }
        
        let multipartFormData: (MultipartFormData) -> Void = { multipartFormData in
            multipartFormData.append(
                data,
                withName: name,
                fileName: name,
                mimeType: mimeType)
            
            for (key, value) in parameters {
                guard let paramData = value.data(using: String.Encoding.utf8.rawValue) else { return }
                multipartFormData.append(paramData, withName: key)
            }
        }
        
        sessionManager.upload(multipartFormData: multipartFormData, with: urlRequest, encodingCompletion: encodingCompletionHandler)
    }
}
