//
//  LessonListView.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/28.
//

import SwiftUI
import SwiftUIPullToRefresh
import Kingfisher

struct LessonListView: View {
    @StateObject private var viewModel = LessonListViewModel()
    
    @Binding var locationButton : Bool
    @Binding var District : String
    @Binding var selectedTab : Int
    
    init(locationButtonClicked : Binding<Bool>, selectedDistrict : Binding<String>, selectedTab : Binding<Int>) {
        _locationButton = locationButtonClicked
        _District = selectedDistrict
        _selectedTab = selectedTab
    }
    
    var body: some View {
        VStack {
            // Toolbar
            HStack(spacing : 10) {
                Button {
                    withAnimation(.spring()) {
                        locationButton.toggle()
                    }
                } label : {
                    Text(District + " ▾")
                        .foregroundColor(.black)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
                Button {
                    // 로그인 되어 있다면
                    if UserService.shared.userInfo != nil { viewModel.showLessonCreationView = true }
                    else { viewModel.showNeedToLoginAlert = true }
                } label : {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                }
                Button {
                    withAnimation { viewModel.isSearching.toggle() }
                } label : {
                    Image(systemName : "magnifyingglass")
                        .foregroundColor(.black)
                }
            }.padding(.horizontal, 20)
            Divider().padding(.horizontal)
            
            if viewModel.isSearching {
                HStack {
                    TextField("검색", text : $viewModel.searchingText)
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .background(Color.systemDefaultGray)
                        .cornerRadius(20)
                    Button {
                        withAnimation { viewModel.isSearching = false }
                        viewModel.searchingText = ""
                    } label : {
                        Text("취소")
                            .fontWeight(.semibold)
                    }
                }.padding(5)
                .padding(.horizontal, 10)
            }
            
            if viewModel.isFetching {
                VStack(spacing : 10) {
                    Spacer()
                    ProgressView()
                    Text("클래스 로딩중..")
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else if viewModel.LessonList.isEmpty {
                VStack(spacing : 10) {
                    Spacer()
                    Image(systemName : "exclamationmark.icloud.fill")
                        .font(.system(size : 70))
                        .foregroundColor(.gray)
                    Text("해당 지역에 개설된 클래스가 없습니다 :(")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                RefreshableScrollView(onRefresh : { done in
                    //viewModel.isFetchDone = false
                    print("Fetch new post (pull to refresh)")
                    viewModel.isFetching = true
                    viewModel.fetchLessons()
                    withAnimation { viewModel.isSearching = false }
                    viewModel.searchingText = ""
                    hideKeyboard()
                    done()
                }) {
                    ScrollViewReader { proxy in
                        LazyVStack {
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation(.spring()) { viewModel.sort_OnlyAvailable.toggle() }
                                } label : {
                                    HStack(spacing : 3) {
                                        Image(systemName : viewModel.sort_OnlyAvailable ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundColor(viewModel.sort_OnlyAvailable ? .blue : .gray)
                                        Text("모집중인 클래스만 보기")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                    }
                                    .padding(4)
                                    .font(.system(size : 13))
                                }
                            }.padding(.horizontal)
                            .padding(.top, 5)
                            .id(1)
                            
                            ForEach(viewModel.LessonList
                                .filter {
                                    if viewModel.sort_OnlyAvailable { return $0.status == viewModel.sort_OnlyAvailable }
                                    else { return true }
                                }.filter {
                                    if !viewModel.searchingText.isEmpty { return $0.lessonName.lowercased().contains((viewModel.searchingText.lowercased())) }
                                    else { return true }
                            }, id : \.self) { lesson in
                                Button {
                                    viewModel.selectedLesson = lesson
                                    viewModel.detailViewShow = true
                                } label : {
                                    ZStack {
                                        if !lesson.images.isEmpty {
                                            KFImage(URL(string : lesson.images[0].lessonImgId.lessonImg)
                                                     ?? URL(string: "https://static.thenounproject.com/png/741653-200.png")!)
                                                .resizable()
                                                .fade(duration: 1.0)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth : .infinity, maxHeight : .infinity)
                                                .overlay(
                                                    LinearGradient(
                                                        colors: [.black.opacity(0.01), .black.opacity(0.7)],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                        } else { Color.blue }
                                        
                                        VStack {
                                            HStack {
                                                Text(lesson.status ? "모집중" : "모집완료")
                                                    .font(.footnote)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(7)
                                                    .background(lesson.status ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                                                    .cornerRadius(20)
                                                Spacer()
                                            }
                                            
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text("#" + lesson.category)
                                                    .fontWeight(.bold)
                                            }
                                            HStack {
                                                Spacer()
                                                Text(lesson.lessonName)
                                                    .font(.system(size: 45, weight : .semibold))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.4)
                                            }
                                            HStack {
                                                Spacer()
                                                Text(convertReturnedDateString(lesson.createDate))
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                        }.foregroundColor(.white)
                                        .frame(width :UIScreen.main.bounds.width * 0.9, height : UIScreen.main.bounds.height * 0.26)
                                    }.frame(width: UIScreen.main.bounds.width * 0.95, height : UIScreen.main.bounds.height * 0.3)
                                    .cornerRadius(20)
                                    .padding(3)
                                }
                            }
                        }
                        
                        Button {
                            withAnimation(.spring()) { proxy.scrollTo(1) }
                        } label : {
                            HStack {
                                Image(systemName : "arrow.up")
                                Text("상단으로 이동").fontWeight(.semibold)
                            }.padding()
                        }
                    }
                }
            }
        }.padding(.top)
        .navigationBarHidden(true)
        .navigationTitle(Text(""))
        .fullScreenCover(isPresented: $viewModel.detailViewShow, onDismiss : viewModel.fetchLessons ) {
            LessonInfoView(
                lesson : viewModel.selectedLesson,
                viewModel : LessonInfoViewModel(hostUserId : viewModel.selectedLesson.creator, lessonStatus: viewModel.selectedLesson.status)
            )
        }
        .onAppear {
            viewModel.selectedDistrict = District
            viewModel.fetchLessons()
        }
        .onChange(of: District) { _ in
            viewModel.isFetching = true
            viewModel.selectedDistrict = District
            print("Fetch Lessons in " + District)
            viewModel.fetchLessons()
        }
        .background(NavigationLink(destination : LessonCreateView(), isActive : $viewModel.showLessonCreationView){ })
        .alert(isPresented: $viewModel.showNeedToLoginAlert) {
            Alert(title: Text("알림\n"),
                  message : Text("로그인 후 강좌를 생성할 수 있습니다 😆"),
                  primaryButton : .destructive(Text("로그인")) { withAnimation { selectedTab = 1 } },
                  secondaryButton : .cancel(Text("취소"))
            )
        }
    }
}
