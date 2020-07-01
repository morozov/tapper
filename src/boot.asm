CLS      equ $0d6b ; https://skoolkid.github.io/rom/asm/0D6B.html
BORDCR   equ $5c48 ; https://skoolkid.github.io/rom/asm/5C48.html
ATTR_P   equ $5c8d ; https://skoolkid.github.io/rom/asm/5C8D.html

; Clear screen
    xor     a
    ld      (ATTR_P), a
    ld      (BORDCR), a
    out     ($fe), a
    call    CLS

; Load image
    ld      de, ($5cf4) ; restore the FDD head position
    ld      hl, $9c40   ; destination address (40000)
    ld      bc, $1005   ; load 16 sectors of compressed image
    call    $3d13       ;
    call    $9c40       ; decompress the image

; Load data
    ld      de, ($5cf4) ; restore the FDD head position again
    ld      hl, $62d4   ; destination address (25300)
    ld      bc, $9c05   ; load 156 sectors of data
    call    $3d13       ;

; Clean up TR-DOS leftovers
; Without this, there will be animation artifacts when playing thimblerig
    ld      hl, $5b00
    ld      (hl), 0

    jp      $8000
