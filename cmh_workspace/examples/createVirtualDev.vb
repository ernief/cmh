Dim dv
Dim DevExists = hs.DeviceExistsCode("A1")
If DevExists = -1 Then 
   dv = hs.NewDeviceRef("Reading")
   dv.Location = "Utility"
   dv.Code = "A1"
   dv.Device_Type_String = "Status Only"
EndIf

' from https://forums.homeseer.com/showthread.php?t=166047 
Sub CreateDevices()

    Dim CurrRef As Integer = 0
    Dim BaseRef As Integer = 0
    Dim dv As Scheduler.Classes.DeviceClass = Nothing
    Dim root_dv As Scheduler.Classes.DeviceClass = Nothing

    Try
        Log("Devices Do Not Exist - Creating - Data Will Update On Next Run")
        'four devices need to be created, root, current location, current time, am I at home
        For i As Byte = 0 To 3 'needs to be four new devices
            Select Case i
                Case 0
                    dv = hs.GetDeviceByRef(hs.NewDeviceRef(DAddS & " Root Device"))
                    dv.Address(hs) = DAddS & "-Root"
                    BaseRef = dv.Ref(hs)
                Case 1
                    dv = hs.GetDeviceByRef(hs.NewDeviceRef(DAddS & " Current Location Data"))
                    dv.Address(hs) = DAddS & "-CurrLoc"
                Case 2
                    dv = hs.GetDeviceByRef(hs.NewDeviceRef(DAddS & " Current Location Time"))
                    dv.Address(hs) = DAddS & "-CurrTime"
                Case 3
                    dv = hs.GetDeviceByRef(hs.NewDeviceRef(DAddS & " Am I At Home"))
                    dv.Address(hs) = DAddS & "-AmIAtHome"
            End Select

            dv.Location(hs) = "FollowMee"
            dv.Last_Change(hs) = Now
            dv.Device_Type_String(hs) = DAddS & " Device"

            Log("VGP Count: " & hs.DeviceVGP_Count(dv.Ref(hs)))

            hs.DeviceVGP_ClearAll(dv.Ref(hs), True)
            hs.DeviceVGP_Clear(dv.Ref(hs), 0)
            hs.DeviceVGP_Clear(dv.Ref(hs), 1)

            hs.saveeventsdevices()

            Log("VGP Count: " & hs.DeviceVGP_Count(dv.Ref(hs)))

            If i = 0 Then 'on the base device do this, set up the relationships between the devices
                root_dv = dv
                dv.Relationship(hs) = Enums.eRelationship.Parent_Root
            Else
                If root_dv IsNot Nothing Then root_dv.AssociatedDevice_Add(hs, dv.Ref(hs))
                dv.Relationship(hs) = Enums.eRelationship.Child
                dv.AssociatedDevice_Add(hs, BaseRef)
            End If

            'VSPairs? I think only the Am I At Home will need a VSPair

            Select Case i

                Case 0
                    hs.setdevicestring(dv.Ref(hs), "Root Device", True)
                Case 1
                    hs.setdevicestring(dv.Ref(hs), "Awaiting Data", True)
                Case 2
                    hs.setdevicestring(dv.Ref(hs), "Awaiting Data", True)
                Case 3
                    Dim Pair As VSPair

                    Pair = New VSPair(HomeSeerAPI.ePairStatusControl.Status)
                    Pair.PairType = VSVGPairType.SingleValue
                    Pair.Value = 1
                    Pair.Status = "I Am At Home"
                    hs.DeviceVSP_AddPair(dv.Ref(hs), Pair)

                    Pair = New VSPair(HomeSeerAPI.ePairStatusControl.Status)
                    Pair.PairType = VSVGPairType.SingleValue
                    Pair.Value = 0
                    Pair.Status = "I Am Not At Home"
                    hs.DeviceVSP_AddPair(dv.Ref(hs), Pair)

            End Select

        Next

        Log("End Of Create Devices Routine")
    Catch ex As Exception
        Log("Create Devices Exception: " & ex.message.tostring)
    End Try

End Sub

' In response to the issue of getting rid of the default icon (light bulb icon), ... 
' Try setting dv.Interface(hs) to something other than blank i.e.
'
'PHP Code:
'dv.Interface(hs)="FollowMee"  
'Otherwise set the devicestring for the device which contains a blank image i.e.
'
'PHP Code:
'hs.SetDeviceString(dvRef, "<img src=""/images/Homeseer/ui/5-x-5_trans_spacer.gif"">", True)  
