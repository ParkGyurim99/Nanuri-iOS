//
//  LessonInfoViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/01.
//

import Foundation
import Alamofire
import Combine

final class LessonInfoViewModel : ObservableObject {
    @Published var lessonStatus : Bool
    @Published var hostUser : UserInfo?
    
    @Published var seeMore : Bool = false
    @Published var viewOffset : CGFloat = 0
    @Published var isImageTap : Bool = false
    @Published var showDeleteConfirmationMessage : Bool = false
    @Published var showActionSheet : Bool = false
    
    private var subscription = Set<AnyCancellable>()
    
    init(hostUserId : Int, lessonStatus : Bool) {
        self.lessonStatus = lessonStatus
        getHostInfo(hostId: hostUserId)
    }
    
    func getHostInfo(hostId : Int){
        let url = baseURL + "/user/info/\(hostId)"
        
        AF.request(url,
                   method: .get
        ).responseJSON { response in
            print(response)
        }.publishDecodable(type : UserResponse.self)
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
    
    func updateLessonStatus(_ lessonId : Int) {
        guard let token = UserService.shared.userInfo?.token else { return }
        let url = baseURL + "/lesson/\(lessonId)/updateStatus"
        let tokenPayload = token.tokenType + " " + token.accessToken
        let header : HTTPHeaders = [ "X-AUTH-TOKEN" : tokenPayload ]
        
        AF.request(url, method : .put, headers: header)
            .responseJSON { response in print(response) }
    }
    
    func deleteLesson(_ lessonId : Int) {
        guard let token = UserService.shared.userInfo?.token else { return }
        let url = baseURL + "/lesson/\(lessonId)"
        let tokenPayload = token.tokenType + " " + token.accessToken
        let header : HTTPHeaders = [ "X-AUTH-TOKEN" : tokenPayload ]
        
        AF.request(url, method : .delete, headers: header)
            .responseJSON { response in print(response) }
    }
}
