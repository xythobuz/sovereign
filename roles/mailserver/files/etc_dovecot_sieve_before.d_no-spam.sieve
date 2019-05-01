require "fileinto";
require "imap4flags";

if header :contains "X-Spam-Flag" "YES" {
    setflag "\\seen";
    fileinto "Junk";
    stop;
}

if header :is "X-Spam" "Yes" {
    setflag "\\seen";
    fileinto "Junk";
    stop;
}
