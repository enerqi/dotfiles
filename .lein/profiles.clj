{:user {:plugins [[lein-cljsbuild "0.3.2"]
                  [lein-ritz "0.6.0"]]
        :dependencies [[org.clojure/test.generative "0.1.4"]
                       [ritz/ritz-nrepl-middleware "0.6.0"]
                       [ritz/ritz-debugger "0.6.0"]
                       [ritz/ritz-repl-utils "0.6.0"]
                       [clojure-complete "0.2.2"] ; docs for nrepl/ritz don't mention it but seems necessary right now
                       ]
        :repl-options {:nrepl-middleware
                       [ritz.nrepl.middleware.javadoc/wrap-javadoc
                        ritz.nrepl.middleware.simple-complete/wrap-simple-complete]}
        ;:hooks [ritz.add-sources]  ; docs says to add this but then get cannot resolve  ritz.add-sources
        :dev-dependencies [[midje "1.4.0"]]}}


;; :dependencies [[org.clojure/clojure "1.3.0"]
;;                  [org.clojure/core.match "0.2.0-alpha9"]
;;                  [org.clojure/data.json "0.1.1"]
;;                  [org.clojure/test.generative "0.1.4"]
;;                  [org.clojure/tools.cli "0.1.0"]
;;                  [clj-time "0.3.1"] ; joda time
;;                  [criterium "0.2.0"]
;;                  [fs "0.9.0"]
;;                  [trammel "0.8.0-SNAPSHOT"]
;;                  [incanter "1.3.0"]] 
;;   :dev-dependencies [[midje "1.3.0"]
;;                      [lein-midje "1.0.3"]
;;                      [swank-clojure "1.3.3"]]
