#Persistent
#SingleInstance force

; Initialize variables
lastClipboard := ""
isFirstRun := true  ; Flag to prevent initial notification

; Create GUI for notification
Gui, +AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, Color, 000000	
Gui, Font, s11 cFFFFFF, Belinda, Bold
Gui, Add, Text, vNotificationText w160 Center, Ready
Gui, +LastFound
WinSet, Transparent, 220

; Initialize at startup
lastClipboard := Clipboard  ; Remember initial clipboard content
isFirstRun := true

; Position GUI at bottom right
PositionGui()

; Hook keyboard for better detection
#InstallKeybdHook

; Initialize clipboard checking variable
global clipCheck := ""

; Set timer to check clipboard
SetTimer, CheckClipboard, 100
return

PositionGui() {
    SysGet, MonitorWorkArea, MonitorWorkArea, 1
    Gui, Show, % "x" . (MonitorWorkAreaRight-200) . " y" . (MonitorWorkAreaBottom-70) . " NoActivate Hide", Copy Paste Notification
}

; Monitor for copy operations specifically
~^c::
    Sleep, 100  ; Give time for the clipboard to update
    
    if (isFirstRun) {
        lastClipboard := Clipboard
        isFirstRun := false
        GuiControl,, NotificationText, Copied
        ShowNotification()
        return
    }
    
    ; Compare with last copied content
    if (Clipboard == lastClipboard && Clipboard != "") {
        GuiControl,, NotificationText, Already Copied
        ShowNotification()
    } else if (Clipboard != "") {
        lastClipboard := Clipboard
        GuiControl,, NotificationText, Copied
        ShowNotification()
    }
return

; Monitor for cut operations (Ctrl+X)
~^x::
    Sleep, 100  ; Give time for the clipboard to update
    
    if (Clipboard != "") {
        lastClipboard := Clipboard
        isFirstRun := false
        GuiControl,, NotificationText, Cut
        ShowNotification()
    }
return

; Monitor for paste operations
~^v::
    if (Clipboard != "") {
        GuiControl,, NotificationText, Pasted
        ShowNotification()
    }
return

; Also monitor for typical context menu copy
~RButton::
    ; We'll monitor for right-click menu copy operations
    ; This is more complex and requires context menu tracking
    ; For simplicity, we'll just use the CheckClipboard timer
return

CheckClipboard:
    ; This timer checks for clipboard changes from sources other than Ctrl+C
    ; such as right-click menu copy or application-specific copy functions
    
    if (clipCheck != Clipboard && !isFirstRun && Clipboard != "") {
        if (A_ThisHotkey != "~^c" && A_ThisHotkey != "~^x" && Clipboard != lastClipboard) {
            clipCheck := Clipboard
            lastClipboard := Clipboard
            GuiControl,, NotificationText, Copied
            ShowNotification()
        }
    }
    
    clipCheck := Clipboard
return

ShowNotification() {
    ; Cancel any existing hide timer
    SetTimer, HideGui, Off
    
    ; Show notification
    Gui, Show, NoActivate
    
    ; Set timer to hide
    SetTimer, HideGui, -2000
}

HideGui:
    Gui, Hide
return

; Exit script with Ctrl+Shift+X
^+x::ExitApp