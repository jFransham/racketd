#! /usr/bin/env racket
#lang sweet-exp racket

require json

define port 65511

define server
  tcp-listen port 4 #f "127.0.0.1"

define (println-if-non-void val)
  unless (void? val)
    println val

define (eval-with-io sexp ns args input output)
  parameterize
    group
      current-namespace ns
      current-command-line-arguments args
      current-input-port input
      current-output-port output
    with-handlers
      group
        exn? (compose displayln exn-message)
      cond
        {(list? sexp) and {(car sexp) eq? 'module}}
          eval `(begin ,sexp (require ',(cadr sexp)))
        compiled-expression? sexp
          eval sexp
          eval `(require ',(module-compiled-name sexp))
        else
          println-if-non-void (eval sexp)

define (handle input output)
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

define (main)
  let-values ([(input output) (tcp-accept server)])
    thread
      λ ()
        handle input output
        close-output-port output
        close-input-port input
    (main)

read-accept-lang   #t
read-accept-reader #t
read-accept-compiled #t

(main)
