#lang racket/base
;; Hardware-free, executable examples from README.md / README.zh-CN.md.
;; Keep expected bytes in sync with the LIN codec and Scribble manual.
(require lin
         rackunit)

(define sample-data (bytes #x4A #x55 #x93 #xE5))

;; Six-bit IDs, LIN 2.2A checksum reference vector.
(check-equal? (protected-id #x01) #xC1)
(check-equal? (protected-id #x3C) #x3C)
(check-equal? (checksum-classic sample-data) #xE6)
(check-equal? (checksum-enhanced #xBF sample-data) #x27)

;; The enhanced checksum for protected ID 0x11 is 0xD5, not 0xC7.
(define f (frame (protected-id #x11) sample-data))
(check-equal? (frame-bytes f)
              (bytes #x55 #x11 #x4A #x55 #x93 #xE5 #xD5))
(check-equal? (parse-frame (frame-bytes f)) f)
(check-exn exn:fail?
           (lambda ()
             (parse-frame (bytes #x55 #x11 #x4A #x55 #x93 #xE5 #x00))))

;; Diagnostic frames 60/61 always use classic checksums.
(define req (diagnostic-request #x01 #xB4 (bytes #x07 #x01)))
(check-equal? (lin-frame-pid req) #x3C)
(check-equal? (lin-frame-kind req) 'classic)
(check-equal? (diagnostic-parse (lin-frame-data req))
              '(1 3 180 7 1 255 255 255))

(displayln "lin quickstart: OK")
