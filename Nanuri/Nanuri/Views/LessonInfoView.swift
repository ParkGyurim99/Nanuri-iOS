//
//  LessonInfoView.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/28.
//

import SwiftUI
import Kingfisher

struct LessonInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel : LessonInfoViewModel
    
    private let isMyPost : Bool
    
    init(_ creatorId : Int, viewModel : LessonInfoViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        if creatorId == UserService.shared.userInfo?.userId { self.isMyPost = true }
        else { self.isMyPost = false }
    }
    
    var Title : some View {
        HStack {
            VStack(alignment : .leading, spacing : 5) {
                Text(viewModel.lesson.lessonName)
                    .font(.title)
                    .fontWeight(.bold)
                Text(convertReturnedDateString(viewModel.lesson.createDate) + " #" + viewModel.lesson.category)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(spacing : 5) {
                Text("\(viewModel.lesson.participantNumber)명 / \(viewModel.lesson.limitedNumber)명")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(viewModel.lesson.status ? "모집중" : "모집완료")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(viewModel.lesson.status ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                    .cornerRadius(20)
            }
        }.padding(.horizontal)
    }
    
    var MemberInfo : some View {
        VStack {
            Divider().frame(width : UIScreen.main.bounds.width * 0.9)
            if let host = viewModel.hostUser {
                HStack(spacing : 15) {
                    KFImage(URL(string : host.imageUrl) ??
                            URL(string: "https://phito.be/wp-content/uploads/2020/01/placeholder.png")!
                    ).resizable()
                    .fade(duration: 0.5)
                    .aspectRatio(contentMode : .fill)
                    .frame(width : UIScreen.main.bounds.width * 0.15,
                           height : UIScreen.main.bounds.width * 0.15)
                    .clipShape(Circle())
                    
                    VStack(alignment : .leading, spacing : 5) {
                        Text(host.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            
                        Text(host.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName : "person.fill")
                        .font(.system(size: 25))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.darkGray)
                        .clipShape(Circle())
                    Text("유저 정보 찾을 수 없음")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.darkGray)
                    Spacer()
                }
            }
            Divider().frame(width : UIScreen.main.bounds.width * 0.9)
        }.padding(.horizontal)
    }
    
    var ClassActionBar : some View {
        VStack {
            Divider()
            if isMyPost {
                HStack {
                   Spacer()
                    Button {
                        viewModel.actionSheetType = 0
                        viewModel.showActionSheet = true
                    } label : {
                        HStack {
                            Text("클래스 설정")
                                .fontWeight(.semibold)
                                .foregroundColor(.darkGray)
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size : 25))
                                .foregroundColor(.darkGray)
                        }.padding(5)
                        .padding(.horizontal)
                    }
                }
            } else {
                if UserService.shared.userInfo == nil {
                    Text("로그인 후 신청할 수 있습니다 😆")
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                // 참가자인지 확인하는 과정 필요
                // else if  {이미 참가한 클래스입니다.}
                Button {
                    viewModel.actionSheetType = 1
                    viewModel.showActionSheet = true
                } label : {
                    Text("신청하기")
                        .strikethrough(!viewModel.lesson.status)
                        .foregroundColor(.white)
                        .frame(width : UIScreen.main.bounds.width * 0.9, height: 50)
                        .background(Color.blue.opacity(viewModel.lesson.status  ? 1.0 : 0.5))
                        .cornerRadius(20)
                }.disabled(!viewModel.lesson.status || UserService.shared.userInfo == nil)
                    .opacity(UserService.shared.userInfo == nil  ? 0.5 : 1)
            }
        }
    }
    
    var body: some View {
        VStack {
            TabView {
                if viewModel.lesson.images.isEmpty {
                    Color.blue
                        .edgesIgnoringSafeArea(.top)
                } else {
                    ForEach(viewModel.lesson.images, id : \.self) { image in
                        KFImage(URL(string : image.lessonImgId.lessonImg)
                                ?? URL(string : "https://www.publicdomainpictures.net/pictures/280000/velka/not-found-image-15383864787lu.jpg")!)
                            .fade(duration : 0.5)
                            .resizable()
                            .aspectRatio(contentMode: viewModel.isImageTap ? .fit : .fill)
                            .edgesIgnoringSafeArea(.top)
                    }
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .frame(width: UIScreen.main.bounds.width, height: viewModel.isImageTap ? UIScreen.main.bounds.height * 0.9: UIScreen.main.bounds.height * 0.45)
            .zIndex(5)
            .overlay (
                VStack {
                    Spacer().frame(height : UIScreen.main.bounds.height * 0.04)
                    HStack {
                        Spacer()
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label : {
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                                .opacity(0.8)
                        }.padding()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring()) { viewModel.isImageTap.toggle() }
                        } label : {
                            Image(systemName: viewModel.isImageTap ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                                .opacity(0.8)
                        }.padding()
                    }
                }
            )
            
            if !viewModel.isImageTap {
                Title
                MemberInfo
                Text(viewModel.lesson.location)
                    .font(.footnote)
                    .fontWeight(.light)
                    .frame(maxWidth : .infinity, alignment : .trailing)
                    .padding(.horizontal)

                ScrollView {
                    Text(viewModel.lesson.content)
                        .frame(maxWidth : .infinity, alignment : .leading)
                        .padding(.horizontal)
                        .lineLimit(viewModel.seeMore ? .max : 4)
                        .font(.system(.body, design: .rounded))
                    
                    Button {
                        viewModel.seeMore.toggle()
                    } label : {
                        Text(viewModel.seeMore ? "접기" : "> 더보기")
                            .foregroundColor(.gray)
                            .font(.callout)
                            .frame(maxWidth : .infinity, alignment : .trailing)
                            .padding(.horizontal)
                    }
                }
                Spacer()
                ClassActionBar
            }
        }.offset(y : viewModel.viewOffset)
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.fetchLessonInfo() }
        .sheet(isPresented: $viewModel.showApplicant, onDismiss: viewModel.fetchLessonInfo) {
            LessonApplicantModalView(isPresented : $viewModel.showApplicant, lessonId : viewModel.lesson.lessonId)
        }
        .sheet(isPresented: $viewModel.showParticipant, onDismiss: viewModel.fetchLessonInfo) {
            LessonParticipantModalView(isPresented: $viewModel.showParticipant, lessonId: viewModel.lesson.lessonId)
        }
        .actionSheet(isPresented: $viewModel.showActionSheet) {
            if viewModel.actionSheetType == 0 {
                return ActionSheet(title: Text("클래스 설정"),
                            buttons: [
                                .default(Text("신청자 관리")) {
                                    viewModel.showApplicant = true
                                },
                                .default(Text("참가자 관리")) {
                                    viewModel.showParticipant = true
                                },
                                .default(Text("모집 상태 변경")) {
                                    viewModel.updateLessonStatus(viewModel.lesson.lessonId)
                                    //presentationMode.wrappedValue.dismiss()
                                    viewModel.lesson.status.toggle()
                                },
                                .destructive(Text("클래스 삭제")) {
                                    viewModel.alertType = 0
                                    viewModel.showAlert = true
                                },
                                .cancel(Text("취소"))
                            ]
                )
            } else {
                return ActionSheet(title: Text("해당 클래스를 신청하시겠습니까?"),
                            buttons: [
                                .default(Text("신청하기")) {
                                    viewModel.participateLesson(viewModel.lesson.lessonId)
                                    viewModel.alertType = 1
                                    viewModel.showAlert = true
                                },
                                .cancel(Text("취소"))
                            ]
                )
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            if viewModel.alertType == 0 {
                return Alert(title: Text("알림\n"),
                      message : Text("클래스를 삭제하시겠습니까?"),
                      primaryButton: .destructive(Text("클래스 삭제")) {
                                            viewModel.deleteLesson(viewModel.lesson.lessonId)
                                            presentationMode.wrappedValue.dismiss()
                                    },
                      secondaryButton: .cancel(Text("취소"))
                )
            } else { // alertType == 1
                return Alert(title: Text("클래스 신청 완료 😁\n"),
                            message : Text("클래스 개설자의 승인 후 수강이 확정됩니다."),
                            dismissButton: .default(Text("확인"))
                )
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if 0 < gesture.translation.height && gesture.translation.height < 50 {
                        withAnimation(.spring()) { viewModel.viewOffset = gesture.translation.height }
                    }
                }
                .onEnded { gesture in
                    if gesture.translation.height > 70 {
                        withAnimation(.spring()) { presentationMode.wrappedValue.dismiss() }
                    } else {
                        withAnimation(.spring())  { viewModel.viewOffset = 0 }
                    }
                }
        )
    }
}
