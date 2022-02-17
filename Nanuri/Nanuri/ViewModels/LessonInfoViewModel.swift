//
//  LessonInfoViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/01.
//

import SwiftUI
import Alamofire
import Combine

final class LessonInfoViewModel : ObservableObject {
    @Published var lesson : Lesson
    @Published var hostUser : UserInfo?
    
    @Published var seeMore : Bool = false
    @Published var viewOffset : CGFloat = 0
    @Published var isImageTap : Bool = false
    
    @Published var showAlert : Bool = false
    @Published var alertType = 0
    @Published var showDeleteConfirmationMessage : Bool = false
    
    @Published var showActionSheet : Bool = false
    @Published var actionSheetType : Int = 0
    @Published var showApplicant : Bool = false
    @Published var showParticipant : Bool = false
    
    private var subscription = Set<AnyCancellable>()
    
    init(hostUserId : Int, lesson : Lesson) {
        self.lesson = lesson
        getHostInfo(hostId: hostUserId)
    }
    
    func fetchLessonInfo() {
        let url = baseURL + "/lesson/info/\(lesson.lessonId)"
        
        AF.request(url, method: .get)
            .publishDecodable(type : LessonInfo.self)
            .compactMap { $0.value }
            .map { $0.body }
            .sink { completion in
                switch completion {
                case let .failure(error) :
                    print(error.localizedDescription)
                case .finished :
                    print("Get Lesson Info Finished")
                }
            } receiveValue: { [weak self] receivedValue in
                self?.lesson = receivedValue
            }.store(in: &subscription)
    }
    
    func getHostInfo(hostId : Int){
        let url = baseURL + "/user/info/\(hostId)"
        
        AF.request(url,
                   method: .get
        ).responseJSON { response in print(response) }
        .publishDecodable(type : UserResponse.self)
        .compactMap { $0.value }
        .map { $0.body }
        .sink { completion in
            switch completion {
            case let .failure(error) :
                print(error.localizedDescription)
            case .finished :
                print("Get UserInfo Finished")
            }
        } receiveValue: { [weak self] recievedValue in
            //print(recievedValue)
            self?.hostUser = recievedValue
        }.store(in: &subscription)
    }
    
    // Lesson owner
    func updateLessonStatus(_ lessonId : Int) {
        let url = baseURL + "/lesson/\(lessonId)/updateStatus"
        
        print("Update status")
        AF.request(url,
                   method : .put,
                   interceptor: authorizationInterceptor())
            .validate()
            .responseJSON { response in print("Update lesson status (\(response.response?.statusCode ?? 0))") }
    }
    
    func deleteLesson(_ lessonId : Int) {
        let url = baseURL + "/lesson/\(lessonId)"

        AF.request(url,
                   method : .delete,
                   interceptor: authorizationInterceptor())
            .validate()
            .responseJSON { response in print("Delete lesson (\(response.response?.statusCode ?? 0))") }
    }
    
    // Lesson participant
    func participateLesson(_ lessonId : Int) {
        let url = baseURL + "/lesson/\(lessonId)/registration"
        
        print(url)
        AF.request(url,
                   method : .post,
                   parameters: [ "registrationForm" : "mm" ],
                   encoder: JSONParameterEncoder.prettyPrinted,
                   interceptor: authorizationInterceptor())
            .validate()
            .responseJSON { response in print(response) }
    }
}
