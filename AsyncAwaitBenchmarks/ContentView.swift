//
//  ContentView.swift
//  AsyncAwaitBenchmarks
//
//  Created by Robert Ryan on 9/23/22.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            Text(viewModel.elapsed)
            Button("AsyncAwait") {
                Task {
                    await viewModel.testAsyncAwait()
                }
            }
            Button("concurrentPerform") {
                viewModel.testConcurrentPerform()
            }
            Button("Serial") {
                viewModel.testSerial()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
