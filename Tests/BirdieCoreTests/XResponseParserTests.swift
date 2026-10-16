import Foundation
import Testing
@testable import BirdieCore

struct XResponseParserTests {
    @Test func preservesRankingAndDoesNotFlattenQuotes() throws {
        let quoted = Fixtures.post("quoted")
        let timeline = try Fixtures.timeline([
            Fixtures.entry("rank-1", post: Fixtures.post("100", quote: quoted)),
            Fixtures.entry("rank-2", post: Fixtures.post("900")),
            Fixtures.entry("rank-3", post: quoted),
            Fixtures.cursor("next")
        ])
        let result = try XResponseParser.timeline(timeline)
        #expect(result.entries.map(\.post.id) == ["100", "900", "quoted"])
        #expect(result.entries[0].post.quotedPost?.id == "quoted")
        #expect(result.nextCursor == "next")
    }

    @Test func parsesModernFieldsWithoutLegacyUserObject() throws {
        var post = Fixtures.post("one")
        post["note_tweet"] = ["note_tweet_results": ["result": ["text": "Complete long post"]]]
        post["media_entities2"] = [["type": "photo", "media_url_https": "https://example.com/photo.jpg"], ["type": "animated_gif", "media_url_https": "https://example.com/gif.jpg", "video_info": ["variants": [["content_type": "video/mp4", "url": "https://example.com/gif.mp4"]]]]]
        let parsed = try #require(XResponseParser.post(Fixtures.json(post)))
        #expect(parsed.text == "Complete long post")
        #expect(parsed.likeCount == 9)
        #expect(parsed.bookmarkCount == 4)
        #expect(parsed.user.isFollowing == false)
        #expect(parsed.user.bio == nil)
        #expect(parsed.date == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(parsed.media?.photos.count == 1)
        #expect(parsed.media?.videos.first?.variants.first?.url == "https://example.com/gif.mp4")
    }

    @Test func visibilityWrappersAndUnavailablePosts() throws {
        let wrapped: [String: Any] = ["__typename": "TweetWithVisibilityResults", "tweet": Fixtures.post("visible")]
        let result = try XResponseParser.timeline(Fixtures.timeline([
            Fixtures.entry("a", post: wrapped),
            Fixtures.entry("b", post: ["__typename": "TweetTombstone"]), Fixtures.cursor("next")
        ]))
        #expect(result.entries.map(\.post.id) == ["visible"])
        #expect(result.nextCursor == "next")
    }

    @Test func preservesConversationModuleOrder() throws {
        let module: [String: Any] = ["entry_id": "conversation", "content": ["__typename": "TimelineTimelineModule", "items": [
            ["entry_id": "parent", "item": ["content": ["tweet_results": ["result": Fixtures.post("parent")]]]],
            ["entry_id": "reply", "item": ["content": ["tweet_results": ["result": Fixtures.post("reply")]]]]
        ]]]
        let result = try XResponseParser.timeline(Fixtures.timeline([module]))
        #expect(result.entries.map(\.post.id) == ["parent", "reply"])
        #expect(result.entries.allSatisfy { $0.conversationID == "conversation" })
    }

    @Test func bottomTerminationWinsOverCursor() throws {
        let result = try XResponseParser.timeline(Fixtures.timeline([Fixtures.cursor("next")], extra: [["__typename": "TimelineTerminateTimeline", "direction": "Bottom"]]))
        #expect(result.isTerminated)
        #expect(result.nextCursor == nil)
    }

    @Test func missingTimelineIsAnErrorRatherThanAnEmptyFeed() throws {
        #expect(throws: XAPIError.responseChanged) { try XResponseParser.home(Fixtures.json(["data": [:]])) }
    }

    @Test func supportsLegacyAncillaryOperationsWithoutFlattening() throws {
        let user: [String: Any] = ["rest_id": "u", "legacy": ["screen_name": "example", "name": "Example", "description": "Bio"]]
        let post: [String: Any] = ["__typename": "Tweet", "rest_id": "legacy", "core": ["user_results": ["result": user]], "legacy": ["full_text": "Legacy post", "in_reply_to_status_id_str": "parent", "favorite_count": 7]]
        let legacy = try Fixtures.json(["instructions": [["type": "TimelineAddEntries", "entries": [["entryId": "one", "content": ["itemContent": ["tweet_results": ["result": post]]]]]]]])
        let result = try XResponseParser.timeline(legacy)
        #expect(result.entries.first?.post.text == "Legacy post")
        #expect(result.entries.first?.post.replyToID == "parent")
        #expect(result.entries.first?.post.user.bio == "Bio")
    }
}

extension XResponseParserTests {
    @Test func malformedPostsFailClearlyInsteadOfSilentlyEmptyingFeed() throws {
        #expect(throws: XAPIError.responseChanged) {
            try XResponseParser.timeline(Fixtures.timeline([Fixtures.entry("broken", post: ["__typename": "Tweet", "rest_id": "one"])]))
        }
    }

    @Test func modernRepostsAndReplyTargetsUseTheSharedModel() throws {
        var raw = Fixtures.post("outer")
        raw["legacy"] = ["retweeted_status_results": ["result": Fixtures.post("repost")]]
        raw["reply_to_results"] = ["rest_id": "parent"]
        let post = try #require(XResponseParser.post(Fixtures.json(raw)))
        #expect(post.repostedPost?.id == "repost")
        #expect(post.replyToID == "parent")
    }

    @Test func preservesPromotionDisclosureAndContext() throws {
        let value: [String: Any] = ["entry_id": "promoted", "content": ["__typename": "TimelineTimelineItem", "social_context": ["text": "Popular in your network"], "content": ["promoted_metadata": ["disclosure_type": "Promoted"], "tweet_results": ["result": Fixtures.post("one")]]]]
        let result = try XResponseParser.timeline(Fixtures.timeline([value]))
        #expect(result.entries.first?.isPromoted == true)
        #expect(result.entries.first?.context == "Popular in your network")
    }
}
