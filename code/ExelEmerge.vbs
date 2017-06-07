dim filename
filename = "HW-招聘业绩汇总-" & timeStamp & "-result.xlsx"
set WshShell = WScript.CreateObject("WScript.Shell")
set fso = CreateObject("Scripting.FileSystemObject")
set xlsapp = CreateObject("excel.Application")
xlsapp.ScreenUpdating = False
xlsapp.DisplayAlerts = False
xlsapp.visible = False
set hb = xlsapp.workbooks.add
hb.saveas(WshShell.CurrentDirectory & "\" & filename)
set myfolder = fso.GetFolder(WshShell.CurrentDirectory)

Function timeStamp()
    Dim t 
    t = Now
    timeStamp = Year(t) & _
    Right("0" & Month(t),2) & _
    Right("0" & Day(t),2)  & _  
    Right("0" & Hour(t),2) & _
    Right("0" & Minute(t),2) & _
	Right("0" & Second(t),2) 
End Function

Function CopyData(srcSheet, srcStartRow, destSheet, destStartRow, keyCol)
	for i = srcStartRow To srcSheet.UsedRange.Rows.Count
		v = srcSheet.Cells(i, keyCol).Value
		if v = Empty then
			exit for
		end if
	next
	i = i - 1
	''Wsh.Echo srcStartRow & ":" & i, destStartRow

	srcSheet.Rows(srcStartRow & ":" & i).Copy
	destSheet.Rows(destStartRow).PasteSpecial
End Function

Function CopyHead(srcSheet, destSheet, headRow)
	srcSheet.Rows("1:" & headRow).Copy
	destSheet.Rows("1").PasteSpecial
End Function

Function DoMergeOneSheet(folder, sheetName, headRow, keyCol)
	idx = 1
	Set destSheet = hb.Sheets.Add
	destSheet.name = sheetName
	for each file in folder.Files
		if InStr(file.name, ".xls") <> 0 and Instr(file.name, "result.xlsx") = 0 and InStr(file.name, "$") = 0 then
			''Wsh.Echo WshShell.CurrentDirectory & "\" & file.name
			set workbook = xlsapp.workbooks.open(WshShell.CurrentDirectory & "\" & file.name)
			set srcSheet = workbook.Sheets(sheetName)

			if idx = 1 then
				CopyHead srcSheet, destSheet, headRow
				idx = destSheet.UsedRange.Rows.Count + 1
			end if
			
			CopyData srcSheet, headRow+1, destSheet, idx, keyCol
			idx = destSheet.UsedRange.Rows.Count + 1
			
			workbook.close False
			set workbook = Nothing
		end if
	next
End Function

call DoMergeOneSheet(myfolder, "奖励性工资汇总表", 3, 3)	
call DoMergeOneSheet(myfolder, "招聘业绩报表-IS & SCH业务", 2, 2)

hb.save
hb.close
xlsapp.ScreenUpdating = True
xlsapp.quit
MsgBox "Ok, 请打开" & filename



	
