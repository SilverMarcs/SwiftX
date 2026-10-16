import Foundation
import Testing
@testable import BirdieCore

@MainActor
struct TimelineStoreTests {
    private func makeStore(_ client: ScriptedTimelineClient) throws -> (TimelineStore, SeenPostStore) {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let seen = SeenPostStore(defaults: defaults)
        let store = TimelineStore(client: client, seen: seen, tracksSeenPosts: true)
        store.configure(accountKey: "account")
        return (store, seen)
    }

    @Test func appendsInRankOrderAndStopsRepeatedCursor() async throws {
        let client = ScriptedTimelineClient()
        client.handler = { cursor, _, _ in cursor == nil ? Fixtures.page(["old", "new"], cursor: "a") : Fixtures.page(["new", "older"], cursor: "a") }
        let (store, _) = try makeStore(client)
        await store.refresh()
        await store.loadMore()
        await store.loadMore()
        #expect(store.entries.map(\.post.id) == ["old", "new", "older"])
        #expect(store.nextCursor == nil)
        #expect(client.requests.count == 2)
    }

    @Test func failedPageCanRetryWithoutLosingFeedOrCursor() async throws {
        let client = ScriptedTimelineClient()
        var fail = true
        client.handler = { cursor, _, _ in
            if cursor == nil { return Fixtures.page(["one"], cursor: "a") }
            if fail { fail = false; throw XAPIError.server(503) }
            return Fixtures.page(["two"])
        }
        let (store, _) = try makeStore(client)
        await store.refresh()
        await store.loadMore()
        #expect(store.entries.count == 1)
        #expect(store.nextCursor == "a")
        #expect(store.loadMoreError != nil)
        await store.loadMore()
        #expect(store.entries.map(\.post.id) == ["one", "two"])
        #expect(store.loadMoreError == nil)
    }

    @Test func refreshFailureRetainsExistingFeed() async throws {
        let client = ScriptedTimelineClient()
        client.handler = { _, _, _ in Fixtures.page(["one"], cursor: "a") }
        let (store, _) = try makeStore(client)
        await store.refresh()
        client.handler = { _, _, _ in throw XAPIError.sessionExpired }
        await store.refresh()
        #expect(store.entries.map(\.post.id) == ["one"])
        #expect(store.nextCursor == "a")
        #expect(store.error != nil)
        #expect(!store.isRefreshing)
    }

    @Test func newerRefreshCannotBeOverwrittenByOlderPage() async throws {
        let client = ScriptedTimelineClient()
        var continuation: CheckedContinuation<TimelinePage, any Error>?
        client.handler = { cursor, _, _ in
            if cursor == nil { return Fixtures.page(["initial"], cursor: "a") }
            return try await withCheckedThrowingContinuation { continuation = $0 }
        }
        let (store, _) = try makeStore(client)
        await store.refresh()
        let loading = Task { await store.loadMore() }
        while continuation == nil { await Task.yield() }
        client.handler = { _, _, _ in Fixtures.page(["refreshed"], cursor: "b") }
        await store.refresh()
        continuation?.resume(returning: Fixtures.page(["stale"], cursor: "c"))
        await loading.value
        #expect(store.entries.map(\.post.id) == ["refreshed"])
        #expect(store.nextCursor == "b")
        #expect(!store.isLoadingMore)
    }

    @Test func boundsEmptyPagesAndDoesNotMarkFetchedPostsSeen() async throws {
        let client = ScriptedTimelineClient()
        var count = 0
        client.handler = { _, _, _ in count += 1; return Fixtures.page([], cursor: String(count)) }
        let (store, seen) = try makeStore(client)
        await store.refresh()
        for _ in 0..<5 { await store.loadMore() }
        #expect(client.requests.count == 4)
        #expect(store.nextCursor == nil)
        #expect(seen.pending.isEmpty)
    }

    @Test func pendingSeenSnapshotIsAcknowledgedOnlyOnSuccess() async throws {
        let client = ScriptedTimelineClient()
        let (store, seen) = try makeStore(client)
        seen.markVisible("visible")
        client.handler = { _, _, _ in throw XAPIError.server(500) }
        await store.refresh()
        #expect(seen.pending == ["visible"])
        client.handler = { _, ids, _ in
            #expect(ids == ["visible"])
            seen.markVisible("seen-during-request")
            return Fixtures.page(["one"])
        }
        await store.refresh()
        #expect(seen.pending == ["seen-during-request"])
    }

    @Test func changingAccountsDiscardsAnInFlightResponse() async throws {
        let client = ScriptedTimelineClient()
        var continuation: CheckedContinuation<TimelinePage, any Error>?
        client.handler = { _, _, _ in try await withCheckedThrowingContinuation { continuation = $0 } }
        let (store, _) = try makeStore(client)
        let loading = Task { await store.refresh() }
        while continuation == nil { await Task.yield() }
        store.configure(accountKey: "other-account")
        continuation?.resume(returning: Fixtures.page(["other-persons-post"]))
        await loading.value
        #expect(store.entries.isEmpty)
        #expect(store.nextCursor == nil)
        #expect(!store.isRefreshing)
    }
}

extension TimelineStoreTests {
    @Test func seenTrackingIsDisabledAndSavedHistoryIsNotSentOrAcknowledged() async throws {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let seen = SeenPostStore(defaults: defaults)
        seen.configure(accountKey: "account")
        seen.markVisible("previously-seen")
        let client = ScriptedTimelineClient()
        client.handler = { cursor, _, _ in
            cursor == nil ? Fixtures.page(["one"], cursor: "a") : Fixtures.page(["two"])
        }
        let store = TimelineStore(client: client, seen: seen)
        store.configure(accountKey: "account")
        await store.refresh()
        store.markVisible(try #require(store.entries.first))
        await store.loadMore()
        #expect(client.requests.count == 2)
        #expect(client.requests.allSatisfy { $0.1.isEmpty })
        #expect(seen.pending == ["previously-seen"])
    }

    @Test func concurrentPaginationDoesNotIssueDuplicateRequests() async throws {
        let client = ScriptedTimelineClient()
        var continuation: CheckedContinuation<TimelinePage, any Error>?
        client.handler = { cursor, _, _ in
            if cursor == nil { return Fixtures.page(["one"], cursor: "a") }
            return try await withCheckedThrowingContinuation { continuation = $0 }
        }
        let (store, _) = try makeStore(client)
        await store.refresh()
        let loading = Task { await store.loadMore() }
        while continuation == nil { await Task.yield() }
        await store.loadMore()
        #expect(client.requests.count == 2)
        continuation?.resume(returning: Fixtures.page(["two"]))
        await loading.value
        #expect(store.entries.count == 2)
    }
}
