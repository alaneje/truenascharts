# Mailcow

[Mailcow: dockerized](https://mailcow.email/) is an open source, full-featured email and groupware server suite powered by Dovecot, Postfix, SOGo, Rspamd, ClamAV, and MariaDB.

## Features

- **Webmail & Groupware**: SOGo webmail interface with CalDAV/CardDAV calendar and contact sync.
- **Modern Security**: Rspamd antispam, DKIM signing, ARC, SPF verification, and DMARC reporting.
- **Antivirus**: ClamAV malware scanning engine.
- **Multi-Protocol Support**: IMAP, IMAPS, POP3, POP3S, SMTP, SMTPS, and Submission.
- **Administration UI**: Complete web interface for domains, mailboxes, aliases, relays, and TLS certificates.

## Prerequisites & DNS Setup

Before configuring Mailcow, ensure that you have configured the appropriate DNS records:
- **MX Record**: Points to your Mailcow hostname (e.g. `mail.example.com`).
- **A/AAAA Record**: Points to your server's public IP address.
- **Reverse DNS (PTR)**: Set up with your ISP/hosting provider matching the hostname.
- **SPF Record**: `v=spf1 mx ~all`
- **DKIM & DMARC**: Generated and configured via the Mailcow administration panel.
