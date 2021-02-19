//
//  widget.swift
//  widget
//
//  Created by Efrain Garcia Rocha on 18/02/21.
//  Copyright © 2021 Efrain Garcia Rocha. All rights reserved.
//

import WidgetKit
import SwiftUI

let webAPI: WebApi = WebApi()

struct Order: Hashable {
    let Id: CLongLong
    let Customer: String
    let Amount: Decimal
}

struct LastOrdersEntry: TimelineEntry {
    public let date: Date
    public let orders: [Order]
    var relevance: TimelineEntryRelevance? {
        return TimelineEntryRelevance(score: 100)
    }
}

struct LastOrdersLoader {
    static func fetch(completion: @escaping (Result<[Order], Error>) -> Void) {
        webAPI.DoGet("orders", onCompleteHandler: { response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard response != nil else { return }
            
            do{
                if let data = response {
                    let orders = try JSONDecoder().decode([OrdersModel].self, from: data)
                    let parsedOrders = parseOrders(fromData: orders)
                    completion(.success(parsedOrders))
                }
            }
            catch {
                return
            }
        })
    }
    
    static func parseOrders(fromData data:[OrdersModel]) -> [Order] {
        var parsedOrders:[Order] = []
        for order in data.reversed().prefix(5) {
            parsedOrders.append(Order(Id: order.orderId, Customer: order.customer, Amount: order.orderTotal))
        }
        return parsedOrders
    }
}

struct LastOrdersProvider: TimelineProvider {
    func placeholder(in context: Context) -> LastOrdersEntry {
        var entry: LastOrdersEntry = LastOrdersEntry(date: Date(), orders: [])
        LastOrdersLoader.fetch { result in
            let newOrders: [Order]
            if case .success(let fetchedOrders) = result {
                newOrders = fetchedOrders
            } else {
                newOrders = []
            }
            entry = LastOrdersEntry(date: Date(), orders: newOrders)
        }
        return entry
    }
        
    func getSnapshot(in context: Context, completion: @escaping (LastOrdersEntry) -> Void) {
        LastOrdersLoader.fetch { result in
            let newOrders: [Order]
            if case .success(let fetchedOrders) = result {
                newOrders = fetchedOrders
            } else {
                newOrders = []
            }
            let entry = LastOrdersEntry(date: Date(), orders: newOrders)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LastOrdersEntry>) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)
        LastOrdersLoader.fetch { result in
            let newOrders: [Order]
            if case .success(let fetchedOrders) = result {
                newOrders = fetchedOrders
            } else {
                newOrders = []
            }
            let entry = LastOrdersEntry(date: Date(), orders: newOrders)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))
            completion(timeline)
        }
    }
    
    typealias Entry = LastOrdersEntry
}

struct WidgetView: View {
    let entry: LastOrdersEntry    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 50, content: {
                Text(NSLocalizedString("w-widget-title", tableName: "messages", comment: ""))
                    .font(.title)
                    .frame(alignment: .leading)
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .frame(alignment: .trailing)
                    .foregroundColor(.gray)
            })
            
            if entry.orders.count > 0 {
                VStack(alignment: .leading, spacing: 5, content: {
                    ForEach(entry.orders, id: \.self) { o in
                        HStack(alignment: .center, spacing: 10, content: {
                            Text("#\(String(o.Id).leftPadding(toLength: 6, withPad: "0"))")
                            Text(o.Customer).frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            Text(currencyText(o.Amount))
                        }).font(.system(size: 12)).padding(.horizontal, 10)
                    }
                }).frame(alignment: .leading)
            } else {
                Text(NSLocalizedString("w-fetch-failed", tableName: "messages", comment: ""))
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                    .frame(alignment: .center)
            }
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
        .foregroundColor(.white)
        .background(Color.black)
        .padding(0)
    }
}

func currencyText(_ amout: Decimal) -> String {
    let format: NumberFormatter = NumberFormatter()
    format.locale = Locale(identifier: "es_MX")
    format.numberStyle = .currency
    return format.string(for: amout)!
}

@main
struct widget: Widget {
    let kind: String = NSLocalizedString("w-kind", tableName: "messages", comment: "")

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LastOrdersProvider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("w-title", tableName: "messages", comment: ""))
        .description(NSLocalizedString("w-description", tableName: "messages", comment: ""))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: LastOrdersEntry(date: Date(), orders: [
            Order(Id: 10334, Customer: "María del Carmen Rodríguez", Amount: 150.00),
            Order(Id: 10335, Customer: "Ara Lago", Amount: 550.50),
            Order(Id: 10336, Customer: "Araceli Álvarez", Amount: 750.00),
            Order(Id: 10337, Customer: "Gloria Nelly Vargas López", Amount: 1150.00),
            Order(Id: 10338, Customer: "Carmen Frutas", Amount: 150.00)
        ]))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
