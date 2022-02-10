//
//  LessonCreateViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/31.
//

import Foundation
import PhotosUI
import Alamofire

final class LessonCreateViewModel : ObservableObject {
    // Payload - Images
    @Published var showImagePicker : Bool = false
    @Published var selectedImages : [UIImage] = []
    
    // Payload - Text contents
    @Published var titleText : String = ""
    @Published var categoryText : String = ""
    @Published var locationText : String = ""
    @Published var participantLimit : String = ""
    @Published var contentText : String = ""
    
    // Upload Action
    @Published var isUploadProcessing : Bool = false
    @Published var isUploadDone : Bool = false
    @Published var isUploadFail : Bool = false
    
    var payloadFillCheck : Bool {
        selectedImages.isEmpty || titleText.isEmpty || categoryText.isEmpty ||
        locationText.isEmpty || participantLimit.isEmpty || contentText.isEmpty
    } // 한가지라도 비워져 있으면 true
    
    var configuration : PHPickerConfiguration {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 4 - selectedImages.count
        
        return configuration
    }
    
    func upload() {
        let url = baseURL + "/lesson"
        guard let token = UserService.shared.userInfo?.token else { return }
        let tokenPayload = token.tokenType + " " + token.accessToken
        let header : HTTPHeaders = [ "Content-Type" : "multipart/form-data",
                                     "X-AUTH-TOKEN" : tokenPayload ]
        
        AF.upload(multipartFormData: { [weak self] multipartFormData in
            guard let self = self else { return }
            
            for image in self.selectedImages {
                multipartFormData.append(image.jpegData(compressionQuality : 1.0)!, withName : "images", fileName: "classImage.jpg", mimeType: "image/jpeg")
            }
            
            // TEMP CREATOR
//            multipartFormData.append("Test Admin".data(using: .utf8)!, withName : "creator", mimeType: "application/json")
            
            multipartFormData.append(self.titleText.data(using: .utf8)!, withName : "lessonName", mimeType: "application/json")
            multipartFormData.append(self.categoryText.data(using: .utf8)!, withName : "category", mimeType: "application/json")
            multipartFormData.append(self.locationText.data(using: .utf8)!, withName : "location", mimeType: "application/json")
            multipartFormData.append(self.participantLimit.data(using: .utf8)!, withName : "limitedNumber", mimeType: "application/json")
            multipartFormData.append(self.contentText.data(using: .utf8)!, withName : "content", mimeType: "application/json")
        }, to: URL(string : url)!, usingThreshold: UInt64.init(), method: .post, headers: header)
        .responseJSON { [weak self] response in
            guard let statusCode = response.response?.statusCode else { return }
            print(statusCode)
            switch statusCode {
            case 200 :
                print("Upload success")
                self?.isUploadDone = true
            default:
                print("Upload fail")
                self?.isUploadFail = true
            }
        }
    }
}
