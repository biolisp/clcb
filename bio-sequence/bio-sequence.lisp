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

(in-package #:clcb)

(defclass bio-sequence (molecule integer-interval)
  ((id :accessor bio-sequence-id
       :initarg :id
       :initform ""
       :documentation "The primary ID of the sequence (genbank etc.)")
   (name :accessor bio-sequence-name
         :initarg :name
         :initform "Unknown"
         :documentation "The sequence's name.")
   (seq :accessor bio-sequence-seq
        :initarg :seq
        :initform nil
        :documentation "The actual sequence information. This can be
of any type, but will normally be of type `string'.")
   (description :accessor bio-sequence-description
                :initarg :description
                :documentation "The descripitions of the object.")
   (lower-bound :accessor seq-start
                :initarg :seq-start
                :initform 1)
   (upper-bound :accessor seq-end
                :initarg :seq-end)))


(defmethod initialize-instance :after ((seq bio-sequence) &rest args)
  (declare (ignore args))
  (unless (slot-boundp seq 'upper-bound)
    (setf (upper-bound seq) (length (bio-sequence-seq seq)))))


(defclass nucleotide-sequence (bio-sequence)
  ((circular :accessor circular-p
             :initarg :circular
             :initform nil
             :documentation "This is true iff the sequence is circular
                             (O RLY?)")
   (alphabet :accessor alphabet
             :initarg :alphabet
             :initform nil
             :documentation "The sequence type. It's typically
             one of DNA or RNA, but it can specify other types as
             well.")
   (strand :accessor strand
           :initarg :strand
           :initform 0
           :type (integer -1 1))))

(defclass amino-acid-sequence (bio-sequence) ())

(defun copy-bio-sequence (seq)
  "Return a fresh copy of the bio-sequence object."
  ;; Copying all slot by themself is probably pretty stupid, but I
  ;; can't think of a better solution right now (Well, Gary King's MOP
  ;; based copy function would do => will implement)
  (make-instance 'bio-sequence
                 :id (bio-sequence-id seq)
                 :name (bio-sequence-name seq)
                 :seq (bio-sequence-seq seq)
                 :mol-weight (mol-weight seq)))

(defmethod make-interval ((bio-seq bio-sequence) lower upper &rest args)
  (declare (ignore args))
  (let ((new-seq (moptilities:copy-template bio-seq)))
    (setf (bio-sequence-seq new-seq) (subseq (bio-sequence-seq new-seq)
                                             (1- lower)
                                             upper)
          (lower-bound new-seq) lower
          (upper-bound new-seq) upper)
    new-seq))


(defmethod print-object ((seq bio-sequence) stream)
  (print-unreadable-object (seq stream :type t)
    (with-slots (id name seq) seq
      (format stream ":id ~A :name ~S :seq ~A~:[...~]"
              id
              name
              (subseq seq 0 (min 15 (length seq)))
              (<= (length seq) 15)))))


(defgeneric bio-sequence-length (seq)
  (:documentation "Return the number of monomers in this sequence.")
  (:method ((seq bio-sequence)) (length (bio-sequence-seq seq))))


(defclass feature ()
  ((feature-type :accessor feature-type
                 :initarg :feature-type)))

(defgeneric shuffle-sequence (seq)
  (:documentation "Return a randomly shuffled copy of the sequence." )
  (:method ((seq bio-sequence)) 
    (let ((shuffled (copy-bio-sequence seq)))
      (setf (bio-sequence-seq shuffled)
            (nshuffle-vector (bio-sequence-seq shuffled)))
      shuffled)))


(defun orthogonal-coded (char)
  (declare (type character char))
  (flet ((char-eq (c)
           (char-equal char c)))
    (the (simple-array single-float (*))
      (make-array 4 :initial-contents
                  (cond ((char-eq #\a) #(1f0 0f0 0f0 0f0))
                        ((char-eq #\c) #(0f0 1f0 0f0 0f0))
                        ((char-eq #\g) #(0f0 0f0 1f0 0f0))
                        ((char-eq #\t) #(0f0 0f0 0f0 1f0))
                        (t (error "Unknown nucleotide character.")))
                  :element-type 'single-float))))

(defgeneric orthogonal-coded-seq (seq)
  (:documentation "Take an nucleotide sequence and generate an
  orthogonal coded copy of the sequence."))

(defmethod orthogonal-coded-seq ((seq string))
  (loop
     with orth-seq = (make-array (* (length seq) 4) :element-type 'single-float)
     for cur-pos fixnum from 0 below (length orth-seq) by 4
     for char character across seq do
     (setf (subseq orth-seq cur-pos (+ cur-pos 4))
           (orthogonal-coded char))
     finally (return orth-seq)))

(defun score-word (word scoring-word)
  (reduce #'+ (map 'vector #'* word scoring-word)))


