#! /usr/bin/env racket
#lang sweet-exp racket

define port 65511

define server
  tcp-listen port 4 #f "127.0.0.1"

define (eval-with-output sexp ns output)
  parameterize
    ([current-namespace ns]
     [current-output-port output])
    with-handlers
      group
        exn?
          compose
            curryr displayln output
            exn-message
      if {(list? sexp) and {(car sexp) eq? 'module}}
        let ([new-sexp `(begin ,sexp (require (quote ,(cadr sexp))))])
          eval new-sexp
        println (eval sexp)

define (main)
  let-values ([(input output) (tcp-accept server)])
    let* ([value (read input)])
      begin
        eval-with-output value (make-base-namespace) output
        close-output-port output
        close-input-port input
        (main)

read-accept-lang   #t
read-accept-reader #t

(main)
