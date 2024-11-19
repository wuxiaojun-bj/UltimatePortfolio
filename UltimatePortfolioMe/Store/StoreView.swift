//
//  StoreView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/11/13.
//
import StoreKit
import SwiftUI

struct StoreView: View {
    //升级商店，以处理我们发现自己所处的三种加载状态：产品正在加载，产品已经加载，或者我们一路上遇到了错误
    enum LoadState {
        case loading, loaded, error
    }
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    
    //应用程序中购买的产品阵列
    @State private var loadState = LoadState.loading
    
    //检查用户是否可以实际进行购买
    @State private var showingPurchaseError = false


    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // header
                VStack {
                    //装饰图像会自动从旁白中隐藏。
                    Image(decorative: "unlock")
                        .resizable()
                        .scaledToFit()

                    Text("Upgrade Today!")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Text("Get the most out of the app")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.blue.gradient)

                ScrollView {
                    VStack {
                        switch loadState {
                        case .loading:
                            Text("Fetching offers…")
                                .font(.title2.bold())
                                .padding(.top, 50)
                            ProgressView()
                                .controlSize(.large)
                            
                        case .loaded:
                            // 产品的整个内容变成一个按钮
                            ForEach(dataController.products) { product in
                                Button {
                                    purchase(product)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(product.displayName)
                                                .font(.title2.bold())
                                            Text(product.description)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(product.displayPrice)
                                            .font(.title)
                                            .fontDesign(.rounded)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                //.rect内容形状可以确保整个标签区域可以被点击，包括产品描述和价格之间的空格。
                                    .background(.gray.opacity(0.2), in: .rect(cornerRadius: 20))
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            
                            
                        case .error:
                            Text("Sorry, there was an error loading our store.")
                                .padding(.top, 50)
                            
                            Button("Try Again") {
                                Task {
                                    await load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(20)
                }
                // footer
                //恢复购买
                Button("Restore Purchases", action: restore)
                Button("Cancel") {
                    dismiss()
                }
                .padding(.top, 20)
                
            }
        }
        .alert("In-app purchases are disabled", isPresented: $showingPurchaseError) {
        } message: {
            Text("""
            You can't purchase the premium unlock because in-app purchases are disabled on this device.

            Please ask whomever manages your device for assistance.
            """)
        }
        .onChange(of: dataController.fullVersionUnlocked) { _ in
            checkForPurchase()
        }
        .task {
            await load()
        }

    }
    
    //关闭视图自动意味着当fullVersionUnlocked变为真时调用dismiss()
    func checkForPurchase() {
        if dataController.fullVersionUnlocked {
            dismiss()
        }
    }
    
    //加载产品
    func load() async {
        loadState = .loading

        do {
            try await dataController.loadProducts()

            if dataController.products.isEmpty {
                loadState = .error
            } else {
                loadState = .loaded
            }
        } catch {
            loadState = .error
        }
    }


    
    //一种实际触发购买流程的方法
    func purchase(_ product: Product) {
        //检查用户是否可以实际进行购买
        guard AppStore.canMakePayments else {
            showingPurchaseError.toggle()
            return
        }

        Task { @MainActor in
            try await dataController.purchase(product)
        }
    }
    
    //恢复购买,迫使StoreKit重新同步其购买。
    func restore() {
        Task {
            try await AppStore.sync()
        }
    }


}

#Preview {
    StoreView()
        .environmentObject(DataController.preview)
}
