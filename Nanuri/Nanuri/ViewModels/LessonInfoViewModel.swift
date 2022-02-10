//
//  LessonInfoViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/01.
//

import SwiftUI
import Alamofire

final class LessonInfoViewModel : ObservableObject {
    @Published var lessonStatus : Bool
    
    @Published var seeMore : Bool = false
    @Published var viewOffset : CGFloat = 0
    @Published var isImageTap : Bool = false
    @Published var showDeleteConfirmationMessage : Bool = false
    @Published var showActionSheet : Bool = false
    
    init(lessonStatus : Bool) {
        self.lessonStatus = lessonStatus
    }
    func updateLessonStatus(_ lessonId : Int) {
        let url = baseURL + "/lesson/\(lessonId)/updateStatus"
        guard let token = UserService.shared.userInfo?.token else { return }
        let tokenPayload = token.tokenType + " " + token.accessToken
        let header : HTTPHeaders = [ "X-AUTH-TOKEN" : tokenPayload ]
        
        AF.request(url, method : .put, headers: header)
            .responseJSON { response in print(response) }
    }
    
    func deleteLesson(_ lessonId : Int) {
        let url = baseURL + "/lesson/\(lessonId)"
        guard let token = UserService.shared.userInfo?.token else { return }
        let tokenPayload = token.tokenType + " " + token.accessToken
        let header : HTTPHeaders = [ "X-AUTH-TOKEN" : tokenPayload ]
        
        AF.request(url, method : .delete, headers: header)
            .responseJSON { response in print(response) }
    }
}
