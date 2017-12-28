Friend Const COLOR_RED As String = "#FF0000"
Friend Const COLOR_NAVY As String = "#000080"
Friend Const COLOR_ORANGE As String = "#D58000"
Friend Const COLOR_GREEN As String = "#008000"
Friend Const COLOR_PURPLE As String = "#4B088A"
Friend Const COLOR_BLUE As String = "#0000FF"

Sub Main(Parm As Object)

End Sub

' Control Uses:
'   On = 1
'   Off = 2
'   Dim = 3
'   On_Alternate = 4 (e.g. On Last Level for a Z-Wave device)

Sub ControlDeviceNameAndUse(ByVal Parm As Object)
    If Parm Is Nothing Then
        Log("ControlDeviceNameAndUse", "No parameters provided", COLOR_RED)
        Exit Sub
    End If
    If TypeOf Parm Is Array Then
    ElseIf TypeOf Parm Is Object Then
    ElseIf TypeOf Parm Is String Then
    Else
        Log("ControlDeviceNameAndUse", "Parameters must be an object or string.", COLOR_RED)
        Exit Sub
    End If

    Dim sParm = Parm.ToString
    Dim sArr() As String = Nothing
    Try
        sArr = Split(sParm, ",")
    Catch ex As Exception
        sArr = Nothing
    End Try
    If sArr Is Nothing OrElse sArr.Length < 2 Then
        ' Must have at least the name and the control use.
        Log("ControlDeviceNameAndUse", "This function requires at least 2 parameters, the name and the control use.", COLOR_RED)
        Exit Sub
    End If

    ' First parameter is the name (string), 2nd parameter is the control use (numeric)
    Dim sName As String = ""
    Dim ControlUse As HomeSeerAPI.ePairControlUse = 99 ' Set it to an invalid value for now.
    Try
        sName = sArr(0).ToString
    Catch ex As Exception
        sName = ""
    End Try
    If sName Is Nothing Then sName = ""
    If String.IsNullOrEmpty(sName.Trim) Then
        ' We have to have a device name.
        Log("ControlDeviceNameAndUse", "No device name (Parameter 1) was provided.", COLOR_RED)
        Exit Sub
    End If

    Dim dvRef As Integer
    dvRef = hs.GetDeviceRefByName(sName)
    If dvRef < 1 Then
        Log("ControlDeviceNameAndUse", "The device reference ID for " & sName & " was not found by HomeSeer.", COLOR_RED)
        Exit Sub
    End If

    Dim dv As Scheduler.Classes.DeviceClass = Nothing
    Try
        dv = hs.GetDeviceByRef(dvRef)
    Catch ex As Exception
        dv = Nothing
    End Try

    If dv Is Nothing Then
        Log("ControlDeviceNameAndUse", "The device reference (" & dvRef.ToString & ") found by the name " & sName & " did not correspond to a device in HomeSeer.", COLOR_RED)
        Exit Sub
    End If

    Try
        ControlUse = Convert.ToInt32(sArr(1))
    Catch ex As Exception
        ControlUse = 99
    End Try

    If Not [Enum].IsDefined(GetType(HomeSeerAPI.ePairControlUse), ControlUse) Then
        Log("ControlDeviceNameAndUse", "The ControlUse passed to the procedure is invalid: " & Parm(1).ToString, COLOR_RED)
        Exit Sub
    End If

    Dim Value As Double
    Dim GotValue As Boolean = False
    Try
        If sArr.Length > 2 Then
            Value = Convert.ToDouble(sArr(2))
            GotValue = True
        End If
    Catch ex As Exception
        GotValue = False
    End Try

    Dim CC As HomeSeerAPI.CAPI.CAPIControl = Nothing
    Try
        CC = hs.CAPIGetSingleControlByUse(dvRef, ControlUse)
    Catch ex As Exception
        CC = Nothing
    End Try

    If CC Is Nothing Then
        Log("ControlDeviceNameAndUse", "The CAPI Control for use " & ControlUse.ToString & " was not found in " & hs.DeviceName(dvRef), COLOR_ORANGE)
        Exit Sub
    End If

    If CC IsNot Nothing AndAlso CC.Range IsNot Nothing Then
        ' It is a range, so set the value if we have it.
        If GotValue Then
            CC.ControlValue = Value
        End If
    End If

    Dim Resp As HomeSeerAPI.CAPI.CAPIControlResponse = HomeSeerAPI.CAPIControlResponse.Indeterminate
    Resp = hs.CAPIControlHandler(CC)
    Select Case Resp
        Case HomeSeerAPI.CAPIControlResponse.All_Failed, HomeSeerAPI.CAPIControlResponse.Some_Failed
            Log("ControlDeviceNameAndUse", "The CAPI Control command FAILED for " & hs.DeviceName(dvRef) & " to be set to " & ControlUse.ToString, COLOR_RED)
        Case HomeSeerAPI.CAPIControlResponse.All_Success
            Log("ControlDeviceNameAndUse", "The CAPI Control command for " & hs.DeviceName(dvRef) & " to set it to " & ControlUse.ToString & " was Successful.", COLOR_BLUE)
        Case HomeSeerAPI.CAPIControlResponse.Indeterminate
            Log("ControlDeviceNameAndUse", "The CAPI Control command result is indeterminate for " & hs.DeviceName(dvRef) & " to be set to " & ControlUse.ToString, COLOR_ORANGE)
    End Select

End Sub

Sub ControlDeviceNameAndLabelValue(ByVal Parm As Object)
    If Parm Is Nothing Then
        Log("ControlDeviceNameAndLabelValue", "No parameters provided", COLOR_RED)
        Exit Sub
    End If
    If TypeOf Parm Is Array Then
    ElseIf TypeOf Parm Is Object Then
    ElseIf TypeOf Parm Is String Then
    Else
        Log("ControlDeviceNameAndLabelValue", "Parameters must be an object or string.", COLOR_RED)
        Exit Sub
    End If

    Dim sParm = Parm.ToString
    Dim sArr() As String = Nothing
    Try
        sArr = Split(sParm, ",")
    Catch ex As Exception
        sArr = Nothing
    End Try
    If sArr Is Nothing OrElse sArr.Length < 2 Then
        ' Must have at least the name and the control label.
        Log("ControlDeviceNameAndLabelValue", "This function requires at least 2 parameters, the name and the control label.", COLOR_RED)
        Exit Sub
    End If

    ' First parameter is the name (string), 2nd parameter is the control use (numeric)
    Dim sName As String = ""
    Try
        sName = sArr(0).ToString
    Catch ex As Exception
        sName = ""
    End Try
    If sName Is Nothing Then sName = ""
    If String.IsNullOrEmpty(sName.Trim) Then
        ' We have to have a device name.
        Log("ControlDeviceNameAndLabelValue", "No device name (Parameter 1) was provided.", COLOR_RED)
        Exit Sub
    End If

    Dim dvRef As Integer
    dvRef = hs.GetDeviceRefByName(sName)
    If dvRef < 1 Then
        Log("ControlDeviceNameAndLabelValue", "The device reference ID for " & sName & " was not found by HomeSeer.", COLOR_RED)
        Exit Sub
    End If

    Dim dv As Scheduler.Classes.DeviceClass = Nothing
    Try
        dv = hs.GetDeviceByRef(dvRef)
    Catch ex As Exception
        dv = Nothing
    End Try

    If dv Is Nothing Then
        Log("ControlDeviceNameAndLabelValue", "The device reference (" & dvRef.ToString & ") found by the name " & sName & " did not correspond to a device in HomeSeer.", COLOR_RED)
        Exit Sub
    End If

    Dim Label As String = ""
    Try
        Label = sArr(1)
        If Label Is Nothing Then Label = ""
    Catch ex As Exception
        Label = ""
    End Try

    If String.IsNullOrEmpty(Label.Trim) Then
        Log("ControlDeviceNameAndLabelValue", "The Control Label passed to the procedure is invalid: " & Parm(1).ToString, COLOR_RED)
        Exit Sub
    End If

    Dim Value As Double
    Dim GotValue As Boolean = False
    Try
        If sArr.Length > 2 Then
            Value = Convert.ToDouble(sArr(2))
            GotValue = True
        End If
    Catch ex As Exception
        GotValue = False
    End Try

    Dim arrCC() As HomeSeerAPI.CAPI.CAPIControl = Nothing
    Try
        arrCC = hs.CAPIGetControl(dvRef)
    Catch ex As Exception
        arrCC = Nothing
    End Try

    If arrCC Is Nothing Then
        Log("ControlDeviceNameAndLabelValue", "No CAPI Controls were found in " & hs.DeviceName(dvRef), COLOR_RED)
        Exit Sub
    End If

    Dim Resp As HomeSeerAPI.CAPI.CAPIControlResponse = HomeSeerAPI.CAPIControlResponse.Indeterminate
    Dim CC As HomeSeerAPI.CAPI.CAPIControl = Nothing

    Dim Found As Boolean = False
    For Each CC In arrCC
        If CC Is Nothing Then Continue For
        If CC.Label Is Nothing Then Continue For
        If GotValue Then
            If CC.Range IsNot Nothing Then
                If Value >= CC.Range.RangeStart AndAlso Value <= CC.Range.RangeEnd Then
                    Found = True
                    Exit For
                End If
            Else
                If CC.ControlValue = Value Then
                    Found = True
                    Exit For
                End If
            End If
        Else
            If CC.Label.Trim.ToLower = Label.Trim.ToLower Then
                Found = True
                Exit For
            End If
        End If
    Next

    Dim sValue As String = ""
    If GotValue Then
        sValue = " (" & Value.ToString & ")"
    End If
    If Found AndAlso CC IsNot Nothing Then
        Resp = hs.CAPIControlHandler(CC)
        Select Case Resp
            Case HomeSeerAPI.CAPIControlResponse.All_Failed, HomeSeerAPI.CAPIControlResponse.Some_Failed
                Log("ControlDeviceNameAndLabelValue", "The CAPI Control command FAILED for " & hs.DeviceName(dvRef) & " to be set to " & Label & sValue, COLOR_RED)
            Case HomeSeerAPI.CAPIControlResponse.All_Success
                Log("ControlDeviceNameAndLabelValue", "The CAPI Control command for " & hs.DeviceName(dvRef) & " to set it to " & Label & sValue & " was Successful.", COLOR_BLUE)
            Case HomeSeerAPI.CAPIControlResponse.Indeterminate
                Log("ControlDeviceNameAndLabelValue", "The CAPI Control command result is indeterminate for " & hs.DeviceName(dvRef) & " to be set to " & Label & sValue, COLOR_ORANGE)
        End Select
    Else
        Log("ControlDeviceNameAndLabelValue", "The CAPI Control command for " & hs.DeviceName(dvRef) & " to set it to " & Label & sValue & " was not found.", COLOR_RED)
    End If

End Sub

Sub Log(ByVal Func As String, ByVal Msg As String, Optional ByVal Color As String = "")
    If Func Is Nothing Then Exit Sub
    If Msg Is Nothing Then Exit Sub
    hs.WriteLogEx("Device Control Script", "Function: " & Func & " - " & Msg, Color)
End Sub