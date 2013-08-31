﻿;
; AutoHotkey (Tested) Version: 1.1.13.00
; Author:         Joe DF  |  http://joedf.co.nr  |  joedf@users.sourceforge.net
; Date:           August 31st, 2013
;
;	LibCon - AutoHotkey Library For Console Support
;
;///////////////////////////////////////////////////////

;Console Constants ;{
	sType := Object("SHORT", 2, "COORD", 4, "WORD", 2, "SMALL_RECT", 8, "DWORD", 4)

	Black:=0x0
	DarkBlue:=0x1
	DarkGreen:=0x2
	Turquoise:=0x3
	DarkGreenBlue:=0x3
	GreenBlue:=0x3
	DarkRed:=0x4
	Purple:=0x5
	Brown:=0x6
	Gray:=0x7
	Grey:=0x7
	DarkGray:=0x8
	DarkGrey:=0x8
	Blue:=0x9
	Green:=0xA
	Cyan:=0xB
	Red:=0xC
	Magenta:=0xD
	Pink:=0xD
	Yellow:=0xE
	White:=0xF
;}

;Console Functions + More... ;{
	StartConsole() {
		global Stdout
		global Stdin
		x:=AllocConsole()
		Stdout:=getStdoutObject()
		Stdin:=getStdinObject()
		return x
	}

	AttachConsole(cPID) {
		global Stdout
		global Stdin
		x:=DllCall("AttachConsole", "int", cPID, "Cdecl int")
		Stdout:=getStdoutObject()
		Stdin:=getStdinObject()
		return x
	}
	
	AllocConsole() {
		return DllCall("AllocConsole")
	}

	FreeConsole() {
		return DllCall("FreeConsole")
	}

	getStdinObject() {
		return FileOpen(DllCall("GetStdHandle", "int", -10, "ptr"), "h `n")
	}

	getStdoutObject() {
		return FileOpen(DllCall("GetStdHandle", "int", -11, "ptr"), "h `n")
	}

	setColor(FG="",BG="") { ;Sets the color (int Hexadecimal number)
		global Stdout
		if FG is not integer
			FG:=getFgColor()
		if BG is not integer
			BG:=getBgColor()
		FG:=abs(FG)
		BG:=abs(BG)*16
		return DllCall("SetConsoleTextAttribute","UPtr",Stdout.__Handle,"Int",(BG+FG))
	}
	
	setFgColor(c) {
		return setcolor(c)
	}
	
	setBgColor(c) {
		return setColor("",c)
	}

	getColor() { ;Returns the current color (int Hexadecimal number)
		global Stdout
		global sType
		VarSetCapacity(consoleInfo,(3*sType.COORD)+sType.WORD+sType.SMALL_RECT,0)
		DllCall("GetConsoleScreenBufferInfo","UPtr",Stdout.__Handle,"Ptr",&consoleInfo)
		return dec2hex(NumGet(&consoleInfo,(2*sType.COORD),"Short"))
	}
	
	getFgColor() {
		c:=getColor()
		return dec2hex(c-(16*getBgColor()))
	}
	
	getBgColor() {
		c:=getColor()
		return dec2hex(c >> 16)
	}
	
	printcolortable() {
		f:=0
		b:=0
		cf:=getFGColor()
		cb:=getBGColor()
		
		puts("`n`t1st Digit: Background 2nd Digit: Foreground")
		puts("_______________________________________________________________")
		
		Loop, 16 
		{
			b:=(A_Index-1)
			print("`t" . "")
			Loop, 16 
			{
				setColor(f:=(A_Index-1), b)
				print(dec2shex(b) . dec2shex(f) . ((f=15 or f="F") ? "`n" : " "))
			}
			setColor(cf,cb)
		}
		puts("_______________________________________________________________")
		puts("Current Color: " . getColor())
	}
	
	puts(string="") {
		global Stdout
		Stdout.WriteLine(string) ;Stdout.write(string . "`n")
		Stdout.Read(0)
	}
	
	print(string="") {
		global Stdout
		if strlen(string) > 0
			Stdout.write(string)
		Stdout.Read(0)
	}
	
	;fork of 'formatprint' :  http://www.autohotkey.com/board/topic/60731-printf-the-ahk-way/#entry382968
	printf(msg, vargs*) {
		for each, varg in vargs
		{
			msg:=RegExReplace(msg,"i)`%.",varg)
			/*
			StringReplace, msg, msg, `%s, % varg
			StringReplace, msg, msg, `%c, % chr(varg)
			msg:=RegExReplace(msg,"i)`%[idufeEgG]",(varg+0))
			StringReplace, msg, msg, `%p, % &varg
			StringReplace, msg, msg, `%o, % num2octal(varg+0)
			hex:="" . dec2hex(varg+0)
			StringLower,hex,hex
			msg:=RegExReplace(msg,"`%x",hex)
			StringUpper,hex,hex
			msg:=RegExReplace(msg,"`%X",hex)
			*/
		}
		return print(msg)
	}
	
	putsf(msg, vargs*) {
		for each, varg in vargs
		{
			msg:=RegExReplace(msg,"i)`%.",varg)
		}
		return puts(msg)
	}
	
	gets(ByRef var="") {
		global Stdin
		return var:=RTrim(Stdin.ReadLine(), "`n")
	}
	
	wait(timeout=0) {
		opt:=""
		if (!timeout=0)
			opt=T%timeout%
		Input, SingleKey, L1 %opt%, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
		return %SingleKey%
	}
	
	;from gwarble
	;http://www.autohotkey.com/board/topic/96304-real-console-applications-command-line-apps/?hl=console
	WaitAction() {
		global Stdin
		VarSetCapacity(INPUT_RECORD, 24, 0)
		DllCall("ReadConsoleInput", uint, stdin.__Handle, uint, &INPUT_RECORD, uint, 1, "ptr*", 0)
		key := NumGet(INPUT_RECORD, 8)
		return key
	}
	
	pause(show=1) {
		n:=""
		if (!show)
			n:=">NUL"
		runwait %ComSpec% /c pause.exe %n%
	}

	dec2hex(var) {
		OldFormat := A_FormatInteger
		SetFormat, Integer, Hex
		var += 0
		SetFormat, Integer, %OldFormat%
		return var
	}

	dec2shex(var) { ;dec to S(tring)Hex
		var:=("" . dec2hex(var))
		StringRight,var,var,1
		;var:=var + 0
		return var
	}

	hex2dec(var) {
		OldFormat := A_FormatInteger
		SetFormat, Integer, D
		var += 0
		SetFormat, Integer, %OldFormat%
		return var
	}
	
	;from Laszlo : http://www.autohotkey.com/board/topic/15951-base-10-to-base-36-conversion/#entry103624
	ToBase(n,b) { ; n >= 0, 1 < b <= 36
		Loop {
			d := mod(n,b), n //= b
			m := (d < 10 ? d : Chr(d+55)) . m
			IfLess n,1, Break
		}
		Return m
	}

	newline(x=1) {
		loop %x%
			puts()
	}
	
	;Fork of http://www.autohotkey.com/board/topic/90674-ascii-progress-bar/
	sProgressBar(Length, Current, Max, Unlock = 0, lp="|", lba="[", lbb="]") {
		;Original Made by Bugz000 with assistance from tidbit, Chalamius and Bigvent
		Progress:=""
		Percent := (Current / Max) * 100
		if (unlock = 0)
				length := length > 97 ? 97 : length < 4 ? 4 : length
		percent := percent > 100 ? 100 : percent < 0 ? 0 : percent
		Loop % round(((percent / 100) * length), 0)
				Progress .= lp
		loop % Length - round(((percent / 100) * length), 0)
				Progress .= A_Space
		return lba progress lbb A_space round(percent, 2) "% Complete"
	}
	
	;Get BufferSize, GetConsoleScreenBufferInfo()
	getConsoleSize(ByRef bufferwidth, ByRef bufferheight) {
		global Stdout
		global sType
		hStdout := Stdout.__Handle
		VarSetCapacity(struct,(sType.COORD*3)+sType.WORD+sType.SMALL_RECT,0)
		rvalue:=DllCall("GetConsoleScreenBufferInfo","UPtr",hStdout,"Ptr",&struct)
		derror:=ErrorLevel
		bufferwidth:=NumGet(&struct,"UShort")
		bufferheight:=NumGet(&struct,sType.SHORT,"UShort")
		
		if (derror) or (rvalue=0)
		{
			return 0 ;Failure
		}
		else
			return 1 ;Success
	}

	getConsoleWidth() {
		if (!getConsoleSize(bufferwidth,bufferheight))
			return 0 ;Failure
		else
			return %bufferwidth% ;Success
	}

	getConsoleHeight() {
		if (getConsoleSize(bufferwidth,bufferheight))
			return 0 ;Failure
		else
			return %bufferheight% ;Success
	}
;}

