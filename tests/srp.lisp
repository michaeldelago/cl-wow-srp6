(defpackage cl-wow-srp6/tests/srp
  (:use :cl
        :cl-wow-srp6.srp
        :rove))
(in-package :cl-wow-srp6/tests/srp)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-wow-srp6)' in your Lisp.

(defparameter calculate-x-salt-username "USERNAME123")
(defparameter calculate-x-salt-password "PASSWORD123")
(defparameter calculate-x-salt (nreverse (ironclad:hex-string-to-byte-array "CAC94AF32D817BA64B13F18FDEDEF92AD4ED7EF7AB0E19E9F2AE13C828AEAF57")))

(defun read-csv-to-string (filename)
  (mapcar (lambda (line) (uiop:split-string line :separator ","))
          (subseq (uiop:read-file-lines filename) 0 150)))

(defun helper-test-verifier (line)
  (destructuring-bind (user pass salt verifier)
      line
    (let ((computed (cl-wow-srp6.srp::calculate-password-verifier user pass (nreverse (ironclad:hex-string-to-byte-array salt))))
          (verifier (ironclad:hex-string-to-byte-array verifier)))
      (unless (equalp computed verifier)
        (format t "~a~%~a~%" computed verifier))
      (equalp computed verifier))))

(defun helper-test-x-salt (line)
  (destructuring-bind (salt x-value)
      line
    (let ((computed (cl-wow-srp6.srp::calculate-x calculate-x-salt-username calculate-x-salt-password (nreverse (ironclad:hex-string-to-byte-array salt)))))
      (equalp computed (ironclad:hex-string-to-byte-array x-value)))))

(defun helper-test-x (line)
  (destructuring-bind (user pass x-value)
      line
    (let ((computed (cl-wow-srp6.srp::calculate-x user pass calculate-x-salt)))
      (equalp computed (ironclad:hex-string-to-byte-array x-value)))))

(deftest calculate-v 
  (testing "Test verifier generation"
    (ok (every #'identity (mapcar #'helper-test-verifier (read-csv-to-string "./tests/calculate-v-values.csv"))))))

(deftest calculate-x
  (testing "Test x generation with different salts"
    (ok (every #'identity (mapcar #'helper-test-x (read-csv-to-string "./tests/calculate-x-values.csv"))))))

(deftest calculate-x-salt 
  (testing "Test x generation with different users"
    (ok (every #'identity (mapcar #'helper-test-x-salt (read-csv-to-string "./tests/calculate-x-salt-values.csv"))))))
