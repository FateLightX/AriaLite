import AppKit
import SwiftUI

struct MainWindowView: View {
    @Environment(\.openSettings) private var openSettings
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 0) {
            FilterTabBar()
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)

            Divider()

            ContentAreaView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
            StatusBarView()
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    store.showAddTask = true
                } label: {
                    Label("添加", systemImage: "plus")
                }
                .disabled(store.connectionState != .connected)
                .help("添加任务")

                Button {
                    Task {
                        await store.resumeSelected()
                    }
                } label: {
                    Label("继续", systemImage: "play.fill")
                }
                .disabled(store.connectionState != .connected || !store.canResumeSelected)
                .help("继续选中的任务")

                Button {
                    Task {
                        await store.pauseSelected()
                    }
                } label: {
                    Label("暂停", systemImage: "pause.fill")
                }
                .disabled(store.connectionState != .connected || !store.canPauseSelected)
                .help("暂停选中的任务")

                Button {
                    store.showDeleteConfirmation = true
                } label: {
                    Label("删除", systemImage: "trash")
                }
                .disabled(store.connectionState != .connected || store.selectedTask == nil)
                .help("删除选中的任务")
            }

            ToolbarItemGroup(placement: .automatic) {
                Button {
                    openSettings()
                } label: {
                    Label("设置", systemImage: "gearshape")
                }
                .help("打开设置")
            }
        }
        .sheet(isPresented: $store.showAddTask) {
            AddTaskSheet()
                .environmentObject(store)
                .frame(width: 560, height: 420)
        }
        .sheet(isPresented: $store.showDeleteConfirmation) {
            DeleteConfirmationSheet()
                .environmentObject(store)
                .frame(width: 440)
        }
    }
}

struct FilterTabBar: View {
    @EnvironmentObject private var store: AppStore

    private let filters: [TaskFilter] = [.all, .active, .waiting, .complete, .failed]

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            HStack(spacing: 8) {
                ForEach(filters) { filter in
                    FilterTab(
                        filter: filter,
                        count: store.count(for: filter),
                        isSelected: store.selectedFilter == filter
                    ) {
                        store.selectFilter(filter)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FilterTab: View {
    let filter: TaskFilter
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    private var tint: Color {
        switch filter {
        case .all: .blue
        case .active: .green
        case .waiting: .orange
        case .complete: Color(red: 0.19, green: 0.78, blue: 0.45)
        case .failed: .red
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(tint)
                    .symbolRenderingMode(.hierarchical)

                Text(filter.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)

                Text("\(count)")
                    .font(.system(size: 11, weight: .semibold).monospacedDigit())
                    .foregroundStyle(isSelected ? tint : Color.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(
                        Capsule()
                            .fill(isSelected ? tint.opacity(0.18) : Color.primary.opacity(0.08))
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? tint.opacity(0.14) : Color.clear)
            )
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? tint.opacity(0.35) : Color.clear, lineWidth: 1)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .help(filter.title)
    }
}

struct ContentAreaView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Group {
            switch store.connectionState {
            case .starting:
                ConnectionStateView(
                    title: "正在连接",
                    message: "正在启动 aria2-next 引擎",
                    symbol: "hourglass",
                    primaryActionTitle: nil,
                    secondaryActionTitle: nil
                )
            case .failed:
                ConnectionStateView(
                    title: "无法连接",
                    message: "请重试连接或检查引擎设置。",
                    symbol: "wifi.slash",
                    primaryActionTitle: "重试连接",
                    secondaryActionTitle: "打开设置"
                )
            case .stopped:
                ConnectionStateView(
                    title: "引擎已停止",
                    message: "下载引擎没有运行",
                    symbol: "stop.circle",
                    primaryActionTitle: "重新连接",
                    secondaryActionTitle: "打开设置"
                )
            case .connected:
                if store.filteredTasks.isEmpty && store.taskSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    EmptyTaskView()
                } else {
                    TaskListView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
