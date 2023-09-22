(defpackage cl-wow-srp6/tests/main
  (:use :cl
        :cl-wow-srp6
        :rove))
(in-package :cl-wow-srp6/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-wow-srp6)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
