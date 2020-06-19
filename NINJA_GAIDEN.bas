randomize timer 'seed the random number generator

dim shared P1_facing as string

dim shared cur_w as integer
dim shared cur_xwidth(1 to 100) as integer
dim shared cur_xwi as integer
dim shared cur_pxwidth(1 to 100) as integer
dim shared cur_pxwi as integer
dim shared P1_state as string
dim full_screen as string

#include once "mb_gamedev_lib1.bi"
#include once "mb_sound_lib2.bi"
#include once "mb_accurate_timing_lib.bi"
#include once "mb_keyboard_lib_zero2.bi"


dim shared ground as integer
dim shared ground2 as integer

TYPE OBJXY
x(1 to 100) as integer
y(1 to 100) as integer
x1 as integer 
y1 as integer
x2 as integer
y2 as integer
ac as integer '1=Active for Collisions
cf as integer 'Current Frame
noc as integer 'number of coordinate pairs
t as integer 'Type 0=ground 1=ground object that can be stood on top of after jumping 
ui as string 'Unique ID
od as string 'object description
ot as string 'object type
fd as string 'further data
END TYPE    
    
dim shared obj_data(1 to 100) as OBJXY    
'===============================================================================
SUB MAKE_OBJ_COLLISION_DATA(x as integer,y as integer,obj as OBJXY,oname as string,ui as string)
dim sx as integer
dim sy as integer
dim i as integer
dim xx as integer
dim yy as integer
obj.ot=oname
obj.ui=ui
select case oname
case "BEER"
obj.x1=x+12
obj.y1=y
obj.x2=x+59
obj.y2=y+123
'23 123
obj.ac=1
sx=x+12
sy=y+102
obj.x(1)=sx
obj.y(1)=sy
xx=sx
yy=sy
obj.noc=1
for i=2 to 20 'front of beer sign
xx=xx+1
yy=yy+1
obj.x(i)=xx
obj.y(i)=yy
obj.noc=obj.noc+1
next

for i=21 to 35 'bottom of beer sign
xx=xx+1
obj.x(i)=xx
obj.y(i)=yy
obj.noc=obj.noc+1
next

for i=36 to 54 'back of beer sign
xx=xx-1
yy=yy-1
obj.x(i)=xx
obj.y(i)=yy
obj.noc=obj.noc+1
next

for i=55 to 70 'up part of beer sign on ground
xx=xx-1    
obj.x(i)=xx
obj.y(i)=yy
obj.noc=obj.noc+1
next
end select    
END SUB    
'===============================================================================
FUNCTION CHECK_OBJ_COLLISION(nx as integer,ny as integer) as integer
CHECK_OBJ_COLLISION=0
dim i as integer
dim oi as integer
for oi=1 to 100
if obj_data(oi).ac=1 then    
for i=1 to obj_data(oi).noc
if ny=obj_data(oi).y(i) then
    if nx=obj_data(oi).x(i) then
        CHECK_OBJ_COLLISION=1:exit function
    end if
end if
next
end if
next
END FUNCTION
'===============================================================================

P1_facing="RIGHT" 

full_screen="NO" 'Yes or NO

color 10,0
dim ifs as string
input "Fullscreen Y/N ? ",ifs

select case ucase(ifs)
case "Y"
full_screen="YES"
case else
full_screen="NO"
end select



if full_screen="YES" then
'640x480 resolution with 32 bit color Fullscreen    
SET_FULLSCREEN 640,480,32, "Ninja Gaiden Arcade Sprite Priority by Matt B." 
else    
'640x480 resolution with 32 bit color in Window
SET_SCREEN 640,480,32, "Ninja Gaiden Arcade Sprite Priority by Matt B." 
end if


mb_install_keyboard_handler 'this installs the keyboard handler, always call it AFTER setting the screen resolution



prepare_sound 'prepare sound library routines


'===============================================================================
'Matt's World Intro
dim as integer hWave2(4),sound2(4)
LOAD_MP3_TO_MEM "data/MW_1.mp3",hWave2(0),sound2(0),@sound2(0)
LOAD_MP3_TO_MEM "data/MW_2.mp3",hWave2(1),sound2(1),@sound2(1)
LOAD_MP3_TO_MEM "data/MW_4.mp3",hWave2(2),sound2(2),@sound2(2)
LOAD_MP3_TO_MEM "data/MW_5.mp3",hWave2(3),sound2(3),@sound2(3)
matt_no_sekai_intro2 sound2(0),sound2(1),sound2(2),sound2(3)
'===============================================================================



dim bufferz3 As Any Ptr = ImageCreate( 640, 480, RGB(0, 0, 0) ) 
dim bufferz4 As Any Ptr = ImageCreate( 640, 480, RGB(0, 0, 0) )
dim imagez3 as Any Ptr = ImageCreate(190, 37, RGB(0, 0, 0) )
LOAD_IMAGE imagez3,"data/Press_Enter1.bmp" 

dim tt as double
tt=timer
dim se as string
se="Y"
dim r as integer
dim r2 as integer
r=255
dim tt2 as double
tt2=timer
dim cld as string
cld="D"
cls
draw string (110,10),"{NINJA GAIDEN ARCADE SPRITE PRIORITY DEMO by Matt B}",RGB(0,r,0)
draw string (30,40),"This demo recreates similar sprite priority found in the original 1988",RGB(0,r,0)
draw string (30,50),"Arcade Game from Tecmo. In the arcade game, sprites are drawn with",RGB(0,r,0)
draw string (30,60),"hardware and not in software. This is common for arcade hardware from",RGB(0,r,0)
draw string (30,70),"the 80s and 90s. After looking at the MAME driver I am still not totally",RGB(0,r,0)
draw string (30,80),"clear on how this works. The video driver shows pixels being blended and",RGB(0,r,0)
draw string (30,90),"mentions priority masks, but I found nothing I could use",RGB(0,r,0)
draw string (30,100),"so I had to start from scratch.",RGB(0,r,0)
draw string (30,120),"My Sprite Sort Priority routines do the following in this order:",RGB(0,r,0)
draw string (30,130),"On the X axis the priority is Right to Left. I sort all X coords first.",RGB(0,r,0)
draw string (30,140),"So, the lower the X value the HIGHER the priority.",RGB(0,r,0)
draw string (30,150),"On the Y axis the priority is Top to Bottom. I sort all Y coords second.",RGB(0,r,0)
draw string (30,160),"So, the higher the Y value the HIGHER the prority.",RGB(0,r,0)
draw string (30,170),"Each object has a Y width/height value. This acts as a Z axis.",RGB(0,r,0)
draw string (30,180),"Any intersections here are swapped based on X axis priority.",RGB(0,r,0)
draw string (20,210),"S=Attack D=Flip UP+D=Jump into background DOWN+D=Jump toward screen ESC=Exit",RGB(0,r,0)
draw string (20,240),"Collision Detection only works when on the ground.",RGB(0,r,0)
draw string (20,250),"TODO:Add the ability to jump on objects & mid-air collision detection.",RGB(0,r,0)
dim shared as integer hWave1(9),sound1(9)
LOAD_MP3_TO_MEM "data/Sonatine.mp3",hWave1(4),sound1(4),@sound1(4)
PLAY_SOUND sound1(4)
LOAD_MP3_TO_MEM "data/JUMPING_SOUND_NG.mp3",hWave1(0),sound1(0),@sound1(0)
LOAD_MP3_TO_MEM "data/NG_ATTACK1.mp3",hWave1(1),sound1(1),@sound1(1)
LOAD_MP3_TO_MEM "data/BREAKING_GLASS_NG.mp3",hWave1(2),sound1(2),@sound1(2)
LOAD_MP3_TO_MEM "data/STAGE_1_NG.mp3",hWave1(3),sound1(3),@sound1(3)
LOAD_MP3_TO_MEM "data/NG_Coin.mp3",hWave1(5),sound1(5),@sound1(5)

do
draw string bufferz3,(110,10),"{NINJA GAIDEN ARCADE SPRITE PRIORITY DEMO by Matt B}",RGB(0,r,0)
draw string bufferz3,(30,40),"This demo recreates similar sprite priority found in the original 1988",RGB(0,r,0)
draw string bufferz3,(30,50),"Arcade Game from Tecmo. In the arcade game, sprites are drawn with",RGB(0,r,0)
draw string bufferz3,(30,60),"hardware and not in software. This is common for arcade hardware from",RGB(0,r,0)
draw string bufferz3,(30,70),"the 80s and 90s. After looking at the MAME driver I am still not totally",RGB(0,r,0)
draw string bufferz3,(30,80),"clear on how this works. The video driver shows pixels being blended and",RGB(0,r,0)
draw string bufferz3,(30,90),"mentions priority masks, but I found nothing I could use",RGB(0,r,0)
draw string bufferz3,(30,100),"so I had to start from scratch.",RGB(0,r,0)
draw string bufferz3,(30,120),"My Sprite Sort Priority routines do the following in this order:",RGB(0,r,0)
draw string bufferz3,(30,130),"On the X axis the priority is Right to Left. I sort all X coords first.",RGB(0,r,0)
draw string bufferz3,(30,140),"So, the lower the X value the HIGHER the priority.",RGB(0,r,0)
draw string bufferz3,(30,150),"On the Y axis the priority is Top to Bottom. I sort all Y coords second.",RGB(0,r,0)
draw string bufferz3,(30,160),"So, the higher the Y value the HIGHER the prority.",RGB(0,r,0)
draw string bufferz3,(30,170),"Each object has a Y width/height value. This acts as a Z axis.",RGB(0,r,0)
draw string bufferz3,(30,180),"Any intersections here are swapped based on X axis priority.",RGB(0,r,0)
draw string bufferz3,(20,210),"S=Attack D=Flip UP+D=Jump into background DOWN+D=Jump toward screen ESC=Exit",RGB(0,r,0)
draw string bufferz3,(20,240),"Collision Detection only works when on the ground.",RGB(0,r,0)
draw string bufferz3,(20,250),"TODO:Add the ability to jump on objects & mid-air collision detection.",RGB(0,r,0)

if timer-tt2>.005 then
if cld="D" then
r=r-1
if r<=40 then cld="U"
end if
if cld="U" then
r=r+1
if r>=255 then cld="D":r=255
end if

tt2=timer
end if

put bufferz4,(0,0),bufferz3,PSET    
if se="Y" then put bufferz4,(200,280),imagez3,PSET
if timer-tt>.5 then
if se="Y" then
    se="N"
else
    se="Y"
end if


tt=timer
end if

put (0,0),bufferz4,PSET
if IS_PLAYING(sound1(4))="NO" then
PLAY_SOUND sound1(4)    
end if 
loop until inkey=chr(13) 'Loop until Enter is pressed 
STOP_SOUND sound1(4)
PLAY_SOUND_MC sound1(5)
tt=timer
do
loop until (timer-tt)>=2    
PLAY_SOUND sound1(3)
'===============================================================================



Dim buffer1 As Any Ptr = ImageCreate( 640, 480, RGB(0, 0, 0) ) 'KOF 96 color 1 28 255 'SS2 color 9 60 53 & 204 228 173


Dim toscreen As Any Ptr = ImageCreate( 640, 480, RGB(0, 0, 0) )
'===============================================================================
'Background Graphics
dim biru as sprite
LOAD_SPRITE biru,"data/NG_Biru2.bmp" 'Beer Sign

dim ninja1 as sprite

'===============================================================================
'Load Ninja Animation Frames
dim ninja_animation_pointers(1 to 68) as any ptr
dim ninja_xwa(1 to 68) as integer

dim ninja_standing(1 to 1) as sprite
LOAD_SPRITE ninja_standing(1),"data/NG_Standing2.bmp"
ninja_animation_pointers(1)=ninja_standing(1).spritebuf
dim ninja_standing_left(1 to 1) as sprite
LOAD_SPRITE_LEFT ninja_standing_left(1),"data/NG_Standing2.bmp"
ninja_animation_pointers(8)=ninja_standing_left(1).spritebuf
ninja_xwa(8)=ninja_standing_left(1).xwidth
dim ninja_run(1 to 6) as sprite
LOAD_SPRITE ninja_run(1),"data/NG_R_1.bmp"
LOAD_SPRITE ninja_run(2),"data/NG_R_2.bmp"
LOAD_SPRITE ninja_run(3),"data/NG_R_3.bmp"
LOAD_SPRITE ninja_run(4),"data/NG_R_4.bmp"
LOAD_SPRITE ninja_run(5),"data/NG_R_5.bmp"
LOAD_SPRITE ninja_run(6),"data/NG_R_6.bmp"
ninja_animation_pointers(2)=ninja_run(1).spritebuf
ninja_animation_pointers(3)=ninja_run(2).spritebuf
ninja_animation_pointers(4)=ninja_run(3).spritebuf
ninja_animation_pointers(5)=ninja_run(4).spritebuf
ninja_animation_pointers(6)=ninja_run(5).spritebuf
ninja_animation_pointers(7)=ninja_run(6).spritebuf

dim ninja_runl(1 to 6) as sprite
LOAD_SPRITE_LEFT ninja_runl(1),"data/NG_R_1.bmp"
LOAD_SPRITE_LEFT ninja_runl(2),"data/NG_R_2.bmp"
LOAD_SPRITE_LEFT ninja_runl(3),"data/NG_R_3.bmp"
LOAD_SPRITE_LEFT ninja_runl(4),"data/NG_R_4.bmp"
LOAD_SPRITE_LEFT ninja_runl(5),"data/NG_R_5.bmp"
LOAD_SPRITE_LEFT ninja_runl(6),"data/NG_R_6.bmp"
ninja_animation_pointers(9)=ninja_runl(1).spritebuf
ninja_animation_pointers(10)=ninja_runl(2).spritebuf
ninja_animation_pointers(11)=ninja_runl(3).spritebuf
ninja_animation_pointers(12)=ninja_runl(4).spritebuf
ninja_animation_pointers(13)=ninja_runl(5).spritebuf
ninja_animation_pointers(14)=ninja_runl(6).spritebuf

ninja_xwa(9)=ninja_runl(1).xwidth
ninja_xwa(10)=ninja_runl(2).xwidth
ninja_xwa(11)=ninja_runl(3).xwidth
ninja_xwa(12)=ninja_runl(4).xwidth
ninja_xwa(13)=ninja_runl(5).xwidth
ninja_xwa(14)=ninja_runl(6).xwidth
dim ninja_walk(1 to 6) as sprite
LOAD_SPRITE ninja_walk(1),"data/NG_W_1.bmp"
LOAD_SPRITE ninja_walk(2),"data/NG_W_2.bmp"
LOAD_SPRITE ninja_walk(3),"data/NG_W_3.bmp"
LOAD_SPRITE ninja_walk(4),"data/NG_W_4.bmp"
LOAD_SPRITE ninja_walk(5),"data/NG_W_5.bmp"
LOAD_SPRITE ninja_walk(6),"data/NG_W_6.bmp"
ninja_animation_pointers(15)=ninja_walk(1).spritebuf
ninja_animation_pointers(16)=ninja_walk(2).spritebuf
ninja_animation_pointers(17)=ninja_walk(3).spritebuf
ninja_animation_pointers(18)=ninja_walk(4).spritebuf
ninja_animation_pointers(19)=ninja_walk(5).spritebuf
ninja_animation_pointers(20)=ninja_walk(6).spritebuf
dim ninja_walkl(1 to 6) as sprite
LOAD_SPRITE_LEFT ninja_walkl(1),"data/NG_W_1.bmp"
LOAD_SPRITE_LEFT ninja_walkl(2),"data/NG_W_2.bmp"
LOAD_SPRITE_LEFT ninja_walkl(3),"data/NG_W_3.bmp"
LOAD_SPRITE_LEFT ninja_walkl(4),"data/NG_W_4.bmp"
LOAD_SPRITE_LEFT ninja_walkl(5),"data/NG_W_5.bmp"
LOAD_SPRITE_LEFT ninja_walkl(6),"data/NG_W_6.bmp"
ninja_animation_pointers(21)=ninja_walkl(1).spritebuf
ninja_animation_pointers(22)=ninja_walkl(2).spritebuf
ninja_animation_pointers(23)=ninja_walkl(3).spritebuf
ninja_animation_pointers(24)=ninja_walkl(4).spritebuf
ninja_animation_pointers(25)=ninja_walkl(5).spritebuf
ninja_animation_pointers(26)=ninja_walkl(6).spritebuf
ninja_xwa(21)=ninja_walkl(1).xwidth
ninja_xwa(22)=ninja_walkl(2).xwidth
ninja_xwa(23)=ninja_walkl(3).xwidth
ninja_xwa(24)=ninja_walkl(4).xwidth
ninja_xwa(25)=ninja_walkl(5).xwidth
ninja_xwa(26)=ninja_walkl(6).xwidth
dim ninja_jumpf(1 to 7) as sprite
LOAD_SPRITE ninja_jumpf(1),"data/NG_JF_1.bmp"
LOAD_SPRITE ninja_jumpf(2),"data/NG_JF_2.bmp"
LOAD_SPRITE ninja_jumpf(3),"data/NG_JF_3.bmp"
LOAD_SPRITE ninja_jumpf(4),"data/NG_JF_4.bmp"
LOAD_SPRITE ninja_jumpf(5),"data/NG_JF_5.bmp"
LOAD_SPRITE ninja_jumpf(6),"data/NG_JF_6.bmp"
LOAD_SPRITE ninja_jumpf(7),"data/NG_JF_7.bmp"
ninja_animation_pointers(27)=ninja_jumpf(1).spritebuf
ninja_animation_pointers(28)=ninja_jumpf(2).spritebuf
ninja_animation_pointers(29)=ninja_jumpf(3).spritebuf
ninja_animation_pointers(30)=ninja_jumpf(4).spritebuf
ninja_animation_pointers(31)=ninja_jumpf(5).spritebuf
ninja_animation_pointers(32)=ninja_jumpf(6).spritebuf
ninja_animation_pointers(33)=ninja_jumpf(7).spritebuf
dim ninja_jumpfl(1 to 7) as sprite
LOAD_SPRITE_LEFT ninja_jumpfl(1),"data/NG_JF_1.bmp"
LOAD_SPRITE_LEFT ninja_jumpfl(2),"data/NG_JF_2.bmp"
LOAD_SPRITE_LEFT ninja_jumpfl(3),"data/NG_JF_3.bmp"
LOAD_SPRITE_LEFT ninja_jumpfl(4),"data/NG_JF_4.bmp"
LOAD_SPRITE_LEFT ninja_jumpfl(5),"data/NG_JF_5.bmp"
LOAD_SPRITE_LEFT ninja_jumpfl(6),"data/NG_JF_6.bmp"
LOAD_SPRITE_LEFT ninja_jumpfl(7),"data/NG_JF_7.bmp"
ninja_animation_pointers(34)=ninja_jumpfl(1).spritebuf
ninja_animation_pointers(35)=ninja_jumpfl(2).spritebuf
ninja_animation_pointers(36)=ninja_jumpfl(3).spritebuf
ninja_animation_pointers(37)=ninja_jumpfl(4).spritebuf
ninja_animation_pointers(38)=ninja_jumpfl(5).spritebuf
ninja_animation_pointers(39)=ninja_jumpfl(6).spritebuf
ninja_animation_pointers(40)=ninja_jumpfl(7).spritebuf
ninja_xwa(34)=ninja_jumpfl(1).xwidth
ninja_xwa(35)=ninja_jumpfl(2).xwidth
ninja_xwa(36)=ninja_jumpfl(3).xwidth
ninja_xwa(37)=ninja_jumpfl(4).xwidth
ninja_xwa(38)=ninja_jumpfl(5).xwidth
ninja_xwa(39)=ninja_jumpfl(6).xwidth
ninja_xwa(40)=ninja_jumpfl(7).xwidth
dim ninja_jump(1 to 2) as sprite
LOAD_SPRITE ninja_jump(1),"data/NG_J_1.bmp"
LOAD_SPRITE ninja_jump(2),"data/NG_J_2.bmp"
ninja_animation_pointers(41)=ninja_jump(1).spritebuf
ninja_animation_pointers(42)=ninja_jump(2).spritebuf
dim ninja_jumpl(1 to 2) as sprite
LOAD_SPRITE_LEFT ninja_jumpl(1),"data/NG_J_1.bmp"
LOAD_SPRITE_LEFT ninja_jumpl(2),"data/NG_J_2.bmp"
ninja_animation_pointers(43)=ninja_jumpl(1).spritebuf
ninja_animation_pointers(44)=ninja_jumpl(2).spritebuf
ninja_xwa(43)=ninja_jumpl(1).xwidth
ninja_xwa(44)=ninja_jumpl(2).xwidth
dim ninja_pk(1 to 12) as sprite
LOAD_SPRITE ninja_pk(1),"data/NG_PK_1.bmp"
LOAD_SPRITE ninja_pk(2),"data/NG_PK_2.bmp"
LOAD_SPRITE ninja_pk(3),"data/NG_PK_3.bmp"
LOAD_SPRITE ninja_pk(4),"data/NG_PK_4.bmp"
LOAD_SPRITE ninja_pk(5),"data/NG_PK_5.bmp"
LOAD_SPRITE ninja_pk(6),"data/NG_PK_6.bmp"
LOAD_SPRITE ninja_pk(7),"data/NG_PK_7.bmp"
LOAD_SPRITE ninja_pk(8),"data/NG_PK_8.bmp"
LOAD_SPRITE ninja_pk(9),"data/NG_PK_9.bmp"
LOAD_SPRITE ninja_pk(10),"data/NG_PK_10.bmp"
LOAD_SPRITE ninja_pk(11),"data/NG_PK_11.bmp"
LOAD_SPRITE ninja_pk(12),"data/NG_PK_12.bmp"
ninja_animation_pointers(45)=ninja_pk(1).spritebuf
ninja_animation_pointers(46)=ninja_pk(2).spritebuf
ninja_animation_pointers(47)=ninja_pk(3).spritebuf
ninja_animation_pointers(48)=ninja_pk(4).spritebuf
ninja_animation_pointers(49)=ninja_pk(5).spritebuf
ninja_animation_pointers(50)=ninja_pk(6).spritebuf
ninja_animation_pointers(51)=ninja_pk(7).spritebuf
ninja_animation_pointers(52)=ninja_pk(8).spritebuf
ninja_animation_pointers(53)=ninja_pk(9).spritebuf
ninja_animation_pointers(54)=ninja_pk(10).spritebuf
ninja_animation_pointers(55)=ninja_pk(11).spritebuf
ninja_animation_pointers(56)=ninja_pk(12).spritebuf
dim ninja_pkl(1 to 12) as sprite
LOAD_SPRITE_LEFT ninja_pkl(1),"data/NG_PK_1.bmp"
LOAD_SPRITE_LEFT ninja_pkl(2),"data/NG_PK_2.bmp"
LOAD_SPRITE_LEFT ninja_pkl(3),"data/NG_PK_3.bmp"
LOAD_SPRITE_LEFT ninja_pkl(4),"data/NG_PK_4.bmp"
LOAD_SPRITE_LEFT ninja_pkl(5),"data/NG_PK_5.bmp"
LOAD_SPRITE_LEFT ninja_pkl(6),"data/NG_PK_6.bmp"
LOAD_SPRITE_LEFT ninja_pkl(7),"data/NG_PK_7.bmp"
LOAD_SPRITE_LEFT ninja_pkl(8),"data/NG_PK_8.bmp"
LOAD_SPRITE_LEFT ninja_pkl(9),"data/NG_PK_9.bmp"
LOAD_SPRITE_LEFT ninja_pkl(10),"data/NG_PK_10.bmp"
LOAD_SPRITE_LEFT ninja_pkl(11),"data/NG_PK_11.bmp"
LOAD_SPRITE_LEFT ninja_pkl(12),"data/NG_PK_12.bmp"
ninja_animation_pointers(57)=ninja_pkl(1).spritebuf
ninja_animation_pointers(58)=ninja_pkl(2).spritebuf
ninja_animation_pointers(59)=ninja_pkl(3).spritebuf
ninja_animation_pointers(60)=ninja_pkl(4).spritebuf
ninja_animation_pointers(61)=ninja_pkl(5).spritebuf
ninja_animation_pointers(62)=ninja_pkl(6).spritebuf
ninja_animation_pointers(63)=ninja_pkl(7).spritebuf
ninja_animation_pointers(64)=ninja_pkl(8).spritebuf
ninja_animation_pointers(65)=ninja_pkl(9).spritebuf
ninja_animation_pointers(66)=ninja_pkl(10).spritebuf
ninja_animation_pointers(67)=ninja_pkl(11).spritebuf
ninja_animation_pointers(68)=ninja_pkl(12).spritebuf
ninja_xwa(57)=ninja_pkl(1).xwidth
ninja_xwa(58)=ninja_pkl(2).xwidth
ninja_xwa(59)=ninja_pkl(3).xwidth
ninja_xwa(60)=ninja_pkl(4).xwidth
ninja_xwa(61)=ninja_pkl(5).xwidth
ninja_xwa(62)=ninja_pkl(6).xwidth
ninja_xwa(63)=ninja_pkl(7).xwidth
ninja_xwa(64)=ninja_pkl(8).xwidth
ninja_xwa(65)=ninja_pkl(9).xwidth
ninja_xwa(66)=ninja_pkl(10).xwidth
ninja_xwa(67)=ninja_pkl(11).xwidth
ninja_xwa(68)=ninja_pkl(12).xwidth
'===============================================================================
SUB GET_AP_NINJA(byref current_state1 as string,byref current_frame1 as integer,byref cur_ani1 as any ptr,naa() as any ptr,naw() as integer)
'Return a pointer to the current frame of animation for main character/Ninja
if P1_facing="RIGHT" then
select case current_state1
case "STANDING"
cur_ani1=naa(1)
case "RUNNING","RUNDU","RUNDD"
if current_frame1=1 then cur_ani1=naa(2)
if current_frame1=2 then cur_ani1=naa(3)
if current_frame1=3 then cur_ani1=naa(4)
if current_frame1=4 then cur_ani1=naa(5)
if current_frame1=5 then cur_ani1=naa(6)
if current_frame1=6 then cur_ani1=naa(7)
case "WALKUP","WALKDOWN"
if current_frame1=1 then cur_ani1=naa(15)
if current_frame1=2 then cur_ani1=naa(16)
if current_frame1=3 then cur_ani1=naa(17)
if current_frame1=4 then cur_ani1=naa(18)
if current_frame1=5 then cur_ani1=naa(19)
if current_frame1=6 then cur_ani1=naa(20)
case "FORWARD FLIP"
if current_frame1=1 then cur_ani1=naa(27)
if current_frame1=2 then cur_ani1=naa(28)
if current_frame1=3 then cur_ani1=naa(29)
if current_frame1=4 then cur_ani1=naa(30)
if current_frame1=5 then cur_ani1=naa(31)
if current_frame1=6 then cur_ani1=naa(32)
if current_frame1=7 then cur_ani1=naa(33)
case "JUMPZBACK","JUMPZFRONT"
if current_frame1=1 then cur_ani1=naa(41)
if current_frame1=2 then cur_ani1=naa(42) 
case "PUNCH & KICK"
if current_frame1=1 then cur_ani1=naa(45)
if current_frame1=2 then cur_ani1=naa(46)
if current_frame1=3 then cur_ani1=naa(47)
if current_frame1=4 then cur_ani1=naa(48)
if current_frame1=5 then cur_ani1=naa(49)
if current_frame1=6 then cur_ani1=naa(50)
if current_frame1=7 then cur_ani1=naa(51)
if current_frame1=8 then cur_ani1=naa(52)
if current_frame1=9 then cur_ani1=naa(53)
if current_frame1=10 then cur_ani1=naa(54)
if current_frame1=11 then cur_ani1=naa(55)
if current_frame1=12 then cur_ani1=naa(56)
end select
end if

if P1_facing="LEFT" then
select case current_state1
case "STANDING"
cur_ani1=naa(8)
cur_xwidth(1)=naw(8)
case "RUNNING","RUNDU","RUNDD"
if current_frame1=1 then cur_ani1=naa(9):cur_xwidth(1)=naw(9)
if current_frame1=2 then cur_ani1=naa(10):cur_xwidth(2)=naw(10)
if current_frame1=3 then cur_ani1=naa(11):cur_xwidth(3)=naw(11)
if current_frame1=4 then cur_ani1=naa(12):cur_xwidth(4)=naw(12)
if current_frame1=5 then cur_ani1=naa(13):cur_xwidth(5)=naw(13)
if current_frame1=6 then cur_ani1=naa(14):cur_xwidth(6)=naw(14)
case "WALKUP","WALKDOWN"
if current_frame1=1 then cur_ani1=naa(21):cur_xwidth(1)=naw(21)
if current_frame1=2 then cur_ani1=naa(22):cur_xwidth(2)=naw(22)
if current_frame1=3 then cur_ani1=naa(23):cur_xwidth(3)=naw(23)
if current_frame1=4 then cur_ani1=naa(24):cur_xwidth(4)=naw(24)
if current_frame1=5 then cur_ani1=naa(25):cur_xwidth(5)=naw(25)
if current_frame1=6 then cur_ani1=naa(26):cur_xwidth(6)=naw(26)
case "FORWARD FLIP"
if current_frame1=1 then cur_ani1=naa(34):cur_xwidth(1)=naw(34) 
if current_frame1=2 then cur_ani1=naa(35):cur_xwidth(2)=naw(35) 
if current_frame1=3 then cur_ani1=naa(36):cur_xwidth(3)=naw(36) 
if current_frame1=4 then cur_ani1=naa(37):cur_xwidth(4)=naw(37) 
if current_frame1=5 then cur_ani1=naa(38):cur_xwidth(5)=naw(38) 
if current_frame1=6 then cur_ani1=naa(39):cur_xwidth(6)=naw(39) 
if current_frame1=7 then cur_ani1=naa(40):cur_xwidth(7)=naw(40) 
case "JUMPZBACK","JUMPZFRONT"
if current_frame1=1 then cur_ani1=naa(43):cur_xwidth(1)=naw(43)
if current_frame1=2 then cur_ani1=naa(44):cur_xwidth(2)=naw(44) 
case "PUNCH & KICK"
if current_frame1=1 then cur_ani1=naa(57):cur_xwidth(1)=naw(57)
if current_frame1=2 then cur_ani1=naa(58):cur_xwidth(2)=naw(58)
if current_frame1=3 then cur_ani1=naa(59):cur_xwidth(3)=naw(59)
if current_frame1=4 then cur_ani1=naa(60):cur_xwidth(4)=naw(60)
if current_frame1=5 then cur_ani1=naa(61):cur_xwidth(5)=naw(61)
if current_frame1=6 then cur_ani1=naa(62):cur_xwidth(6)=naw(62)
if current_frame1=7 then cur_ani1=naa(63):cur_xwidth(7)=naw(63)
if current_frame1=8 then cur_ani1=naa(64):cur_xwidth(8)=naw(64)
if current_frame1=9 then cur_ani1=naa(65):cur_xwidth(9)=naw(65)
if current_frame1=10 then cur_ani1=naa(66):cur_xwidth(10)=naw(66)
if current_frame1=11 then cur_ani1=naa(67):cur_xwidth(11)=naw(67)
if current_frame1=12 then cur_ani1=naa(68):cur_xwidth(12)=naw(68)
end select
end if



END SUB
'===============================================================================
dim x as integer
dim y as integer
dim cur_ani1 as any ptr
'===============================================================================


nok_p1=15 'A total of 15 keys are active for Player 1 
scan_codes_p1(1)=65 'A
scan_codes_p1(2)=83 'S
scan_codes_p1(3)=68 'D
scan_codes_p1(4)=70 'F  90 Z
scan_codes_p1(5)=88 'X
scan_codes_p1(6)=67 'C
scan_codes_p1(7)=38 'Up
scan_codes_p1(8)=37 'Left
scan_codes_p1(9)=40 'Down
scan_codes_p1(10)=39 'Right

scan_codes_p1(11)=13 'Enter
scan_codes_p1(12)=32 'Space Bar
scan_codes_p1(13)=76 'L
scan_codes_p1(14)=75 'K
scan_codes_p1(15)=27 'ESC

x=100
y=300
'===============================================================================
SUB CONTROL_P1(byref input_state as string,byref input_state2 as string,byref input_state3 as string,byref d_state as string,byref attack as string)
static t as double   
static fp as integer
static as string togk
static as string pk2
static i as integer
static p_keys(1 to 10) as integer 'previously pressed keys



if fp=0 then t=timer
if fp=0 then fp=1

input_state="NOTHING"



'mb_keyboard_buffer_sort kts_p1(),kb_p1() there is no need to sort the keyboard buffer unless motions need to be captured
 

if kcs_p1(1)=1 and p_keys(1)=0 then
p_keys(1)=1
if IS_PLAYING(sound1(2))="NO" then 
PLAY_SOUND sound1(2) 'Breaking Glass Sound
end if
end if

if kcs_p1(1)=0 and p_keys(1)=1 then p_keys(1)=0

if kcs_p1(2)=1 and p_keys(2)=0 then
p_keys(2)=1
input_state="ATTACK"    
input_state2=input_State
exit sub
end if

if kcs_p1(2)=0 and p_keys(2)=1 then p_keys(2)=0:input_state3="ATTACK_RELEASE"

if kcs_p1(3)=1 and p_keys(3)=0 and kcs_p1(7)=1 then 'Jump Back
p_keys(3)=1
input_state="JUMPZBACK"    
input_state2=input_State
exit sub
end if   

if kcs_p1(3)=1 and p_keys(3)=0 and kcs_p1(9)=1 then 'Jump Front/Toward Screen
p_keys(3)=1
input_state="JUMPZFRONT"    
input_state2=input_State
exit sub
end if  

if kcs_p1(3)=0 and p_keys(3)=1 then p_keys(3)=0:input_state3="JUMP_RELEASE"

if kcs_p1(3)=1 and p_keys(3)=0 then 'Pressing D for Jump Forward
p_keys(3)=1
input_state="JUMPF"    
input_state2=input_State
exit sub
end if    




if kcs_p1(7)=1 and kcs_p1(10)=1  then 'Pressing Up and Right 
input_state="UAR"
input_state2=input_state 
if P1_facing="LEFT" then P1_facing="RIGHT"
exit sub
end if

if kcs_p1(9)=1 and kcs_p1(10)=1  then 'Pressing Down and Right 
input_state="DAR"
input_state2=input_state 
if P1_facing="LEFT" then P1_facing="RIGHT"
exit sub
end if

if kcs_p1(7)=1 and kcs_p1(8)=1  then 'Pressing Up and Left 
input_state="UAL"
input_state2=input_state 
if P1_facing="RIGHT" then P1_facing="LEFT"
exit sub
end if

if kcs_p1(9)=1 and kcs_p1(8)=1  then 'Pressing Down and Left 
input_state="DAL"
input_state2=input_state 
if P1_facing="RIGHT" then P1_facing="LEFT"
exit sub
end if
'***************************
if kcs_p1(8)=1  then 'Pressing Left 
input_state="LEFT"
input_state2=input_state 
if P1_facing="RIGHT" then P1_facing="LEFT"
end if

if kcs_p1(10)=1  then 'Pressing Right 
input_state="RIGHT"
input_state2=input_state 
if P1_facing="LEFT" then P1_facing="RIGHT"
end if

if kcs_p1(7)=1  then 'Pressing Up 
input_state="UP"
input_state2=input_state 
end if

if kcs_p1(9)=1  then 'Pressing Down 
input_state="DOWN"
input_state2=input_state 
end if
END SUB
'=============================================================================== 
SUB TRANSLATE_INPUT_TO_CURRENT_STATE(byref current_state1 as string, byref attack as string, byref i_state as string, byref input_state1 as string,byref input_status as string, byref d_state as string,byref d_state2 as string)
'Translates Keyboard Input into Current Animation State
static pk as string 
static pstate as string
pstate=current_state1

if input_status="OFF" then
    if input_state1="ATTACK" and current_state1="PUNCH & KICK" then i_state="ATTACK"
    if input_state1<>"ATTACK" and current_state1="PUNCH & KICK" then i_state="NOTHING"   
    else

select case input_state1
case "RIGHT"
if input_state1="RIGHT" and input_status="ON" then 'Pressing Right 
pk="R"
i_state="RF"
end if    
case "LEFT"
if input_state1="LEFT" and input_status="ON" then 'Pressing Left 
pk="L"
i_state="RL"
end if
case "UP"
if input_state1="UP" and input_status="ON" then 'Pressing Up 
pk="U"
i_state="WALKUP"
end if
case "DOWN"
if input_state1="DOWN" and input_status="ON" then 'Pressing Down 
pk="D"
i_state="WALKDOWN"
end if
case "UAR"
if input_state1="UAR" and input_status="ON" then 'Pressing Up and Right  
pk="D"
i_state="RUNDU"
end if    
case "DAR"
if input_state1="DAR" and input_status="ON" then 'Pressing Down and Right  
pk="D"
i_state="RUNDD"
end if 
case "UAL"
if input_state1="UAL" and input_status="ON" then 'Pressing Up and Left  
pk="D"
i_state="RUNDU"
end if    
case "DAL"
if input_state1="DAL" and input_status="ON" then 'Pressing Down and Left  
pk="D"
i_state="RUNDD"
end if 
case "JUMPF"
if input_state1="JUMPF" and input_status="ON" then
pk="D"
i_state="JUMPF"
input_status="OFF"
end if
case "JUMPZBACK"
if input_state1="JUMPZBACK" and input_status="ON" then
pk="D"
i_state="JUMPZBACK"
input_status="OFF"
end if
case "JUMPZFRONT"  
if input_state1="JUMPZFRONT" and input_status="ON" then
pk="D"
i_state="JUMPZFRONT"
input_status="OFF"
end if    
case "ATTACK"
if input_status="ON" then    
pk="D"
i_state="ATTACK"
input_Status="OFF"
end if
case "NOTHING"
i_state=""    
end select



select case i_state
case "RF" 
current_state1="RUNNING"
i_state="RF"
case "RL" 
current_state1="RUNNING"
i_state="RL"
case "WALKUP"
current_state1="WALKUP"
i_state="WALKUP"
case "WALKDOWN"
current_state1="WALKDOWN"
i_state="WALKDOWN"
case "RUNDD"
current_state1="RUNDD"
i_state="RUNDD"
case "RUNDU"
current_state1="RUNDU"
i_state="RUNDU"
case "JUMPF"
current_state1="FORWARD FLIP"
i_state="JUMPF"
input_status="OFF"
case "JUMPZBACK"
current_state1="JUMPZBACK"

case "JUMPZFRONT"  
current_state1="JUMPZFRONT" 
case "ATTACK"
current_State1="PUNCH & KICK"    
case else
current_state1="STANDING"    
i_state="STANDING"

end select

end if
END SUB
'===============================================================================
SUB MOVE_CHARACTER(byref curx as integer,byref cury as integer,cname as string,current_state as string)
'curx=Current X Coordinate  
'cury=Current Y Coordinate
'cname=Character Name
'current_state=Current Character State

dim i as integer
dim i2 as integer
dim i3 as integer
static hit as integer
dim ox as integer
if current_state="N1" then hit=0:ground2=0

select case cname
case "NINJA"
     select case current_state
     case "RUNNING"
     if P1_facing="RIGHT" then
     curx=curx+1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then curx=curx-1:exit sub
     next
     end if
     if P1_facing="LEFT" then
     curx=curx-1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then curx=curx+1:exit sub
     next
     end if
     case "WALKUP"
     'cury=cury-1
     if P1_facing="RIGHT" then
     cury=cury-1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then cury=cury+1:exit sub
     next
     end if
     if P1_facing="LEFT" then
     cury=cury-1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then cury=cury+1:exit sub
     next
     end if
     case "WALKDOWN" 
     'cury=cury+1
     if P1_facing="RIGHT" then
     cury=cury+1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then cury=cury-1:exit sub
     next
     end if
     if P1_facing="LEFT" then
     cury=cury+1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then cury=cury-1:exit sub
     next
     end if
     case "RUNDU"
     if P1_facing="RIGHT" then
     'curx=curx+1
     'cury=cury-1
     curx=curx+1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then curx=curx-1:exit sub
     next
     cury=cury-1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then cury=cury+1:curx=curx-1:exit sub
     next
     end if
     if P1_facing="LEFT" then
     'curx=curx-1
     'cury=cury-1
     curx=curx-1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then curx=curx+1:exit sub
     next
     cury=cury-1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then cury=cury+1:curx=curx+1:exit sub
     next
     end if
     case "RUNDD"
     if P1_facing="RIGHT" then
     'curx=curx+1
     'cury=cury+1
     curx=curx+1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then curx=curx-1:exit sub
     next
     cury=cury+1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then cury=cury-1:curx=curx-1:exit sub
     next
     'end if
     end if
     if P1_facing="LEFT" then
     'curx=curx-1
     'cury=cury+1
     curx=curx-1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then curx=curx+1:exit sub
     next
     cury=cury+1
     for i=curx+4 to curx+51
     if CHECK_OBJ_COLLISION(i,cury+85)=1 then cury=cury-1:curx=curx+1:exit sub
     next
     end if
     
     'end if
     case "N1"
     if P1_facing="RIGHT" then
     end if
     if P1_facing="LEFT" then
     end if
     case "N2"
     if P1_facing="RIGHT" then
     'curx=curx+2
     cury=cury-10
     end if
     if P1_facing="LEFT" then
     'curx=curx-2
     cury=cury-10    
     end if
     case "N3","N4"
     if P1_facing="RIGHT" then
     curx=curx+2
     cury=cury-2
     'future code to handle forward flips onto objects
     'ox=curx
     ' for i2=1 to 100
     '     if obj_data(i2).ac=1 then
     'i3=curx
     'if hit>0 then exit for
     'for i=i3 to i3+2
      '       curx=curx+1
    'if COLLISION(i,cury-85,i+63,cury+85,obj_data(i2).x1,obj_data(i2).y1,obj_data(i2).x2,obj_data(i2).y2)=1 then 
    '    curx=curx-1
    'if current_state="N4" then hit=i2
    'end if
     'next
      '   end if
    ' next
     'if hit=0 then ox=ox+2:curx=ox
     'cury=cury-2
     end if
     if P1_facing="LEFT" then
     curx=curx-2
     cury=cury-2    
     
     end if
     case "N5","N6"
      if P1_facing="RIGHT" then
     curx=curx+2
     cury=cury+4
     if hit>0 and cury>(obj_data(hit).y1+30) then cury=(obj_data(hit).y1+29):ground2=(obj_data(hit).y1+29) 
     if hit>0 then curx=obj_data(hit).x1
     end if
     if P1_facing="LEFT" then
     curx=curx-2
     cury=cury+4    
     end if
    
     end select
end select 
END SUB    
'===============================================================================
SUB NINJA_STANDING1(byref rx as integer,byref ry as integer,byref pstate as string,byref i_state as string,byref current_state1 as string,byref current_frame1 as integer,byref d_state as string,byref input_status as string)
current_frame1=1
CURRENT_STATE1="STANDING"
END SUB
'===============================================================================
SUB NINJA_RUNNING(byref rx as integer,byref ry as integer,byref pstate as string,byref i_state as string,byref current_state1 as string,byref current_frame1 as integer,byref d_state as string,byref input_status as string)
 
static fp as integer
if input_status="ON" and mid(i_state,1,1)="R" then
else
fp=0
exit sub
end if
   

static t as double  
static t2 as double 
static current_frame2 as integer
static frame_count as integer
dim frame_delays(1 to 6) as double

frame_delays(1)=.1
frame_delays(2)=.1
frame_delays(3)=.1
frame_delays(4)=.1
frame_delays(5)=.1
frame_delays(6)=.1

if fp=0 then
fp=1
t=timer
t2=timer
frame_count=6
current_frame2=1
end if

if (timer-t2)>=.006 then
t2=timer    

if current_state1="RUNNING" then
MOVE_CHARACTER rx,ry,"NINJA","RUNNING"
end if

if current_state1="RUNDD" then
MOVE_CHARACTER rx,ry,"NINJA","RUNDD"
end if

if current_state1="RUNDU" then
MOVE_CHARACTER rx,ry,"NINJA","RUNDU"
end if


if (timer-t)>=frame_delays(current_frame2) then
t=timer
current_frame2=current_frame2+1
if current_frame2>frame_count then 
current_frame2=1 
fp=0
  
end if 
end if
current_frame1=current_frame2
end if
END SUB   
'===============================================================================
SUB NINJA_WALKING(byref rx as integer,byref ry as integer,byref pstate as string,byref i_state as string,byref current_state1 as string,byref current_frame1 as integer,byref d_state as string,byref input_status as string)
 
static fp as integer
if input_status="ON" and mid(i_state,1,1)="W" then
else
fp=0
exit sub
end if



static t as double  
static t2 as double 
static current_frame2 as integer
static frame_count as integer
dim frame_delays(1 to 6) as double

frame_delays(1)=.2
frame_delays(2)=.2
frame_delays(3)=.2
frame_delays(4)=.2
frame_delays(5)=.2
frame_delays(6)=.2

if fp=0 then
fp=1    
t=timer
t2=timer
frame_count=6
current_frame2=1
end if

if (timer-t2)>=.03 then
t2=timer    

if current_state1="WALKUP" then
MOVE_CHARACTER rx,ry,"NINJA","WALKUP"
end if

if current_state1="WALKDOWN" then
MOVE_CHARACTER rx,ry,"NINJA","WALKDOWN"
end if

if (timer-t)>=frame_delays(current_frame2) then
t=timer
current_frame2=current_frame2+1
if current_frame2>frame_count then 
fp=0
current_frame2=1 
   
end if 
end if
current_frame1=current_frame2
end if
END SUB   
'===============================================================================
SUB NINJA_FLIP(byref rx as integer,byref ry as integer,byref pstate as string,byref i_state as string,byref current_state1 as string,byref current_frame1 as integer,byref d_state as string,byref input_status as string)
static fp as integer
if input_status="OFF" and current_state1="FORWARD FLIP" then
else
fp=0
exit sub
end if


static t as double  
static t2 as double 
static current_frame2 as integer
static frame_count as integer
dim frame_delays(1 to 7) as double

frame_delays(1)=.1
frame_delays(2)=.1
frame_delays(3)=.1
frame_delays(4)=.15
frame_delays(5)=.2
frame_delays(6)=.1
frame_delays(7)=.2

if fp=0 then
PLAY_SOUND_MC sound1(0) 'Ninja Jumping Sound    
ground=ry    
fp=1    
t=timer
t2=timer
frame_count=7
current_frame2=1
d_state="IN AIR"
end if


if (timer-t2)>=.01 then
t2=timer    
MOVE_CHARACTER rx,ry,"NINJA","N"+str(current_frame2)



if (timer-t)>=frame_delays(current_frame2) then
t=timer
if current_frame2>=7 then
fp=0
current_frame2=1 
input_status="ON"   
d_state="ON GROUND"
exit sub
end if

current_frame2=current_frame2+1
if current_frame2>=7 and ry<ground then current_frame2=6
if current_frame2>=7 and ry>=ground then current_frame2=7:ry=ground
end if

end if



current_frame1=current_frame2

END SUB
'===============================================================================
SUB NINJA_JUMPZBACK(byref rx as integer,byref ry as integer,byref current_state1 as string,byref current_frame1 as integer,byref d_state as string,byref input_status as string)
static fp as integer
if input_status="OFF" and current_state1="JUMPZBACK" then
else
fp=0
exit sub
end if


static t as double  
static t2 as double 
static z as integer
static jc as integer
static dy as integer

if fp=0 then
PLAY_SOUND_MC sound1(0) 'Ninja Jumping Sound    
ground=ry  
z=150 'Jump Straight Up
dy=ry-50 'Destination Y
fp=1    
t=timer
t2=timer
d_state="IN AIR"
jc=0
current_frame1=1
end if


if (timer-t)>.003 and current_frame1=1 then 
t=timer
t2=timer
jc=jc+1
if jc<z then ry=ry-2:current_frame1=1

if jc>=z then ry=ry+2:current_frame1=1:ground=dy
if jc>=z and ry>=dy then current_frame1=2:ground=dy
end if

if (timer-t2)>.3 and current_frame1=2 then 
fp=0
ground=dy
input_status="ON"
current_frame1=1
d_state="ON GROUND"
end if
END SUB
'===============================================================================
SUB NINJA_JUMPZFRONT(byref rx as integer,byref ry as integer,byref current_state1 as string,byref current_frame1 as integer,byref d_state as string,byref input_status as string)
static fp as integer
if input_status="OFF" and current_state1="JUMPZFRONT" then
else
fp=0
exit sub
end if


static t as double  
static t2 as double 
static z as integer
static jc as integer
static dy as integer

if fp=0 then
PLAY_SOUND_MC sound1(0) 'Ninja Jumping Sound    
ground=ry  
z=150 'Jump Straight Up
dy=ry+50 'Destination Y
fp=1    
t=timer
t2=timer
d_state="IN AIR"
jc=0
current_frame1=1
end if


if (timer-t)>.003 and current_frame1=1 then 
t=timer
t2=timer
jc=jc+1
if jc<z then ry=ry-2:current_frame1=1

if jc>=z then ry=ry+2:current_frame1=1:ground=dy
if jc>=z and ry>=dy then current_frame1=2:ground=dy
end if

if (timer-t2)>.3 and current_frame1=2 then 
fp=0
ground=dy
input_status="ON"
current_frame1=1
d_state="ON GROUND"
end if
END SUB
'===============================================================================
SUB NINJA_ATTACK1(byref rx as integer,byref ry as integer,byref pstate as string,byref i_state as string,byref current_state1 as string,byref current_frame1 as integer,byref d_state as string,byref input_status as string)
 
static fp as integer
if input_status="OFF" and current_state1="PUNCH & KICK" then
else
fp=0
exit sub
end if


static t as double  
static t2 as double 
static current_frame2 as integer
static frame_count as integer
dim frame_delays(1 to 12) as double
static lts as double
static ca as string
static fh1 as string
static fh2 as string

frame_delays(1)=.2
frame_delays(2)=.2
frame_delays(3)=.1
frame_delays(4)=.1
frame_delays(5)=.1
frame_delays(6)=.2
frame_delays(7)=.1
frame_delays(8)=.1
frame_delays(9)=.1
frame_delays(10)=.2
frame_delays(11)=.2
frame_delays(12)=.2

if fp=0 then
PLAY_SOUND_MC sound1(1) 'Ninja Attack 1 Sound     
fp=1    
t=timer
t2=timer
frame_count=12
current_frame2=1
lts=t2
ca="Y" 'Continue Attack
fh1=""
fh2=""
end if

if i_state="ATTACK" then lts=timer

if current_frame2=4 and (timer-lts)<=.2 and fh1="" then
ca="Y"
PLAY_SOUND_MC sound1(1) 'Ninja Attack 1 Sound
fh1="1"
else
if current_frame2=4 and fh1="" then ca="N"    
end if    

if current_frame2=9 and (timer-lts)<=.2 and fh2="" then
ca="Y"
PLAY_SOUND_MC sound1(1) 'Ninja Attack 1 Sound  
fh2="2"
else
if current_frame2=9 and fh2="" then ca="N"    
end if 


if ca="N" then
fp=0
current_frame1=1
current_frame2=1
input_status="ON
exit sub
end if    

if (timer-t)>=frame_delays(current_frame2) then
t=timer
current_frame2=current_frame2+1
if current_frame2>frame_count then 
fp=0
current_frame2=1 
input_status="ON"  
end if 
end if
current_frame1=current_frame2

END SUB   
'===============================================================================




dim xof as integer
xof=0

dim show_states as string
show_states="YES"

dim tfps as long
tfps=350
dim delay1 as double
delay1=GET_DELAY(tfps) 'Default Target 350 FPS
dim tol1 as double


dim ik as string

dim input_state as string
dim input_state2 as string
dim input_state3 as string
dim d_state as string
dim attack as string

dim current_state as string
dim i_state as string
dim input_status as string
dim d_state2 as string
dim current_frame as integer
dim pstate as string
input_status="ON"


'=============================================================================== 
SUB ShellsortY(sa() as integer,sa2() as integer,ae() as string,sa3() as integer,noe as integer) 
'This Sub does a shellsort of data in sa() from least to greatest
'noe=number of objects
     dim iNN as single
     dim iD as single
     dim iJ as single
     dim iI as single
     dim s as integer
     dim s2 as integer
     dim s3 as integer
     iNN = noe'Ubound(sa)
     iD = 4
     dim as string aee
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
                    
                    s = sa(iI):aee=ae(iI):s2 = sa2(iI):s3 = sa3(iI)
                    sa(iI) = sa(iI + iD):ae(iI)=ae(iI + iD):sa2(iI)=sa2(iI + iD):sa3(iI)=sa3(iI + iD)
                    sa(iI + iD) = s:ae(iI + iD)=aee:sa2(iI + iD) = s2:sa3(iI + iD) = s3
                    
               Next iI
          Next iJ
     Loop
END SUB
'===============================================================================
SUB ShellsortX(sa() as integer,sa2() as integer,ae() as string,sa6() as integer,noe as integer) 
'This Sub does a shellsort of data in sa() from least to greatest
'noe=Number of objects
     dim iNN as single
     dim iD as single
     dim iJ as single
     dim iI as single
     dim s as integer
     dim s2 as integer
     dim s3 as integer
     iNN = noe'Ubound(sa)
     iD = 4
     dim as string aee
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
                    
                    s = sa(iI):aee=ae(iI):s2 = sa2(iI):s3 = sa6(iI)
                    sa(iI) = sa(iI + iD):ae(iI)=ae(iI + iD):sa2(iI)=sa2(iI + iD):sa6(iI)=sa6(iI + iD)
                    sa(iI + iD) = s:ae(iI + iD)=aee:sa2(iI + iD) = s2:sa6(iI + iD) = s3
                    
               Next iI
          Next iJ
     Loop
dim sa3(1 to iNN) as integer
dim sa4(1 to iNN) as integer
dim sa5(1 to iNN) as string
dim sa7(1 to iNN) as integer

dim i as integer
dim i2 as integer
for i=iNN to 1 step -1
i2=i2+1
sa3(i2)=sa(i)
sa4(i2)=sa2(i)
sa5(i2)=ae(i)
sa7(i2)=sa6(i)
next
for i=1 to iNN
sa(i)=sa3(i)
sa2(i)=sa4(i)
ae(i)=sa5(i)
sa6(i)=sa7(i)
next
END SUB
'===============================================================================
SUB SPRITE_SORT2(xc() as integer,yc() as integer,zc() as integer,od() as string,noe as integer)
'On the X axis the priority is Right to Left. So, the lower the X value the HIGHER the priority.

'On the Y axis the priority is Top to Bottom. So, the higher the X value the HIGHER the priority.

'Each object has a Y width/height value. This acts as a Z axis.
ShellsortX xc(),yc(),od(),zc(),noe 'Sort X Axis Right to Left/Greatest to Least
ShellsortY yc(),xc(),od(),zc(),noe 'Sort Y Axis Top to Bottom Least to Greatest

dim i as integer

for i=1 to noe-1
if (yc(i+1)-zc(i+1))<yc(i) and yc(i)<yc(i+1) and xc(i)<xc(i+1) then 'Sort Z Axis intersections
swap xc(i),xc(i+1)
swap yc(i),yc(i+1)
swap od(i),od(i+1)
swap zc(i),zc(i+1)
end if  
next
END SUB
'===============================================================================









dim xx as integer



dim xc(1 to 6) as integer
dim yc(1 to 6) as integer
dim zc(1 to 6) as integer 

dim od(1 to 6) as string
dim ii as integer

PLAY_SOUND_MC sound1(2)

MAKE_OBJ_COLLISION_DATA 200,300,obj_data(1),"BEER","BEER SIGN 1"
MAKE_OBJ_COLLISION_DATA 300,300,obj_data(2),"BEER","BEER SIGN 2"
MAKE_OBJ_COLLISION_DATA 250,150,obj_data(4),"BEER","BEER SIGN 4"
MAKE_OBJ_COLLISION_DATA 500,100,obj_data(3),"BEER","BEER SIGN 3"

do
tol1=TOP_OF_LOOP 'ALWAYS CALL THIS AT THE TOP OF THE MAIN LOOP
'=============================================================

ik=ucase(inkey)

if IS_PLAYING(sound1(3))="NO" then
PLAY_SOUND sound1(3)    
end if 


pstate=current_state
if input_status="ON" or current_state="PUNCH & KICK" then
CONTROL_P1 input_state,input_state2,input_state3,d_state,attack
end if
TRANSLATE_INPUT_TO_CURRENT_STATE current_state,attack,i_state,input_state,input_status,d_state,d_state2

'---------------------------------------
'Get State 
select case current_state
case "STANDING"
NINJA_STANDING1 x,y,pstate,i_state,current_state,current_frame,d_state,input_status
case "RUNNING","RUNDU","RUNDD"
NINJA_RUNNING x,y,pstate,i_state,current_state,current_frame,d_state,input_status
case "WALKUP","WALKDOWN"
NINJA_WALKING x,y,pstate,i_state,current_state,current_frame,d_state,input_status 
case "FORWARD FLIP"
NINJA_FLIP x,y,pstate,i_state,current_state,current_frame,d_state,input_status 
case "JUMPZBACK"
NINJA_JUMPZBACK x,y,current_state,current_frame,d_state,input_status  
case "JUMPZFRONT"
NINJA_JUMPZFRONT x,y,current_state,current_frame,d_state,input_status
case "PUNCH & KICK"
NINJA_ATTACK1 x,y,pstate,i_state,current_state,current_frame,d_state,input_status
end select
'---------------------------------------

GET_AP_NINJA current_state,current_frame,cur_ani1,ninja_animation_pointers(),ninja_xwa() 'Get Current Ninja Animation Frame

if xof=0 then xof=cur_xwidth(current_frame)
put toscreen,(0,0),buffer1,PSET 'Clear the toscreen buffer with buffer1 

if P1_facing="RIGHT" then 
    xx=x+20
else
    xx=x'+20
end if

'===============================================================================
'This is X & Y data for Sprite Priority
xc(1)=xx
yc(1)=y+90
zc(1)=0
od(1)="NINJA"

if d_state="IN AIR" then yc(1)=ground+90

xc(2)=223
yc(2)=423
zc(2)=17
od(2)="BEER"

xc(3)=323
yc(3)=423
zc(3)=17
od(3)="BEER 2"

xc(4)=523
yc(4)=223
zc(4)=17
od(4)="BEER 3"

xc(5)=273
yc(5)=273
zc(5)=17
od(5)="BEER 4"

xc(6)=265
yc(6)=414
zc(6)=0
od(6)="NINJA 2"

sprite_sort2 xc(),yc(),zc(),od(),6 'Handle Sprite Priority
'===============================================================================

for ii=1 to 6
select case od(ii)
case "NINJA"
if P1_facing="RIGHT" then
put toscreen,(x,y),cur_ani1,Trans
else
put toscreen,(x-(cur_xwidth(current_frame)-xof),y),cur_ani1,Trans 'Display the current frame of animation to allow horizontal sprite flip        
end if     
case "BEER"
put toscreen,(200,300),biru.spritebuf,Trans
case "BEER 2"
put toscreen,(300,300),biru.spritebuf,Trans    
case "BEER 3"
put toscreen,(500,100),biru.spritebuf,Trans
case "BEER 4"
put toscreen,(250,150),biru.spritebuf,Trans
case "NINJA 2"
put toscreen,(245,324),ninja_standing(1).spritebuf,Trans    
end select
next    
   

    


'UPDATE THE SCREEN toscreen is the offscreen buffer that is being used to Double Buffer
draw string toscreen,(10,1),"X="+str(x)
draw string toscreen,(10,10),"Y="+str(y)
draw string toscreen,(10,30),"current_state="+current_state+"  i_state="+i_state+"  input_status="+input_status
draw string toscreen,(10,40),"input_state="+input_state+" current_frame="+str(current_frame)+"   P1_facing="+P1_facing
draw string toscreen,(10,60),"           [Sprite Sort Priority]                "
draw string toscreen,(10,70),"X coord  Y coord Y length front to back(Z axis) Object Description"
draw string toscreen,(10,80),"-------------------------------------------------"
draw string toscreen,(10,90),str(xc(1))+"  "+str(yc(1))+"  "+str(zc(1))+"  "+od(1)
draw string toscreen,(10,100),str(xc(2))+"  "+str(yc(2))+"  "+str(zc(2))+"  "+od(2)
draw string toscreen,(10,110),str(xc(3))+"  "+str(yc(3))+"  "+str(zc(3))+"  "+od(3)
draw string toscreen,(10,120),str(xc(4))+"  "+str(yc(4))+"  "+str(zc(4))+"  "+od(4)
draw string toscreen,(10,130),str(xc(5))+"  "+str(yc(5))+"  "+str(zc(5))+"  "+od(5)
draw string toscreen,(10,140),str(xc(6))+"  "+str(yc(6))+"  "+str(zc(6))+"  "+od(6)
put (0,0),toscreen,PSET 'Display the toscreen buffer to the screen



'=============================================================
if ik=chr(27) or ik="E" then exit do

LOOP_SLEEP tol1,delay1 'ALWAYS CALL THIS AT THE BOTTOM OF THE MAIN LOOP
if ik=chr(27) or ik="E" then exit do
loop until kcs_p1(15)=1

 
close_sound 'close the sound library
if full_screen="YES" then
setmouse 0,0,1 'Make the mouse pointer visible again if in fullscreen mode    
end if    
