//
//  MyPageViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/31.
//

import Foundation
import Alamofire
import Combine

class MyPageViewModel : ObservableObject {
    @Published var showLoginProgress : Bool = false
    @Published var lessonHostedByUser : [Lesson] = []
    @Published var selectedLesson : Lesson = Lesson(
                                                lessonId: 0,
                                                creator: 0,
                                                lessonName: "Title",
                                                category: "Category",
                                                location: "Location",
                                                limitedNumber: 5,
                                                content: "Content",
                                                createDate: "",
                                                status: true,
                                                images: []
                                            )
    @Published var detailViewShow : Bool = false
    
    private var subscription = Set<AnyCancellable>()
    
    init() {
        if let userId = UserService.shared.userInfo?.userId {
            getLessonsHostedByUser(hostId: userId)
        }
    }
    
    func getLessonsHostedByUser(hostId : Int) {
        let url = baseURL + "/user/\(hostId)/lesson"
        
        AF.request(url,
                   method: .get,
                   interceptor: authorizationInterceptor()
        )//.responseJSON { response in print(response) }
        .validate()
        .publishDecodable(type : LessonsByUser.self)
        .compactMap { $0.value }
        .map { $0.body.lessonList }
        .sink { completion in
            switch completion {
                case let .failure(error) :
                    print(error.localizedDescription)
                case .finished :
                    print("Get Lessons hosted by user \(hostId) Finished")
            }
        } receiveValue : { [weak self] receivedValue in
            //print(receivedValue)
            self?.lessonHostedByUser = receivedValue
        }.store(in : &subscription)
    }
}
