# vim: ft=muttrc:
set my_server      = imap.fastmail.com
set my_smtp_server = smtp.fastmail.com
set my_user        = "jenner@jfave.com"

# IMAP/SMTP password — read from an untracked file populated by dot-secrets from
# Bitwarden (see secrets/). Never committed. If the file is absent, neomutt just
# prompts for the password interactively.
set my_pass = `cat ~/.config/fastmail/imap-password 2>/dev/null`

# IMAP
set imap_user = $my_user
set imap_pass = $my_pass
set folder    = "imaps://$my_server/"
set mbox      = "+INBOX"
set postponed = "+Drafts"
set record    = "+Sent"
set spoolfile = "+INBOX"
set trash     = "+Trash"

# SMTP
set smtp_url      = "smtp://$my_user:$my_pass@$my_smtp_server:587/"
set smtp_pass     = $my_pass
set ssl_force_tls = yes
set from          = "jenner@jfave.com"
set hostname      = "jfave.com"
set ssl_starttls  = yes

set mail_check          = 60
set timeout             = 300
set imap_keepalive      = 300
set imap_check_subscribed
set move = no
set include
set auto_tag = yes
set net_inc  = 5

ignore "Authentication-Results:"
ignore "DomainKey-Signature:"
ignore "DKIM-Signature:"
hdr_order Date From To Cc
alternative_order text/plain text/html *
auto_view text/html

# GPG signing
set pgp_use_gpg_agent = yes
set pgp_sign_as       = 85368436
set pgp_timeout       = 3600
set crypt_autosign     = yes
set crypt_replyencrypt = yes
