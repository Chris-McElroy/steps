//
//  StepHelper.swift
//  steps
//
//  Created by Chris McElroy on 7/16/21.
//

import Foundation
import HealthKit
import CoreMotion

extension Date {
	var midnight: Date { Calendar.current.startOfDay(for: self) }
}

class StepHelper: ObservableObject {
	@Published var lastSteps: Int = 0
	
	private let healthStore = HKHealthStore()
	private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
	private let interval = DateComponents(day: 1)
	private let predicate = HKQuery.predicateForSamples(withStart: Date().midnight, end: nil, options: .strictStartDate)
	private let stepQuery: HKStatisticsCollectionQuery
	
	private let phonePedometer = CMPedometer()
	
	init() {
		stepQuery = HKStatisticsCollectionQuery(quantityType: stepType,
												quantitySamplePredicate: predicate,
												options: .cumulativeSum,
												anchorDate:Date().midnight,
												intervalComponents: interval)
		
		requestAuthentication()
		trackSteps()
	}

	func requestAuthentication() {
		healthStore.requestAuthorization(toShare: [], read: [stepType], completion: {_,_ in })
	}

	func trackSteps() {
		stepQuery.initialResultsHandler = { _, collection, _ in
			collection?.enumerateStatistics(from: Date().midnight, to: Date(), with: { stats, _ in
				let quantity = stats.sumQuantity()
				let count = quantity?.doubleValue(for: HKUnit.count()) ?? 0
				self.lastSteps = Int(count)
			})
		}
		
		stepQuery.statisticsUpdateHandler = { _, _, collection, _ in
			collection?.enumerateStatistics(from: Date().midnight, to: Date(), with: { stats, _ in
				let quantity = stats.sumQuantity()
				let count = quantity?.doubleValue(for: HKUnit.count()) ?? 0
				self.lastSteps = Int(count)
			})
		}

		healthStore.execute(stepQuery)
		
		phonePedometer.queryPedometerData(from: Date().midnight, to: Date(), withHandler: { data, _ in
			// includes check for > lastSteps in case they have other devices updating the count
			// currently this means at midnight it would only update when the health results restart
			if let count = data?.numberOfSteps, Int(truncating: count) > self.lastSteps {
				self.lastSteps = Int(truncating: count)
			}
		})
		
		// not sure that this works how i want it to
		Timer.scheduledTimer(withTimeInterval: 84000+Date().midnight.timeIntervalSinceNow, repeats: false, block: { _ in self.trackSteps() })
	}

}
