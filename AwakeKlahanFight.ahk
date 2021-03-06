﻿; This Application Support with Nox(Android Emulator) with Resolution 800x600 + Display using "DirectX" also install Autohotkey ANSI 32L
#SingleInstance
#include Libs\gdip.ahk   ; http://www.autohotkey.com/forum/topic32238.html 
#include Libs\Gdip_ImageSearch.ahk
SetWorkingDir %A_ScriptDir%

FileCopy, %A_ScriptDir%\Test.png, %A_ScriptDir%\Img\Test.png, 1
;#include FileDelete.ahk
;#include FileInstall.ahk
;FileCopy, Config.ini, %A_Temp%\7K
;SetWorkingDir %A_temp%\7K

global hwnd :=0, CountOpenGame:=0, CountArena:=0, CountBattle:=0, CountTower:=0, DragonLevel:=0, CountMyDragon:=0
global StageLeader:=1, FarmLeader:=1, DragonLeader:=1, ArenaLeader:=1, LeaderFirstTime:=1
global StageMastery:=1, FarmMastery:=3, DragonMastery:=2, ArenaMastery:=1
global MyDragon:=0, DelayClick:=0
global NotChangeHero1:=0, NotChangeHero2:=0, NotChangeHero3:=0, NotChangeHero4:=0

iniRead, DelayClick, %A_WorkingDir%\Config.ini, Common, DelayClick
iniRead, StageLeader, %A_WorkingDir%\Config.ini, Stage, StageLeader
iniRead, FarmLeader, %A_WorkingDir%\Config.ini, Stage, FarmLeader
iniRead, DragonLeader, %A_WorkingDir%\Config.ini, Stage, DragonLeader
iniRead, ArenaLeader, %A_WorkingDir%\Config.ini, Stage, ArenaLeader

iniRead, StageMastery, %A_WorkingDir%\Config.ini, Stage, StageMastery
iniRead, FarmMastery, %A_WorkingDir%\Config.ini, Stage, FarmMastery
iniRead, DragonMastery, %A_WorkingDir%\Config.ini, Stage, DragonMastery
iniRead, ArenaMastery, %A_WorkingDir%\Config.ini, Stage, ArenaMastery
sleep 50
global LastLeader:=5
global NumCountFarm:=0
global NumCountStage:=0
global CountDragon:=0, CountHitDragon:=2, CountError:=0, ;MaxHitDragon:=2
global StartTimeR := A_TickCount, global StartTime:=0
global ErrorBackToHome:=0
global NumErrorFarm:=0
global ForceClickEnterDragon:=0
FormatTime, StartTime, , d MMM-HH:mm:ss
SetFormat, float, 0.2
global CheckLevelDragon:=0, MinuteSleepBeforeRepeatDragon:=5
iniRead, StartHitDragon, %A_WorkingDir%\Config.ini, Common, StartHitDragon
iniRead, CheckLevelDragon, %A_WorkingDir%\Config.ini, Common, CheckLevelDragon
iniRead, MinuteSleepBeforeRepeatDragon, %A_WorkingDir%\Config.ini, Common, MinuteSleepBeforeRepeatDragon
global DragonRepeatSleep:=(MinuteSleepBeforeRepeatDragon*60000)
if (StartHitDragon=1) {
 CountHitDragon:=0  
}

global NumRepeatStage:=1, NumRepeatStart:=1
global MapNotFound:=0
global mainSleep:=250
global MaxHitDragon:=2
global DebugScreen:=0
global StageMap="8-15"
global StageMap1="8-15-1"
global StageMap2="8-15-2"
global FarmMap="2-10"
global FarmMap1="2-10-1"
global FarmMap2="2-10-2"
global Hero1Lv30Flag:=0, Hero2Lv30Flag:=0, Hero3LV30Flag:=0, Hero4LV30Flag:=0
global isFarm:=0
iniRead, isFarm, %A_WorkingDir%\Config.ini, Stage, Farm
iniRead, mainSleep, %A_WorkingDir%\Config.ini, Common, MainSleep
iniRead, MaxHitDragon, %A_WorkingDir%\Config.ini, Common, MaxHitDragon
iniRead, DebugScreen, %A_WorkingDir%\Config.ini, Common, DebugScreen
iniRead, StageMap, %A_WorkingDir%\Config.ini, Stage, StageMap
iniRead, StageMapNext, %A_WorkingDir%\Config.ini, Stage, StageMap1
iniRead, FarmMap, %A_WorkingDir%\Config.ini, Stage, FarmMap
iniRead, NumRepeatStage, %A_WorkingDir%\Config.ini, Stage, NumRepeatStage
StageMapFirst2=Img\Map%StageMap%-2.png
StageMapFirst1=Img\Map%StageMap%-1.png
StageMapFirst=Img\Map%StageMap%.png
StageMapNext2=Img\Map%StageMapNext%-2.png
StageMapNext1=Img\Map%StageMapNext%-1.png
StageMapNext=Img\Map%StageMapNext%.png

StageMap2=%StageMapFirst2%
StageMap1=%StageMapFirst1%
StageMap=%StageMapFirst%

FarmMap2=Img\Map%FarmMap%-2.png
FarmMap1=Img\Map%FarmMap%-1.png
FarmMap=Img\Map%FarmMap%.png

PixelColor(pc_x, pc_y, pc_wID)
{	
  If pc_wID
  {
    pc_hDC := DllCall("GetDC", "UInt", pc_wID)
    WinGetPos, , , pc_w, pc_h, ahk_id %pc_wID%
    pc_hCDC := DllCall("CreateCompatibleDC", "UInt", pc_hDC)
    pc_hBmp := DllCall("CreateCompatibleBitmap", "UInt", pc_hDC, "Int", pc_w, "Int", pc_h)
    pc_hObj := DllCall("SelectObject", "UInt", pc_hCDC, "UInt", pc_hBmp)
    DllCall("PrintWindow", "UInt", pc_wID, "UInt", pc_hCDC, "UInt", 0)
    pc_fmtI := A_FormatInteger 
    SetFormat, IntegerFast, Hex
    pc_c := DllCall("GetPixel", "UInt", pc_hCDC, "Int", pc_x, "Int", pc_y, "UInt")
    pc_c := pc_c >> 16 & 0xff | pc_c & 0xff00 | (pc_c & 0xff) << 16
    pc_c .= ""
    SetFormat, IntegerFast, %pc_fmtI%
    DllCall("DeleteObject", "UInt", pc_hBmp)
    DllCall("DeleteDC", "UInt", pc_hCDC)
    DllCall("ReleaseDC", "UInt", pc_wID, "UInt", pc_hDC)
    Return pc_c
  }
}
SkillFarmRound1() {
IniRead, FarmSkillRound1, %A_WorkingDir%\Config.ini, Stage, FarmSkillRound1
  Loop, parse, FarmSkillRound1, `,
  {
    if (A_LoopField = 1) 
      Skill1() 
    if (A_LoopField = 2) 
      Skill2()
    if (A_LoopField = 3)
      Skill3()
    if (A_LoopField = 4)
      Skill4()
    if (A_LoopField = 5)
      Skill5() 
    if (A_LoopField = 6)
      Skill6()
    if (A_LoopField = 7)
      Skill7() 
    if (A_LoopField = 8)
      Skill8() 
    if (A_LoopField = 9)
      Skill9() 
    if (A_LoopField = 10)
      Skill10() 
  }
}
SkillFarmRound2() {
IniRead, FarmSkillRound2, %A_WorkingDir%\Config.ini, Stage, FarmSkillRound2
  Loop, parse, FarmSkillRound2, `,
  {
    if (A_LoopField = 1) 
      Skill1() 
    if (A_LoopField = 2) 
      Skill2()
    if (A_LoopField = 3)
      Skill3()
    if (A_LoopField = 4)
      Skill4()
    if (A_LoopField = 5)
      Skill5() 
    if (A_LoopField = 6)
      Skill6()
    if (A_LoopField = 7)
      Skill7() 
    if (A_LoopField = 8)
      Skill8() 
    if (A_LoopField = 9)
      Skill9() 
    if (A_LoopField = 10)
      Skill10() 
  }
}

SkillFarmRound3() {
IniRead, FarmSkillRound3, %A_WorkingDir%\Config.ini, Stage, FarmSkillRound3
  Loop, parse, FarmSkillRound3, `,
  {
    if (A_LoopField = 1) 
      Skill1() 
    if (A_LoopField = 2) 
      Skill2()
    if (A_LoopField = 3)
      Skill3()
    if (A_LoopField = 4)
      Skill4()
    if (A_LoopField = 5)
      Skill5() 
    if (A_LoopField = 6)
      Skill6()
    if (A_LoopField = 7)
      Skill7() 
    if (A_LoopField = 8)
      Skill8() 
    if (A_LoopField = 9)
      Skill9() 
    if (A_LoopField = 10)
      Skill10() 
  }
}

SkillStageRound1() {
IniRead, SkillComboRound1, %A_WorkingDir%\Config.ini, SkillStage, SkillComboRound1
  Loop, parse, SkillComboRound1, `,
  {
    if (A_LoopField = 1) 
      Skill1() 
    if (A_LoopField = 2) 
      Skill2()
    if (A_LoopField = 3)
      Skill3()
    if (A_LoopField = 4)
      Skill4()
    if (A_LoopField = 5)
      Skill5() 
    if (A_LoopField = 6)
      Skill6()
    if (A_LoopField = 7)
      Skill7() 
    if (A_LoopField = 8)
      Skill8() 
    if (A_LoopField = 9)
      Skill9() 
    if (A_LoopField = 10)
      Skill10() 
  }
}
SkillStageRound2() {
IniRead, SkillComboRound2, %A_WorkingDir%\Config.ini, SkillStage, SkillComboRound2
  Loop, parse, SkillComboRound2, `,
  {
    if (A_LoopField = 1) 
      Skill1() 
    if (A_LoopField = 2) 
      Skill2()
    if (A_LoopField = 3)
      Skill3()
    if (A_LoopField = 4)
      Skill4()
    if (A_LoopField = 5)
      Skill5() 
    if (A_LoopField = 6)
      Skill6()
    if (A_LoopField = 7)
      Skill7() 
    if (A_LoopField = 8)
      Skill8() 
    if (A_LoopField = 9)
      Skill9() 
    if (A_LoopField = 10)
      Skill10() 
  }
}
SkillTowerRound1() {
IniRead, TowerSkillRound1, %A_WorkingDir%\Config.ini, Stage, TowerSkillRound1
  Loop, parse, TowerSkillRound1, `,
  {
    if (A_LoopField = 1) 
      Skill1() 
    if (A_LoopField = 2) 
      Skill2()
    if (A_LoopField = 3)
      Skill3()
    if (A_LoopField = 4)
      Skill4()
    if (A_LoopField = 5)
      Skill5() 
    if (A_LoopField = 6)
      Skill6()
    if (A_LoopField = 7)
      Skill7() 
    if (A_LoopField = 8)
      Skill8() 
    if (A_LoopField = 9)
      Skill9() 
    if (A_LoopField = 10)
      Skill10() 
  }
}
SkillTowerRound2() {
IniRead, TowerSkillRound2, %A_WorkingDir%\Config.ini, Stage, TowerSkillRound2
  Loop, parse, TowerSkillRound2, `,
  {
    if (A_LoopField = 1) 
      Skill1() 
    if (A_LoopField = 2) 
      Skill2()
    if (A_LoopField = 3)
      Skill3()
    if (A_LoopField = 4)
      Skill4()
    if (A_LoopField = 5)
      Skill5() 
    if (A_LoopField = 6)
      Skill6()
    if (A_LoopField = 7)
      Skill7() 
    if (A_LoopField = 8)
      Skill8() 
    if (A_LoopField = 9)
      Skill9() 
    if (A_LoopField = 10)
      Skill10() 
  }
}

SkillHitDragonStart() {
IniRead, SkillBuffDragon, %A_WorkingDir%\Config.ini, SkillDragon, SkillBuffDragon
  Loop, parse, SkillBuffDragon, `,
  {
    if (A_LoopField = 1) 
      Skill1() 
    if (A_LoopField = 2) 
      Skill2()
    if (A_LoopField = 3)
      Skill3()
    if (A_LoopField = 4)
      Skill4()
    if (A_LoopField = 5)
      Skill5() 
    if (A_LoopField = 6)
      Skill6()
    if (A_LoopField = 7)
      Skill7() 
    if (A_LoopField = 8)
      Skill8() 
    if (A_LoopField = 9)
      Skill9() 
    if (A_LoopField = 10)
      Skill10() 
  }
}

SkillHitDragon() {
IniRead, SkillComboDragon, %A_WorkingDir%\Config.ini, SkillDragon, SkillComboDragon
  Loop, parse, SkillComboDragon, `,
  {
    if (A_LoopField = 1) {
      IniRead, DragonSkill1CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill1CD
      SetTimer,Skill1,%DragonSkill1CD%
    }
    if (A_LoopField = 2) {
      IniRead, DragonSkill2CD,  %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill2CD
      SetTimer,Skill2,%DragonSkill2CD%
    }
    if (A_LoopField = 3) {
      IniRead, DragonSkill3CD,  %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill3CD
      SetTimer,Skill3,%DragonSkill3CD%
    }
    if (A_LoopField = 4) {
      IniRead, DragonSkill4CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill4CD
      SetTimer,Skill5,%DragonSkill4CD%
    }
    if (A_LoopField = 5) {
      IniRead, DragonSkill5CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill5CD
      SetTimer,Skill5,%DragonSkill5CD%
    }
    if (A_LoopField = 6) {
      IniRead, DragonSkill6CD,  %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill6CD
      SetTimer,Skill6,%DragonSkill6CD%
    }
    if (A_LoopField = 7) {
      IniRead, DragonSkill7CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill7CD
      SetTimer,Skill7,%DragonSkill7CD%
    }
    if (A_LoopField = 8) {
      IniRead, DragonSkill8CD,  %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill8CD
      SetTimer,Skill8,%DragonSkill8CD%
    }
    if (A_LoopField = 9) {
      IniRead, DragonSkill9CD,  %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill9CD
      SetTimer,Skill9,%DragonSkill9CD%
    }
    if (A_LoopField = 10) {
      IniRead, DragonSkill10CD,  %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill10CD
      SetTimer,Skill10,%DragonSkill10CD%
    }
  }
}


SkillHitDragonEnd() {
IniRead, SkillComboDragon, %A_WorkingDir%\Config.ini, SkillDragon, SkillComboDragon
  Loop, parse, SkillComboDragon, `,
  {
    if (A_LoopField = 1) 
      IniRead, DragonSkill1CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill1CD
      SetTimer,Skill1,off
    if (A_LoopField = 2) 
      IniRead, DragonSkill2CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill2CD
      SetTimer,Skill2,off
    if (A_LoopField = 3)
      IniRead, DragonSkill3CD,  %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill3CD
      SetTimer,Skill3,off
    if (A_LoopField = 4)
      IniRead, DragonSkill4CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill4CD
      SetTimer,Skill5,off
    if (A_LoopField = 5)
      IniRead, DragonSkill5CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill5CD
      SetTimer,Skill5,off
    if (A_LoopField = 6)
      IniRead, DragonSkill6CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill6CD
      SetTimer,Skill6,off
    if (A_LoopField = 7)
      IniRead, DragonSkill7CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill7CD
      SetTimer,Skill7,off
    if (A_LoopField = 8)
      IniRead, DragonSkill8CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill8CD
      SetTimer,Skill8,off
    if (A_LoopField = 9)
      IniRead, DragonSkill9CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill9CD
      SetTimer,Skill9,off
    if (A_LoopField = 10)
      IniRead, DragonSkill10CD, %A_WorkingDir%\Config.ini, SkillDragonCooldown, DragonSkill10CD
      SetTimer,Skill10,off
  }
}

Skill1() {
ControlClick,x456 y500, ahk_id %hwnd%
PrintLog("USE SKILL1 ",0)
sleep 250
return
}

Skill2() {
ControlClick,x456 y570, ahk_id %hwnd% 
PrintLog("USE SKILL2 ",0)
sleep 250
return
}

Skill3() {
ControlClick,x540 y500, ahk_id %hwnd%
PrintLog("USE SKILL3 ",0)
sleep 250
return
}

Skill4() {
ControlClick,x540 y570, ahk_id %hwnd%
PrintLog("USE SKILL4 ",0)
sleep 250
return
}

Skill5() {
ControlClick,x612 y500, ahk_id %hwnd%
PrintLog("USE SKILL5 ",0)
sleep 250
return
}

Skill6() {
ControlClick,x612 y570, ahk_id %hwnd%
PrintLog("USE SKILL6 ",0)
sleep 250
return
}

Skill7() {
ControlClick,x690 y500, ahk_id %hwnd%
PrintLog("USE SKILL7 ",0)
sleep 250
return
}

Skill8() {
ControlClick,x690 y570, ahk_id %hwnd%
PrintLog("USE SKILL8 ",0)
sleep 250
return
}

Skill9() {
ControlClick,x764 y500, ahk_id %hwnd%
PrintLog("USE SKILL9 ",0)
sleep 250
return
}

Skill10() {
ControlClick,x764 y570, ahk_id %hwnd% 
PrintLog("USE SKILL10 ",0)
sleep 250
return
}

SetTimer,Close7KError,60000
Close7KError() {
 if (SearchScreen("Img\7KError.png",1,1,"ERROR 7K Error (Popup)","")) {
    SearchScreen("Img\7KErrorOK.png",1,1,"ERROR-CLICK OK CLOSE ANDRIOD","ERROR-CLICK OK BUTTON INCOMPLETE")
    sleep 5000
    Run taskkill /f /im nox*
    sleep 1000
    OpenNox()
    sleep 30000
    Initialized()
    OpenGame() ; OpenGame After Error Found
 }
}
SetTimer,CloseTeamViewerPopUP,30000
CloseTeamViewerPopUP() { ; Close TeamViewer Pop up
 IfWinExist, Sponsored
  {
   WinActivate
   SendInput {enter}
  }
  Return
}

SetTimer,CloseDragonPopUP,30000
CloseDragonPopUP() {
 ImageSearch, imageX1, imageY1, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%,  *55 *TransBlack DragonPopUp.png
 if (!ErrorLevel) {
  MouseClick, left, %imageX1%, %imageY1%
  PrintLog("WARNING-FOUND DRAGON POP UP ... EXISTING <<< USING ImageSearch",1)
  return 1
 }
 ImageSearch, imageX1, imageY1, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%,  *55 *TransBlack DragonPopUp1.png
  if (!ErrorLevel) {
  MouseClick, left, %imageX1%, %imageY1%
  PrintLog("WARNING-FOUND DRAGON POP UP ... EXISTING <<< USING ImageSearch",1)
  return 1
  }
 if (SearchScreen("Img\DragonPopUp.png",1,0,"INFO-FOUND DRAGON ... EXITING","")) {
  ClickBackToHome()
  DragonFight()
  return 1
 }
 if (SearchScreen("Img\DragonPopUp1.png",1,0,"INFO-FOUND DRAGON ... EXITING","")) {
  ClickBackToHome()
  DragonFight()
  return 1
 }
 SearchScreen("Img\QuestComplete.png",1,0,"INFO-CLICK QUEST COMPLETE","") 
return 0
}

SetTimer,CloseArenaHonorFull,30000
CloseArenaHonorFull() {
  if (SearchScreen("Img\ExceedHonor.png",0,2,"INFO-ARENA> EXCEED HONOR ","")) {
    SearchScreen("Img\ExceedHonorYes.png",1,2,"INFO-ARENA> CONFIRM YES","")
  ClickBackToHome()
  }
}

SetTimer,GamePopUp,30000
GamePopUp() {
  SearchScreen("Img\ServerDisconnected.png",1,1,"INFO-SERVER DISCONNECTED ... RECONNECTING","")
  SearchScreen("Img\GameUpdate.png",1,1,"INFO-SERVER DISCONNECTED ... RECONNECTING","")
  SearchScreen("Img\RaidAlreadyEnd.png",1,1,"INFO-SERVER DISCONNECTED ... RECONNECTING","")
  SearchScreen("Img\ReConnected.png",1,1,"INFO-CLICK RECONNECTED","") 
}

;SetTimer,GameHangToLobby,60000
GameHangToLobby(){
  SearchScreen("Img\ArenaMoveRank.png",1,1,"INFO-ARENA> MOVE RANK","")
  SearchScreen("Img\ReConnected.png",1,1,"INFO-TIMER>CLICK RECONNECTED","") 
  if (SearchScreen("Img\StageLobby.png",0,1,"INFO-TIMER> FOUND LOBBY","")) {
    sleep 55000
    SearchScreen("Img\StageLobby.png",1,1,"INFO-TIMER> CLICK LOBBY","")
  }
  if (SearchScreen("Img\StageLobby1.png",0,1,"INFO-TIMER> FOUND LOBBY","")) {
    sleep 55000
    SearchScreen("Img\StageLobby1.png",1,1,"INFO-TIMER> CLICK LOBBY","")
  }
  if (SearchScreen("Img\RaidLobby.png",0,1,"INFO-TIMER> FOUND LOBBY","")) {
    sleep 55000
    SearchScreen("Img\RaidLobby.png",1,1,"INFO-TIMER> CLICK LOBBY","")
  }
  if (SearchScreen("Img\RaidLobby1.png",0,1,"INFO-TIMER> FOUND LOBBY","")) {
    sleep 55000
    SearchScreen("Img\RaidLobby1.png",1,1,"INFO-TIMER> CLICK LOBBY","") 
  }
  if (SearchScreen("Img\ArenaLobby.png",0,1,"INFO-ARENA> CLICK LOBBY","")) {
    sleep 55000
    SearchScreen("Img\ArenaLobby.png",1,1,"INFO-ARENA> CLICK LOBBY","")
  }
  if (SearchScreen("Img\ArenaLobbyLost.png",0,1,"INFO-ARENA> CLICK LOBBY","")) {
    sleep 55000
    SearchScreen("Img\ArenaLobbyLost.png",1,1,"INFO-ARENA> CLICK LOBBY","")
  }
}

ClickBackToHome(Timeout="25") {
 SkillHitDragonEnd()
 end := A_TickCount + Timeout*1000
 loop {
  if (SearchScreen("Img\Back.png",1,1,"INFO-CLICK BACK","")) {
    SearchScreen("Img\Back.png",1,1,"INFO-CLICK BACK","")
    SearchScreen("Img\Back.png",1,1,"INFO-CLICK BACK","")
    SearchScreen("Img\Back.png",1,1,"INFO-CLICK BACK","")
  }
    SearchScreen("Img\QuestComplete.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
    SearchScreen("Img\QuestHero30.png",1,1,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
    SearchScreen("Img\QuestComplete.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
  if (A_TickCount >= end) {
    ErrorBackToHome++
    PrintLog("TIMEOUT TO HOME SCREEN CLICK ESC",1)
    ESCNO()
    ;ControlClick,x500 y,500 ahk_id %hwnd%
    if (ErrorBackToHome >= 3) {
      CloseDragonPopUP()
      OpenGame()
      ;MouseClick, left, 300, 300
      ;ErrorBackToHome=0
    }
    if (ErrorBackToHome >= 30) {
      Run taskkill /f /im Nox*      
      OpenNox()
      ErrorBackToHome=0
    }
    return 0
  }
  if (SearchScreen("Img\Home-Adventure.png",0,0,"INFO-FOUND ADVENTURE","INFO-BACKING TO HOME")) {
    break
  }
  if (SearchScreen("Img\Home-Adventure1.png",0,0,"INFO-FOUND ADVENTURE1","INFO-BACKING TO HOME1")) {
    break
  }
    if (SearchScreen("Img\Home-Adventure2.png",0,0,"INFO-FOUND ADVENTURE2","INFO-BACKING TO HOME")) {
    break
  }
    if (SearchScreen("Img\Home-Battle.png",0,0,"INFO-FOUND BATTLE","INFO-BACKING TO HOME")) {
    break
  }
      if (SearchScreen("Img\Home-Adventure3.png",0,0,"INFO-FOUND ADVENTURE3","INFO-BACKING TO HOME")) {
    break
  }
 }
 CloseDragonPopUP()
 PrintLog("INFO-HOME SCREEN NOW",1)
}

FormatSeconds(NumberOfSeconds)  ; Convert the specified number of seconds to hh:mm:ss format.
{
    time = 19990101  ; *Midnight* of an arbitrary date.
    time += %NumberOfSeconds%,seconds
    FormatTime,mmss,%time%,mm:ss
    SetFormat,float,2.0
    return NumberOfSeconds//3600 ":" mmss  ; This method is used to support more than 24 hours worth of sections.
}

PrintLog(Text,ShowTime=1) { ; Print Log file to 7kLog.txt file PrintLog(Text Message, Show Time Stamp Flag)
FormatTime, TimeString, , d MMM-HH:mm:ss
  if (ShowTime=1 and Text !="") {
    FileAppend, `n%TimeString% %Text% , %A_WorkingDir%\7kLog.txt
  } else {
    if (Text != "") {
      FileAppend, %Text% , %A_WorkingDir%\7kLog.txt
    }
  }
} 

GetHwnd() {
 iniRead, NoxTitleName, %A_WorkingDir%\Config.ini, Common, NoxTitleName
 PrintLog("DEBUG-HWND> NoxTitleName="NoxTitleName)
 IfWinExist, %NoxTitleName%
 {
   WinActivate
   hwnd := WinExist("A")
   PrintLog("DEBUG-HWND> HWND FROM TITLE NAME MATCH = "hwnd,1)
   return 1
 }
 IfWinExist, Nox App Player
 {
   WinActivate
   hwnd := WinExist("ahk_class Qt5QWindowIcon")
   PrintLog("DEBUG-HWND> HWND FROM CLASS = "hwnd,1)
   return 1
 }
 
   hwnd := WinExist("ahk_class Qt5QWindowIcon")
   PrintLog("DEBUG-HWND> HWND FROM Exception case = "hwnd,1)
return 1
}

SearchScreen(ImgName,ClickButton="1",Timeout="5",Text="",TextError="",X1="0",Y1="0",W="0",H="0",PlusX="0",Deviation="20",PlusY="0",DelayClick="0"){
 ;sleep 100
 end := A_TickCount + Timeout*1000
 imgfile=%A_WorkingDir%\%ImgName%
 pToken := Gdip_Startup()
 ;pBitmapScreen := Gdip_BitmapFromHWND(hwnd)
 pBitmapSearch := Gdip_CreateBitmapFromFile(imgFile)
 ;Gdip_SaveBitmapToFile(pBitmapScreen,"image1.png") ; Use for debug
 if (DebugScreen) {
  Gdip_SaveBitmapToFile(pBitmapSearch,"SearchImage.png") ; Use for debug
 }
 loop {
   sleep mainSleep
   Gdip_DisposeImage(pBitmapScreen) ; To Prevent Memory Leak
   pBitmapScreen := Gdip_BitmapFromHWND(hwnd)
   if (DebugScreen) {
     Gdip_SaveBitmapToFile(pBitmapScreen,"ScreenImage.png") ; Use for debug
   }
   if (Gdip_ImageSearch(pBitmapScreen, pBitmapSearch, LIST,X1,Y1,W,H,Deviation,0x000000,1,0)>0) {
     StringSplit,PositionList,LIST,`n 
     StringSplit,Position,PositionList1,`, 
     x:=Position1 + PlusX
     y:=Position2
     if (ClickButton = 1) {
	   sleep DelayClick
       ControlClick,x%x% y%y%, ahk_id %hwnd%
     }
    PrintLog(Text,1)
    Gdip_DisposeImage(pBitmapScreen)
    Gdip_DisposeImage(pBitmapSearch)
    Gdip_Shutdown(pToken)
    sleep 500
    return 1
   } 
  if (A_TickCount >= end) {
    PrintLog(TextError,1)
    Gdip_DisposeImage(pBitmapScreen)
    Gdip_DisposeImage(pBitmapSearch)
    Gdip_Shutdown(pToken)
    return 0
  }
 }
 PrintLog(TextError,1)
 Gdip_DisposeImage(pBitmapScreen)
 Gdip_DisposeImage(pBitmapSearch)
 Gdip_Shutdown(pToken)
 return 0
}

OpenNox() {
 iniRead, NoxLocation, %A_WorkingDir%\Config.ini, Common, NoxLocation
 sleep 5000
 ;Run %userprofile%\AppData\Roaming\Nox\bin\nox.exe
 Run %NoxLocation%
 PrintLog("INFO-OPENNING NOX",1)
 sleep 10000
 OpenGame()
 GetHwnd()
return 1
}
ESCNO() { ; Control send Key "ESC" and if Pop up to Close Game Click "No"
 ControlSend,, {ESC}, ahk_id %hwnd%
; if (SearchScreen("Img\PopUpCloseGame.png",0,0,"INFO-POP UP CLOSE GAME","")) {
 SearchScreen("Img\PopUpCloseGameNo.png",1,0,"INFO-CLOSE POP-UP","")
 SearchScreen("Img\PopUpPauseGame.png",1,0,"INFO-CLOSE POP-UP PAUSE GAME","")
 SearchScreen("Img\CloseAd.png",1,1,"INFO-Click CLOSE AD","")
 SearchScreen("Img\CloseAdPopUp.png",1,1,"INFO-Click CLOSE AD PopUp","")
; }
return 1
}

ClickHomeAdventure(){
 ;if(SearchScreen("Img\Home-Adventure.png",1,0.1,"INFO-CLICK HOME ADVENTURE","") or SearchScreen("Img\Home-Adventure1.png",1,0.1,"INFO-CLICK HOME ADVENTURE1","") or SearchScreen("Img\Home-Adventure2.png",1,0.1,"INFO-CLICK HOME ADVENTURE2","") or SearchScreen("Img\Home-Adventure3.png",1,0.1,"INFO-CLICK HOME ADVENTURE3","") or SearchScreen("Img\Home-Adventure4.png",1,1,"INFO-CLICK HOME ADVENTURE4","") or SearchScreen("Img\Home-Adventure4.png",1,0.1,"INFO-CLICK HOME ADVENTURE4","") or SearchScreen("Img\Home-Adventure5.png",1,0.1,"INFO-CLICK HOME ADVENTURE5","")) {
 if(SearchScreen("Img\Home-Adventure.png",1,1,"INFO-CLICK HOME ADVENTURE","") or SearchScreen("Img\Home-Adventure1.png",1,1,"INFO-CLICK HOME ADVENTURE1","") or SearchScreen("Img\Home-Adventure2.png",1,1,"INFO-CLICK HOME ADVENTURE2","") or SearchScreen("Img\Home-Adventure3.png",1,1,"INFO-CLICK HOME ADVENTURE3","") or ForceClickHomeAdvanture() ) { 
   return 1
 }
return 0
}

ClickHomeBattle(){
 if(SearchScreen("Img\Home-Battle.png",1,2,"INFO-CLICK HOME BATTLE","") ) {
   return 1
 }
return 0
}

OpenGame(Timeout="180") {
 CountTabNotFound=0
 if (SearchScreen("Img\Game.png",1,5,"INFO-OPENING GAME","INFO-GAME IS OPENNING ... OK")) {
  CountError++
  end := A_TickCount + Timeout*1000
  While !(SearchScreen("Img\Home-Adventure1.png",0,1,"INFO-HOME SCREEN NOW","INFO-NOT HOME SCREEN")) { 
    if (SearchScreen("Img\TabToPlay.png",1,1,"INFO-Click Tab To Play","")) {
      sleep 5000
    } else {
      CountTabNotFound++
    }
    if (CountTabNotFound>=5) {
     ControlClick,x200 y220, ahk_id %hwnd%
    }
    ESCNO()  
    sleep 3000
    if (A_TickCount >= end) {
      return 0
    }
  }
  PrintLog("INFO-GAME OPENED",1)
 }
}



Initialized() {
  SetTitleMatchMode 2
  SetControlDelay -1 
  Run baretail %A_WorkingDir%\7kLog.txt
  PrintLog("`n############ 7K BOT by HerQliZ ############# ",0)
  PrintLog("`n#### INFO> PRESS F2 To START BOT ",0)
  PrintLog("`n#### INFO> PRESS F1 To Pause BOT ",0)
  PrintLog("`n#### INFO> PRESS F3 To Resume BOT ",0)
  PrintLog("`n#### INFO> PRESS F9 To HIDDEN BOT SCREEN ",0)
  PrintLog("`n#### INFO> PRESS F10 To UNHIDDEN BOT SCREEN",0)
  PrintLog("`n#### INFO> PRESS F12 To EXIT BOT ",0)
  iniRead, FarmMapTemp, %A_WorkingDir%\Config.ini, Stage, FarmMap
  iniRead, StageMapTemp, %A_WorkingDir%\Config.ini, Stage, StageMap
  PrintLog("`n#### INFO> 1. HIT MAP ",0)
  if (isFarm=1) {
    ;NotChangeHero1=0
    PrintLog(FarmMapTemp " (" MaxNumFarm " TIMES) + LEADER No. " FarmLeader " + Mastery No." FarmMastery,0)
  } else {
    ;NotChangeHero1=1
    PrintLog(StageMapTemp "(1 TIME) + LEADER No. " StageLeader " + Mastery No. " StageMastery,0)
  }
  PrintLog("`n#### INFO> 2. Gold Chamber (1 TIME)",0)
  PrintLog("`n#### INFO> 3. ARENA (1 TIME) + LEADER No."ArenaLeader " + Mastery No." ArenaMastery,0)
  PrintLog("`n#### INFO> 4. Dragon (" MaxHitDragon " TIMES) + LEADER No. " DragonLeader " + Mastery No. " DragonMastery ,0)
  PrintLog("`n#### INFO> REPEAT STEP 1-4`n",0)
  sleep 2000
  GetHwnd()
  global NotChangeHeroList
  iniRead, NotChangeHeroList, %A_WorkingDir%\Config.ini, Stage, NotChangeHeroList
  
  if (isFarm=1){
   NotChangeHero1=0
   NotChangeHero2=0
   NotChangeHero3=0
   NotChangeHero4=0
  
  } else {
   ifInString, NotChangeHeroList, 1 
     NotChangeHero1=1
   
   ifInString, NotChangeHeroList, 2 
     NotChangeHero2=1
     
   ifInString, NotChangeHeroList, 3 
     NotChangeHero3=1
   
   ifInString, NotChangeHeroList, 4 
     NotChangeHero4=1
   
  }
}

Summary() {
  if (NumCountFarm=0) {
    NumCountFarm1:=MaxNumFarm
  } else {
    NumCountFarm1:=NumCountFarm
  }
  PrintLog("`n################ SUMMARY ###############",0)
  PrintLog("`n>>>>> START TIME      :  "  StartTime,0)
  PrintLog("`n>>>>> RUN TIME        : " FormatSeconds((A_TickCount-StartTimeR)/1000),0)
  PrintLog("`n>>>>> RUN TIME        : " FormatSeconds((A_TickCount-StartTimeR)/1000),0)
  if (isFarm=1){
  PrintLog("`n>>>>> CURRENT FARM    : " NumCountFarm1 " OF " MaxNumFarm,0)
  }
  if (NumCountFarm1 < MaxNumFarm) {
    PrintLog(" <---- FARM In Progress",0)
  }
  PrintLog("`n>>>>> CURRENT DRAGON  : " CountHitDragon " OF " MaxHitDragon,0)
  if (CountHitDragon < MaxHitDragon) {
    PrintLog(" <---- Dragon In Progress",0)
  }
  PrintLog("`n>>>>> TOTAL BATTLE    :  "  CountBattle,0)
  PrintLog("`n>>>>> TOTAL TOWER     :  "  CountTower,0)
  PrintLog("`n>>>>> TOTAL ARENA     :  "  CountArena,0)
  PrintLog("`n>>>>> TOTAL DRAGON    :  "  CountDragon,0)
  PrintLog("`n>>>>> TOTAL MY DRAGON :  "  CountMyDragon,0)
  PrintLog("`n>>>>> TOTAL ERROR     :  "  CountError,0)
  PrintLog("`n>>>>> GOLD GAIN(~)    :  "  CountBattle*3000+CountTower*5600,0)
  PrintLog("`n############ END SUMMARY ###############`n",0)
  sleep 4000
}

StageFight() {
  NumErrorFarm=0
  ClickBackToHome()
  ;ChangeMastery(StageMastery)
  if ((StageLeader != ArenaLeader) or LeaderFirstTime=1) {
    if (LastLeader!=1) {
      PrintLog("INFO-STAGE> CHANGE LEADER TO HERO No. " StageLeader,1)
      ChangeLeader(StageLeader)
      LeaderFirstTime=0
      LastLeader=1
    } else {
      PrintLog("INFO-STAGE> LEADER NOT CHANGE",1)
    }
  } else {
      PrintLog("INFO-STAGE> LEADER NOT CHANGE",1)
  }
  if ClickHomeAdventure() {
   if (SearchScreen("Img\Adventure1.png",1,5,"INFO-STAGE> CLICK ADVENTURE","WARNING-STAGE> NO ADVENTURE BUTTON-Adventure.png") or SearchScreen("Img\Adventure.png",1,5,"INFO-STAGE> CLICK ADVENTURE","WARNING-STAGE> NO ADVENTURE BUTTON-Adventure.png") or SearchScreen("Img\AdventureHotTime.png",1,5,"INFO-STAGE> CLICK ADVENTURE","WARNING-STAGE> NO ADVENTURE BUTTON-AdventureHotTime.png") or SearchScreen("Img\AdventureHotTime1.png",1,5,"INFO-STAGE> CLICK ADVENTURE","WARNING-STAGE> NO ADVENTURE BUTTON-AdventureHotTime.png")) {
     end := A_TickCount + 300000 ; timeout is 90 second to find map
     ;While !(SearchScreen("Img\Map815.png",1,5,"INFO-STAGE> CLICK MAP","INFO-STAGE> FINDING MAP")) {
     ChangeEasyMap:=0
     While !(SearchScreen(StageMap,1,5,"INFO-STAGE> CLICK MAP","INFO-STAGE> FINDING MAP",0,0,0,0,0,50,0) or SearchScreen(StageMap1,1,5,"INFO-STAGE> CLICK MAP","INFO-STAGE> FINDING MAP",0,0,0,0,0,50,0) or SearchScreen(StageMap2,1,5,"INFO-STAGE> CLICK MAP","INFO-STAGE> FINDING MAP",0,0,0,0,0,50,0)) {
       SearchScreen("Img\Moon.png",1,3,"INFO-STAGE> CLICK MOONLITISLE","")  ; Click MoonLITISLE <<< 
       if (ChangeEasyMap=0){
         if (SearchScreen("Img\MapAsGarNormal.png",1,3,"INFO-STAGE> CLICK ASGAR NORMAL","") or SearchScreen("Img\MapAsGarNormal1.png",1,3,"INFO-STAGE> CLICK ASGAR NORMAL","") or SearchScreen("Img\MapAsGarNormal2.png",1,3,"INFO-STAGE> CLICK ASGAR NORMAL","")) {
           if (SearchScreen("Img\MapAsGarNormalEasy.png",1,3,"INFO-STAGE> CLICK EASY","") or SearchScreen("Img\MapAsGarNormalEasy1.png",1,3,"INFO-STAGE> CLICK EASY","")) {
             ChangeEasyMap=1
           } else {
             ControlClick,x81 y544, ahk_id %hwnd% 
             ChangeEasyMap=1
           }
         }
       }
       SearchScreen("Img\NextMap.png",1,1,"INFO-STAGE> CLICK Next Map","")
      
       if (A_TickCount >= end) {
         PrintLog("INFO-STAGE> TIMEOUT FINDING MAP",1)
         ClickBackToHome()
         return 0
       }
     } ; End Search Map
     if (SearchScreen("Img\StageReady.png",1,5,"INFO-STAGE> CLICK READY","WARNING-STAGE> NOT FOUND READY BUTTON-StageReady.png") or SearchScreen("Img\StageReady1.png",1,5,"INFO-STAGE> CLICK READY","WARNING-STAGE> NOT FOUND READY BUTTON-StageReady.png")) {
       ; Select Team C if other team are selected
	   
	   loop {
	      SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","")
          SearchScreen("Img\QuestHero30.png",1,2,"INFO-AWAKE> Hero Quest Lv.30 ... Click OK","")
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
	   iniRead, TeamtoFight, %A_WorkingDir%\Config.ini, Stage, TeamtoFight
	   if (TeamtoFight="A") {
		   if !(SearchScreen("Img\TeamASelected.png",1,3,"INFO-STAGE> CLICK TEAM A","WARNING-STAGE>NOT FOUND TEAM A-TeamCSelected.png ... TRY PIRCURE2") or SearchScreen("Img\ClickTeamA.png",1,3,"INFO-STAGE> CLICK TEAM A","WARNING-STAGE>NOT FOUND TEAM C-ClickTeamC.png ... TRY PIRCURE2") or SearchScreen("Img\TowerTeamA.png",1,3,"INFO-STAGE> CLICK TEAM C","WARNING-STAGE>NOT FOUND TEAM C-TowerTeamC.png ... FORCE CLICK POSITION")) {
			 ControlClick,x125 y144, ahk_id %hwnd%
		   }
	   } else {   
		   if !(SearchScreen("Img\TeamCSelected.png",1,3,"INFO-STAGE> CLICK TEAM C","WARNING-STAGE>NOT FOUND TEAM C-TeamCSelected.png ... TRY PIRCURE2") or SearchScreen("Img\ClickTeamC.png",1,3,"INFO-STAGE> CLICK TEAM C","WARNING-STAGE>NOT FOUND TEAM C-ClickTeamC.png ... TRY PIRCURE2") or SearchScreen("Img\TowerTeamC.png",1,3,"INFO-STAGE> CLICK TEAM C","WARNING-STAGE>NOT FOUND TEAM C-TowerTeamC.png ... FORCE CLICK POSITION")) {
			 ControlClick,x298 y144, ahk_id %hwnd%
		   }
	   }
       if !(AISwitchHero()) {
        NumErrorFarm++ 
        if (NumErrorFarm>=1) {
          PrintLog("INFO-AWAKE> COUNT ERROR = "NumErrorFarm,1)
        }
       }       
       SearchScreen("Img\AutoRepeatOff.png",1,2,"INFO-STAGE> CLICK AUTO REPEAT OFF","")
       SearchScreen("Img\RemoveFriend.png",1,2,"INFO-STAGE> CLICK REMOVE FRIEND","")
       if (SearchScreen("Img\StageStart.png",1,5,"INFO-STAGE> CLICK START","WARNING-STAGE> NOT FOUND START BUTTON-StaeStart.png") or SearchScreen("Img\StageStart1.png",1,5,"INFO-STAGE> CLICK START1","WARNING-STAGE> NOT FOUND START1 BUTTON-StageStart1.png")) {
         endFight := A_TickCount + 300000
         if (SearchScreen("Img\HeroFull.png",1,0,"ERROR-FARM> HERO OR ITEM ARE FULL ... CLICK PROCEED","") or SearchScreen("Img\ItemFull.png",1,0,"ERROR-FARM> HERO OR ITEM ARE FULL ... CLICK PROCEED","")) {
           loop, 1{
             soundbeep, 750, 500
             soundbeep, 1100, 500
           }
         }
         SearchScreen("Img\HeroFull.png",1,0,"ERROR-STAGE> HERO FULL CLICK PROCEED","")
		 SearchScreen("Img\ItemFull.png",1,0,"ERROR-STAGE> Item FULL CLICK PROCEED","")
         SkillUsed1 := 0
         SkillUsed2 := 0
         ; Turn on Auto Skill if off
         ;SearchScreen("Img\AutoSkillOn.png",1,5,"INFO-STAGE> CLICK AUTO SKILL ON ","")
         ;SearchScreen("Img\AutoSkillOff.png",1,1,"INFO-STAGE> CLICK AUTO SKILL OFF ","")
         start := A_TickCount
         PrintLog("INFO-STATE> FIGHTING ",1)
         AutoSkillFlag:=0
         loop {       
           ;if (AutoSkillFlag=0) {
           ;  SearchScreen("Img\AutoSkillOff.png",1,0,"INFO-STAGE> CLICK AUTO SKILL OFF ","")
           ;  AutoSkillFlag=1 
           ;}
           ;PrintLog(".",0)
           if (SkillUsed1 = 0) {
             if (SearchScreen("Img\StageRound1.png",0,3,"INFO-STAGE> ROUND1!!!","") or SearchScreen("Img\AutoSkillOn.png",0,2,"INFO-STAGE> ROUND1!!!","") or SearchScreen("Img\AutoSkillOff.png",0,2,"INFO-STAGE> ROUND1!!!","")) {
               SkillStageRound1()
                if (AutoSkillFlag=0) { ; Turn off Auto Skill after Use Skill 1 List
                  SearchScreen("Img\AutoSkillOff.png",1,3,"INFO-STAGE> CLICK AUTO SKILL OFF ","")
                  AutoSkillFlag=1 
                }
               SkillUsed1=1
             }
           }
           PrintLog(".",0)
           if (SearchScreen("Img\StageNoKey.png",1,1,"INFO-STAGE> NO ENOUGH KEY BACK TO LOBBY","")) {
             ClickBackToHome()
             return 0
           }
           if (SkillUsed2 = 0) {
             if (SearchScreen("Img\StageRound2.png",0,3,"INFO-STAGE> ROUND2!!!","") ) {
               SkillStageRound2()
               SkillUsed2=1
               SearchScreen("Img\AutoSkillOn.png",1,3,"INFO-STAGE> CLICK AUTO SKILL ON ","")
             }
           }
           ;if (AutoSkillFlag=0) {
           ;  SearchScreen("Img\AutoSkillOff.png",1,0,"INFO-STAGE> CLICK AUTO SKILL OFF ","")
           ;  AutoSkillFlag=1 
           ;}
           if (A_TickCount >= endFight) { 
             ClickBackToHome()
             return 0 
           }
           if (SearchScreen("Img\StageLobby.png",0,0,"INFO-STAGE> CLICK LOBBY","")) {
		     NumCountStage++
           }
		   if (SearchScreen("Img\FarmRepeat.png",1,0,"INFO-STAGE> CLICK REPEAT","")) {
             break
           }
         }  
         PrintLog("INFO-STAGE> TOTAL FIGHT TIME= " (A_TickCount-start)/1000 " SECONDS",1)
		 PrintLog("INFO-STAGE> CURRENT HIT ROUND= "NumCountStage "/" MaxNumFarm,1)
         CountBattle++
         ;return 0
		 if (NumCountStage>=MaxNumFarm){
		   if (CloseDragonPopUP()) {
             ClickBackToHome()
             DragonFight()
             CountBattle++
           } ; 
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","")
          SearchScreen("Img\QuestHero30.png",1,2,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\StageLobby.png",1,0,"INFO-AWAKE> CLICK LOBBY","")
          ClickBackToHome()
          return 1
		 }
       }
	      if (NumErrorFarm >= 3) {
           NumErrorFarm=0
           ClickBackToHome()
           return 0
         }
	  }
     } ; End of Ready Loop
   }
  }
 ClickBackToHome()
 return 0
}

DragonEnterClick(ImgName){
  if(SearchScreen("Img\"%ImgName%,0,1,"INFO-DRAGON> SLOT1?... YES","INFO-DRAGON> SLOT1?... NO",10,175,790,236)) {
     SearchScreen("Img\RaidEnter.png",1,5,"INFO-DRAGON> CLICK ENTER RAID","WARNING-DRAGON> NOT FOUND RAID ENTER BUTTON-RaidEnter.png",10,175,790,236)
     return 1
  } 
;  if(SearchScreen("Img\DragonLevel9x.png",0,1,"INFO-DRAGON> Slot1-DRAGON LEVEL 90+","INFO-DRAGON>-DRAGON 9X",16,224,790,308)) {
;     SearchScreen("Img\RaidEnter.png",1,5,"INFO-DRAGON> CLICK ENTER RAID","WARNING-DRAGON> NOT FOUND RAID ENTER BUTTON-RaidEnter.png",16,224,790,308)
;     return 1
;  }
}

AIRaidEnterMyDragon() {
 MyDragon=0
 DragonSearchDeviation:=60
 DragonLevel=0
 loop,2 {
   if (SearchScreen("Img\MyDragon.png",1,5,"INFO-DRAGON> FOUND-MY DRAGON --> MyDragon.png at top folder","INFO-DRAGON>-NOT FOUND MY DRAGON --> MyDragon.png at top folder",0,0,0,0,540,DragonSearchDeviation,30) or SearchScreen("Img\MyDragon1.png",1,5,"INFO-DRAGON> FOUND-MY DRAGON --> MyDragon.png at top folder","INFO-DRAGON>-NOT FOUND MY DRAGON --> MyDragon.png at top folder",0,0,0,0,540,DragonSearchDeviation,30) ) {
      MyDragon=1
	  DragonLevel=90
      CountMyDragon++
      return 1
   }
   ScrollDragon()
 }
return 0
}

CheckLevelDragonFlag(){

 if (CheckLevelDragon=1) {
  return 1
 }
 
 return 0
}

AIRaidEnterNew() {
 DragonSearchDeviation:=70
 if (CheckLevelDragon=0) {
  return 0
 }
 DragonLevel=0
 loop,3 {
   if (SearchScreen("Img\DragonLevel9x.png",1,0,"INFO-DRAGON> FOUND-DRAGON LV.90+","INFO-DRAGON>-NOT FOUND DRAGON LV.90+",0,0,0,0,600,DragonSearchDeviation) or SearchScreen("Img\DragonLevel99_Scroll.png",1,0,"INFO-DRAGON> FOUND-DRAGON LV.90+","INFO-DRAGON>-NOT FOUND DRAGON LV.90+",0,0,0,0,600,DragonSearchDeviation)) {
      DragonLevel=90
	  PrintLog("DEBUG-RAID> FOUND DRAGON LV.90+ ... RETURN 1")
      return 1
   }
   ;if (SearchScreen("Img\DragonLevel8x.png",1,1,"INFO-DRAGON> FOUND-DRAGON LV.80+","INFO-DRAGON>-NOT FOUND DRAGON LV.80+",0,0,0,0,600,DragonSearchDeviation) ) {
   ;  DragonLevel=80
   ;  return 1
   ;}
  ;if (SearchScreen("Img\DragonLevel7x.png",1,1,"INFO-DRAGON> FOUND-DRAGON LV.70+","INFO-DRAGON>-NOT FOUND DRAGON LV.70+",0,0,0,0,600,DragonSearchDeviation) ) {
  ;   DragonLevel=70
  ;   return 1
  ;}

  ScrollDragon()
 }
return 0
}

ForceClickDragon(){
ControlClick,x744 y220, ahk_id %hwnd%
PrintLog("WARNING-DRAGON> FORCE CLICK ENTER DRAGON",1)
ForceClickEnterDragon=1
return 1
}

ForceClickHomeAdvanture(){
ControlClick,x727 y586, ahk_id %hwnd%
PrintLog("ERROR-FARM> FORCE CLICK HOME ADVENTURE!!! Please CHECK HOME-ADVENTURE PICTURE",1)
return 1
}


ForceClickAdvanture(){
ControlClick,x168 y213, ahk_id %hwnd%
PrintLog("ERROR-FARM> FORCE CLICK ADVENTURE!!! Please CHECK ADVENTURE PICTURE",1)
return 1
}

ForceClickTower(){
ControlClick,x588 y207, ahk_id %hwnd%
PrintLog("WARNING-TOWER> FORCE CLICK ENTER TOWER",1)
return 1
}


ForceClickRaidNew(){
ControlClick,x502 y144, ahk_id %hwnd%
PrintLog("WARNING-TOWER> FORCE CLICK NEW RAID",1)
return 1
}


ForceClickArena(){
ControlClick,x157 y244, ahk_id %hwnd%
PrintLog("WARNING-TOWER> FORCE CLICK Arena",1)
return 1
}


TowerFight() {
  ClickBackToHome()
  if ClickHomeAdventure() {
   if (SearchScreen("Img\Tower.png",1,5,"INFO-TOWER> CLICK TOWER","WARNING-TOWER> NO TOWER BUTTON-Tower.png",0,0,0,0,0,50,0) or SearchScreen("Img\Tower1.png",1,5,"INFO-TOWER> CLICK TOWER1","WARNING-TOWER> NO TOWER BUTTON-Tower1.png",0,0,0,0,0,50,0) or ForceClickTower()) {
     if (SearchScreen("Img\TowerGoldChamber.png",1,5,"INFO-TOWER> CLICK GOLD CHAMBER","WARNING-TOWER> NOT FOUND GOLD CHAMBER-TowerGoldChamber.png") or SearchScreen("Img\TowerGoldChamber1.png",1,5,"INFO-TOWER> CLICK GOLD CHAMBER","WARNING-TOWER> NOT FOUND GOLD CHAMBER-TowerGoldChamber1.png") ) {
       ;if !(SearchScreen("Img\TeamCSelected.png",1,3,"INFO-STAGE> CLICK TEAM C","WARNING-STAGE>NOT FOUND TEAM C-ClickTeamC.png ... TRY PIRCURE2") or SearchScreen("Img\ClickTeamC.png",1,3,"INFO-STAGE> CLICK TEAM C","WARNING-STAGE>NOT FOUND TEAM C-ClickTeamC.png ... TRY PIRCURE2") or SearchScreen("Img\TowerTeamC.png",1,3,"INFO-STAGE> CLICK TEAM C","WARNING-STAGE>NOT FOUND TEAM C-TowerTeamC.png ... FORCE CLICK POSITION")) {
       ;  ControlClick,x298 y144, ahk_id %hwnd%
       ;}
       SearchScreen("Img\RemoveFriend.png",1,2,"INFO-TOWER> CLICK REMOVE FRIEND","")
       if (SearchScreen("Img\TowerStart.png",1,5,"INFO-TOWER> CLICK START","WARNING-TOWER> NOT FOUND START BUTTON-TowerStart.png") or SearchScreen("Img\TowerStart1.png",1,4,"INFO-TOWER> CLICK START","WARNING-TOWER> NOT FOUND START BUTTON1-TowerStart1.png")) {
         endFight := A_TickCount + 180000
         if (SearchScreen("Img\TowerNoKey.png",1,2,"INFO-TOWER> NO ENOUGH KEY BACK TO LOBBY","")) {
           ClickBackToHome()
           return 0
         }
         ; Turn on Auto Skill if off
         SearchScreen("Img\AutoSkillOn.png",1,5,"INFO-TOWER> CLICK AUTO SKILL ON ","")
         start := A_TickCount
         PrintLog("INFO-TOWER> FIGHTING ",1)
         SkillUsed1:=0
         SkillUsed2:=0
         Loop {
           ;SearchScreen("Img\AutoSkillOn.png",1,1,"INFO-TOWER> CLICK AUTO SKILL ON ","")
           if (SkillUsed1 = 0) {
             if (SearchScreen("Img\FarmRound1.png",0,2,"INFO-TOWER> ROUND1!!!","") or SearchScreen("Img\AutoSkillOn.png",0,2,"INFO-AWAKE> ROUND1!!! ","") or SearchScreen("Img\AutoSkillOff.png",0,2,"INFO-AWAKE> ROUND1!!! ","")) {
               SkillTowerRound1()
               SkillUsed1=1
             }
           }
           if (SkillUsed2 = 0) {
             if (SearchScreen("Img\FarmRound2.png",0,1,"INFO-TOWER> ROUND2!!!","") ) {
               SkillTowerRound2()
               SkillUsed2=1
             }
           }
           if (SearchScreen("Img\TowerNoKey.png",1,1,"INFO-TOWER> NO ENOUGH KEY BACK TO LOBBY","") or SearchScreen("Img\TowerNoKey1.png",1,1,"INFO-TOWER> NO ENOUGH KEY BACK TO LOBBY","")) {
             ClickBackToHome()
             return 0
           } 
           sleep 100
           PrintLog(".",0)
           if (A_TickCount >= endFight) { 
             ClickBackToHome()
             return 0 
           }
           if (SearchScreen("Img\TowerLobby.png",1,2,"INFO-TOWER> CLICK LOBBY","")) {
             break
           }
         } 
         PrintLog("INFO-TOWER> TOTAL FIGHT TIME= " (A_TickCount-start)/1000 " SECONDS",1)
         CountTower++
         return 1
       }
     }
   }
  }
;ESCNO()
 ClickBackToHome()
return 0
}

ArenaFight(){
global FightLeader:=0
  ClickBackToHome()
  ;ChangeMastery(ArenaMastery)
  if (isFarm=0){
    FightLeader:=StageLeader
  } else {
    FightLeader:=FarmLeader
  }
  if ((FightLeader != ArenaLeader) or (DragonLeader != ArenaLeader)) {
    if (LastLeader!=3) {
      PrintLog("INFO-ARENA> CHANGE LEADER TO HERO No. " ArenaLeader,1)
      ChangeLeader(ArenaLeader)
      LeaderFirstTime=0
      LastLeader=3
    } else {
      PrintLog("INFO-ARENA> LEADER NOT CHANGE ... SAME AS FARM/DRAGON/STAGE",1)
    }
  } else {
      PrintLog("INFO-ARENA> LEADER NOT CHANGE ... SAME AS FARM/DRAGON/STAGE",1)
  }
  if ClickHomeBattle() {
   if (SearchScreen("Img\Arena.png",1,4,"INFO-ARENA> CLICK ARENA","WARNING-ARENA> NO ARENA BUTTON-Arena.png") or SearchScreen("Img\Arena1.png",1,3,"INFO-ARENA> CLICK ARENA","WARNING-ARENA> NO ARENA BUTTON-Arena1.png") or ForceClickArena()) {
      SearchScreen("Img\ArenaNotice.png",1,1,"WARNING-ARENA> ARENA NOTICE SEASON END","")
      SearchScreen("Img\ArenaNoticeOK.png",1,1,"WARNING-ARENA> ARENA NOTICE ... OK","")
      SearchScreen("Img\ArenaNotice2x.png",1,1,"WARNING-ARENA> ARENA NOTICE 2X Point ... OK","")
      if !(SearchScreen("Img\ArenaReady.png",1,5,"INFO-ARENA> CLICK READY","WARNING-ARENA> NOT FOUND READY BUTTON-ArenaReady.png") or SearchScreen("Img\ArenaReady1.png",1,5,"INFO-ARENA> CLICK READY","WARNING-ARENA> NOT FOUND READY BUTTON-ArenaReady.png")) { 
		 ControlClick,x624 y541, ahk_id %hwnd%
	  } 
           if (SearchScreen("Img\ArenaStart.png",1,5,"INFO-ARENA> CLICK START","WARNING-ARENA> NOT FOUND START BUTTON-ArenaStart.png") or SearchScreen("Img\ArenaStart1.png",1,5,"INFO-ARENA> CLICK START1","WARNING-ARENA> NOT FOUND START1 BUTTON-ArenaStart1.png") or SearchScreen("Img\ArenaStart2.png",1,5,"INFO-ARENA> CLICK START2","WARNING-ARENA> NOT FOUND START2 BUTTON-ArenaStart2.png")) {
             if (SearchScreen("Img\ArenaNoKey.png",1,1,"INFO-ARENA> NO ENOUGH KEY BACK TO LOBBY","") or SearchScreen("Img\ArenaNoKey1.png",1,1,"INFO-ARENA> NO ENOUGH KEY BACK TO LOBBY","") or (SearchScreen("Img\ArenaSeasonEnd.png",1,1,"INFO-ARENA> SEASON END ... CANNOT START","")) or SearchScreen("Img\ArenaNotFindMatch.png",1,1,"INFO-ARENA> NOT FIND MATCH ... EXIT","")) {
               ClickBackToHome()
               return 0
             }
             if (SearchScreen("Img\ExceedHonor.png",0,3,"INFO-ARENA> EXCEED HONOR ","INFO-ARENA> HONOR NOT EXCEED")) {
               SearchScreen("Img\ExceedHonorYes.png",1,2,"INFO-ARENA> CONFIRM YES","")
               SearchScreen("Img\ExceedHonorEnter.png",1,2,"INFO-ARENA> CONFIRM YES","")
               ;ClickBackToHome()
               ;return 0
             }
             endFight := A_TickCount + 600000 ;Timeout ARENA is 10 Minutes
             start := A_TickCount
             PrintLog("INFO-ARENA> FIGHTING ",1)
             Loop {
               if (SearchScreen("Img\ArenaNoKey.png",1,0,"INFO-ARENA> NO ENOUGH KEY BACK TO LOBBY","") or (SearchScreen("Img\ArenaSeasonEnd.png",1,1,"INFO-ARENA> SEASON END ... CANNOT START","")) or SearchScreen("Img\ArenaNotFindMatch.png",1,1,"INFO-ARENA> NOT FIND MATCH ... EXIT","")) {
                 ClickBackToHome()
                 return 0
               } 
               
               sleep 200
               PrintLog(".",0)
               if (A_TickCount >= endFight) { 
                 ClickBackToHome()
                 return 0 
               }
               if (SearchScreen("Img\ArenaLobby.png",1,2,"INFO-ARENA> CLICK LOBBY","")) {
                 break
               }
             } 
             PrintLog("INFO-ARENA> TOTAL FIGHT TIME= " (A_TickCount-start)/1000 " SECONDS",1)
             CountArena++
             return 1           
           }
     
   } else {
       ClickBackToHome()
       return 1
     }
  }
 ClickBackToHome()
return 0
}


SortHeroByLevel(){
 ControlClick,x700 y150, ahk_id %hwnd%
 SearchScreen("Img\FarmLevel.png",1,2,"INFO-AWAKE>CLICK LEVEL","")
 if (SearchScreen("Img\FarmArrowUp.png",1,2,"INFO-AWAKE>ARROW-UP ...CLICK 2 Times to Refresh","") or SearchScreen("Img\FarmArrowUp1.png",1,2,"INFO-AWAKE>ARROW-UP ...CLICK 2 Times to Refresh","")){
  SearchScreen("Img\FarmArrowDown.png",1,2,"INFO-AWAKE>ARROW-DOWN ...CLICK","") 
  SearchScreen("Img\FarmArrowDown1.png",1,2,"INFO-AWAKE>ARROW-DOWN ...CLICK","") 
 }
 SearchScreen("Img\FarmArrowDown.png",1,2,"INFO-AWAKE>ARROW-DOWN ...CLICK","")
 SearchScreen("Img\FarmArrowDown1.png",1,2,"INFO-AWAKE>ARROW-DOWN ...CLICK","")
}

isHero30(x,y){
 ControlClick,x%x% y%y%, ahk_id %hwnd%
 if (SearchScreen("Img\FarmHero30.png",0,1,"INFO-AWAKE> HERO TO CHANGE ... LEVEL 30","")) {
  ControlSend,, {ESC}, ahk_id %hwnd%
  return 1
 }
 ControlSend,, {ESC}, ahk_id %hwnd%
 return 0
}
isHero1LV30() {
 NumHeroMatch:=0
 ;iniRead, NotChangeHero1, %A_WorkingDir%\Config.ini, Stage, NotChangeHero1
 if (NotChangeHero1=0) {
	 if (PixelColor(153,251,hwnd)="0xF7C41F") {
	  NumHeroMatch++
	 }
	 if (PixelColor(154,255,hwnd)="0xF79A07") {
	  NumHeroMatch++
	 }
	 if (PixelColor(152,260,hwnd)="0xE98003") {
	  NumHeroMatch++
	 }
	 if (PixelColor(160,255,hwnd)="0xF98003" ) {
	  NumHeroMatch++
	 }
	 if (PixelColor(164,256,hwnd)="0xEE8A07" ) {
	  NumHeroMatch++
	 }
	 if (PixelColor(151,259,hwnd)="0xFE9107" ) {
	  NumHeroMatch++
	 }
	 if (NumHeroMatch>=2) {
	   Hero1Lv30Flag=1
	   PrintLog("INFO-AWAKE> HERO1 LEVEL30",1)
	   return 1
	 }
 }
 Hero1Lv30Flag=0
 return 0
}

isHero2LV30() {
NumHeroMatch:=0

 if (NotChangeHero2=0) {
	 if (PixelColor(153,342,hwnd)="0xD5960C" ) {
	  NumHeroMatch++
	 }
	 if (PixelColor(154,345,hwnd)="0xF3AC10") {
	  NumHeroMatch++
	 }
	 if (PixelColor(153,351,hwnd)="0xDC8103") {
	  NumHeroMatch++
	 }
	 if (PixelColor(160,346,hwnd)="0xF28B04" ) {
	  NumHeroMatch++
	 }
	 if (NumHeroMatch>=2) {
	   Hero2Lv30Flag=1
	   PrintLog("INFO-AWAKE> HERO2 LEVEL30",1)
	   return 1
	 }
 }
 Hero2Lv30Flag=0
 return 0
}

isHero3LV30() {
 NumHeroMatch:=0
  if (NotChangeHero3=0) {
	 if (PixelColor(152,432,hwnd)="0xE7A914") {
	  NumHeroMatch++
	 }
	 if (PixelColor(154,436,hwnd)="0xEE8E04") {
	  NumHeroMatch++
	 }
	 if (PixelColor(152,440,hwnd)="0xDD7E05") {
	  NumHeroMatch++
	 }
	 if (PixelColor(160,437,hwnd)="0xE87D01" ) {
	  NumHeroMatch++
	 }
	 if (NumHeroMatch>=2) {
	   Hero3Lv30Flag=1
	   PrintLog("INFO-AWAKE> HERO3 LEVEL30",1)
	   return 1
	 }
  }
 Hero3Lv30Flag=0
 return 0
}
isHero4LV30() {
 NumHeroMatch:=0
  if (NotChangeHero4=0) {
	 if (PixelColor(151,524,hwnd)="0xF2B613") {
	  NumHeroMatch++
	 }
	 if (PixelColor(154,528,hwnd)="0xD87200") {
	  NumHeroMatch++
	 }
	 if (PixelColor(151,532,hwnd)="0xEA7E01") {
	  NumHeroMatch++
	 }
	 if (PixelColor(160,528,hwnd)="0xEC8203" ) {
	  NumHeroMatch++
	 }
	 if (PixelColor(164,528,hwnd)="0xEC8709" ) {
	  NumHeroMatch++
	 }
	 if (NumHeroMatch>=2) {
	   Hero4Lv30Flag=1
	   PrintLog("INFO-AWAKE> HERO4 LEVEL30",1)
	   return 1
	 }
  }
 Hero4Lv30Flag=0
 return 0
}
ScrollHero() {
  if (SearchScreen("Img\HeroPage.png",0,2,"INFO-AWAKE> CHECK IF CURRENT IS HERO MANAGE PAGE... PASS","")) {
    sleep 250
    ControlClick,x527 y453, ahk_id %hwnd%,,,,D
    ControlClick,x527 y305, ahk_id %hwnd%,,,,U
    PrintLog("INFO-AWAKE>SCROLL HERO UP",1)
    sleep 250
    return 1
  }
return 0
}
ScrollDragon() {
  sleep 250
  ControlClick,x406 y489, ahk_id %hwnd%,,,,D
  ControlClick,x406 y125, ahk_id %hwnd%,,,,U
  PrintLog("INFO-AWAKE>SCROLL DRAGON UP",1)
  sleep 250
}

MonSwitch(x,y,m1,m2) {
  PrintLog("DEBUG-FARM> Click HERO",1)
  sleep 1000
  ControlClick,x%m1% y%m2%
  if (SearchScreen("Img\FarmHero1.png",0,1,"INFO-AWAKE> HERO LEVEL 1","DEBUG-FARM> MON NOT LEVEL1") and (SearchScreen("Img\FarmJoin.png",0,1,"INFO-AWAKE> CAN SELECT","DEBUG-FARM> NO JOIN BUTTON") or SearchScreen("Img\FarmJoin1.png",0,1,"INFO-AWAKE> CAN SELECT","DEBUG-FARM> NO JOIN BUTTON")))  {
      SearchScreen("Img\FarmJoin.png",1,1,"INFO-AWAKE> CLICK JOIN","")
      if (SearchScreen("Img\FarmArrowUp.png",0,3,"INFO-AWAKE> ARROW UP","") or SearchScreen("Img\FarmArrowUp1.png",0,3,"INFO-AWAKE> ARROW UP","") ) {
        PrintLog("INFO-AWAKE>HERO TO CHANGE CLICKED",1)
        ControlClick,x%x% y%y%, ahk_id %hwnd%
        if (SearchScreen("Img\FarmFailSameTeam.png",0,3,"INFO-AWAKE> SAME HERO ... FAIL","")) {
          ControlSend,, {ESC}, ahk_id %hwnd%
          return 0
        }
        ControlClick,x%x% y%y%, ahk_id %hwnd%
        if (SearchScreen("Img\FarmHero1.png",0,1,"INFO-AWAKE> HERO LEVEL 1","")) {
          PrintLog("INFO-AWAKE>HERO CHANGE COMPLETE",1)
          ControlSend,, {ESC}, ahk_id %hwnd%
          return 1
        }
      }
    } else {
      ControlSend,, {ESC}, ahk_id %hwnd%
      return 0
    }
return 0
}


ChangeHero(x,y) {
 printLog("DEBUG-FARM> CHANGE HERO LOOP",1)
 loop,10 { ; How many loop to scroll hero 
  loop,2 {
    if(MonSwitch(x,y,324,250)) {
     return 1
    } else {
     if(MonSwitch(x,y,463,250)) {
       return 1
     } else {
       if(MonSwitch(x,y,592,250)) {
        return 1
       } else {
        if(MonSwitch(x,y,724,250)) {
          return 1
        }
       }
     }
    }
    ControlClick,x565 y147, ahk_id %hwnd%
  }
  if (ScrollHero()) {

  } else {
    PrintLog("INFO-AWAKE> Scroll HERO FAIL back to Home",1)
    return 0
  }
  sleep 500
 }
return 0
}

AISwitchHero(){
  SearchScreen("Img\ClickTeamA.png",1,1,"INFO-AWAKE> CLICK TEAM A","") ; Again Check if Team A are selected
  Hero1Lv30Flag=0  
  Hero2Lv30Flag=0  
  Hero3Lv30Flag=0  
  Hero4Lv30Flag=0  
  isHero1LV30()
  isHero2LV30()
  isHero3LV30()
  isHero4LV30()
  PrintLog("INFO-AWAKE> CHECKING IF HERO LEVEL 30",1)
  SearchScreen("Img\QuestComplete.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
  if (isHero1LV30() or isHero2LV30() or isHero3LV30() or isHero4LV30()) {
    if (SearchScreen("Img\FarmManage.png",1,2,"INFO-AWAKE>CLICK MANAGE ","")) {
      SortHeroByLevel()
      if (Hero1Lv30Flag) {
        PrintLog("INFO-AWAKE> TRY CHANGING HERO1",1)
        ChangeHero(90,214)
      }
      if (Hero2LV30Flag) {
        PrintLog("INFO-AWAKE> TRY CHANGING HERO2",1)
        ChangeHero(90,300)
      }
      if (Hero3LV30Flag) {
        PrintLog("INFO-AWAKE> TRY CHANGING HERO3",1)
        ChangeHero(90,386)
      }
      if (Hero4LV30Flag) {
        PrintLog("INFO-AWAKE> TRY CHANGING HERO4",1)
        ChangeHero(90,483)
      }
    }
  } else {
    return 0
  }
ControlSend,, {ESC}, ahk_id %hwnd%
return 1
}

ChangeMastery(IndexMastery="1"){
  if (SearchScreen("Img\MainMastery.png",1,2,"INFO-MASTERY> CLICK MASTERY","WARNING-MASTERY> NOT FOUND MASTERY`(MainMastery.png`)") or SearchScreen("Img\MainMastery1.png",1,2,"INFO-MASTERY> CLICK MASTERY","WARNING-MASTERY> NOT FOUND MASTERY`(MainMastery.png`)")) {
   PrintLog("INFO-MASTERY> TRY CHANGING MASTERY TO No. >>> "IndexMastery,1)
    sleep 1000
    if (IndexMastery=1) {
      ControlClick,x569 y152, ahk_id %hwnd%
      PrintLog("INFO-MASTERY> CHANGE MASTERY TO ... 1 COMPLETE",1)
    } else {
      if (IndexMastery=2) {
       ControlClick,x618 y152, ahk_id %hwnd%
       PrintLog("INFO-MASTERY> CHANGE MASTERY TO ... 2 COMPLETE",1)
      } else {
        if (IndexMastery=3) {
          ControlClick,x682 y152, ahk_id %hwnd%
          PrintLog("INFO-MASTERY> CHANGE MASTERY TO ... 3 COMPLETE",1)
        } else {
            PrintLog("ERROR-MASTERY> WRONG MASTERY NUMBER 1-3",1)
            return 0
        } 
      }
    }
  }
  sleep 1000
  ESCNO()  
  ClickBackToHome()
  return 0
}

ChangeLeader(IndexHero="1") {

 if (SearchScreen("Img\Heroes.png",1,2,"INFO-LEADER> CLICK HEROES","WARNING-LEADER> NOT FOUND HEROES`(Heroes.png`)")) {
   if (SearchScreen("Img\FarmArrowDown.png",1,2,"INFO-LEADER>ARROW-DOWN ...CLICK","") or SearchScreen("Img\FarmArrowDown1.png",1,2,"INFO-LEADER>ARROW-DOWN ...CLICK","")){
     SearchScreen("Img\FarmArrowUp.png",1,2,"INFO-LEADER>ARROW-UP ...CLICK","") 
     SearchScreen("Img\FarmArrowUp1.png",1,2,"INFO-LEADER>ARROW-UP ...CLICK","") 
   }
   SearchScreen("Img\FarmArrowUp.png",1,2,"INFO-LEADER>ARROW-UP ...CLICK","") 
   SearchScreen("Img\FarmArrowUp1.png",1,2,"INFO-LEADER>ARROW-UP ...CLICK","") 
 }
 PrintLog("INFO-LEADER> TRY CHANGING LEADER TO No. >>> "IndexHero,1)
 
 
 if (IndexHero>8){
   IndexHero:=IndexHero - 8
   PrintLog("DEBUG-FARM> INDEX HERO="IndexHero,1)
    sleep 250
    ControlClick,x523 y453, ahk_id %hwnd%,,,,D
    ControlClick,x523 y305, ahk_id %hwnd%,,,,U
    PrintLog("DEBUG-FARM>SCROLL HERO UP#1",1)
	sleep 550
	ControlClick,x523 y453, ahk_id %hwnd%,,,,D
    ControlClick,x523 y305, ahk_id %hwnd%,,,,U
    PrintLog("DEBUG-FARM>SCROLL HERO UP#2",1)
    sleep 250
 }
 if (IndexHero=1) {
   ControlClick,x329 y243, ahk_id %hwnd%
 } else {
   if (IndexHero=2) {
     ControlClick,x459 y243, ahk_id %hwnd%
   } else {
     if (IndexHero=3) {
       ControlClick,x599 y243, ahk_id %hwnd%
     } else {
       if (IndexHero=4) {
         ControlClick,x722 y243, ahk_id %hwnd%
       } else {
          if (IndexHero=5) {
            ControlClick,x329 y444, ahk_id %hwnd%
          } else {
            if (IndexHero=6) {
              ControlClick,x459 y444, ahk_id %hwnd%
            } else {
              if (IndexHero=7) {
                ControlClick,x599 y444, ahk_id %hwnd%
              } else {
                if (IndexHero=8) {
                  ControlClick,x722 y444, ahk_id %hwnd%
                } else {
                  PrintLog("ERROR-LEADER> WRONG HERO NUMBER 1-8",1)
                  return 0
                }
              }
            }
          } 
       }
     }
   }
 }
if (SearchScreen("Img\Leader.png",1,3,"INFO-LEADER> CLICK LEADER","WARNING-LEADER> NOT FOUND LEADER BUTTON") or SearchScreen("Img\Leader1.png",1,3,"INFO-LEADER> CLICK LEADER","WARNING-LEADER> NOT FOUND LEADER BUTTON")) {
   SearchScreen("Img\LeaderChange.png",1,3,"INFO-LEADER> CLICK CHANGE","")
}
ClickBackToHome()
return 0
}

DragonFight(){
  ForceClickEnterDragon=0
  RaidRepeat:=1
  NumRetry:=0
  ClickBackToHome()
  DragonLevel=0
  ;ChangeMastery(DragonMastery)
  if ((DragonLeader != ArenaLeader) ) {
    if (LastLeader!=2) {
      PrintLog("INFO-DRAGON> CHANGE LEADER TO HERO No. " DragonLeader,1)
      ChangeLeader(DragonLeader)
      LastLeader=2
     } else {
        PrintLog("INFO-DRAGON> LEADER NOT CHANGE ... SAME AS ARENA",1)
       }
  } else {
      PrintLog("INFO-DRAGON> LEADER NOT CHANGE ... SAME AS ARENA",1)
    }

  if ClickHomeAdventure() {
   if (SearchScreen("Img\Raid.png",1,5,"INFO-DRAGON> CLICK RAID","WARNING-DRAGON> NO RAID BUTTON-Raid.png") or SearchScreen("Img\Raid1.png",1,5,"INFO-DRAGON> CLICK RAID1","WARNING-DRAGON> NO RAID BUTTON-Raid1.png") ) { 
     if (SearchScreen("Img\RaidNew.png",1,5,"INFO-DRAGON> CLICK NEW RAID","WARNING-DRAGON> NOT FOUND NEW RAID-RaidNew.png") or SearchScreen("Img\RaidNew1.png",1,5,"INFO-DRAGON> CLICK NEW1","WARNING-DRAGON> NOT FOUND NEW RAID1-RaidNew1.png") or SearchScreen("Img\RaidNew2.png",1,5,"INFO-DRAGON> CLICK NEW RAID2-RaidNew2.png","") or SearchScreen("Img\RaidNew3.png",1,5,"INFO-DRAGON> CLICK NEW RAID3-RaidNew3.png","") or ForceClickRaidNew()) {
      ;if (SearchScreen("Img\RaidNotAvailable.png",1,5,"INFO-DRAGON> NO RAID QUOTA ... Back To Home","")) {
      ;  ClickBackToHome()
      ;  return 1
      ;}
      loopEndFight := A_TickCount + 300000 ;Timeout Fight Dragon is 5 Minutes
      loop ,100 {
       ;PrintLog("DEBUG1",1)
       ;SearchScreen("Img\RaidRefresh.png",1,2,"INFO-DRAGON> CLICK REFRESH ","WARNING-DRAGON> NO SEE REFRESH BUTTON")
         if (A_TickCount >= loopEndFight) { 
           PrintLog("INFO-DRAGON> 5 Minute no see Dragon ... Back to Home",1)
           ClickBackToHome()
           return 0 
         }
       if (AIRaidEnterMyDragon() or AIRaidEnterNew() or SearchScreen("Img\RaidEnter.png",1,5,"INFO-DRAGON> CLICK ENTER DRAGON","INFO-DRAGON> NOT FOUND RaidEnter.png") or SearchScreen("Img\RaidEnter1.png",1,2,"INFO-DRAGON> CLICK ENTER DRAGON","INFO-DRAGON> NOT FOUND RaidEnter1.png") or SearchScreen("Img\RaidEnter2.png",1,2,"INFO-DRAGON> CLICK ENTER DRAGON","INFO-DRAGON> NOT FOUND RaidEnter2.png") ) {
	     if (CheckLevelDragon=1 and DragonLevel=0) {
		   PrintLog("DEBUG-RAID> DRAGON LEVEL NOT 90 ... BACK HOME")
		   ClickBackToHome()
		   return 1
		 }
         if (SearchScreen("Img\RaidReady.png",1,5,"INFO-DRAGON> CLICK READY","WARNING-DRAGON> NOT FOUND READY BUTTON-RaidReady.png") or SearchScreen("Img\RaidReady1.png",1,5,"INFO-DRAGON> CLICK READY","WARNING-DRAGON> NOT FOUND READY BUTTON-RaidReady.png")) { 
           if (SearchScreen("Img\RaidStart.png",1,5,"INFO-DRAGON> CLICK START","WARNING-DRAGON> NOT FOUND START BUTTON-RaidStart.png") ) {

             endFight := A_TickCount + 1800000 ;Timeout Fight Dragon is 30 Minutes
             TimeMove := A_TickCount + 800000 ; Cooldown 40 Seconds
             start := A_TickCount
             SkillPJ := 0
             ; Turn on Auto Skill if off
             SearchScreen("Img\AutoSkillOn.png",1,1,"INFO-DRAGON> CLICK AUTO SKILL ","")
             PrintLog("INFO-DRAGON> FIGHTING ",1)
             ;sleep 1000
             if SearchScreen("Img\RaidBegin.png",0,5,"INFO-DRAGON> CLICK AUTO SKILL ","") {
               SkillHitDragonStart()
             }
             SkillHitDragon()
             AutoSkillFlag:=0
             SkillPriority2Used:=0
             CounterSkill:=1
             Loop {
			 if (SearchScreen("Img\RaidNoKey.png",1,0,"INFO-DRAGON> NO ENOUGH KEY BACK TO LOBBY","") ) {
               ClickBackToHome()
               SkillHitDragonEnd()
               return 0
             }
             if (SearchScreen("Img\RaidFinish.png",1,0,"INFO-RAID> CLICK RAID FINISH","") or SearchScreen("Img\RaidFinish1.png",1,0,"INFO-RAID> CLICK RAID FINISH","")) {
               ClickBackToHome()
               SkillHitDragonEnd()
               return 1
             }
			 if (SearchScreen("Img\RaidNoEntries.png",1,0,"INFO-RAID> CLICK RAID NO ENTRIES","") ) {
               ClickBackToHome()
               SkillHitDragonEnd()
               return 1
             }
               if (AutoSkillFlag=0) {
                 SearchScreen("Img\AutoSkillOn.png",1,0,"INFO-DRAGON> CLICK AUTO SKILL ","")
                 AutoSkillFlag=1
               }
               ;SearchScreen("Img\RaidPaused.png",1,0.1,"","") 
               ;if(SearchScreen("Img\RaidAlreadyEnd.png",1,0,"INFO-DRAGON> RAID ALREADY END ","")) {
               ; break
               ;}
               if (SkillPriority2Used=0){
			   ;SearchScreen(ImgName,ClickButton="1",Timeout="5",Text="",TextError="",X1="0",Y1="0",W="0",H="0",PlusX="0",Deviation="20",PlusY="0",DelayClick="0"){
			     SearchScreen("Img\SkillPriority2.png",1,1,"INFO-DRAGON> CLICK - SKILL JUPY-1 ","",,,,,,,,DelayClick) 
				 SearchScreen("Img\SkillPriority2-1.png",1,1,"INFO-DRAGON> CLICK - SKILL JUPY-2 ","",,,,,,,,DelayClick)  
				 SearchScreen("Img\SkillPriority2-2.png",1,1,"INFO-DRAGON> CLICK - SKILL JUPY-1 ","",,,,,,,,DelayClick)  
                 SearchScreen("Img\SkillPriority1-2.png",1,1,"INFO-DRAGON> CLICK - SKILL SIEG-1 ","",,,,,,,,DelayClick)  
                 CounterSkill=0
               }
               CounterSkill++
             if (CounterSkill >=3) {
               if (SkillPJ=0) {  
                  if (SearchScreen("Img\SkillPriority2-3.png",1,1,"INFO-DRAGON> CLICK - SKILL Peijeow-1 ","",,,,,,,,DelayClick)){
                    SkillPJ=1
                  }
               }
			   ;SkillDellon
               if (SearchScreen("Img\SkillPriority1.png",1,1,"INFO-DRAGON> CLICK - SKILL SEIN ","",,,,,,,,DelayClick)) {
                  SkillPriority2Used=1
               }
			   if (SearchScreen("Img\SkillDellon.png",1,1,"INFO-DRAGON> CLICK - SKILL DELLON ","",,,,,,,,DelayClick)) {
                  SkillPriority2Used=1
               }
             }
               if (SearchScreen("Img\SkillPriority1.png",1,1,"INFO-DRAGON> CLICK - SKILL SEIN ","",,,,,,,,DelayClick)) {
                  SkillPriority2Used=1
               }
               ;sleep 200
               ;if (A_TickCount >= TimeMove) {
               ;  MouseClick Left, 10,10
               ;  TimeMove = TimeMove + A_TickCount
               ;}

               PrintLog(".",0)
               if (A_TickCount >= endFight) { 
                 SkillHitDragonEnd()
                 ClickBackToHome()
                 return 0 
               }
               if (SearchScreen("Img\RaidLobby.png",0,0,"INFO-DRAGON> FIGHT END","") or SearchScreen("Img\RaidLobby1.png",0,0,"INFO-DRAGON> FIGHT END","") or SearchScreen("Img\RaidLobby2.png",0,0,"INFO-DRAGON> FIGHT END","")) {
                 ;if (DragonLevel >= 80 and RaidRepeat<=1) {
                 if (RaidRepeat<=NumDragonRepeat) {
                   PrintLog("INFO-DRAGON> WAIT FOR " MinuteSleepBeforeRepeatDragon " MINUTE TO ENSURE THERE ARE KEY TO REPEAT DRAGON",1)
                   ;sleep 300000 ; Wait 4 minute before click Repeat
                  ;ClickRepeat()
                  ;if (nokey) {
;
;                  }
                   sleep DragonRepeatSleep
                   SearchScreen("Img\RaidRepeat.png",1,1,"INFO-DRAGON> DRAGON LV. THAN 80 CLICK REPEAT!!!","") 
                   SearchScreen("Img\RaidRepeat1.png",1,1,"INFO-DRAGON> DRAGON LV. THAN 80 CLICK REPEAT!!!","")
                   endFight := A_TickCount + 1800000
                   AutoSkillFlag:=0
                   SkillPriority2Used:=0
                   CounterSkill:=1
                   NumRetry++ 
                   if(SearchScreen("Img\RaidReady.png",1,5,"INFO-DRAGON> CLICK READY","WARNING-DRAGON> NOT FOUND READY BUTTON-RaidReady.png") or SearchScreen("Img\RaidReady1.png",1,5,"INFO-DRAGON> CLICK READY","WARNING-DRAGON> NOT FOUND READY BUTTON-RaidReady.png")){
                     if !(SearchScreen("Img\RaidStart.png",1,5,"INFO-DRAGON> CLICK START","WARNING-DRAGON> NOT FOUND START BUTTON-RaidStart.png")) {
                       break
                     }
                   } else {
                     if (NumRetry<=1) {
                      NumRetry=0
                      ControlClick,x748 y279, ahk_id %hwnd%
                      if(SearchScreen("Img\RaidReady.png",1,5,"INFO-DRAGON> CLICK READY","WARNING-DRAGON> NOT FOUND READY BUTTON-RaidReady.png") or SearchScreen("Img\RaidReady1.png",1,5,"INFO-DRAGON> CLICK READY","WARNING-DRAGON> NOT FOUND READY BUTTON-RaidReady.png")){
                        if !(SearchScreen("Img\RaidStart.png",1,5,"INFO-DRAGON> CLICK START","WARNING-DRAGON> NOT FOUND START BUTTON-RaidStart.png")) {
                          break
                        }
                      } else {
                        break
                       }
                     } else {
                      break
                     }
                   }
                   RaidRepeat++
                 } else {
                     if (SearchScreen("Img\RaidLobby.png",1,1,"INFO-DRAGON> CLICK LOBBY","") or SearchScreen("Img\RaidLobby1.png",1,1,"INFO-DRAGON> CLICK LOBBY","") or SearchScreen("Img\RaidLobby2.png",1,1,"INFO-DRAGON> CLICK LOBBY","")) {
                       break
                     }
                 }
               }
             } 
             PrintLog("INFO-DRAGON> TOTAL FIGHT TIME= " (A_TickCount-start)/1000 " SECONDS",1)
             CountDragon++
             SkillHitDragonEnd()
             return 1           
           }
         }
         if (ForceClickEnterDragon=1) {
            return 1
         }  
       } ; else {
         ;PrintLog("END OF RAID READY ",1)
         ;SkillHitDragonEnd()
         ;ClickBackToHome()
         ;return 1
       ;}
      SearchScreen("Img\RaidRefresh.png",1,2,"INFO-DRAGON> CLICK REFRESH ","WARNING-DRAGON> NO SEE REFRESH BUTTON")
	 } ; END OF SEARCH RAID ENTER
    }
    PrintLog("END OF LOOP",1)
   }
    PrintLog("END OF No New RAID",1)
  }
 SkillHitDragonEnd()
 PrintLog("END OF ALL BACK HOME",1)
 ClickBackToHome()
return 0
}

ForceClickKarinDun(){
ControlClick,x304 y417, ahk_id %hwnd%
PrintLog("WARNING-DRAGON> FORCE CLICK ENTER DRAGON",1)
ForceClickEnterDragon=1
return 1
}

ForceClickEvanDun(){
ControlClick,x274 y325, ahk_id %hwnd%
PrintLog("WARNING-DRAGON> FORCE CLICK ENTER DRAGON",1)
ForceClickEnterDragon=1
return 1
}

ForceClickKlaHanDun(){
ControlClick,x319 y512, ahk_id %hwnd%
PrintLog("WARNING-DRAGON> FORCE CLICK ENTER DRAGON",1)
ForceClickEnterDragon=1
return 1
}

AwakeFight() {
  ClickBackToHome()
  NumCountFarm:=0
  if ClickHomeAdventure() {
   if (SearchScreen("Img\AwakeSpecialDun.png",1,5,"INFO-AWAKE> CLICK SpecialDun","WARNING-AWAKE> NOT FOUND AwakeSpecialDun.png")) {
     end := A_TickCount + 180000
	 ;SearchScreen(ImgName,ClickButton="1",Timeout="5",Text="",TextError="",X1="0",Y1="0",W="0",H="0",PlusX="0",Deviation="20",PlusY="0")
  
	 ForceClickKlaHanDun()
     ;if (SearchScreen("Img\AwakeReady.png",1,5,"INFO-AWAKE> CLICK READY","WARNING-FARM> NOT FOUND READY BUTTON-StageReady.png") or SearchScreen("Img\AwakeReady1.png",1,5,"INFO-AWAKE> CLICK READY","WARNING-FARM> NOT FOUND READY BUTTON-StageReady1.png")) {
       ; Select Team C if other team are selected


     loop, {
	  NumCountFarm++
	  if (SearchScreen("Img\AwakeReady.png",1,5,"INFO-AWAKE> CLICK READY","WARNING-FARM> NOT FOUND READY BUTTON-StageReady.png") or SearchScreen("Img\AwakeReady1.png",1,5,"INFO-AWAKE> CLICK READY","WARNING-FARM> NOT FOUND READY BUTTON-StageReady1.png")) {
       ; Select Team C if other team are selected
       ; SearchScreen("Img\QuestComplete.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
       ; SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
        if (SearchScreen("Img\AwakeNoKey.png",1,1,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")) {
		  ClickBackToHome()
		  return 0
		}
       ; SearchScreen("Img\QuestComplete.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
       ; SearchScreen("Img\RemoveFriend.png",1,2,"INFO-AWAKE> CLICK REMOVE FRIEND","")
       if (SearchScreen("Img\AwakeStart.png",1,5,"INFO-AWAKE> CLICK START","WARNING-FARM> NOT FOUND START BUTTON-StageStart.png") or SearchScreen("Img\AwakeStart1.png",1,5,"INFO-AWAKE> CLICK START","WARNING-FARM> NOT FOUND START BUTTON-StageStart.png")) {
         endFight := A_TickCount + 180000

        ; Turn on Auto Skill if off
         ;SearchScreen("Img\AutoSkillOn.png",1,5,"INFO-STAGE> CLICK AUTO SKILL ON ","")
         start := A_TickCount
         PrintLog("INFO-STATE> FIGHTING ",1)
         Loop {       
           PrintLog(".",0)
           if (SkillUsed1 = 0) {
             if (SearchScreen("Img\FarmRound1.png",0,2,"INFO-AWAKE> ROUND1!!!","") or SearchScreen("Img\AutoSkillOn.png",0,2,"INFO-AWAKE> ROUND1!!! ","") or SearchScreen("Img\AutoSkillOff.png",0,2,"INFO-AWAKE> ROUND1!!! ","")) {
               SkillFarmRound1()
               SkillUsed1=1
               if (AutoSkillFlag=0) {
                 SearchScreen("Img\AutoSkillOff.png",1,1,"INFO-AWAKE> CLICK AUTO SKILL OFF ","")
                 AutoSkillFlag=1 
               }
             }
           }
         if (SearchScreen("Img\StageNoKey.png",1,2,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")) {
           ClickBackToHome()
           return 0
         }
           if (SkillUsed2 = 0) {
             if (SearchScreen("Img\FarmRound2.png",0,1,"INFO-AWAKE> ROUND2!!!","") ) {
               SkillFarmRound2()
               SkillUsed2=1
             }
           }

           if (A_TickCount >= endFight) { 
             ClickBackToHome()
             return 0 
           }
           if (SearchScreen("Img\StageLobby.png",0,0,"INFO-AWAKE> CLICK LOBBY","")) {
             NumCountFarm++
             break
           }
           if (SearchScreen("Img\StageNoKey.png",1,1,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")) {
             return 0
           }
         if (SearchScreen("Img\HeroFull.png",1,0,"ERROR-FARM> HERO OR ITEM ARE FULL ... CLICK PROCEED","") or SearchScreen("Img\ItemFull.png",1,0,"ERROR-STAGE> HERO FULL CLICK PROCEED","")) {
           loop, 30{
             soundbeep, 750, 500
             soundbeep, 1100, 500
           }
         }		   
         } 
         PrintLog("INFO-AWAKE> TOTAL FIGHT TIME= " (A_TickCount-start)/1000 " SECONDS",1)
         PrintLog("INFO-AWAKE> CURRENT HIT ROUND= "NumCountFarm "/" 99,1)
         SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
         SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
         SearchScreen("Img\QuestHero30.png",1,1,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
         SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
           if (CloseDragonPopUP()) {
             ClickBackToHome()
             DragonFight()
             CountBattle++
           } ; 
           ;SearchScreen("Img\StageReady.png",1,5,"INFO-AWAKE> CLICK READY","WARNING-FARM> NOT FOUND READY BUTTON-StageReady.png")
         CountBattle++
         ;return 1
       }
         if (NumCountFarm>=99) {
		     NumCountFarm=0
          if (CloseDragonPopUP()) {
             ClickBackToHome()
             DragonFight()
             CountBattle++
           } ; 
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","")
          SearchScreen("Img\QuestHero30.png",1,2,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\StageLobby.png",1,0,"INFO-AWAKE> CLICK LOBBY","")
          ClickBackToHome()
          return 1
         } else {
          if (CloseDragonPopUP()) {
             ClickBackToHome()
             DragonFight()
             CountBattle++
           } ; 
          SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","")
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\QuestHero30.png",1,2,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          if (SearchScreen("Img\AwakeRepeat.png",1,0,"INFO-AWAKE> CLICK REPEAT","")) {
           NumErrorFarm=0
          }
         }  
         if (NumErrorFarm >= 3) {
           NumErrorFarm=0
           ClickBackToHome()
           return 0
         }
        } 
      }
     }
 }
ClickBackToHome()
return 0
}


FarmFight() {
  ClickBackToHome()
  ;ChangeMastery(FarmMastery)
  if ((FarmLeader != ArenaLeader) or LeaderFirstTime=1) {
    if (LastLeader!=1) {
      PrintLog("INFO-AWAKE> CHANGE LEADER TO HERO No. " FarmLeader,1)
      ChangeLeader(FarmLeader)
      LeaderFirstTime=0
      LastLeader=1
    } else {
      PrintLog("INFO-AWAKE> LEADER NOT CHANGE ... SAME AS ARENA",1)
    }
  } else {
      PrintLog("INFO-AWAKE> LEADER NOT CHANGE ... SAME AS ARENA",1)
  }
  if ClickHomeAdventure() {
   if (SearchScreen("Img\Adventure.png",1,2,"INFO-AWAKE> CLICK ADVENTURE","WARNING-FARM> NO ADVENTURE BUTTON-Adventure.png") or SearchScreen("Img\Adventure1.png",1,2,"INFO-AWAKE> CLICK ADVENTURE","WARNING-FARM> NO ADVENTURE BUTTON-Adventure.png") or SearchScreen("Img\AdventureHotTime.png",1,2,"INFO-AWAKE> CLICK ADVENTURE","WARNING-FARM> NO ADVENTURE BUTTON-AdventureHotTime.png") or ForceClickAdvanture()) {
     end := A_TickCount + 180000
	 ;SearchScreen(ImgName,ClickButton="1",Timeout="5",Text="",TextError="",X1="0",Y1="0",W="0",H="0",PlusX="0",Deviation="20",PlusY="0")
     While !(SearchScreen(FarmMap,1,2,"INFO-AWAKE> CLICK MAP","INFO-AWAKE> FINDING MAP",0,0,0,0,0,50,0) or SearchScreen(FarmMap1,1,2,"INFO-AWAKE> CLICK MAP","INFO-AWAKE> FINDING MAP",0,0,0,0,0,50,0) or SearchScreen(FarmMap2,1,2,"INFO-AWAKE> CLICK MAP","INFO-AWAKE> FINDING MAP",0,0,0,0,0,50,0)) {
       SearchScreen("Img\Asgar.png",1,0,"INFO-AWAKE> CLICK ASGAR","")  ; Click ASGAR <<< 
       SearchScreen("Img\NextMap.png",1,0,"INFO-AWAKE> CLICK Next Map","")
       if (A_TickCount >= end) {
         ClickBackToHome()
         return 0
       }
     } ; End Search Map
     if (SearchScreen("Img\StageReady.png",1,5,"INFO-AWAKE> CLICK READY","WARNING-FARM> NOT FOUND READY BUTTON-StageReady.png") or SearchScreen("Img\StageReady1.png",1,5,"INFO-AWAKE> CLICK READY","WARNING-FARM> NOT FOUND READY BUTTON-StageReady1.png")) {
       ; Select Team C if other team are selected
		if !(SearchScreen("Img\TeamASelected.png",1,3,"INFO-STAGE> CLICK TEAM A","WARNING-STAGE>NOT FOUND TEAM A-TeamCSelected.png ... TRY PIRCURE2") or SearchScreen("Img\ClickTeamA.png",1,3,"INFO-STAGE> CLICK TEAM A","WARNING-STAGE>NOT FOUND TEAM C-ClickTeamC.png ... TRY PIRCURE2") or SearchScreen("Img\TowerTeamA.png",1,3,"INFO-STAGE> CLICK TEAM A","WARNING-STAGE>NOT FOUND TEAM C-TowerTeamC.png ... FORCE CLICK POSITION")) {
		     sleep 1000
			 ControlClick,x125 y144, ahk_id %hwnd%
		}
			 ControlClick,x125 y144, ahk_id %hwnd%
       SearchScreen("Img\AutoRepeatOff.png",1,2,"INFO-AWAKE> CLICK AUTO REPEAT OFF","")
       NumErrorFarm=0
     loop, {
       SearchScreen("Img\QuestComplete.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
       SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
       SearchScreen("Img\QuestHero30.png",1,1,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
       SearchScreen("Img\QuestComplete.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
       if !(AISwitchHero()) {
        NumErrorFarm++ 
        if (NumErrorFarm>=1) {
          PrintLog("INFO-AWAKE> COUNT ERROR = "NumErrorFarm,1)
        }
       }
       SearchScreen("Img\RemoveFriend.png",1,2,"INFO-AWAKE> CLICK REMOVE FRIEND","")
       if (SearchScreen("Img\StageStart.png",1,5,"INFO-AWAKE> CLICK START","WARNING-FARM> NOT FOUND START BUTTON-StageStart.png")) {
         endFight := A_TickCount + 300000

         if (SearchScreen("Img\HeroFull.png",1,0,"ERROR-FARM> HERO OR ITEM ARE FULL ... CLICK PROCEED","") or SearchScreen("Img\ItemFull.png",1,0,"ERROR-FARM> HERO OR ITEM ARE FULL ... CLICK PROCEED","")) {
           loop, 1{
             soundbeep, 750, 500
             soundbeep, 1100, 500
           }
         }
         SkillUsed1 := 0
         SkillUsed2 := 0
         SkillUsed3 := 0
         AutoSkillFlag=0
         ; Turn on Auto Skill if off
         ;SearchScreen("Img\AutoSkillOn.png",1,5,"INFO-STAGE> CLICK AUTO SKILL ON ","")
         start := A_TickCount
         PrintLog("INFO-STATE> FIGHTING ",1)
         Loop {       
           PrintLog(".",0)
           if (SkillUsed1 = 0) {
             if (SearchScreen("Img\FarmRound1.png",0,2,"INFO-AWAKE> ROUND1!!!","") or SearchScreen("Img\AutoSkillOn.png",0,2,"INFO-AWAKE> ROUND1!!! ","") or SearchScreen("Img\AutoSkillOff.png",0,2,"INFO-AWAKE> ROUND1!!! ","")) {
               SkillFarmRound1()
               SkillUsed1=1
               if (AutoSkillFlag=0) {
                 SearchScreen("Img\AutoSkillOff.png",1,1,"INFO-AWAKE> CLICK AUTO SKILL OFF ","")
                 AutoSkillFlag=1 
               }
             }
           }
         if (SearchScreen("Img\StageNoKey.png",1,2,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")) {
           ClickBackToHome()
           return 0
         }
           if (SkillUsed2 = 0) {
             if (SearchScreen("Img\FarmRound2.png",0,1,"INFO-AWAKE> ROUND2!!!","") ) {
               SkillFarmRound2()
               SkillUsed2=1
             }
           }
           if (SkillUsed3 = 0) {
             if (SearchScreen("Img\FarmRound3.png",0,1,"INFO-AWAKE> ROUND3!!!","") ) {
               SkillFarmRound3()
               SkillUsed3=1
               SearchScreen("Img\AutoSkillOn.png",1,1,"INFO-AWAKE> AUTO SKILL ON ","")
             }
           }
           if (A_TickCount >= endFight) { 
             ClickBackToHome()
             return 0 
           }
           if (SearchScreen("Img\StageLobby.png",0,0,"INFO-AWAKE> CLICK LOBBY","")) {
             NumCountFarm++
             break
           }
           if (SearchScreen("Img\StageNoKey.png",1,1,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")) {
             return 0
           }
         if (SearchScreen("Img\HeroFull.png",1,0,"ERROR-FARM> HERO OR ITEM ARE FULL ... CLICK PROCEED","") or SearchScreen("Img\ItemFull.png",1,0,"ERROR-STAGE> HERO FULL CLICK PROCEED","")) {
           loop, 30{
             soundbeep, 750, 500
             soundbeep, 1100, 500
           }
         }		   
         } 
         PrintLog("INFO-AWAKE> TOTAL FIGHT TIME= " (A_TickCount-start)/1000 " SECONDS",1)
         PrintLog("INFO-AWAKE> CURRENT HIT ROUND= "NumCountFarm "/" MaxNumFarm,1)
         SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
         SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","") 
         SearchScreen("Img\QuestHero30.png",1,1,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
         SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
           if (CloseDragonPopUP()) {
             ClickBackToHome()
             DragonFight()
             CountBattle++
           } ; 
           ;SearchScreen("Img\StageReady.png",1,5,"INFO-AWAKE> CLICK READY","WARNING-FARM> NOT FOUND READY BUTTON-StageReady.png")
         CountBattle++
         ;return 1
       }
         if (NumCountFarm>=MaxNumFarm) {
          if (CloseDragonPopUP()) {
             ClickBackToHome()
             DragonFight()
             CountBattle++
           } ; 
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","")
          SearchScreen("Img\QuestHero30.png",1,2,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\StageLobby.png",1,0,"INFO-AWAKE> CLICK LOBBY","")
          ClickBackToHome()
          return 1
         } else {
          if (CloseDragonPopUP()) {
             ClickBackToHome()
             DragonFight()
             CountBattle++
           } ; 
          SearchScreen("Img\LevelUp.png",1,1,"INFO-CLICK QUEST COMPLETE","")
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          SearchScreen("Img\QuestHero30.png",1,2,"INFO-AWAKE> NO ENOUGH KEY BACK TO LOBBY","")
          SearchScreen("Img\QuestComplete.png",1,2,"INFO-CLICK QUEST COMPLETE","") 
          if (SearchScreen("Img\FarmRepeat.png",1,0,"INFO-AWAKE> CLICK REPEAT","")) {
           NumErrorFarm=0
          }
         }  
         if (NumErrorFarm >= 3) {
           NumErrorFarm=0
           ClickBackToHome()
           return 0
         }
        } 
      }
     }
 }
ClickBackToHome()
return 0
}

F2::
global CurrentXpos, CurrentYPos
global RunHour:=2
global MaxNumFarm:=5
global NumDragonRepeat:=0
iniRead, RunHour, %A_WorkingDir%\Config.ini, Common, RunHour
iniRead, MaxNumFarm, %A_WorkingDir%\Config.ini, Stage, MaxNumFarm
iniRead, NumDragonRepeat, %A_WorkingDir%\Config.ini, Common, NumDragonRepeat
  MainEnd:=A_TickCount + RunHour*3600000
  Initialized()

  

  WinGetPos ,CurrentXpos,CurrentYpos,,,A
  loop, {
    ; CloseDragonPopUP()
    ; if (A_TickCount >= MainEnd){
      ; PrintLog("INFO-COMMON> RUN HOUR REACH ... EXITING APP",1)
      ; exitapp
    ; }
    OpenGame()
    ;ESCNO()
    ClickBackToHome() ; To ensure we are ready @ Home 
	AwakeFight()
    ; if (CountHitDragon >= MaxHitDragon) { ; Number to hit dragon per number to Fight in a State (Default value is 2)
     ; if (isFarm=0){
        ; if(NumRepeatStart<=NumRepeatStage){
          ; StageMap1=%StageMapFirst1%
          ; StageMap=%StageMapFirst%
        ; } else {
          ; StageMap1=%StageMapNext1%
          ; StageMap=%StageMapNext%
          ; if (NumRepeatStart>=NumRepeatStage*2) {
            ; NumRepeatStart=1
          ; }
        ; }
      ; if (StageFight()) {
        ; CountHitDragon = 0
        ; NumRepeatStart++
      ; }
	  ; if (NumCountStage>=MaxNumFarm) {
        ; NumCountStage=0
		; CountHitDragon = 0
      ; }
     ; } else {
      ; FarmFight()
      ; if (NumCountFarm>=MaxNumFarm) {
        ; NumCountFarm=0
        ; CountHitDragon = 0
      ; }
     ; }
    ; } else {
      ; if (DragonFight()) {
        ; CountHitDragon++
      ; }
    ; }
    ; TowerFight()
    ; ArenaFight()
    Summary()
  }  
F1::
PrintLog("INFO-SYSTEM> PRESS F1-PAUSE TO RESUME PRESS F3!!!",1)
pause, on
return

F3::
PrintLog("INFO-SYSTEM> PRESS F3-RESUME TO PAUSE PRESS F1!!!",1)
pause, off
return

F12::
PrintLog("INFO-SYSTEM> EXITING APPLICATION !!!",1)
sleep 1000
Run taskkill /f /im baretail*
ExitApp
Return

F9::
PrintLog("Current Position are X= "CurrentXpos " Y=" CurrentYPos,1)
WinMove ,ahk_id %hwnd%,,A_ScreenWidth+20,10
PrintLog("GAME SCREEN NOW HIDED at Position X= "A_ScreenWidth+20 " Y=" 10,1)
return

F10::
;PrintLog("Current Position are X&Y= "CurrentXpos "&" CurrentYPos,1)
WinMove ,ahk_id %hwnd%,,CurrentXpos,CurrentYPos
PrintLog("GAME SCREEN NOW UNHIDE",1)
return

