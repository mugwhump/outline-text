; gimp-image-get-active-layer (image)
; gimp-item-is-text-layer (item) returns 0/1, not #f/#t
; gimp-layer-new (image, width, height, type, name, opacity, mode)
; gimp-image-insert-layer (img, layer, parent-layer, position)
; gimp-image-set-active-layer
; gimp-image-get-selection (image)
; gimp-image-select-item (image, op, item)
;

(define (script-fu-outline-text img active-layer color size merge)
    ; Abort if current layer not text
    (if (= 0 (car (gimp-item-is-text-layer active-layer)))
        (error "Current layer is not a text layer"))
    (let* (
        (img-width (car (gimp-image-width img)))
        (img-height (car (gimp-image-height img)))
        (img-base-type (car (gimp-image-base-type img))) ; 0=RGB 1=GRAY 2=IND
        (type (* 2 img-base-type)) ; 0=RGB 1=RGBA 2=GRAY 3=GRAYA 4=IND 5=INDA
        (layer (car (gimp-layer-new img img-width img-height type "" 100 0)))
        (old-selection (car (gimp-image-get-selection img)))
        (old-fg (car (gimp-context-get-foreground img)))
        )
        
        (begin
        ; Make all of these into a single "undo" operation
        (gimp-image-undo-group-start img)
        ; Insert new layer above text layer
        (gimp-image-insert-layer img layer 0 -1)
        ; Add alpha to new layer, clear to transparent
        (gimp-layer-add-alpha layer)
        (gimp-selection-all img)
        (gimp-edit-clear layer)
        ; Select the text
        (gimp-image-select-item img 2 active-layer) ; 2 replaces current sel
        ; Raise text layer above new layer
        (gimp-image-raise-item img active-layer)
        (gimp-image-set-active-layer img layer)
        ; Grow selection
        (gimp-selection-grow img size)
        ; Set foreground color. TODO: save old foreground.
        (gimp-context-set-foreground color)
        (gimp-edit-fill layer 0)
        ; Restore old selection and fg color

        ; Merge
        (if merge (gimp-image-merge-down img active-layer 0))
        (gimp-image-undo-group-end img)
        )
    )
)


(script-fu-register
  "script-fu-outline-text"
  "Outline Text"                        ; Label
  "Creates a simple outline around\
  the selected text layer."             ; Description
  "Grayson Bartlet"
  "Fat Man License"
  "May 2014"
  ""                                    ; Works on all image types
  SF-IMAGE "Image" 0
  SF-DRAWABLE "Drawable" 0
  SF-COLOR "Outline Color" '(255 255 255)     ; Default white
  SF-VALUE "Outline Width (px)" "3"
  SF-TOGGLE "Merge Text With Outline?" TRUE
)

(script-fu-menu-register "script-fu-outline-text" "<Image>/Layer/Outline")
