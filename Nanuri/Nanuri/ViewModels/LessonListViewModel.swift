//
//  LessonListViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/30.
//

import Foundation
import Combine
import Alamofire

final class LessonListViewModel : ObservableObject {
    @Published var selectedDistrict : String = ""
    
    @Published var LessonList : [Lesson] = []
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
    
    @Published var isFetching : Bool = true
    
    @Published var showLessonCreationView : Bool = false
    @Published var showNeedToLoginAlert : Bool = false
    
    @Published var isSearching : Bool = false
    @Published var searchingText : String = ""
    
    @Published var selectedClassId = 0
    @Published var detailViewShow : Bool = false
    
    @Published var sort_OnlyAvailable : Bool = false
    
    private var subscription = Set<AnyCancellable>()
    
    func fetchLessons() {
        var url = baseURL + "/lesson/"
        if selectedDistrict != "모든지역" { url += selectedDistrict }
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serviceURL = URL(string: encodedURL)!
        
        isFetching = true
        
        AF.request(serviceURL,
                   method: .get
        )
        .responseJSON { [weak self] response in
            guard let statusCode = response.response?.statusCode else { return }
            if statusCode == 200 { self?.isFetching = false }
            print("statusCode : \(statusCode)")
            print(response)
        }
        .publishDecodable(type : Lessons.self)
        .compactMap { $0.value }
        .map { $0.body }
        .sink { completion in
            switch completion {
            case let .failure(error) :
                print(error.localizedDescription)
            case .finished :
                print("Get Lesson Finished")
            }
        } receiveValue: { [weak self] recievedValue in
            //print(recievedValue)
            self?.LessonList = recievedValue.reversed()
            //print(self?.LessonList)
        }.store(in: &subscription)
    }
}
