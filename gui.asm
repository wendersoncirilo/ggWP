TITLE ggWP

;========= COLOR ENUM =========
PL_BLACK equ 00h
PL_BLUE equ 01h
PL_GREEN equ 02h
PL_CYAN equ 03h
PL_RED equ 04h
PL_MAGENTA equ 05h
PL_BROWN equ 06h
PL_LGRAY equ 07h
PL_DGRAY equ 08h
PL_LBLUE equ 09h
PL_LGREEN equ 0Ah
PL_LCYAN equ 0Bh
PL_LRED equ 0Ch
PL_LMAGENTA equ 0Dh
PL_YELLOW equ 0Eh
PL_WHITE equ 0Fh
;========= COLOR ENUM =========

;========= SCANCODE ENUM =========
KEY_LEFT equ 4B00h
KEY_RIGHT equ 4D00h
KEY_DOWN equ 5000h
KEY_UP equ 4800h
KEY_ESC equ 011Bh
KEY_ENTER equ 1C0DH
KEY_F1 equ 3B00h
KEY_F2 equ 3C00h
KEY_F3 equ 3D00h
KEY_F4 equ 3E00h
KEY_F5 equ 3F00h
KEY_F6 equ 4000h
KEY_F7 equ 4100h
KEY_F8 equ 4200h
KEY_F9 equ 4300h
KEY_F10 equ 4400h
KEY_BACKSPACE equ 0E08h
KEY_DEL equ 5300h
;========= SCANCODE ENUM =========

;========= OTHER PARAM =========
MAX_LEN_FILENAME equ 8d ;Working up to 8 ?
MAX_LEN_SEARCH_STR equ 16d
SELECTION_COLOR equ PL_RED
;Cursor parameters
BG_COLOR equ PL_BLUE
CURSOR_COLOR equ PL_LGRAY
CURSOR_BG_COLOR equ PL_BLUE
CURSOR_TYPE equ 219d
;UI parameters
UIBUTTONOFFSET equ 103d ;Offset to first Buttons
UIBUTTONSPACING equ 65d ;Spacing between Buttons
UIBUTTONHEIGHT equ 30d ;Button height
UIBUTTONWIDTH equ 32d ;Button width
UIBUTTONNUMBER equ 5d ; Number of buttons
UIBUTTONXPOS equ 24d ; Button X position
UIROWCOLSTRPOS equ 64d; Row and column count , position in y
;========= OTHER PARAM =========

;========= MACRO DEFINITIONS =========
LOG_HANDLE_N_ERROR MACRO FileHandleReg, FileErrorCodeReg
local proc_success
            jnc proc_success
            mov FileErrorCodeReg,ax
            ;mov FileHandleReg,0000h
            POPALL
            RET
proc_success:
            mov FileHandleReg,ax
            mov FileErrorCodeReg,0000h
            POPALL
            RET
ENDM

PASS_RECT_PARAM MACRO Xpos, Ypos, Xlen, Ylen, Color
;Pass parameters to register for rectangle function
            mov RectXpos,Xpos
            mov RectYpos,Ypos
            mov RectXdim,Xlen
            mov RectYdim,Ylen
            mov RectColor,Color
ENDM

PASS_SEL_PARAM MACRO Xpos, Ypos, Xlen, Ylen, Color
;Pass parameters to register for selection function
            mov BoxXpos,Xpos
            mov BoxYpos,Ypos
            mov BoxXdim,Xlen
            mov BoxYdim,Ylen
            mov BoxSelColor,Color
ENDM

MOVRB       MACRO reg1, reg2
;Mov byte reg2 to reg1
            push bx
            xor bx,bx
            mov bl,reg2
            mov reg1,bl
            pop bx
ENDM

MOVRW       MACRO reg1, reg2
;Mov word reg2 to reg1
            push bx
            mov bx,reg2
            mov reg1,bx
            pop bx
ENDM

MULW        MACRO reg1, reg2
;MUL word reg2 to reg1 and store to reg1
            PUSHALL
            xor dx,dx
            mov bx,reg2
            mov ax,reg1
            mul bx
            mov reg1,ax
            POPALL
ENDM

PUSHALL     MACRO
            push ax
            push cx
            push dx
            push bx
ENDM

POPALL      MACRO
            pop bx
            pop dx
            pop cx
            pop ax
ENDM

CMPSC       MACRO var1, var2
            push bx
            mov bx,var2
            cmp var1,bl
            pop bx
ENDM

PUT_PIXEL   MACRO x_cor, y_cor, color
            PUSHALL
            xor bx,bx
            mov ah,0Ch
            mov al,color
            mov cx,x_cor
            mov dx,y_cor
            int 10h
            POPALL
ENDM

SET_CURSOR  MACRO row, col
;Set cursor to row,col
            PUSHALL
            mov ax,0200h
            xor bx,bx
            mov dh,row
            mov dl,col
            int 10h
            POPALL
ENDM

PUT_CURSOR  MACRO rowPos, colPos ,crsColor, crsBG_COLOR
        PUSHALL
;set cursor
        mov ax,0200h
        xor bx,bx
        mov dh,rowPos
        mov dl,colPos
        int 10h
;Put undersoce and restore cursor position
        mov ah,0Eh
        mov al,CURSOR_TYPE ;underscore cursor
        xor bh,bh
        mov bl,crsColor ;Text Color
        xor bl,crsBG_COLOR ;Button BG
        or bl,0F0h
        int 10h
;restore cursor
        mov ax,0200h
        xor bx,bx
        mov dh,rowPos
        mov dl,colPos
        int 10h

        POPALL
ENDM

PRINT_BHEX_NUM MACRO PackedHex, strColor, strBG_COLOR
;Print byte hex num
        xor ah,ah
        mov al,PackedHex
        xor bx,bx
        mov bl,10d
        div bl
        add al,30h
        push ax

        mov ah,0Eh
        xor bh,bh
        mov bl,strColor ;Text Color
        xor bl,strBG_COLOR ;Button BG
        or bl,0F0h
        int 10h

        pop ax
        mov al,ah
        add al,30h
        mov ah,0Eh
        xor bh,bh
        mov bl,strColor ;Text Color
        xor bl,strBG_COLOR ;Button BG
        or bl,0F0h
        int 10h
ENDM

DEL_CHAR MACRO Row, Col, stringName, charColor, BG_COLOR
        PUSHALL
        MOVRB FEcursorRow,Row
        MOVRB FEcursorCol,Col
        call CalcCursorPos
        lea bx,stringName
        add bx,FEcursorPos
        xor ax,ax
        mov al,[bx]
        push ax
        ;Reset position
        mov ax,0200h
        xor bx,bx
        mov dh,Row
        mov dl,Col
        int 10h
        ;Put char into position
        pop ax
        mov ah,0Eh
        xor bh,bh
        mov bl,charColor ;Text Color
        xor bl,BG_COLOR ;Button BG
        or bl,0F0h
        int 10h

        lea bx,stringName
        add bx,FEcursorPos
        mov BYTE PTR [bx],20h
        POPALL
ENDM

WRITE_CHAR  MACRO char, rowPos, colPos ,strColor, strBG_COLOR, crsColor, crsBG_COLOR
        push bx
        push dx
;Delete cursor at pos
        push ax
;Reset position
        mov ax,0200h
        xor bx,bx
        mov dh,rowPos
        mov dl,colPos
        int 10h
        mov ah,0Eh
        mov al,CURSOR_TYPE ;put underscore
        xor bh,bh
        mov bl,crsColor ;Text Color
        xor bl,strBG_COLOR ;Button BG
        or bl,0F0h
        int 10h
;Reset position
        mov ax,0200h
        xor bx,bx
        mov dh,rowPos
        mov dl,colPos
        int 10h
;Put char into position
        pop ax
        mov al,char ;put char
        mov ah,0Eh
        xor bh,bh
        mov bl,strColor ;Text Color
        xor bl,strBG_COLOR ;Button BG
        or bl,0F0h
        int 10h
        pop dx
        pop bx
ENDM

WRITE_STRING MACRO strName, strColor, strBG_COLOR
local string_loop
        lea bx,strName
        mov al,[bx]
string_loop:
        push bx
        mov ah,0Eh
        xor bh,bh
        mov bl,strColor ;Text Color
        xor bl,strBG_COLOR ;Button BG
        or bl,0F0h
        int 10h
        pop bx
        inc bx
        mov al,[bx]
        cmp al,'$'
        jnz string_loop
ENDM

WRITE_STRING_BYTE MACRO strName, strColor, strBG_COLOR ,byteNum
local string_loop
        lea bx,strName
        mov al,[bx]
        mov cx,byteNum
string_loop:
        push bx
        mov ah,0Eh
        xor bh,bh
        mov bl,strColor ;Text Color
        xor bl,strBG_COLOR ;Button BG
        or bl,0F0h
        int 10h
        pop bx
        inc bx
        mov al,[bx]
        inc FEcursorCol
        call WrapColRowCount
        call CalcCursorPos
        SET_CURSOR FEcursorRow, FEcursorCol
        loop string_loop
ENDM


;========= MACRO DEFINITIONS =========

.MODEL large,stdcall
.STACK 100h ;256 BYTE STACK

.DATA
;======== STRINGS ========
strLoad db "Load File",'$'
strNew db "New File",'$'
strSave db "Save File",'$'
strResume db "Resume",'$'
strExit db "Exit",'$'
strToolbar  db "F1 ","#Menu  ","*F2 ","#Load  ","*F3 ","#New  ","*F4 ","#Save  ","*F5 ","#Find  ","*F6 ","#Find-Replace  "
            db 0Ah, 0Dh, "    ","*F7 ","#Capitalize Sentence  ","*F8 ","#Capitalize Words  ","*ESC ","#Exit  ",'$'
; '#' write in PL_BLACK color
; '*' write in PL_RED color
strName db "File Name : ",'$'
strRow db "Row    = ",'$'
strCol db "Column = ",'$'
strTxt db ".txt",'$'
strSearch db "Search for : ",'$'
strReplace db "Replace with: ",'$'
strHeader db "gg Word  Processor",'$'
strFooterVersion db "Ver 1.0",'$'
strNotFoundError db "Not Found !!$"
;======== STRINGS ========
MenuOption dw LoadFile, NewFile, SaveFile, Resume, Exit
StatCallFromMenu db 0d ;Called from menu 1 , not 0
;Set palette variables
PLnewcolor db 00h
PLlastcolor db 00h
PLaddrReg db 00h
PLdataReg db 00h
;DrawRect function variables
RectXpos dw 0000h ;0-80
RectYpos dw 0000h ;0-480
RectXdim dw 0000h ;0-80
RectYdim dw 0000h ;0-480
RectColor db 00h
;DrawSelectionBox function variables
BoxXpos dw 0000h ;0-80
BoxYpos dw 0000h ;0-480
BoxXdim dw 0000h ;0-80
BoxYdim dw 0000h ;0-480
BoxSelColor db 00h ;Selection box color
;DrawSelection function variables
UIactiveSel dw 103d ;Position of active selection px
UIopt dw 0000h ;Number of active selection 0-1-2-3-4
;Draw toolbar varibles
DTstrColor db 00h
DTstatActive db 00h ;Status for toolbar, 0:Deactive , 1:Active
;Namebar variables
NBstatActive db 00h ;Status for namebar, 0:Deactive , 1:Active
NBfileName db MAX_LEN_FILENAME DUP (20h),'$'
;Write Methods
FEcursorPos dw 00h
FEcursorRow db 00h
FEcursorCol db 00h
WIFcursorStatActive db 00h ;Status for cursor str 0:Deactive , 1:Active
;File Methods
FileBuffer db 2500d DUP (20h),'$'
TempBuffer db 3500d DUP (20h),'$'
FileErrorCode dw 0000h
FileHandle dw 0000h
FileBytesRead dw 0000h
FileBytesWrite dw 0000h
FilePointer dw 0000h
LoadedFilePath db "./" ,MAX_LEN_FILENAME DUP (20h),".txt",0
NewFilePath db "./" ,MAX_LEN_FILENAME DUP (20h),".txt",0
;New feature variables
FNRsearchStr db MAX_LEN_SEARCH_STR DUP (20h),'$'
FNRreplaceStr db MAX_LEN_SEARCH_STR DUP (20h),'$'
FNRfoundindex dw 80d ; Found : index of found pattern
FNRstrPointer dw 0000d
FileBuffer_index dw ?             ;INDEX FOR "FileBuffer".
TempBuffer_index dw ?             ;INDEX FOR "RESULT".


.CODE
.STARTUP
        ;DS -> Data segment
        mov ax,@data
        mov ds,ax
        ;ES -> Video memory
        mov ax,0A000h
        mov es,ax
init:
        call InitScreen
main:
        call CheckKey
        call DrawSelection
        jmp main
.EXIT
        mov ax,0002h  ;Set text mode
        int 10h
        mov ax,4c00h
        int 21h
; ===================== PROCEDURES =====================
InitScreen  PROC
;Initialize display
        mov ax,0012h
        int 10h
;Draw Menu
        call DrawMenu
        ret
InitScreen  ENDP

CheckKey  PROC
;Check keyboard and update ui
        mov ax,0000h
        int 16h
        cmp ax,KEY_UP
        jz ck_dec
        cmp ax,KEY_DOWN
        jz ck_inc
        cmp ax,KEY_ENTER
        jz ck_enter
        cmp ax,KEY_ESC
        jz ck_exit
ck_end:
        ret
ck_inc:
        mov ax,UIBUTTONNUMBER
        add UIopt,1d
        cmp UIopt,ax
        jb ck_end
        sub UIopt,ax
        jmp ck_end
ck_dec:
        mov ax,UIBUTTONNUMBER
        sub UIopt,1d
        cmp UIopt,0d
        jns ck_end
        add UIopt,ax
        jmp ck_end
ck_enter:
        mov StatCallFromMenu,1d
        mov bx,UIopt
        shl bx,1
        jmp MenuOption[bx]
        jmp ck_end
ck_exit:
        mov ax,0002h  ;Set text mode
        int 10h
        mov ax, 4c00h
        int 21h
CheckKey  ENDP

NotFoundError PROC
        SET_CURSOR 0d, 35d
        WRITE_STRING strNotFoundError, PL_RED, PL_LGRAY
        mov ax,0000h
        int 16h
        cmp ax,KEY_ESC
        jz Exit
        PASS_RECT_PARAM 35d,0d,12d,20d,PL_LGRAY
        call DrawRect
        ret
NotFoundError ENDP

WrapColRowCount PROC
;Checks boundaries of row and column positions
    PUSHALL
    cmp FEcursorCol,01d
    jb wcrc_col_below
    cmp FEcursorCol,78d
    ja wcrc_col_above

wcrc_col_end:
    cmp FEcursorRow,2d
    jb wcrc_row_below
    cmp FEcursorRow,26d
    ja wcrc_row_above
    jmp wcrc_row_end

wcrc_row_below:
    mov FEcursorRow,26d
    jmp wcrc_row_end
wcrc_row_above:
    mov FEcursorRow,2d
    jmp wcrc_row_end

wcrc_col_below:
    mov FEcursorCol,78d
    dec FEcursorRow
    jmp wcrc_col_end
wcrc_col_above:
    mov FEcursorCol,01d
    inc FEcursorRow
    jmp wcrc_col_end

wcrc_row_end:
    POPALL
    ret

WrapColRowCount ENDP

CalcCursorPos  PROC
;Calculates linear cursor position using row and column data
;pos = 78*(row-2)+column-1
        PUSHALL
        xor ax,ax
        mov al,FEcursorRow
        sub ax,2d
        mov bl,78d
        mul bl
        xor bx,bx
        mov bl,FEcursorCol
        add ax,bx
        dec ax
        mov FEcursorPos,ax
        POPALL
        ret
CalcCursorPos  ENDP

CalcCursorRowCol  PROC
;Calculates row and column data using cursor position data
        PUSHALL
        xor ax,ax
        xor dx,dx
        mov ax,FEcursorPos
        mov bl,78d
        div bl
        add al,2
        add ah,1
        mov FEcursorCol,ah
        mov FEcursorRow,al
        POPALL
        ret
CalcCursorRowCol  ENDP

FileEditor  PROC
        mov FEcursorRow,2d
        mov FEcursorCol,2d
        SET_CURSOR FEcursorRow, FEcursorCol
        call CalcCursorPos
fe_loop:
        call DrawCursorStr
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        mov ax,0000h
        int 16h
        ;;Check valid input
        cmp ax,KEY_F1
        jz fe_Menu
        cmp ax,KEY_F2
        jz fe_LoadFile
        cmp ax,KEY_F3
        jz fe_NewFile
        cmp ax,KEY_F4
        jz fe_SaveFile
        cmp ax,KEY_F5
        jz fe_Find
        cmp ax,KEY_F6
        jz fe_Find_Replace
        cmp ax,KEY_F7
        jz fe_Cap_Sents
        cmp ax,KEY_F8
        jz fe_Cap_Words
        cmp ax,KEY_ENTER
        jz fe_Enter
        cmp ax,KEY_UP
        jz fe_Up
        cmp ax,KEY_DOWN
        jz fe_Down
        cmp ax,KEY_LEFT
        jz fe_Left
        cmp ax,KEY_RIGHT
        jz fe_Right
        cmp ax,KEY_BACKSPACE
        jz fe_BackSpace
        cmp ax,KEY_DEL
        jz fe_Delete
        cmp ax,KEY_ESC
        jz fe_Exit
        ;else print to screen
        DEL_CHAR FEcursorRow, FEcursorCol, FileBuffer, PL_WHITE, BG_COLOR
        WRITE_CHAR al, FEcursorRow, FEcursorCol, PL_WHITE, BG_COLOR, CURSOR_COLOR, CURSOR_BG_COLOR
        lea bx,FileBuffer
        add bx,FEcursorPos
        mov BYTE PTR [bx],al
        inc FEcursorCol
        call WrapColRowCount
        call CalcCursorPos
        jmp fe_loop
        ret
fe_Enter:
        WRITE_CHAR 0Dh, FEcursorRow, FEcursorCol, PL_WHITE, BG_COLOR, CURSOR_COLOR, CURSOR_BG_COLOR
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        WRITE_CHAR 0Ah, FEcursorRow, FEcursorCol, PL_WHITE, BG_COLOR, CURSOR_COLOR, CURSOR_BG_COLOR
        mov FEcursorCol,01d ; chars in 1 line
        inc FEcursorRow
        call WrapColRowCount
        call CalcCursorPos
        jmp fe_loop
fe_Menu:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        call Menu
        ret
fe_LoadFile:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        mov StatCallFromMenu,0d
        call LoadFile
        ret
fe_NewFile:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        mov StatCallFromMenu,0d
        call NewFile
        ret
fe_SaveFile:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        mov StatCallFromMenu,0d
        call SaveFile
        ret
fe_Find:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        mov FNRstrPointer,Offset FNRsearchStr
        call ResetSearchStr
        call DrawSearchbar
        mov FNRstrPointer,Offset FNRsearchStr
        call TakeSearchStr
        call SearchInBuffer
        cmp FNRfoundindex,-1d
        jz fe_searchnotfound
    ;search and mark
        MOVRW FEcursorPos,FNRfoundindex
        call CalcCursorRowCol
        call WrapColRowCount
        jmp fe_loop
        ret
fe_searchnotfound:
        call NotFoundError
        mov FEcursorPos,00d
        call CalcCursorRowCol
        call WrapColRowCount
        jmp fe_loop
        ret

fe_Find_Replace:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        ;reset search/replace str
        mov FNRstrPointer,Offset FNRsearchStr
        call ResetSearchStr
        mov FNRstrPointer,Offset FNRreplaceStr
        call ResetSearchStr
        ;take search str
        call DrawSearchbar
        mov FNRstrPointer,Offset FNRsearchStr
        call TakeSearchStr
        ;take replace str
        PASS_RECT_PARAM 50d,0d,30d,20d,PL_LGRAY
        call DrawRect
        SET_CURSOR 0d, 50d
        WRITE_STRING strReplace, PL_BLACK, PL_LGRAY ;replace word
        SET_CURSOR 0d, 63d
        mov FNRstrPointer,Offset FNRreplaceStr
        call TakeSearchStr
        call FindReplaceInBuffer
        call Resume
        jmp fe_loop
        ret
fe_Cap_Sents:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        call CapSentsInBuffer
        call Resume
        jmp fe_loop
        ret
fe_Cap_Words:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        call CapWordsInBuffer
        call Resume
        jmp fe_loop
        ret
fe_Up:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        dec FEcursorRow
        call WrapColRowCount
        call CalcCursorPos
        jmp fe_loop
        ret
fe_Down:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        inc FEcursorRow
        call WrapColRowCount
        call CalcCursorPos
        jmp fe_loop
        ret
fe_Left:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        dec FEcursorCol
        call WrapColRowCount
        call CalcCursorPos
        jmp fe_loop
        ret
fe_Right:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        inc FEcursorCol
        call WrapColRowCount
        call CalcCursorPos
        jmp fe_loop
        ret
fe_BackSpace:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        dec FEcursorCol
        call WrapColRowCount
        call CalcCursorPos
        ;delete char at pos
        DEL_CHAR FEcursorRow, FEcursorCol, FileBuffer, PL_WHITE ,BG_COLOR
        call WrapColRowCount
        call CalcCursorPos
        jmp fe_loop
        ret
fe_Delete:
        PUT_CURSOR FEcursorRow, FEcursorCol, CURSOR_COLOR, CURSOR_BG_COLOR
        inc FEcursorCol
        call WrapColRowCount
        call CalcCursorPos
        ;delete char at pos
        DEL_CHAR FEcursorRow, FEcursorCol, FileBuffer, PL_WHITE ,BG_COLOR
        call WrapColRowCount
        call CalcCursorPos
        jmp fe_loop
        ret
fe_Exit:
        call Exit
        jmp fe_loop
        ret
FileEditor  ENDP

TakeFileName  PROC
        call ResetFileName
        mov FEcursorRow,0d
        mov FEcursorCol,13d
        SET_CURSOR 0d, 13d
        lea bx,NBfileName
        mov cx,bx
        add cx,MAX_LEN_FILENAME ;End condition
        inc cx
tfn_loop:
        PUT_CURSOR FEcursorRow, FEcursorCol, PL_RED, PL_LGRAY
        mov ax,0000h
        int 16h
        cmp bx,cx
        jz tfn_end
        cmp ax,KEY_ENTER ;Enter key
        jz tfn_end
        cmp ax,KEY_BACKSPACE
        jz tfn_BackSpace
        cmp ax,KEY_ESC
        jz tfn_Exit
        WRITE_CHAR al, FEcursorRow, FEcursorCol, PL_RED, PL_LGRAY, PL_RED, PL_LGRAY
        inc FEcursorCol ;check and inc FEcursorRow also
        mov [bx],al
        inc bx
        jmp tfn_loop

tfn_end:
        WRITE_CHAR ' ', FEcursorRow, FEcursorCol, PL_RED, PL_LGRAY, PL_RED, PL_LGRAY ;delete underscore
        SET_CURSOR FEcursorRow,FEcursorCol
        WRITE_STRING strTxt, PL_RED, PL_LGRAY ;put .txt
        mov NBstatActive,1d
        ret
tfn_BackSpace:
        lea dx,NBfileName
        cmp bx,dx
        jz tfn_donothing
;delete cursor at pos
        PUT_CURSOR FEcursorRow, FEcursorCol, PL_RED, PL_LGRAY
        dec FEcursorCol
        SET_CURSOR FEcursorRow,FEcursorCol
;delete char at pos
        dec bx
        mov ah,[bx]
        WRITE_CHAR ah, FEcursorRow, FEcursorCol, PL_RED, PL_LGRAY, PL_RED, PL_LGRAY
        mov BYTE PTR [bx],' '
tfn_donothing:
        PUT_CURSOR FEcursorRow, FEcursorCol, PL_RED, PL_LGRAY
        jmp tfn_loop
        ret
tfn_Exit:
        call Exit
        jmp tfn_loop
        ret
TakeFileName  ENDP

TakeSearchStr  PROC
        mov FEcursorRow,0d
        mov FEcursorCol,63d
        SET_CURSOR 0d, 63d
        mov bx,FNRstrPointer
        ;lea bx,FNRsearchStr
        mov cx,bx
        add cx,MAX_LEN_SEARCH_STR ;End condition
tss_loop:
        PUT_CURSOR FEcursorRow, FEcursorCol, PL_BLUE, PL_LGRAY
        mov ax,0000h
        int 16h
        cmp ax,KEY_ENTER ;Enter key
        jz tss_end
        cmp ax,KEY_BACKSPACE
        jz tss_BackSpace
        cmp ax,KEY_ESC
        jz tss_Exit
        WRITE_CHAR al, FEcursorRow, FEcursorCol, PL_BLUE, PL_LGRAY, PL_BLUE, PL_LGRAY
        inc FEcursorCol ;check and inc FEcursorRow also
        mov BYTE PTR [bx],al
        inc bx
        cmp bx,cx
        jnz tss_loop

tss_end:
        WRITE_CHAR ' ', FEcursorRow, FEcursorCol, PL_BLUE, PL_LGRAY, PL_BLUE, PL_LGRAY ;delete underscore
        ret
tss_BackSpace:
        ;lea dx,FNRsearchStr
        mov dx,FNRstrPointer
        cmp bx,dx
        jz tss_donothing
;delete cursor at pos
        PUT_CURSOR FEcursorRow, FEcursorCol, PL_BLUE, PL_LGRAY
        dec FEcursorCol
        SET_CURSOR FEcursorRow,FEcursorCol
;delete char at pos
        dec bx
        mov ah,[bx]
        WRITE_CHAR ah, FEcursorRow, FEcursorCol, PL_BLUE, PL_LGRAY, PL_BLUE, PL_LGRAY
        mov BYTE PTR [bx],' '
tss_donothing:
        PUT_CURSOR FEcursorRow, FEcursorCol, PL_BLUE, PL_LGRAY
        jmp tss_loop
        ret
tss_Exit:
        call Exit
        jmp tss_loop
        ret
TakeSearchStr  ENDP

ResetBuffer PROC
        push bx
        push cx
        mov cx,2500d
        lea bx,FileBuffer
        add cx,bx
rfir_loop:
        mov BYTE PTR [bx],20h
        inc bx
        cmp bx,cx
        jnz rfir_loop
        pop cx
        pop bx
        ret
ResetBuffer ENDP

ResetFileName PROC
        push bx
        push cx
        mov cx,MAX_LEN_FILENAME
        lea bx,NBfileName
        add cx,bx
rfn_loop:
        mov BYTE PTR [bx],20h
        inc bx
        cmp bx,cx
        jnz rfn_loop
        pop cx
        pop bx
        ret
ResetFileName ENDP

ResetSearchStr PROC
        push bx
        push cx
        mov cx,MAX_LEN_SEARCH_STR
        mov bx,FNRstrPointer
        add cx,bx
rss_loop:
        mov BYTE PTR [bx],20h
        inc bx
        cmp bx,cx
        jnz rss_loop
        pop cx
        pop bx
        ret
ResetSearchStr ENDP

SearchInBuffer PROC
        PUSHALL
        xor cx,cx ;Search index for file
        xor dx,dx ;index for FNRsearchStr
sib_loop:
        lea bx,FNRsearchStr
        add bx,dx
        mov ah,[bx]

        cmp ah,20h
        jz sib_found
        cmp ah,'$'
        jz sib_found

        lea bx,FileBuffer
        add bx,cx
        cmp BYTE PTR [bx],ah
        jz sib_match
        jmp sib_unmatch

sib_match:
        cmp dx,0h
        jnz sib_notfirstmatch
        mov FNRfoundindex,cx
sib_notfirstmatch:
        inc cx
        cmp cx,2500d;search depth
        ja sib_notfound
        inc dx
        jmp sib_loop
sib_unmatch:
        inc cx
        cmp cx,2500d;search depth
        ja sib_notfound
        xor dx,dx
        jmp sib_loop

sib_notfound:
        mov FNRfoundindex,-1d
sib_found:
        POPALL
        RET
SearchInBuffer ENDP

FindReplaceInBuffer PROC
        PUSHALL
        mov FileBuffer_index, offset FileBuffer
        mov TempBuffer_index, offset TempBuffer
        mov si, FileBuffer_index
        lea di, FNRsearchStr
frib_search:
        mov al, [di]
        cmp al, 20h
        je frib_match
        mov bl,[si]
        cmp bl,24h
        je frib_finale

        cmp [si], al
        jne frib_mismatch
        inc si
        inc di
        jmp frib_search
frib_match:
        mov FileBuffer_index, si
        dec FileBuffer_index
        lea di, FNRreplaceStr
frib_replace:
        mov al,[di]
        cmp al,20h
        je  frib_next
        mov si, TempBuffer_index
        mov [si], al
        inc TempBuffer_index
        inc di
        jmp frib_replace
frib_mismatch:
        mov si, FileBuffer_index
        mov di, TempBuffer_index
        mov al, [si]
        mov [di], al
        inc TempBuffer_index
frib_next:
        lea di, FNRsearchStr
        inc FileBuffer_index
        mov si,FileBuffer_index
        mov bl,[si]
        cmp bl,24h
        jne frib_search
frib_finale:
        mov si,Offset TempBuffer
        mov di,Offset FileBuffer
        mov cx,2500d
load_temp:
        mov ah,BYTE PTR [si]
        mov BYTE PTR [di],ah
        inc si
        inc di
        loop load_temp
        POPALL
        RET
FindReplaceInBuffer ENDP

CapWordsInBuffer PROC
        PUSHALL
        lea bx,FileBuffer
        dec bx
cwib_blank:
        inc bx
        cmp BYTE PTR [bx],'$' ;chk end
        jz cwib_end_con ;if end goto end_con
        cmp BYTE PTR [bx],' ' ;chk space
        jz cwib_blank ;if space goto blank
        cmp BYTE PTR [bx],'.' ;chk period
        jz cwib_blank
        and BYTE PTR [bx],0DFh ;else convert uppercase
        jmp cwib_word ;then goto word
cwib_word:
        cmp BYTE PTR [bx],'$' ;chk end
        jz cwib_end_con ;if end goto end_con
        cmp BYTE PTR [bx],' ' ;chk space
        jz cwib_blank ;if space goto blank
        inc bx ;else increase BX
        jmp cwib_word ;and goto word
cwib_end_con:
        POPALL
        ret
CapWordsInBuffer ENDP

CapSentsInBuffer PROC
        PUSHALL
        lea bx,FileBuffer
        dec bx
csib_blank:
        inc bx
        cmp BYTE PTR [bx],'$' ;chk end
        jz csib_end_con ;if end goto end_con
        cmp BYTE PTR [bx],'.' ;chk period
        jz csib_word
        jmp csib_blank
csib_word:
        inc bx ;else increase BX
        cmp BYTE PTR [bx],'$' ;chk end
        jz csib_end_con ;if end goto end_con
        cmp BYTE PTR [bx],'.' ;chk period
        jz csib_word
        cmp BYTE PTR [bx],' ' ;chk period
        jz csib_word
        and BYTE PTR [bx],0DFh ;else convert uppercase
        jmp csib_blank ;and goto word
csib_end_con:
        POPALL
        ret
CapSentsInBuffer ENDP

ExitProgram  PROC
;Check keyboard and exits if F10 pressed
        mov ax,0000h
        int 16h
        cmp ax,KEY_F10
        jnz continue
        mov ax,0002h  ;Set text mode
        int 10h
        mov ax, 4c00h
        int 21h
continue:
        ret
ExitProgram  ENDP
; ===================== MENU METHODS =====================
Menu PROC
        call DrawMenu
m_ret:
        call CheckKey
        call DrawSelection
        jmp m_ret
        ret
Menu ENDP
LoadFile PROC
        call CloseFile ;close previous file
        mov NBstatActive,0d
        mov WIFcursorStatActive,0d
;Reset file in ram
        call ResetBuffer
;Draw Editor window
        call DrawEditorWindow
lf_ret:
        call TakeFileName
        call OpenFile
        call ReadFile
        call WriteBuffer2screen
        call FileEditor
        jmp lf_ret
        ret
LoadFile ENDP

NewFile PROC
        call CloseFile; close previous file
        mov NBstatActive,0d
        mov WIFcursorStatActive,0d
;Reset file in ram
        call ResetBuffer
;Draw Editor window
        call DrawEditorWindow
nf_ret:
        call FileEditor
        jmp nf_ret
        ret
NewFile ENDP

SaveFile PROC
        mov NBstatActive , 0d
        call DrawEditorWindow
        call WriteBuffer2screen
        call TakeFileName
        call CreateFile
        call MoveFilePTR
        call WriteFile
        call CloseFile
        call FileEditor
        ret
sf_callmenu:
        call Menu
        ret
SaveFile ENDP
Resume PROC
        call DrawEditorWindow
        call WriteBuffer2screen
        call FileEditor
        ret
Resume ENDP
Exit PROC
        call CloseFile
        mov ax,0002h  ;Set text mode
        int 10h
        mov ax, 4c00h
        int 21h
        ret
Exit ENDP
; ===================== MENU METHODS =====================
; ===================== DRAW METHODS =====================
DrawMenuStr PROC

        SET_CURSOR 7d, 35d
        WRITE_STRING strLoad, PL_WHITE, PL_CYAN

        SET_CURSOR 11d, 35d
        WRITE_STRING strNew, PL_WHITE, PL_CYAN

        SET_CURSOR 15d, 35d
        WRITE_STRING strSave, PL_WHITE, PL_CYAN

        SET_CURSOR 19d, 36d
        WRITE_STRING strResume, PL_WHITE, PL_CYAN

        SET_CURSOR 23d, 37d
        WRITE_STRING strExit, PL_WHITE, PL_CYAN

        RET

DrawMenuStr ENDP

DrawHeaderStr PROC
        SET_CURSOR 0d, 31d
        WRITE_STRING strHeader, PL_RED, PL_LGRAY
        RET
DrawHeaderStr ENDP

DrawFooterStr PROC
        SET_CURSOR 28d, 70d
        WRITE_STRING strFooterVersion, PL_RED, PL_LGRAY
        RET
DrawFooterStr ENDP


DrawEditorWindow PROC
;Reset Center rectangle
        PASS_RECT_PARAM 0d,0d,80d,440d,0d
        call ResetRect
;Redraw center rectangle
        mov bl,BG_COLOR
        PASS_RECT_PARAM 0d,20d,80d,420d,bl
        call DrawRect
;Draw toolbar
        call DrawToolbar
        call DrawNamebar
        RET
DrawEditorWindow ENDP

DrawCursorStr PROC
        PASS_RECT_PARAM UIROWCOLSTRPOS+9, 440d, 3d, 40d, PL_LGRAY
        call DrawRect
        SET_CURSOR 28d, UIROWCOLSTRPOS + 9
        PRINT_BHEX_NUM FEcursorRow, PL_BLUE, PL_LGRAY
        SET_CURSOR 29d, UIROWCOLSTRPOS + 9
        PRINT_BHEX_NUM FEcursorCol, PL_BLUE, PL_LGRAY
        RET
DrawCursorStr ENDP

DrawNamebar PROC
;Draw Header
        PASS_RECT_PARAM 0d,0d,80d,20d,PL_LGRAY
        call DrawRect
        cmp NBstatActive,0d ;Write filename when NBstatActive
        jz dn_nbactive
        SET_CURSOR 0d, 13d
        ;WRITE_STRING Sequance but stops at ' ' char also
        lea bx,NBfileName
        mov al,[bx]
dn_loop:
        push bx
        mov ah,0Eh
        xor bh,bh
        mov bl,PL_RED ;Text Color
        xor bl,PL_LGRAY ;Button BG
        or bl,0F0h
        int 10h
        pop bx
        inc bx
        mov al,[bx]
        cmp al,' '
        jz dn_endloop
        cmp al,'$'
        jnz dn_loop
dn_endloop:
        WRITE_STRING strTxt, PL_RED, PL_LGRAY ;put .txt
dn_nbactive:
        SET_CURSOR 0d, 1d
        WRITE_STRING strName, PL_BLACK, PL_LGRAY
        RET
DrawNamebar ENDP

DrawSearchbar PROC
        PASS_RECT_PARAM 50d,0d,30d,20d,PL_LGRAY
        call DrawRect
        SET_CURSOR 0d, 50d
        WRITE_STRING strSearch, PL_BLACK, PL_LGRAY
        SET_CURSOR 0d, 63d
        RET
DrawSearchbar ENDP

DrawToolbar PROC
;Draw upper toolbar
        ;Draw Header
        PASS_RECT_PARAM 0d,0d,80d,20d,PL_LGRAY
        call DrawRect
        ;Draw Footer
        PASS_RECT_PARAM 0d,440d,80d,40d,PL_LGRAY
        call DrawRect
        SET_CURSOR 28d, 4d
        mov DTstrColor,PL_RED
        lea bx,strToolbar
        mov al,[bx]
dt_string_loop:
        push bx
        mov ah,0Eh
        xor bh,bh
        mov bl,DTstrColor ;Text Color
        xor bl,PL_LGRAY ;Button BG
        or bl,0F0h
        int 10h
        pop bx
        inc bx
        mov al,[bx]
        cmp al,'#'
        jz dt_set_black
        cmp al,'*'
        jz dt_set_red
dt_continue:
        cmp al,'$'
        jnz dt_string_loop
        jmp dt_end

dt_set_red:
        mov DTstrColor,PL_RED
        inc bx
        mov al,[bx]
        jmp dt_continue
dt_set_black:
        mov DTstrColor,PL_BLACK
        inc bx
        mov al,[bx]
        jmp dt_continue

dt_end:
        SET_CURSOR 28d, UIROWCOLSTRPOS
        WRITE_STRING strRow, PL_MAGENTA, PL_LGRAY
        SET_CURSOR 29d, UIROWCOLSTRPOS
        WRITE_STRING strCol, PL_MAGENTA, PL_LGRAY
        RET

DrawToolbar ENDP

DrawRect PROC
;Create mask for new color
        MOVRB PLnewcolor,RectColor
        call SetPalette

;Calculate Di = 80*y + x and Cx = ylen
        mov ax,RectYpos
        xor dx,dx
        mov bx,80d
        mul bx
        add ax,RectXpos
        mov di,ax ;Start position
        mov cx,RectYdim
;Draw rectangle
DrawRect_START:
        push cx
        mov cx,RectXdim
        mov al,0FFh
        rep stosb
        sub di,RectXdim
        add di,80d
        pop cx
        loop DrawRect_START
        ret
DrawRect ENDP

ResetRect PROC
;Create mask for new color
        mov PLnewcolor,0Fh
        call SetPalette

;Calculate Di = 80*y + x and Cx = ylen
        mov ax,RectYpos
        xor dx,dx
        mov bx,80d
        mul bx
        add ax,RectXpos
        mov di,ax ;Start position
        mov cx,RectYdim
;Draw rectangle
ResetRect_START:
        push cx
        mov cx,RectXdim
        mov al,00h
        rep stosb
        sub di,RectXdim
        add di,80d
        pop cx
        loop ResetRect_START
        ret
ResetRect ENDP

DrawSelection PROC
;Reset current selection
        mov ax,UIactiveSel
        PASS_SEL_PARAM UIBUTTONXPOS,ax,UIBUTTONWIDTH,UIBUTTONHEIGHT,BG_COLOR
        call DrawSelectionBox

;Draw new selection
        mov UIactiveSel,UIBUTTONSPACING
        MULW UIactiveSel,UIopt
        add UIactiveSel,UIBUTTONOFFSET
        mov ax,UIactiveSel

        PASS_SEL_PARAM UIBUTTONXPOS,ax,UIBUTTONWIDTH,UIBUTTONHEIGHT,SELECTION_COLOR
        call DrawSelectionBox

        ret
DrawSelection ENDP

DrawSelectionBox PROC
        MULW BoxXpos,8d
        MULW BoxXdim,8d

        mov cx,BoxXpos
        mov dx,BoxYpos
        dec cx
        dec dx

        mov ax,cx
        add ax,BoxXdim
        inc ax
ds_toploop:
        PUT_PIXEL cx, dx, BoxSelColor
        dec dx ;2wide
        PUT_PIXEL cx, dx, BoxSelColor
        inc dx ;2wide
        inc cx
        cmp cx,ax
        jnz ds_toploop

        mov ax,dx
        add ax,BoxYdim
        inc ax
ds_rsidelp:
        PUT_PIXEL cx, dx, BoxSelColor
        inc cx ;2wide
        PUT_PIXEL cx, dx, BoxSelColor
        dec cx ;2wide
        inc dx
        cmp dx,ax
        jnz ds_rsidelp

        mov ax,BoxXpos
        dec ax
ds_botloop:
        PUT_PIXEL cx, dx, BoxSelColor
        inc dx ;2wide
        PUT_PIXEL cx, dx, BoxSelColor
        dec dx
        dec cx
        cmp cx,ax
        jnz ds_botloop

        mov ax,BoxYpos
        dec ax
ds_lsidelp:
        PUT_PIXEL cx, dx, BoxSelColor
        dec cx ;2wide
        PUT_PIXEL cx, dx, BoxSelColor
        inc cx ;2wide
        dec dx
        cmp dx,ax
        jnz ds_lsidelp

        RET

DrawSelectionBox ENDP

DrawMenu PROC
;Reset center rectangle
        PASS_RECT_PARAM 0d,20d,80d,420d,0d
        call ResetRect
;Set Palette Color
        MOVRB PLnewcolor,BG_COLOR
        call SetPalette
;BG fill
        mov ax,0FFFFh
        mov cx,19200d ;Fullscreen 640*480/16bit
        xor di,di
        rep stosw
;Draw Buttons
        mov ax,UIBUTTONOFFSET
        mov cx,UIBUTTONNUMBER
init_drawbtn:
        push cx
        push ax
        PASS_RECT_PARAM UIBUTTONXPOS,ax,UIBUTTONWIDTH,UIBUTTONHEIGHT,PL_CYAN
        call DrawRect
        pop ax
        pop cx
        add ax,UIBUTTONSPACING
        loop init_drawbtn

;Draw Header
        PASS_RECT_PARAM 0d,0d,80d,20d,PL_LGRAY
        call DrawRect

;Draw Footer
        PASS_RECT_PARAM 0d,440d,80d,40d,PL_LGRAY
        call DrawRect

;Write button texts
        call DrawMenuStr
        call DrawHeaderStr
        call DrawFooterStr
;Draw Selection box
        mov UIopt,0d
        call DrawSelection
        ret
DrawMenu ENDP

SetPalette PROC
        ;save value of address register
        mov dx,03c4h
        in al,dx
        mov PLaddrReg,al

        ;output the index of desired data reg. to address reg
        mov al,02h ; Map Mask register (02h)
        out dx,al

        ;read value of data register and save
        mov dx,03c5h
        in al,dx
        mov PLdataReg,al

        ;modify data register value
        MOVRB PLdataReg,PLnewcolor ; 0b0000XXXX Planes I-R-G-B

        ;Write into data register
        mov al,PLdataReg
        mov dx,03c5h
        out dx,al

        ;Write stored address register value to address reg.
        mov dx,3c4h
        mov al,PLaddrReg
        out dx,al

        ;Update current color palette
        MOVRB PLlastcolor,PLnewcolor

        ret
SetPalette ENDP
; ===================== DRAW METHODS =====================
; ===================== FILE METHODS =====================
OpenFile PROC
        PUSHALL
        mov cx,MAX_LEN_FILENAME
        dec cx
of_strcpy:
        lea bx,NBfileName
        add bx,cx
        mov ah,BYTE PTR [bx]
        lea bx,LoadedFilePath
        add bx,cx
        add bx,2d
        mov BYTE PTR [bx],ah
        loop of_strcpy

        lea bx,NBfileName
        add bx,cx
        mov ah,BYTE PTR [bx]
        lea bx,LoadedFilePath
        add bx,cx
        add bx,2d
        mov BYTE PTR [bx],ah

        mov ah,3Dh
        mov al,0100010b
        lea dx,LoadedFilePath
        int 21h
;Write error/filehandle , POPALL and return
        LOG_HANDLE_N_ERROR FileHandle, FileErrorCode
OpenFile ENDP

CreateFile PROC
        PUSHALL
        mov cx,MAX_LEN_FILENAME
        dec cx
cf_strcpy:
        lea bx,NBfileName
        add bx,cx
        mov ah,BYTE PTR [bx]
        lea bx,NewFilePath
        add bx,cx
        add bx,2d
        mov BYTE PTR [bx],ah
        loop cf_strcpy

        lea bx,NBfileName
        add bx,cx
        mov ah,BYTE PTR [bx]
        lea bx,NewFilePath
        add bx,cx
        add bx,2d
        mov BYTE PTR [bx],ah

        mov ah,3ch
        mov cx,0000h
        lea dx,NewFilePath
        int 21h
;Write error/filehandle , POPALL and return
        LOG_HANDLE_N_ERROR FileHandle, FileErrorCode
CreateFile ENDP

WriteFile PROC
        PUSHALL
        mov ah,40h
        mov bx,FileHandle
        mov cx,1950d
        lea dx,FileBuffer
        int 21h
;Write error/filehandle , POPALL and return
        LOG_HANDLE_N_ERROR FileBytesWrite, FileErrorCode
WriteFile ENDP

ReadFile PROC
        PUSHALL
        mov ah,3Fh
        mov bx,FileHandle
        mov cx,1950d
        lea dx,FileBuffer
        int 21h
;Write error/filehandle , POPALL and return
        LOG_HANDLE_N_ERROR FileBytesRead, FileErrorCode
ReadFile ENDP

CloseFile PROC
        PUSHALL
        mov ah,3Eh
        mov bx,FileHandle
        int 21h
;Write error/filehandle , POPALL and return
        LOG_HANDLE_N_ERROR FileHandle, FileErrorCode
CloseFile ENDP

MoveFilePTR PROC
        PUSHALL
        mov ah,42h
        mov al,00h
        mov cx,0000h
        mov dx,0000h
        mov bx,FileHandle
        int 21h
;Write error/filepointer , POPALL and return
        LOG_HANDLE_N_ERROR FilePointer, FileErrorCode
MoveFilePTR ENDP

WriteBuffer2screen PROC
;Write data in ram to editor
        mov FEcursorRow,2d
        mov FEcursorCol,1d
        SET_CURSOR FEcursorRow, FEcursorCol
        WRITE_STRING_BYTE FileBuffer, PL_WHITE, BG_COLOR, 1950d ;?
        call CalcCursorPos
        RET
WriteBuffer2screen ENDP

; ===================== FILE METHODS =====================
; ===================== PROCEDURES =====================

END
