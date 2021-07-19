//
//  ContentView.swift
//  steps
//
//  Created by Chris McElroy on 7/12/21.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var stepHelper = StepHelper()
	
    var body: some View {
		ZStack {
			Rectangle().foregroundColor(.black)
			Text(stepText)
				.font(.system(size: 100))
				.foregroundColor(.white)
		}
    }
	
	var stepText: String {
		stepHelper.lastSteps != 0 ? String(stepHelper.lastSteps) : ""
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
