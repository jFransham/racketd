#! /usr/bin/env racket
#lang sweet-exp racket

require json

define port 65511

define server
  tcp-listen port 4 #f "127.0.0.1"

define (eval-with-io sexp ns args input output)
  parameterize
    group
      current-namespace ns
      current-command-line-arguments args
      current-input-port input
      current-output-port output
    with-handlers
      group
        exn?
          compose
            displayln
            exn-message
      if {(list? sexp) and {(car sexp) eq? 'module}}
        let ([new-sexp `(begin ,sexp (require (quote ,(cadr sexp))))])
          eval new-sexp
        println (eval sexp)

define (main)
  let-values ([(input output) (tcp-accept server)])
    with-handlers
      group
        exn?
          compose
            curryr displayln output
            exn-message
      define data
        let ([json (read-json input)])
          begin
            close-input-port input
            json
      define-values (args stdin value)
        match data
          (hash-table
            ('file (? string? input-file-name))
            ('stdin (? string? stdin-file-name))
            ('args (? (listof string?) args-list)))
            begin
              values
                list->vector args-list
                open-input-file stdin-file-name
                read
                  open-input-file input-file-name #:mode 'text
          _
            error "Invalid json"
      eval-with-io value
        (make-base-namespace)
        args
        stdin
        output
      close-output-port output
      close-input-port stdin
      (main)

read-accept-lang   #t
read-accept-reader #t

(main)
