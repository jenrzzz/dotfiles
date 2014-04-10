# vim: set ft=muttrc:
set from="jenner_lafave@apple.com"
set hostname="apple.com"
set imap_user="jenner_lafave"
set imap_pass="apOptionExplicitBanana42"
set smtp_url="smtp://jenner_lafave@mail.apple.com"
set smtp_pass="apOptionExplicitBanana42"

set folder="imaps://mail.apple.com"
set postponed="+Drafts"
set spoolfile="+INBOX"
set record="+Sent"
set mail_check=60
set timeout=300
set imap_keepalive=300
set imap_check_subscribed
set move=no
set include
set auto_tag=yes
ignore "Authentication-Results:"
ignore "DomainKey-Signature:"
ignore "DKIM-Signature:"
hdr_order Date From To Cc
alternative_order text/plain text/html *
auto_view text/html
