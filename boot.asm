[bits 16]
[org 0x7c00]

start:
    jmp 0:init          ; Нормализуем CS

init:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov [boot_drive], dl ; Сохраняем номер диска от BIOS

    ; Сброс дисковой системы
    xor ax, ax
    int 0x13

    ; Читаем ядро и программы (120 секторов = 60КБ)
    mov ax, 0x07e0      ; Читаем в сегмент 0x07E0 (адрес 0x7E00)
    mov es, ax
    xor bx, bx

    mov ah, 0x02
    mov al, 255         ; Количество секторов
    mov ch, 0           ; Цилиндр 0
    mov dh, 0           ; Головка 0
    mov cl, 2           ; Начинаем со 2-го сектора
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    jmp 0:0x7e00        ; Прыгаем в ядро

disk_error:
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    jmp $

boot_drive db 0
times 446-($-$$) db 0   ; Таблица разделов для старых BIOS
db 0x80, 0, 1, 0, 0x0B, 0, 0x3F, 0
dd 1, 0xFFFF
times 16*3 db 0
dw 0xaa55