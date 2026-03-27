//
//  ScheduleEditorCard.swift
//  Boundary
//

import SwiftUI

struct ScheduleEditorCard: View {
    @Binding var selectedWeekdays: Set<Weekday>
    @Binding var startTime: SimpleTime
    @Binding var endTime: SimpleTime

    var body: some View {
        BoundaryCard {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                Text("Days")
                    .font(BoundaryTheme.Typography.headline)
                weekdayGrid

                Text("Time window")
                    .font(BoundaryTheme.Typography.headline)
                    .padding(.top, BoundaryTheme.Spacing.xs)

                HStack(alignment: .top, spacing: BoundaryTheme.Spacing.lg) {
                    timePickers(title: "Start", time: $startTime)
                    timePickers(title: "End", time: $endTime)
                }

                Text("Overnight windows (e.g. 6 PM → 8 AM) are supported.")
                    .font(BoundaryTheme.Typography.captionSmall)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var weekdayGrid: some View {
        let columns = [
            GridItem(.adaptive(minimum: 52), spacing: BoundaryTheme.Spacing.xs),
        ]
        return LazyVGrid(columns: columns, spacing: BoundaryTheme.Spacing.xs) {
            ForEach(Weekday.allCases) { day in
                let on = selectedWeekdays.contains(day)
                Button {
                    if on {
                        selectedWeekdays.remove(day)
                    } else {
                        selectedWeekdays.insert(day)
                    }
                } label: {
                    Text(String(day.shortSymbol.prefix(1)))
                        .font(BoundaryTheme.Typography.caption.weight(.semibold))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(on ? Color.accentColor.opacity(0.2) : Color(.tertiarySystemFill))
                        )
                        .overlay {
                            Circle()
                                .strokeBorder(on ? Color.accentColor : Color.clear, lineWidth: 2)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(day.shortSymbol))
            }
        }
    }

    private func timePickers(title: String, time: Binding<SimpleTime>) -> some View {
        let hourBinding = Binding<Int>(
            get: { time.wrappedValue.hour },
            set: { time.wrappedValue = SimpleTime(hour: $0, minute: time.wrappedValue.minute) }
        )
        let minuteBinding = Binding<Int>(
            get: { time.wrappedValue.minute },
            set: { time.wrappedValue = SimpleTime(hour: time.wrappedValue.hour, minute: $0) }
        )
        return VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
            Text(title)
                .font(BoundaryTheme.Typography.captionSmall)
                .foregroundStyle(.tertiary)
            HStack(spacing: BoundaryTheme.Spacing.xs) {
                Picker("Hour", selection: hourBinding) {
                    ForEach(0 ..< 24, id: \.self) { h in
                        Text(String(format: "%02d", h)).tag(h)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()

                Text(":")
                    .foregroundStyle(.secondary)

                Picker("Minute", selection: minuteBinding) {
                    ForEach([0, 15, 30, 45], id: \.self) { m in
                        Text(String(format: "%02d", m)).tag(m)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        }
    }
}

#Preview {
    struct Host: View {
        @State private var days: Set<Weekday> = Set(Weekday.allCases.filter { $0 != .sunday && $0 != .saturday })
        @State private var start = SimpleTime(hour: 18)
        @State private var end = SimpleTime(hour: 8)
        var body: some View {
            ScheduleEditorCard(selectedWeekdays: $days, startTime: $start, endTime: $end)
                .padding()
        }
    }
    return Host()
}
