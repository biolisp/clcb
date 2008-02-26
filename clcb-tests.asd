;;;; Copyright (c) 2007 Albert Krewinkel
;;;;
;;;; Permission is hereby granted, free of charge, to any person
;;;; obtaining a copy of this software and associated documentation
;;;; files (the "Software"), to deal in the Software without
;;;; restriction, including without limitation the rights to use,
;;;; copy, modify, merge, publish, distribute, sublicense, and/or sell
;;;; copies of the Software, and to permit persons to whom the
;;;; Software is furnished to do so, subject to the following
;;;; conditions:
;;;;
;;;; The above copyright notice and this permission notice shall be
;;;; included in all copies or substantial portions of the Software.
;;;;
;;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;;;; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
;;;; OTHER DEALINGS IN THE SOFTWARE.

(defpackage #:cffi-tests-system
  (:use #:cl #:asdf))

(in-package #:cffi-tests-system)

(defvar *tests-dir* (append (pathname-directory *load-truename*) '("tests")))

(defsystem clcb-tests
  :description "LIFT unit tests for CLCB."
  :depends-on ("clcb"
               "lift")
  :components
  ((:module "tests"
    :serial t
    :components
    ((:file "clcb-tests-package")
     (:file "clcb-tests")
     (:file "utils-test")
     (:file "bio-sequence-tests")
     (:file "fasta-io-tests")))))

(defmethod perform ((o test-op) (c (eql (find-system :clcb-tests))))
  (funcall (intern (symbol-name '#:run-clcb-tests) 
                   '#:clcb-tests)))

