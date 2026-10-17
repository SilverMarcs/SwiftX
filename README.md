# Birdie

A native X reader for iOS, macOS, and visionOS 26 or later.

- **Feed** shows the signed-in account’s Following timeline, with Recent and Popular in the toolbar.
- **Settings** contains account sign-in/sign-out and playback/cache preferences.
- **Search** finds posts and people. Open an author’s profile to follow, unfollow, or cancel a pending follow request.

Sign-in uses X’s website in an isolated WebKit session. Birdie validates the account before saving its session in the device Keychain. Safari’s existing login is separate. Sign-out clears Birdie’s saved credentials and its X website data.

The integration uses X’s undocumented web endpoints. Operation metadata is captured during sign-in, with current public JavaScript discovery when a read endpoint changes. No developer API key or server is required. Session expiration prompts another sign-in; rate limits and other failures remain retryable.

Open `Birdie.xcodeproj` and build the `Birdie` scheme. Live account actions require a signed-in session. Never add cookies, tokens, or personal response captures to the repository.
