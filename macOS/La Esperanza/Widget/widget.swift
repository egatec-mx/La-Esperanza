//
//  widget.swift
//  widget
//
//  Created by Efrain Garcia Rocha on 18/02/21.
//  Copyright © 2021 Efrain Garcia Rocha. All rights reserved.
//

import WidgetKit
import SwiftUI

let serverURL: String = ""
let suiteName: String = ""

struct Order: Hashable {
    let Id: CLongLong
    let Customer: String
    let Amount: Decimal
    let Status: Int
}

struct WidgetEntry: TimelineEntry {
    public let date: Date
    public let orders: [Order]
    public let error: Bool
    var relevance: TimelineEntryRelevance? {
        return TimelineEntryRelevance(score: 100)
    }
}

struct WidgetApi {
    static func Get(completion: @escaping (Result<[Order], Error>) -> Void) {
        WebApi.baseURL = serverURL
        WebApi.suiteName = suiteName
        
        WebApi().DoGet("orders", onCompleteHandler: { response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard response != nil else { return }
            
            do {
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
        var parsedOrders: [Order] = []
        for order in data.reversed() {
            parsedOrders.append(Order(Id: order.orderId, Customer: order.customer, Amount: order.orderTotal, Status: order.statusId))
        }
        return parsedOrders
    }
}

struct WidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        var entry: WidgetEntry = WidgetEntry(date: Date(), orders: [], error: false)
        WidgetApi.Get { result in
            let newOrders: [Order]
            var failed: Bool = false
            if case .success(let fetchedOrders) = result {
                newOrders = fetchedOrders
                failed = false
            } else {
                newOrders = []
                failed = true
            }
            entry = WidgetEntry(date: Date(), orders: newOrders, error: failed)
        }
        return entry
    }
        
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        WidgetApi.Get { result in
            let newOrders: [Order]
            var failed: Bool = false
            if case .success(let fetchedOrders) = result {
                newOrders = fetchedOrders
                failed = false
            } else {
                newOrders = []
                failed = true
            }
            let entry = WidgetEntry(date: Date(), orders: newOrders, error: failed)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)
        WidgetApi.Get { result in
            let newOrders: [Order]
            var failed: Bool = false
            if case .success(let fetchedOrders) = result {
                newOrders = fetchedOrders
                failed = false
            } else {
                newOrders = []
                failed = true
            }
            let entry = WidgetEntry(date: Date(), orders: newOrders, error: failed)
            let timeline = Timeline(entries: [entry], policy: .after(futureDate!))
            completion(timeline)
        }
    }
    
    typealias Entry = WidgetEntry
}

struct WidgetView: View {
    let entry: WidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
        
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: nil, content: {
            HStack(alignment: .center, spacing: nil, content: {
                Spacer()
                Image(systemName: "network")
                    .foregroundColor((entry.error ? .red : .green))
                    .fixedSize()
                    .frame(width: 16, height: 16)
            })
            .padding(.horizontal, 15.0)
            .padding(.top, 10.0)
            .padding(.bottom, 0.0)
            
            HStack(alignment: .firstTextBaseline, spacing: nil, content: {
                Text(NSLocalizedString("w-widget-title", tableName: "messages", comment: ""))
                    .font(.title2)
                Spacer()
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            })
            .padding(.top, 0.0)
            .padding(.bottom, 1.0)
            .padding(.horizontal, 15.0)
            
            if entry.orders.count > 0 {
                VStack(alignment: .leading, spacing: nil, content: {
                    ForEach(filterOrdersView(widgetFamily, orders: entry.orders), id: \.self) { o in
                        HStack(alignment: .center, spacing: nil, content: {
                            Group {
                                Image(systemName: statusIcon(o.Status).name)
                                    .foregroundColor(statusIcon(o.Status).color)
                                    .fixedSize()
                                    .frame(width: 16, height: 16)
                                    .scaledToFit()
                                Text("#\(String(o.Id).leftPadding(toLength: 6, withPad: "0"))")
                                    .fontWeight(.bold)
                                    .scaledToFit()
                                Text(o.Customer)
                                    .scaledToFit()
                                Spacer()
                                Text(o.Amount.toStringFormat(.currency))
                                    .scaledToFit()
                            }.font(.system(size: 11.5))
                        }).padding(.horizontal, 5.0)
                    }
                }).frame(alignment: .leading).padding(.horizontal,10)
            } else {
                if entry.error {
                    Text(NSLocalizedString("w-no-connection", tableName: "messages", comment: ""))
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                        .frame(alignment: .center)
                } else {
                    Text(NSLocalizedString("w-empty", tableName: "messages", comment: ""))
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                        .frame(alignment: .center)
                }
            }
        })
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
        .foregroundColor(.primary)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(0)
        .containerBackground(for:.widget) {
            Color(.systemBackground)
        }
    }
}

func statusIcon(_ status: Int) -> (name: String, color: Color) {
    var imgName: String = ""
    var imgColor: Color = .clear
    switch status {
    case 1:
        imgName = "bell"
        imgColor = Color(UIColor.systemTeal.cgColor)
    case 2:
        imgName = "clock"
        imgColor = .orange
    case 3:
        imgName = "car"
        imgColor = .purple
    case 4:
        imgName = "hand.thumbsup"
        imgColor = .green
    case 5:
        imgName = "trash.slash"
        imgColor = .red
    case 6:
        imgName = "hand.thumbsdown"
        imgColor = .pink
    default:
        imgName = "bell"
        imgColor = Color(UIColor.systemTeal.cgColor)
    }
    return (imgName, imgColor)
}

func filterOrdersView(_ family: WidgetFamily, orders: [Order]) -> ArraySlice<Order> {
    switch family {
    case .systemMedium:
        return orders.prefix(5)
    case .systemLarge:
        return orders.prefix(15)
    default:
        return orders.prefix(upTo: orders.count)
    }
}

@main
struct widget: Widget {
    let kind: String = NSLocalizedString("w-kind", tableName: "messages", comment: "")
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("w-title", tableName: "messages", comment: ""))
        .description(NSLocalizedString("w-description", tableName: "messages", comment: ""))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetView(entry: WidgetEntry(date: Date(), orders: [
                Order(Id: 10334, Customer: "María del Carmen", Amount: 150.00, Status: 1),
                Order(Id: 10335, Customer: "Ara Lago", Amount: 550.50, Status: 2),
                Order(Id: 10336, Customer: "Araceli", Amount: 750.00, Status: 3),
                Order(Id: 10337, Customer: "Gloria", Amount: 1150.00, Status: 4),
                Order(Id: 10338, Customer: "Carmen Frutas", Amount: 150.00, Status: 5)
            ], error: false)).previewContext(WidgetPreviewContext(family: .systemLarge))
            
            WidgetView(entry: WidgetEntry(date: Date(), orders: [
                Order(Id: 10334, Customer: "María del Carmen", Amount: 150.00, Status: 1),
                Order(Id: 10335, Customer: "Ara Lago", Amount: 550.50, Status: 2),
                Order(Id: 10336, Customer: "Araceli", Amount: 750.00, Status: 3),
                Order(Id: 10337, Customer: "Gloria", Amount: 1150.00, Status: 4),
                Order(Id: 10338, Customer: "Carmen Frutas", Amount: 150.00, Status: 5)
            ], error: false)).previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
