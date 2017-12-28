' Used to send alerting text messages from HS events.
' This provides a common place to change who/how to send text messages
'
Public Sub Main(ByVal strSubject As String)

        Dim strFrom As String = "aaaaaaa@gmail.com"
        Dim strTo As String = "3038597374@vtext.com"
        Dim strMessage As String = "$time $date"

        hs.SendEmail(strTo, strFrom, "", "", strSubject, strMessage, "")

End Sub
