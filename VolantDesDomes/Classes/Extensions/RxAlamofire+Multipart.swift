//
//  RxAlamofire+Multipart.swift
//  VolantDesDomes
//
//  Created by Drusy on 12/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

extension Reactive where Base: SessionManager {
    func encodeMultipartUpload(to url: URLRequestConvertible, method: HTTPMethod = .post, headers: HTTPHeaders = [:], data: @escaping (MultipartFormData) -> Void) -> Observable<UploadRequest> {
        return Observable.create { observer in
            self.base.upload(multipartFormData: data, with: url, encodingCompletion: { (result: SessionManager.MultipartFormDataEncodingResult) in
                switch result {
                case .failure(let error):
                    observer.onError(error)
                case .success(let request, _, _):
                    observer.onNext(request)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
}
