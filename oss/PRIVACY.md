# RS-MediaPlayer privacy policy

*Effective: 7 November 2026*

RS-MediaPlayer needs an account so that your subscription, profiles and lists work on every device you
use: Mac, iPhone, iPad and Samsung TV. This policy says what is stored, where, why, and how to remove it.
There is no analytics, no advertising and no tracking, and nothing is sold or shared.

**Who is responsible:** RS-Development, the developer of RS-MediaPlayer.
**Contact:** roy@rs-development.nl, or an issue at https://github.com/RoySchultz/rs-mediaplayer.

## What is stored on our server

| Data | Why |
|---|---|
| **Your email address** | To sign in, and to send a password-reset link or a confirmation when you delete your account. We send no other mail. |
| **Your password, as a hash** (Argon2id) | To check your sign-in. The password itself is never stored. |
| **Signed-in devices**: a device ID, the name you see in the app (for example "Living room"), the kind of device, and when it signed in and was last used | To keep you signed in, and so you can see and sign out your devices. |
| **Your profiles**: name, picture, colour; the child-lock PIN only as a hash | So "Who's Watching?" is the same on every device. |
| **Your lists, per profile**: favorites with their order and groups, Recently Watched, Continue Watching with how far you got, thumbs up or down, watched titles, hidden and locked categories, audio and subtitle language per title, and reminders | So they are the same on every device, and For You can use them. |
| **Your sources, encrypted** (server address, username and password of your provider, or a playlist address) | So you don't have to add them on every device. They are encrypted on your device with a key made from your account password. That key never leaves your devices, so **we can't read your sources**. |
| **What is playing now**: the device and the title of each picture that plays | To count screens for your subscription and show "Watching on another device". Kept only while it plays: removed at most a few minutes after it stops. |
| **Your subscription**: which product, from which store, until when, and the store's purchase number | So your subscription works on all your devices. |

Titles in your lists are linked to a source by a code computed on your device, not by the source's address
or login. Settings such as buffer, appearance and stream format stay on each device and are not stored.

**Security records.** To stop people guessing passwords, the server counts failed sign-ins and reset
requests for a short time (at most a day). It keeps these counts under a one-way code (a hash) of your email
and IP address, never the address itself.

**Server logs.** Like every web host, our hosting provider keeps standard access logs (IP address, time,
which address on our server was requested) for a short period, for security and to fix problems. We don't
use them for anything else.

## Where it is stored

On a server of STRATO AG in Germany (European Union), only reachable over an encrypted connection (HTTPS).

## What is not collected

- What you watch is not sent anywhere except as part of your own lists above, and the title that is playing
  right now (removed minutes after it stops).
- Your streams, channel lists and guides go directly from your provider to your device, not through our server.
- No analytics, crash reporting, advertising or tracking identifiers.

## Subscriptions

Purchases are handled by Apple (App Store) or Samsung. They tell our server which subscription belongs to
your account and until when it is valid, so it works on all your devices. We never see your payment details.

## How long it is kept, and deleting it

- Everything is kept as long as you have an account.
- When you remove something from a list, a small marker is kept for up to 180 days so your other devices
  remove it too.
- **Delete your account** in any of the apps: Settings → Account on iPhone, iPad and Samsung TV, or Profiles → Delete Account… on the Mac. That removes your
  account and everything above from our server at once, and you get a confirmation mail. Store
  subscriptions are not cancelled by this; cancel them in your Apple or Samsung account.
- Signing out of a device ends its session; deleting the app removes what it kept on that device.
- If you forget your password and reset it, your encrypted sources can no longer be opened and are removed
  from the server; your profiles and lists stay.

## Your rights

You can ask what we store about you, have it corrected or deleted, get a copy, or object to its use, by
contacting us at the address above. You can also complain to a data protection authority, in the
Netherlands the Autoriteit Persoonsgegevens.

The legal basis is the contract with you (the account and the service you asked for) and, for the
security records, our legitimate interest in keeping accounts safe.

## Children

RS-MediaPlayer is not meant for children to create accounts. Profiles for children are part of a parent's
account.

## Changes

If this policy changes, the new version is published here with a new date, and the apps point it out.

RS-MediaPlayer doesn't include, sell or recommend any channels, playlists or providers.
