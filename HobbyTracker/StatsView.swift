//
//  StatsView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    // 1. Fetch all data to calculate stats
    @Query private var miniatures: [Miniature]
    
    // 2. Dismiss environment to close the sheet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: - Chart 1: Project Status
                    // A "Donut" chart showing progress
                    VStack(alignment: .leading) {
                        Text("Project Status")
                            .font(.headline)
                            .padding(.leading)
                        
                        Chart(Status.allCases, id: \.self) { status in
                            // Count how many minis have this specific status
                            let count = miniatures.filter { $0.status == status }.count
                            
                            // Only show slices that actually have data
                            if count > 0 {
                                SectorMark(
                                    angle: .value("Count", count),
                                    innerRadius: .ratio(0.6), // Makes it a donut
                                    angularInset: 1.5
                                )
                                .cornerRadius(5)
                                .foregroundStyle(by: .value("Status", status.displayName))
                                .annotation(position: .overlay) {
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                        .bold()
                                }
                            }
                        }
                        .frame(height: 250)
                        .padding()
                    }
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // MARK: - Chart 2: Faction Breakdown
                    // A Bar chart showing your biggest armies
                    VStack(alignment: .leading) {
                        Text("Faction Breakdown")
                            .font(.headline)
                            .padding(.leading)
                        
                        if factionData.isEmpty {
                            Text("Add factions to see data here.")
                                .foregroundStyle(.secondary)
                                .padding()
                        } else {
                            Chart(factionData, id: \.name) { data in
                                BarMark(
                                    x: .value("Count", data.count),
                                    y: .value("Faction", data.name)
                                )
                                .foregroundStyle(by: .value("Faction", data.name))
                                .annotation(position: .trailing) {
                                    Text("\(data.count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(height: 300)
                            .padding()
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Hobby Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Helper Struct for the Bar Chart
    struct FactionData {
        let name: String
        let count: Int
    }
    
    // Computed property to group miniatures by Faction
    var factionData: [FactionData] {
        // 1. Get all unique faction names
        let allFactions = Set(miniatures.map { $0.faction })
        
        // 2. Count minis for each faction
        let data = allFactions.map { faction in
            let count = miniatures.filter { $0.faction == faction }.count
            return FactionData(name: faction, count: count)
        }
        
        // 3. Sort by biggest army first
        return data.sorted { $0.count > $1.count }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: Miniature.self, inMemory: true)
}
