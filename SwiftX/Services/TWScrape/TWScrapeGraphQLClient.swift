import Foundation

struct TWScrapeGraphQLClient {
    enum CursorType: String {
        case bottom = "Bottom"
        case showMoreThreads = "ShowMoreThreads"
    }

    private let account: TWScrapeAccount
    private let gqlURL = "https://x.com/i/api/graphql"

    init(account: TWScrapeAccount = .defaultActive) {
        self.account = account
    }

    func pagedRequest(
        op: String,
        baseVariables: [String: Any],
        fieldToggles: [String: Any]? = nil,
        limit _: Int,
        pageSize: Int,
        cursorType: CursorType = .bottom,
        maxPages: Int = 12
    ) async throws -> [[String: Any]] {
        var pages: [[String: Any]] = []
        var cursor: String?
        var page = 0

        repeat {
            page += 1
            var variables = baseVariables
            variables["count"] = pageSize
            if let cursor = cursor {
                variables["cursor"] = cursor
            }

            let response = try await request(
                op: op,
                variables: variables,
                fieldToggles: fieldToggles
            )

            pages.append(response)
            cursor = findCursor(in: response, type: cursorType.rawValue)
        } while cursor != nil && page < maxPages

        return pages
    }

    func singleRequest(
        op: String,
        variables: [String: Any],
        fieldToggles: [String: Any]? = nil
    ) async throws -> [String: Any] {
        try await request(op: op, variables: variables, fieldToggles: fieldToggles)
    }

    private func request(
        op: String,
        variables: [String: Any],
        fieldToggles: [String: Any]? = nil
    ) async throws -> [String: Any] {
        var components = URLComponents(string: "\(gqlURL)/\(op)")
        var queryItems = [
            URLQueryItem(name: "variables", value: Self.encodeQueryParam(variables)),
            URLQueryItem(name: "features", value: Self.encodeQueryParam(Self.features))
        ]

        if let fieldToggles = fieldToggles {
            queryItems.append(URLQueryItem(name: "fieldToggles", value: Self.encodeQueryParam(fieldToggles)))
        }

        components?.queryItems = queryItems

        guard let url = components?.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = account.authHeaders()

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badServerResponse
        }

        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let json = jsonObject as? [String: Any] else {
            throw NetworkError.decodingError
        }

        return json
    }

    private static func encodeQueryParam(_ value: Any) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    private static let features: [String: Any] = [
        "articles_preview_enabled": false,
        "c9s_tweet_anatomy_moderator_badge_enabled": true,
        "communities_web_enable_tweet_community_results_fetch": true,
        "creator_subscriptions_quote_tweet_preview_enabled": false,
        "creator_subscriptions_tweet_preview_api_enabled": true,
        "freedom_of_speech_not_reach_fetch_enabled": true,
        "graphql_is_translatable_rweb_tweet_is_translatable_enabled": true,
        "longform_notetweets_consumption_enabled": true,
        "longform_notetweets_inline_media_enabled": true,
        "longform_notetweets_rich_text_read_enabled": true,
        "responsive_web_edit_tweet_api_enabled": true,
        "responsive_web_enhance_cards_enabled": false,
        "responsive_web_graphql_exclude_directive_enabled": true,
        "responsive_web_graphql_skip_user_profile_image_extensions_enabled": false,
        "responsive_web_graphql_timeline_navigation_enabled": true,
        "responsive_web_media_download_video_enabled": false,
        "responsive_web_twitter_article_tweet_consumption_enabled": true,
        "rweb_tipjar_consumption_enabled": true,
        "rweb_video_timestamps_enabled": true,
        "standardized_nudges_misinfo": true,
        "tweet_awards_web_tipping_enabled": false,
        "tweet_with_visibility_results_prefer_gql_limited_actions_policy_enabled": true,
        "tweet_with_visibility_results_prefer_gql_media_interstitial_enabled": false,
        "tweetypie_unmention_optimization_enabled": true,
        "verified_phone_label_enabled": false,
        "view_counts_everywhere_api_enabled": true,
        "responsive_web_grok_analyze_button_fetch_trends_enabled": false,
        "premium_content_api_read_enabled": false,
        "profile_label_improvements_pcf_label_in_post_enabled": false,
        "responsive_web_grok_share_attachment_enabled": false,
        "responsive_web_grok_analyze_post_followups_enabled": false,
        "responsive_web_grok_image_annotation_enabled": false,
        "responsive_web_grok_analysis_button_from_backend": false,
        "responsive_web_jetfuel_frame": false,
        "rweb_video_screen_enabled": true,
        "responsive_web_grok_show_grok_translated_post": true
    ]
}

private func findCursor(in obj: Any, type: String) -> String? {
    if let dict = obj as? [String: Any] {
        if let cursorType = dict["cursorType"] as? String,
           cursorType == type,
           let value = dict["value"] as? String {
            return value
        }

        for value in dict.values {
            if let found = findCursor(in: value, type: type) {
                return found
            }
        }
    } else if let arr = obj as? [Any] {
        for item in arr {
            if let found = findCursor(in: item, type: type) {
                return found
            }
        }
    }

    return nil
}
