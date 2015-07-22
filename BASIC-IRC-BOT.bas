
client = _OPENCLIENT("TCP/IP:6667:chat.freenode.net")
IF client THEN
    PRINT "[Connected to " + _CONNECTIONADDRESS(client) + "]"
    IrcClient (client)
ELSE 
    PRINT "[Connection Failed!]"
END IF

' The "main" sub-routine
SUB IrcClient (handler)
    nick$ = "NICK TonyBot" + CHR$(13) + CHR$(10)
    user$ = "USER TonyBot irc.freenode.net bla HavreBot" + CHR$(13) + CHR$(10)
    PUT handler, , nick$ ' Set nickname on the IRC network
    PUT handler, , user$ ' Send user information IDENT HOST and REALNAME
    ' Superloop, should never end this loop
    WHILE 1
        SLEEP 1 ' Read data every second should be enough
        GET handler, , b$
        IF LEN(b$) <> 0 THEN
            PRINT "Received: " + b$ 'For debugging
        END IF
        ProcessMessage handler, b$
    WEND
    ' End of super loop
END SUB

' Processes messages coming from the server and sends the
' message to it's handler
SUB ProcessMessage(handler, message$)
    ' Respond to PING
    IF INSTR(message$, "PING") <> 0 THEN
        Ping handler, message$
    END IF
    ' Check if the message is a channel message
    IF INSTR(message$, "PRIVMSG #") <> 0 THEN
        ChannelMessage handler, message$
    ' Check if the message is a private message
    ELSEIF INSTR(message$, "PRIVMSG") <> 0 THEN
        PrivateMessage handler, message$
    END IF    
END SUB
' Handle the ping from the IRC server
' A ping message and it's response should be as follows:
' PING :<server-ip>
' PONG :<server-ip>
SUB Ping(handler, message$)
    l$ = LEFT$(message$, INSTR(message$, " ") - 1) ' Left side of splitted string
    r$ = RIGHT$(message$, LEN(message$) - LEN(l$) - 1) ' Right side of splitted string
    IF l$ = "PING" THEN
        pong$ = "PONG " + r$ + CHR$(13) + CHR$(10)
        PUT handler, , pong$
        PRINT "Sent: " + pong$
    END IF
END SUB

' Handle channel messages
' Responds "Hello World!" when someone writes the 
' word "Hello" in the channel #tonys
SUB ChannelMessage(handler, message$)
    IF INSTR(message$, "Hello") <> 0 AND INSTR(message$, "#tonys") <> 0 THEN
        channelResponse$ = "PRIVMSG #tonys :Hello World!" + CHR$(13) + CHR$(10)
        PUT handler, , channelResponse$
        PRINT "Sent: " + channelResponse$
    END IF
END SUB

' Handle private messages
' Joins the server #tonys when it receives a 
' private message consisting of the word "Foo"
SUB PrivateMessage(handler, message$)
    IF INSTR(message$, "Foo") <> 0 THEN
        joinChannel$ = "JOIN #tonys" + CHR$(13) + CHR$(10)
        PUT handler, , joinChannel$
        PRINT "Sent: " +joinChannel$
    END IF
END SUB