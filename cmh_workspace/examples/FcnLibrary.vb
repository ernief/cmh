' File containing various subroutines and functions
' Test routine
Public Sub Main(ByVal Parms As Object)

   dim debugSelector as integer

   debugSelector = 1

   if debugSelector = 1 then
           hs.writelog( "Debug", "Testing dGetDevValByAddr" )

	   dim strDevAddress as string
	   dim dDevVal as double
'	   strDevAddress = "DB000002F891D328:T:A"
	   strDevAddress = "003D3571-043-Q70"
	   dDevVal = dGetDevValByAddr(strDevAddress) 
	   hs.writelog( "Debug", "Value of " & strDevAddress & " = " & dDevVal )

	   strDevAddress = "DB000002F891D328:T:x"
	   dDevVal = dGetDevValByAddr(strDevAddress) 
	   hs.writelog( "Debug", "Value of " & strDevAddress & " = " & dDevVal )

   else if debugSelector = 2 then
           hs.writelog( "Debug", "Testing iGetDevValByAddr" )

	   dim strDevAddress as string
	   dim iDevVal as integer
	   strDevAddress = "DB000002F891D328:T:A"
	   iDevVal = iGetDevValByAddr(strDevAddress) 
	   hs.writelog( "Debug", "Value of " & strDevAddress & " = " & iDevVal )

	   strDevAddress = "DB000002F891D328:T:x"
	   iDevVal = iGetDevValByAddr(strDevAddress) 
	   hs.writelog( "Debug", "Value of " & strDevAddress & " = " & iDevVal )

   else if debugSelector = 3 then
           hs.writelog( "Debug", "Testing ControlDevByAddr" )

	   dim strDevAddress as string
           strDevAddress = "003D3571-002-Q1"
	   ControlDevByAddr( strDevAddress, "Off" )
	   hs.Waitsecs(3)
	   ControlDevByAddr( strDevAddress, "On" )

   else if debugSelector = 4 then
           hs.writelog( "Debug", "Testing dumpCAPI" )

	   dim strDevAddress as string
	   dim intDevRef as Integer
           strDevAddress = "003D3571-002-Q1"
           intDevRef = hs.GetDeviceRef(strDevAddress)
           dumpCAPI( intDevRef )

   else if debugSelector = 5 then
           hs.writelog( "Debug", "Testing get time of last change" )
	   dim strDevAddress as string = "A5000002F758C128:T:A"
	   dim lastchange as date
	   lastchange = dateGetDevLastChgByAddr(strDevAddress)
           hs.writelog( "Debug", "dateGetDevLastChgByAddr = " & lastchange )
	   strDevAddress = "A5000002F758C128:T:xx"
	   lastchange = dateGetDevLastChgByAddr(strDevAddress)
           hs.writelog( "Debug", "dateGetDevLastChgByAddr = " & lastchange )

   else if debugSelector = 6 then
           hs.writelog( "Debug", "Testing set value of virtual device" )
	   dim strDevAddress as string = "WillowCk-V4"
	   setDevStringByAddr( strDevAddress, now() )
	   dim intDevRef as Integer
	   dim strValue as string
           intDevRef = hs.GetDeviceRef(strDevAddress)
           strValue = hs.DeviceString(intDevRef)
           hs.writelog( "Debug", "String value of " & strDevAddress & " is " & strValue )
   end if
End Sub
'-------------------------------------------------------------------
' dGetDevValByAddr: returns a device's value as a double
'-------------------------------------------------------------------
private Function dGetDevValByAddr(ByVal DevAddrStr As String ) as Double
        Dim intDevRef as Integer = hs.GetDeviceRef(DevAddrStr)
	dGetDevValByAddr = -1
	if intDevRef <= 0 Then
	    hs.writelog( "Error", "dGetDevValByAddr: device not found =" & DevAddrstr )
	else
	    dGetDevValByAddr = hs.DeviceValueEx( intDevRef )
	end If
End Function
'-------------------------------------------------------------------
' setDevStringByAddr: sets a device's string value
'-------------------------------------------------------------------
private Sub setDevStringByAddr(ByVal DevAddrStr As String, ByVal strNewVal as String )
        Dim intDevRef as Integer = hs.GetDeviceRef(DevAddrStr)
	if intDevRef <= 0 Then
	    hs.writelog( "Error", "setDevStringByAddr: device not found =" & DevAddrstr )
	else
	    hs.SetDeviceString( intDevRef, strNewVal, TRUE )
	end If
End Sub
'-------------------------------------------------------------------
' setDevValueByAddr: sets a device's string value
'-------------------------------------------------------------------
private Sub setDevValueByAddr(ByVal DevAddrStr As String, ByVal strNewVal as String )
        Dim intDevRef as Integer = hs.GetDeviceRef(DevAddrStr)
	if intDevRef <= 0 Then
	    hs.writelog( "Error", "setDevValueByAddr: device not found =" & DevAddrstr )
	else
	    hs.SetDeviceValueByRef( intDevRef, strNewVal, TRUE )
	end If
End Sub
'-------------------------------------------------------------------
' iGetDevValByAddr: returns a device's value as an integer
'-------------------------------------------------------------------
private Function iGetDevValByAddr(ByVal DevAddrStr As String ) as Integer
        Dim intDevRef as Integer = hs.GetDeviceRef(DevAddrStr)
	iGetDevValByAddr = -1
	if intDevRef <= 0 Then
	    hs.writelog( "Error", "iGetDevValByAddr: device not found =" & DevAddrstr )
	else
	    iGetDevValByAddr = hs.DeviceValue( intDevRef )
	end If
End Function
'-------------------------------------------------------------------
' dGetDevLastChgByAddr: returns a device's value as a Date
'-------------------------------------------------------------------
private Function dateGetDevLastChgByAddr(ByVal DevAddrStr As String ) as Date
        Dim intDevRef as Integer = hs.GetDeviceRef(DevAddrStr)
	dateGetDevLastChgByAddr = #2/2/2002 12:12 PM#
	if intDevRef <= 0 Then
	    hs.writelog( "Error", "dateGetDevLastChgByAddr: device not found =" & DevAddrstr )
	else
	    dateGetDevLastChgByAddr = hs.DeviceLastChangeRef( intDevRef )
	end If
End Function
'-------------------------------------------------------------------
' ControlDevByAddr: sends a command to the address-named device.
'-------------------------------------------------------------------
private Sub ControlDevByAddr(ByVal DevAddrStr As String, ByVal strDevCmd As String)
        Dim intDevRef as Integer = hs.GetDeviceRef(DevAddrStr)
	if intDevRef <= 0 Then
	    hs.writelog( "Error", "ControlDevStr: device not found =" & DevAddrstr )
	else
	   	' Enum for CAPIControlResponse:
	    	' 	CAPIControlResponse.Indeterminate= 0
	    	'	CAPIControlResponse.All_Success  = 1
	    	'	CAPIControlResponse.Some_Failed  = 2
	    	'	CAPIControlResponse.All_Failed   = 3
	    Dim CAPIResponse as CAPIControlResponse
            CAPIResponse = CAPIControlResponse.Indeterminate  'set default return value
	    'Iterate through all device controls to find a matching label
	    For Each objCAPIControl As CAPIControl In hs.CAPIGetControl(intDevRef)
		If LCase(objCAPIControl.Label) = LCase(strDevCmd) Then
'			ControlDevByAddr = hs.CAPIControlHandler(objCAPIControl)
			CAPIResponse = hs.CAPIControlHandler(objCAPIControl)
			Exit For
		End If
	    Next
	    if CAPIResponse <> CAPIControlResponse.All_Success Then
	        hs.writelog( "Error", "ControlDevByAddr: Unable to control device " & DevAddrStr & " to " & strDevCmd )
	    End If
	end If
End Sub
'-------------------------------------------------------------------
' dumpCAPI: Dump out the contents of the control object (e.g. label)
'-------------------------------------------------------------------
Private sub dumpCAPI( ByVal DevRef As Integer )
    Dim objDev As Object
    Dim intCount As Integer

    objDev = hs.GetDevicebyRef(DevRef)
    If objDev Is Nothing Then
        hs.WriteLog("DevInfo","Invalid device ref: " & DevRef)
    Else
        hs.WriteLog("DevInfo", "Name=" & objDev.Name(hs) & "; Location=" & objDev.Location(hs) & "; Location2=" & objDev.Location2(hs) & "; Address=" & objDev.Address(hs))

    intCount = 0
    For Each objCAPIControl As CAPIControl In hs.CAPIGetControl(DevRef)
        hs.WriteLog("DevInfo", ".CCIndex=" & CStr(objCAPIControl.CCIndex) & "; Label=" & Cstr(objCAPIControl.Label) & "; ControlType=" & CStr(objCAPIControl.ControlType) & "; ControlValue=" & CStr(objCAPIControl.ControlValue) & "; ControlString=" & objCAPIControl.ControlString)

        intCount = intCount + 1
    Next
    If intCount = 0 Then hs.WriteLog("DevInfo", "No CAPIControl objects defined for this device")
    End If
end sub
