@rem dir without header, footer, empty and dotdir
@dir %* | findstr /v /r /c:"^ [V ]" /c:"^$" /c:"[.]$"
