(defpackage cl-wow-srp6.srp
  (:use :cl)
  (:export #:srp-state-username
           #:srp-state-verifier
           #:srp-state-salt
           #:generate-srp))

(in-package :cl-wow-srp6.srp)

;; these are constant for wow's implementation of srp6

(defparameter k-value 3)

(defparameter generator 7)

(defparameter large-safe-prime
  (ironclad:octets-to-integer
    (ironclad:hex-string-to-byte-array
      "894b645e89e1535bbdad5b8b290650530801b18ebfbf5e8fab3c82872a3e9bb7")
    :big-endian t))

(deftype byte-array (&optional size) `(simple-array (unsigned-byte 8) (,size)))

(defstruct srp-state
  (username nil :type string)
  (verifier nil :type (byte-array 32))
  (salt nil :type (byte-array 32)))

(declaim (ftype (function ((or null byte-array)) byte-array) get-salt))

(defun get-salt (salt)
  (if salt
      salt
      (ironclad:make-random-salt 32)))

(declaim (ftype (function (string string byte-array) byte-array) calculate-x))

(defun calculate-x (username password salt)
  (let* ((user-pass
          (string-upcase (concatenate 'string username ":" password)))
         (user-pass-bytes (ironclad:ascii-string-to-byte-array user-pass))
         (interim (ironclad:digest-sequence :sha1 user-pass-bytes)))
    (reverse
      (ironclad:digest-sequence :sha1 (concatenate 'byte-array salt interim)))))

(declaim
 (ftype (function (string string (byte-array 32)) byte-array)
        calculate-password-verifier))

(defun calculate-password-verifier (username password salt)
  (let ((x (calculate-x username password salt)))
    (pad-byte-array-32
      (reverse
        (ironclad:integer-to-octets
          (ironclad:expt-mod generator (ironclad:octets-to-integer x)
                             large-safe-prime))))))

(defun pad-byte-array (bytes len)
  (when (eq (length bytes) len)
    bytes)
  (let ((out
         (make-array (list len)
                     :element-type `(byte-array ,len)
                     :adjustable nil
                     :initial-element 0)))
    (progn
     (loop for x across bytes
           for i from 0
           while (array-in-bounds-p out i)
           do (setf (aref out (- len i 1)) (aref bytes i)))
     out)))

(defun pad-byte-array-32 (bytes) (pad-byte-array bytes 32))

(declaim
 (ftype (function (string string &optional (or null byte-array)) srp-state)
        generate-srp))

(defun generate-srp (username password &optional (salt nil))
  (let* ((enforced-salt (get-salt salt))
         (verifier
          (calculate-password-verifier username password enforced-salt)))
    (make-srp-state :username username :verifier verifier :salt enforced-salt)))