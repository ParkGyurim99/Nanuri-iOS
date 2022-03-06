//
//  LessonParticipantModalViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/16.
//

import Foundation
import Alamofire
import Combine

final class LessonParticipantModalViewModel : ObservableObject {
    @Published var participants : [UserInfo] = []
    @Published var participantsInfo : [Int : UserInfo] = [:]
    @Published var isFetching : Bool = true
    @Published var showErrorAlert : Bool = false
    
    private var subscription = Set<AnyCancellable>()
    
    func getParticipant(_ lessonId : Int) {
        let url = baseURL + "/lesson/\(lessonId)/participant"
        print(url)
        AF.request(url,
                   method : .get,
                   interceptor : authorizationInterceptor())
            .validate()
            .responseJSON {response in print(response) }
            .publishDecodable(type : ParticipantInfo.self)
            .compactMap { $0.value }
            .map { $0.body }
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error) :
                    print(error.localizedDescription)
                case .finished :
                    print("Get Participant Finished")
                    self?.isFetching = false
                }
            } receiveValue: { [weak self] receivedValue in
                self?.participants = receivedValue
            }.store(in: &subscription)
    }
    
    func deleteParticipant(_ lessonId : Int, _ userId : Int, completion : @escaping (Result<Bool, Error>) -> ()) {
        let url = baseURL + "/lesson/\(lessonId)/participant/\(userId)"
        
        AF.request(url,
                   method: .delete,
                   interceptor: authorizationInterceptor()
        ).validate()
        .responseJSON { response in
            print(response)
            guard let statusCode = response.response?.statusCode else { return completion(.success(false))}
            if statusCode == 200 {
                return completion(.success(true))
            }
        }
    }
}
