import AppKit
import SwiftUI

@main
struct AriaLiteApp: App {
    @NSApplicationDelegateAdaptor(AriaLiteAppDelegate.self) private var appDelegate
    @StateObject private var store = AppStore()

    var body: some Scene {
        Window("AriaLite", id: "main") {
            MainWindowView()
                .environmentObject(store)
                .frame(width: 600, height: 400)
                .onAppear {
                    AppPresentation.mainWindowDidAppear(store: store)
                }
                .onDisappear {
                    AppPresentation.mainWindowDidDisappear(store: store)
                }
        }
        .defaultSize(width: 600, height: 400)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建任务...") {
                    store.showAddTask = true
                }
                .disabled(store.connectionState != .connected)
                .keyboardShortcut("n")
            }

            CommandMenu("任务") {
                Button("刷新任务") {
                    Task {
                        await store.refreshTasksFromEngine()
                    }
                }
                .disabled(store.connectionState != .connected)
                .keyboardShortcut("r")

                Divider()

                Button("继续") {
                    Task {
                        await store.resumeSelected()
                    }
                }
                .disabled(store.connectionState != .connected || !store.canResumeSelected)

                Button("暂停") {
                    Task {
                        await store.pauseSelected()
                    }
                }
                .disabled(store.connectionState != .connected || !store.canPauseSelected)

                Divider()

                Button("继续全部") {
                    Task {
                        await store.resumeAll()
                    }
                }
                .disabled(store.connectionState != .connected || store.waitingCount == 0)

                Button("暂停全部") {
                    Task {
                        await store.pauseAll()
                    }
                }
                .disabled(store.connectionState != .connected || store.activeCount == 0)

                Divider()

                Button("保存会话") {
                    Task {
                        await store.saveSession()
                    }
                }
                .disabled(store.connectionState != .connected)

                Button("清理完成和失败结果") {
                    Task {
                        await store.clearStoppedResults()
                    }
                }
                .disabled(store.connectionState != .connected || (store.completeCount + store.failedCount) == 0)

                Divider()

                Button("删除...") {
                    store.showDeleteConfirmation = true
                }
                .disabled(store.connectionState != .connected || store.selectedTask == nil)
            }
        }

        MenuBarExtra {
            AriaLiteMenuBarView()
                .environmentObject(store)
        } label: {
            AriaLiteMenuBarLabel(appDelegate: appDelegate)
                .environmentObject(store)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsWindowView()
                .environmentObject(store)
                .onAppear {
                    AppPresentation.settingsDidAppear()
                }
                .onDisappear {
                    AppPresentation.settingsDidDisappear(store: store)
                }
        }
    }
}
