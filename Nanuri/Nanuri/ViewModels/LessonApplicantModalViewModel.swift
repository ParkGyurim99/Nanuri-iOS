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
                    self?.getApplicantInfo()
                }
            } receiveValue: { [weak self] receivedValue in
                self?.applicants = receivedValue
            }.store(in: &subscription)
    }
    
    func getApplicantInfo() {
        if applicants.isEmpty {
            isFetching = false
        } else {
            for user in applicants {
                let userId = user.userId
                let url = baseURL + "/user/info/\(userId)"

                AF.request(url,
                           method: .get
                )//.responseJSON { response in print(response) }
                .publishDecodable(type : UserResponse.self)
                .compactMap { $0.value }
                .map { $0.body }
                .sink { [weak self] completion in
                    switch completion {
                    case let .failure(error) :
                        print(error.localizedDescription)
                    case .finished :
                        print("Get User \(userId)'s info Finished")
                        self?.isFetching = false
                    }
                } receiveValue: { [weak self] recievedValue in
                    self?.applicantsInfo[user.userId] = recievedValue
                }.store(in: &subscription)
            }
        }
    }
    
    func applicationStatus(status : String) -> String {
        switch status {
        case "ACCEPTED" :
            return "수락됨"
        case "DENIED" :
            return "거절됨"
        default :
            return ""
        }
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
    func removeUser(lessonId : Int, userId : Int) {
        let url = baseURL + "/lesson/\(lessonId)/registration/\(userId)"
        
        AF.request(url,
                   method : .delete,
                   interceptor : authorizationInterceptor()
        ).validate()
        .responseJSON { response in print(response) }
    }
}
