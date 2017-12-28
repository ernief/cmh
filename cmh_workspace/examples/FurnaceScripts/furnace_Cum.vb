'description - Sum furnace on-time (in seconds) through the day
' This script is called when the Furnace monitor detects the Furnace turns off.
' A paired event stores the time in "WillowCk-V4" when the furnace turned on.
' The on-time is then calculated to be the difference between the two times and
' this is stored back in virtual device V3.
Sub Main(ByVal Parms As String)

	dim strDevVirtTimeOn as string = "WillowCk-V4"
	dim TimeOn as string = GetDevStringByAddr( strDevVirtTimeOn )

	Dim TimeOff as String = Now()
	Dim SecSinceLastChange as Long = DateDiff( "s", TimeOn, TimeOff)

	dim strDevVirtCum as string = "WillowCk-V3"
        Dim CumSeconds as long = iGetDevValByAddr( strDevVirtCum )

	Dim newCumSeconds as long = CumSeconds + SecSinceLastChange

	setDevValueByAddr(  strDevVirtCum, newCumSeconds )
	setDevStringByAddr( strDevVirtCum, Timeoff )

hs.writelog("FurnaceLog", "Debug: CumTime: " & newCumSeconds & "  oldcum=" & CumSeconds & "  delta=" & SecSinceLastChange )

End Sub
'-------------------------------------------------------------------
' Store in WillowCk-V4 the current time that the furnace turned on
'-------------------------------------------------------------------
Sub FurnaceTurnedOn(ByVal Parms As String)
	dim strVirtDevAddress as string = "WillowCk-V4"
	setDevStringByAddr( strVirtDevAddress, now() )
End Sub
'-------------------------------------------------------------------
' Reset V3 value=0 at midnight
'-------------------------------------------------------------------
Sub FurnaceCumReset(ByVal Parms As String)
	dim strDevVirtCum as string = "WillowCk-V3"
	setDevValueByAddr(  strDevVirtCum, 0 )
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
' GetDevStringByAddr: returns a device's value as an integer
'-------------------------------------------------------------------
private Function GetDevStringByAddr(ByVal DevAddrStr As String ) as String
        Dim intDevRef as Integer = hs.GetDeviceRef(DevAddrStr)
	GetDevStringByAddr = ""
	if intDevRef <= 0 Then
	    hs.writelog( "Error", "iGetDevValByAddr: device not found =" & DevAddrstr )
	else
	    GetDevStringByAddr = hs.DeviceString(intDevRef)
	end If
End Function
'-------------------------------------------------------------------
' setDevValueByAddr: sets a device's double value
'-------------------------------------------------------------------
private Sub setDevValueByAddr(ByVal DevAddrStr As String, ByVal dblNewVal as Double )
        Dim intDevRef as Integer = hs.GetDeviceRef(DevAddrStr)
	if intDevRef <= 0 Then
	    hs.writelog( "Error", "setDevValueByAddr: device not found =" & DevAddrstr )
	else
	    hs.SetDeviceValueByRef( intDevRef, dblNewVal, TRUE )
	end If
End Sub
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

