//
//  LessonApplicantModalViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/16.
//

import Foundation
import Alamofire
import Combine

final class LessonApplicantModalViewModel : ObservableObject {
    @Published var applicants : [Applicant] = []
    @Published var applicantsInfo : [Int : UserInfo] = [:]
    @Published var isFetching : Bool = true
    
    private var subscription = Set<AnyCancellable>()

    func getApplicant(_ lessonId : Int) {
        let url = baseURL + "/lesson/\(lessonId)/registration"
        
        AF.request(url,
                   method : .get,
                   interceptor : authorizationInterceptor())
            .validate()
            .responseJSON {response in print(response) }
            .publishDecodable(type : ApplicantInfo.self)
            .compactMap { $0.value }
            .map { $0.body }
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error) :
                    print(error.localizedDescription)
                case .finished :
                    print("Get Applicant Finished")
                    self?.isFetching = false
                }
            } receiveValue: { [weak self] receivedValue in
                self?.applicants = receivedValue
            }.store(in: &subscription)
    }
    func acceptUser(lessonId : Int, userId : Int) {
        let url = baseURL + "/lesson/\(lessonId)/registration/accept/\(userId)"
        
        AF.request(url,
                   method : .put,
                   interceptor : authorizationInterceptor()
        ).validate()
        .responseJSON { response in print(response) }
    }
    func rejectUser(lessonId : Int, userId : Int) {
        let url = baseURL + "/lesson/\(lessonId)/registration/deny/\(userId)"
        
        AF.request(url,
                   method : .put,
                   interceptor : authorizationInterceptor()
        ).validate()
        .responseJSON { response in print(response) }
    }
}
