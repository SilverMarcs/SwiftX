import Foundation

/// Observes only GraphQL read requests. Login forms, password fields, and login request bodies are never inspected.
enum XLoginCaptureScript {
    static let handlerName = "birdieSession"
    static let allowedOperations: Set<String> = [
        "HomeLatestTimeline", "HomeTimeline", "SearchTimeline", "UserByScreenName", "UserByRestId",
        "UserTweets", "UserTweetsAndReplies", "UserMedia", "TweetDetail",
        "viewerQuery", "HomeLatestTimelineQuery", "UserOriginalsTimeline"
    ]

    static let source = #"""
    (() => {
      if (location.protocol !== 'https:' || location.hostname !== 'x.com' || window !== window.top) return;
      const operations = new Set(['HomeLatestTimeline', 'HomeTimeline', 'SearchTimeline', 'UserByScreenName',
        'UserByRestId', 'UserTweets', 'UserTweetsAndReplies', 'UserMedia', 'TweetDetail',
        'viewerQuery', 'HomeLatestTimelineQuery', 'UserOriginalsTimeline']);
      function target(value) {
        try {
          const url = new URL(value, location.href);
          const operation = url.pathname.split('/').filter(Boolean).at(-1);
          if (url.protocol !== 'https:' || (url.port && url.port !== '443') || !['x.com', 'api.x.com'].includes(url.hostname) ||
              !url.pathname.includes('/graphql/') || !operations.has(operation)) return null;
          return url;
        } catch (_) { return null; }
      }
      function notify(url, bearer, rawBody, method) {
        if (!url || typeof bearer !== 'string' || !/^Bearer\s+\S+$/i.test(bearer) || bearer.length > 2048) return;
        let body = {};
        if (typeof rawBody === 'string' && rawBody.length < 200000) {
          try {
            const parsed = JSON.parse(rawBody);
            for (const key of ['variables', 'features', 'fieldToggles']) {
              if (parsed[key] && typeof parsed[key] === 'object') body[key] = parsed[key];
            }
          } catch (_) {}
        }
        window.webkit.messageHandlers.birdieSession.postMessage({ url: url.href, bearer, userAgent: navigator.userAgent, body, method: String(method || 'GET').toUpperCase() });
      }
      const originalFetch = window.fetch;
      window.fetch = function(input, options) {
        const url = target(input instanceof Request ? input.url : input);
        if (url) {
          try {
            const headers = new Headers(input instanceof Request ? input.headers : undefined);
            if (options?.headers) new Headers(options.headers).forEach((value, key) => headers.set(key, value));
            const bearer = headers.get('authorization');
            const method = options?.method || (input instanceof Request ? input.method : 'GET');
            if (typeof options?.body === 'string') notify(url, bearer, options.body, method);
            else if (input instanceof Request) input.clone().text().then(body => notify(url, bearer, body, method)).catch(() => {});
            else notify(url, bearer, null, method);
          } catch (_) {}
        }
        return originalFetch.apply(this, arguments);
      };
      const state = new WeakMap();
      const open = XMLHttpRequest.prototype.open;
      const header = XMLHttpRequest.prototype.setRequestHeader;
      const send = XMLHttpRequest.prototype.send;
      XMLHttpRequest.prototype.open = function(method, value) {
        const url = target(value);
        if (url) state.set(this, { url, method }); else state.delete(this);
        return open.apply(this, arguments);
      };
      XMLHttpRequest.prototype.setRequestHeader = function(name, value) {
        const request = state.get(this);
        if (request && String(name).toLowerCase() === 'authorization') request.bearer = String(value);
        return header.apply(this, arguments);
      };
      XMLHttpRequest.prototype.send = function(body) {
        const request = state.get(this);
        // Session observation must never prevent X from sending its own request.
        try { if (request) notify(request.url, request.bearer, body, request.method); } catch (_) {}
        return send.apply(this, arguments);
      };
    })();
    """#
}
