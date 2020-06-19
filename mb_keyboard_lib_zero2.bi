'##############################
'mb_keyboard_lib v2.0 is a set of routines to manage a keyboard and joystick handler, input buffer, 
'and input motion interpretation for up to 2 Players. 
'Due to the Windows API it only supports 4 joystick buttons.
'##############################
#include once "windows.bi"
#include once "win/mmsystem.bi"
#include once "fbgfx.bi"
'#####################################################################################################
dim shared as string last_evt_p1 'Last Event Type for Player 1 K=Keyboard J=Joystick
dim shared as string last_evt_p2 'Last Event Type for Player 2 K=Keyboard J=Joystick


dim shared as string jx1(1 to 9),jy1(1 to 9) 'x and y coords for Player 1 Joystick
dim shared as string jx2(1 to 9),jy2(1 to 9) 'x and y coords for Player 2 Joystick

dim shared as integer jsh_i 'Joystick Initializer
jsh_i=0

dim shared as LONG_PTR g_pFBGfxWindowProc 'needed for keyboard handler
dim shared as integer hwndFbgfx 'needed for keyboard handler


dim shared as string keyboard_lkp,joy1_lkp,joy2_lkp 'last key pressed scancode
dim shared as string keyboard_lks,joy1_lks,joy2_lks 'last key state U=Up D=Down


dim shared as integer nok_p1,nok_p2,ibuff_p1_c,ibuff_p2_c,ibuff_p1j_c,ibuff_p2j_c 'number of keys player 1 & player 2
nok_p1=10 'these are default values, mb_install_keyboard subroutine can change these values
nok_p2=10
ibuff_p1_c=1
ibuff_p2_c=1
ibuff_p1j_c=1
ibuff_p2j_c=1
'The input buffer is hardcoded to be 30 unique inputs long
dim shared as double kts_p1(1 to 30),jts_p1(1 to 30) 'time stamp array
dim shared as string kb_p1(1 to 30),jb_p1(1 to 30) 'Keyboard Buffer Player 1
redim shared as integer scan_codes_p1(1 to nok_p1)
dim shared as string kbls_p1,jbls_p1 'Keyboard Buffer Last State Player 1

'Toggle Time Stamp for Player 1, the total time a key is held down then released
'it should  be cleared after each use/awknowledgement 
'index corresponds to scan_codes_p1() 
redim shared as double time_stamp_kp1(1 to nok_p1) 'Player 1 time stamp for last key press Up OR Down 

redim shared as double tts_d_p1(1 to nok_p1),tts_d_p1j(1 to 13) 'Player 1 time stamp for first down press
redim shared as double tts_u_p1(1 to nok_p1),tts_u_p1j(1 to 13) 'Player 1 time stamp for first release press, the delta is stored here

redim shared as double time_stamp_down_p1(1 to nok_p1) 'Player 1 time stamp for last down key press
redim shared as double time_stamp_up_p1(1 to nok_p1) 'Player 1 time stamp for last release of key




'**************same stuff but this time for player 2
dim shared as double kts_p2(1 to 30),jts_p2(1 to 30) 'time stamp array
dim shared as string kb_p2(1 to 30),jb_p2(1 to 30) 'Keyboard Buffer Player 2
redim shared as integer scan_codes_p2(1 to nok_p2)
dim shared as string kbls_p2,jbls_p2 'Keyboard Buffer Last State Player 2

'Toggle Time Stamp for Player 2, the total time a key is held down then released
'it should  be cleared after each use/awknowledgement 
'index corresponds to scan_codes_p2() 
redim shared as double tts_d_p2(1 to nok_p2),tts_d_p2j(1 to 13) 'Player 2 time stamp for first down press
redim shared as double tts_u_p2(1 to nok_p2),tts_u_p2j(1 to 13) 'Player 2 time stamp for first release press, the delta is stored here

redim shared as double time_stamp_down_p2(1 to nok_p2) 'Player 2 time stamp for last down key press
redim shared as double time_stamp_up_p2(1 to nok_p2) 'Player 2 time stamp for last release of key

redim shared as double time_stamp_kp2(1 to nok_p2) 'Player 2 time stamp for last key press Up OR Down

kbls_p1=""
kbls_p2=""
jbls_p1=""
jbls_p2=""

'scan_codes_p1() array holds the scan codes for each Player 1 key, the same is true for Player 2
'for example: 
'scan_codes_p1(1)=65 'A
'scan_codes_p1(2)=83 'S
'scan_codes_p1(3)=68 'D
'scan_codes_p1(4)=90 'Z
'scan_codes_p1(5)=88 'X
'scan_codes_p1(6)=67 'C
'scan_codes_p1(7)=38 'Up
'scan_codes_p1(8)=37 'Left
'scan_codes_p1(9)=40 'Down
'scan_codes_p1(10)=39 'Right

redim shared as integer kcs_p1(1 to nok_p1),jcs_p1(1 to 13) 'Player 1 key current state
redim shared as integer kps_p1(1 to nok_p1),jps_p1(1 to 13) 'Player 1 previous key state

redim shared as integer kcs_p2(1 to nok_p2),jcs_p2(1 to 13) 'Player 2 key current state
redim shared as integer kps_p2(1 to nok_p2),jps_p2(1 to 13) 'Player 2 previous key state

dim shared p1kb_sub as any ptr 'pointer to player 1 keyboard motion sub
dim shared p2kb_sub as any ptr 'pointer to player 2 keyboard motion sub 

dim shared as string p1kb_tog,p1j_tog 'Player 1 key was pressed or released Y=On N=Off reset after motion check is performed
p1kb_tog="N"
p1j_tog="N"

dim shared as string p2kb_tog,p2j_tog 'Player 2 key was pressed or released Y=On N=Off reset after motion check is performed
p2kb_tog="N"
p2j_tog="N"
'#####################################################################################################
'mb_keyboard_lib v1.0 routines
declare sub mb_keyboard_buffer_sort(sa() as double,ae() as string)
declare sub mb_player1_motion_check
declare sub mb_player2_motion_check
declare function mb_keyboard_handler ( byval hwnd as HWND, byval uMsg as uinteger, byval wParam as WPARAM, byval lParam as LPARAM ) as integer 
declare sub delim_kb(stringz as string,delims() as string,delimiter as string)
declare sub mb_install_keyboard_handler
declare sub mb_kb_clear_p1
declare sub mb_kb_clear_p2
'#####################################################################################################
'===============================================================================
SUB mb_keyboard_buffer_sort(sa() as double,ae() as string)
'sa()=time stamp array
'ae()=non-redundant key state changes array
'This Sub does a shellsort of data in sa() from least to greatest
'lbound(sa(1))=Least
'ubound(sa(1))=Greatest
     dim as double iNN,iD,iJ,iI,s
     dim as string aee
     
     iNN = 30'Last 30 Keyboard State Changes'Ubound(sa(1))
     iD = 4
     Do While iD < iNN 
          iD = iD + iD
     Loop
     iD = iD - 1
     Do
          iD = iD \ 2
          If iD < 1 Then Exit Do
          For iJ = 1 To iNN - iD
               For iI = iJ To 1 Step -iD
                    If sa(iI + iD) >= sa(iI) Then Exit For
                    
                    s = sa(iI):aee=ae(iI)
                    sa(iI) = sa(iI + iD):ae(iI)=ae(iI + iD)
                    sa(iI + iD) = s:ae(iI + iD)=aee
                    
               Next iI
          Next iJ
     Loop
END SUB 
'===============================================================================
SUB mb_player1_motion_check 
'this is a dummy/place holder sub
'
'empty subroutine that is called by keyboard_handler when a Player 1 key is pressed
'or released
'can be used to call other subroutines to perform things like Hadoken motion checks

'be sure to call mb_keyboard_buffer_sort(sa() as double,ae() as string) 
'to sort the input buffer before checking for motions.

'sleep
'update: due to thread/messaging issues, perform motion checks in main loop
END SUB
'===============================================================================
SUB mb_player2_motion_check 
'this is a dummy/place holder sub
'
'empty subroutine that is called by keyboard_handler when a Player 2 key is pressed
'or released
'can be used to call other subroutines to perform things like Hadoken motion checks

'be sure to call mb_keyboard_buffer_sort(sa() as double,ae() as string) 
'to sort the input buffer before checking for motions.

END SUB
'===============================================================================
SUB delim_kb(stringz as string,delims() as string,delimiter as string)
'Break string into array elements based on delimiter
dim rcc as integer
dim as string z,z2
rcc=0
z2=""
dim nam as long
for nam=1 to len(stringz)
    z=mid(stringz,nam,1)
    if z=delimiter then 
        rcc=rcc+1 
    delims(rcc)=z2
    z2=""
    else
        z2=z2+z
    end if
next
if len(z2)>=1 then rcc=rcc+1:delims(rcc)=z2
END SUB 
'===============================================================================
FUNCTION mb_keyboard_handler ( byval hwnd as HWND, byval uMsg as uinteger, byval wParam as WPARAM, byval lParam as LPARAM ) as integer
dim as double t
dim as integer i,i2,csc,csc2,x,y,dv
dim as string p1orp2


p1orp2=""
    select case uMsg

       case WM_KEYDOWN
        

        csc=(wParam and &hff)
        
                
        keyboard_lkp=str(csc)
        keyboard_lks="U"
        
        for i=1 to nok_p1
         if csc=scan_codes_p1(i) then p1orp2="P1":p1kb_tog="Y":last_evt_p1="K": exit for
        next
        for i=1 to nok_p2
         if csc=scan_codes_p2(i) then p1orp2="P2":p2kb_tog="Y":last_evt_p2="K": exit for
        next
        
        select case p1orp2
        case "P1"
         for i=1 to nok_p1
         if csc=scan_codes_p1(i) then 
         kps_p1(i)=kcs_p1(i)
         kcs_p1(i)=1
         if kbls_p1=str(scan_codes_p1(i))+"D" then
         else
         t=timer
         kbls_p1=str(scan_codes_p1(i))+"D"
         kb_p1(ibuff_p1_c)=kbls_p1
         kts_p1(ibuff_p1_c)=t'timer
         ibuff_p1_c=ibuff_p1_c+1
         if ibuff_p1_c>30 then ibuff_p1_c=1
         tts_d_p1(i)=t
         time_stamp_down_p1(i)=t
         time_stamp_kp1(i)=t
         end if
         end if

         next
         
         case "P2"
         for i=1 to nok_p2
         if csc=scan_codes_p2(i) then 
         kps_p2(i)=kcs_p2(i)
         kcs_p2(i)=1
         if kbls_p2=str(scan_codes_p2(i))+"D" then
         else
         t=timer
         kbls_p2=str(scan_codes_p2(i))+"D"
         kb_p2(ibuff_p2_c)=kbls_p2
         kts_p2(ibuff_p2_c)=t'timer
         ibuff_p2_c=ibuff_p2_c+1
         if ibuff_p2_c>30 then ibuff_p2_c=1
         tts_d_p2(i)=t
         time_stamp_down_p2(i)=t
         time_stamp_kp2(i)=t
         end if
         end if

         next
         
         end select
     case WM_KEYUP
     

        csc=(wParam and &hff)
        
               
        keyboard_lkp=str(csc)
        keyboard_lks="D"
        
        for i=1 to nok_p1
         if csc=scan_codes_p1(i) then p1orp2="P1":last_evt_p1="K": exit for
        next
        for i=1 to nok_p2
         if csc=scan_codes_p2(i) then p1orp2="P2":last_evt_p2="K": exit for
        next
        
        select case p1orp2
        case "P1"
         for i=1 to nok_p1
         if csc=scan_codes_p1(i) then 
         kps_p1(i)=kcs_p1(i)
         kcs_p1(i)=0
         if kbls_p1=str(scan_codes_p1(i))+"U" then
         else
         t=timer
         kbls_p1=str(scan_codes_p1(i))+"U"
         kb_p1(ibuff_p1_c)=kbls_p1
         kts_p1(ibuff_p1_c)=t'timer
         ibuff_p1_c=ibuff_p1_c+1
         if ibuff_p1_c>30 then ibuff_p1_c=1
         tts_u_p1(i)=t-tts_d_p1(i)
         time_stamp_up_p1(i)=t
         time_stamp_kp1(i)=t
         end if
         end if
         next
         
         case "P2"
         for i=1 to nok_p2
         if csc=scan_codes_p2(i) then 
         kps_p2(i)=kcs_p2(i)
         kcs_p2(i)=0
         if kbls_p2=str(scan_codes_p2(i))+"U" then
         else
         t=timer
         kbls_p2=str(scan_codes_p2(i))+"U"
         kb_p2(ibuff_p2_c)=kbls_p2
         kts_p2(ibuff_p2_c)=t'timer
         ibuff_p2_c=ibuff_p2_c+1
         if ibuff_p2_c>30 then ibuff_p2_c=1
         tts_u_p2(i)=t-tts_d_p2(i)
         time_stamp_up_p2(i)=t
         time_stamp_kp2(i)=t
         end if
         end if

         next
         
         end select

      'case WM_CLOSE

       ' joyReleaseCapture( JOYSTICKID1 ) 
       ' joyReleaseCapture( JOYSTICKID2 ) 
        'PostQuitMessage( null )


      end select
   





    return CallWindowProc( cast(WNDPROC,g_pFBGfxWindowProc),hWnd, uMsg, wParam, lParam )
END FUNCTION
'===============================================================================
SUB mb_install_keyboard_handler
'Before calling this routine make sure the screen resolution has been set
'Call this Sub 1st before any other keyboard routines    
dim as integer i
dim as double t


ScreenControl( FB.GET_WINDOW_HANDLE, hwndFbgfx )
g_pFBGfxWindowProc = SetWindowLongPtr( cast(HWND,hwndFbgfx), GWLP_WNDPROC, cast(LONG,@mb_keyboard_handler) )


t=timer

'0=Key Up 1=Key Down
for i=1 to nok_p1
kcs_p1(i)=0   
time_stamp_kp1(i)=t 'initialize all keys with same time stamp
next    
for i=1 to nok_p2
kcs_p2(i)=0    
time_stamp_kp2(i)=t 'initialize all keys with same time stamp
next

'Keybd_event VK_M,0,0,0
'Keybd_event VK_M,0,KEYEVENTF_KEYUP,0
'p1kb_sub=@mb_player1_motion_check
'p2kb_sub=@mb_player2_motion_check
END SUB    
'===============================================================================
SUB mb_kb_clear_p1
'clear Player 1's keyboard buffer
dim as integer i
ibuff_p1_c=1
for i=1 to 30
kb_p1(i)=""
kts_p1(i)=0
time_stamp_up_p1(i)=0
time_stamp_down_p1(i)=0
time_stamp_kp1(i)=0
next
END SUB
'===============================================================================
SUB mb_kb_clear_p2
'clear Player 2's keyboard buffer
dim as integer i
ibuff_p2_c=1
for i=1 to 30
kb_p2(i)=""
kts_p2(i)=0
time_stamp_up_p2(i)=0
time_stamp_down_p2(i)=0
time_stamp_kp2(i)=0
next
END SUB
'===============================================================================
