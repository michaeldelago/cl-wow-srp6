(defsystem "cl-wow-srp6"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on (:ironclad)
  :components ((:module "src"
                :components
                ((:file "main")
                  (:file "srp"))))
  :description ""
  :in-order-to ((test-op (test-op "cl-wow-srp6/tests"))))

(defsystem "cl-wow-srp6/tests"
  :author ""
  :license ""
  :depends-on ("cl-wow-srp6"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main")
                  (:file "srp"))))
  :description "Test system for cl-wow-srp6"
  :perform (test-op (op c) (symbol-call :rove :run c)))
